---
title: 《Effective Objective-C 2.0》第五章阅读笔记(2)  
date: 2018-05-09  
tags: [Effective Objective-C 2.0]  
category: "iOS开发"  

---

# <center>第五章：内存管理(2)</center>

## 第31条：在 dealloc 方法中只释放引用并解除监听
对象经历其生命期后，最终会为系统所回收，这时候就会执行 dealloc 方法。也就是引用计数为0时调用，且在生命期内仅调用一次，并且我们也无法控制其什么时候调用。

在这个方法里会释放所有的方法引用，也就是把 Objective-C 对象全部释放。ARC 会生成一个 .cxx_destruct 方法，在 dealloc 中为你自动添加这些释放代码。但也有一些对象是需要自己手动释放。

#### 释放 CoreFoundation 对象

CoreFoundation 对象必须手动释放，因为这个是由纯C生成的。这些对象最好在不需要时就立刻释放掉，没必要等到 dealloc 才释放。

#### 释放 KVO && NSNotificationCenter
如果有 KVO 那么最迟应该在这里将其释放。如果注册了通知也应该最迟在这里移除。不然可能会造成程序崩溃。

#### 释放由对象管理的资源

如果此对象管理者某些资源，那么也要在这里释放掉。

### 注意
不要在 dealloc 中调用属性的存取方法。  
不要在这里调用异步方法，因为对象已经处于回收状态了。
不需要用的资源应该及时释放，系统不能保证每个 dealloc 方法都会执行。

## 第32条：编写“异常安全代码”时留意内存管理问题
有时候我们需要编写异常代码来捕获并处理异常，发生异常时应该如何管理内存是个值得深究的问题。先看看在MRC环境下应该怎么处理，直接上代码

~~~ objc
@try { 
	EOCSomeClass *object = [[EOCSomeClass alloc]init]; 
	[object doSomethingThatMayThrow]; 
	[object release]; 
} @catch (NSException *exception) { 
	NSLog(@"there was an error."); 
}
~~~
事实上当 doSomethingThatMayThrow 发生异常时，就会直接跳出，不会再往下执行，所以 release 方法无法执行，也就出现内存泄漏了。  
使用 @finally 可以解决这个问题  

~~~ objc
EOCSomeClass *object = nil;
@try {
	object = [[EOCSomeClass alloc] init]; 
	[object doSomethingThatMayThrow];
} @catch (NSException *exception) {
	NSLog(@"there was an error.");
} @finally {
	[object release];
}
~~~

在 ARC 环境下，也会出现这样的问题，由于 ARC 不能调用 release 方法。上面的代码同样会出问题    

~~~ objc
@try { 
	EOCSomeClass *object = [[EOCSomeClass alloc] init];
	[object doSomethingThatMayThrow];
} @catch (NSException *exception) {
	NSLog(@"there was an error.");
} @finally {
	
}
~~~
默认情况下 如果 doSomethingThatMayThrow 出现异常了，那么 ARC 也不会自动去处理这个问题。导致 object 这个对象无法回收。虽然默认状况下不能处理这个问题，但ARC依然能生成这种安全处理异常所用的附加代码。**-fobjc-arc-exception** 这个编译器标志用来开启此功能。打开这个标志会加入大量的样例代码，会影响运行期的性能。  
处于 Objective-C++ 模式时，编译器会自动把 **-fobjc-arc-exception** 标志打开，因为C++处理异常所用的代码与ARC实现的附加代码类似，所以令ARC加入自己的代码以安全处理异常，其性能损失并不太大。

> 这里需要了解的是，Objective-C中，只有当应用程序必须因异常状况而终止时才抛出异常。因此，如果应用程序即将终止，那么是否还会发生内存泄露就已经无关紧要了。在应用程序必须立即终止的情况下，还去添加安全处理异常所用的附加代码是没有意义的。

## 总结
捕获异常时，一定要注意将try块内所创立的对象清理干净。  
在默认情况下，ARC不生成安全处理异常所需的清理代码。开启编译器标志后，可生成这种代码，不过会导致应用程序变大，而且会降低运行效率。

## 第33条：用弱引用避免循环引用
对象图里经常会出现一种情况，就是几个对象都以某种方式互相引用，从而形成”环“。由于 Objective-C 内存管理模型使用引用计数架构，所以这种情况通常会泄露内存，因为最后没有别的东西会引用环中的对象。这样的话，环里的对象就无法为外界所访问了，但对象之间尚有引用，这些引用使得他们都能继续存活下去，而不会为系统所回收。  
如下图是最简单的一种内存泄漏，两个对象相互引用，永远无法释放。  
![](http://ovsbvt5li.bkt.clouddn.com/18-5-11/81656748.jpg) 

### 弱引用
避免循环引用的最佳方式就是弱引用，即表示“非拥有关系”。有两个关键字可以用来修饰这种方式，分别是 unsafe_unretained 和 weak 。

#### unsafe_unretained
用 unsafe_unretained 修饰的属性特质，其语义同 assign 特质等价，然而 assign 通常只用于数值类型，unsafe_unretained 则多用于对象类型。这个词本身就表明其所修饰的属性可能无法安全使用。也就是 unsafe_unretained 修饰的属性所指向的对象即使已经释放，unsafe_unretained 修饰的属性的值也不会自动置nil(相对于weak)。

#### weak
weak 和 unsafe_unretained 同样用于修饰对象，唯一不同的是，当 weak 修饰的属性所指的对象被系统回收时，weak会自动置nil。

下图可以看出两者之间的区别。
![](http://ovsbvt5li.bkt.clouddn.com/18-5-11/50645693.jpg)
当对象释放时，unsafe_unretained 属性仍然指向那个已经回收的实例，而weak属性则指向nil。所以 使用 weak 比 unsafe_unretained 安全。

## 总结
如果某对象不归你所拥有，而只是需要使用这个对象，那么就应该用“弱引用”。
