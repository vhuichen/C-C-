---
title: 《Effective Objective-C 2.0》第五章阅读笔记(1)  
date: 2018-05-08  
tags: [Effective Objective-C 2.0]  
category: "iOS开发"  

---

# <center>第五章：内存管理(1)</center>
ARC 几乎把所有内存管理事宜都交由编译器来决定，开发者只需专注于业务逻辑。  

## 第29条：理解引用计数
Objective-C 语言使用引用计数来管理内存，每个对象都有个可以递增或递减的计数器。如果想使某个对象继续存活，那就递增其引用计数；用完了之后，就递减其计数。计数变为0，就表示没人关注此对象了，于是，就可以把它销毁。
### 引用计数的工作原理
在引用计数架构下，对象有个计数器，用以表示当前有多少个事物想令此对象继续存活下去。这在 Objective-C 中叫做“引用计数”（reference count）。NSObject协议声明了下面三个方法用于操作计数器，以递增或递减其值：  
retain：递增保留计数。  
release：递减保留计数。  
autorelease：待稍后清理“自动释放池”（autorelease pool）时，再递减保留计数。  

~~~ objc
@protocol NSObject

- (instancetype)retain OBJC_ARC_UNAVAILABLE;
- (oneway void)release OBJC_ARC_UNAVAILABLE;
- (instancetype)autorelease OBJC_ARC_UNAVAILABLE;

@end
~~~
对象创建出来时，其引用计数至少为1。若想令其继续存活，则调用 retain 方法。要是某部分代码不再使用此对象，不想令其继续存活，那就调用 release 或 autorelease 方法。最终当引用计数归零时，对象就回收了（deallocated），也就是说，系统会将其占用的内存标记为“可重用”（reuse）。此时，所有指向该对象的引用也都变得无效了。
#### 调用 release 之后，就已经无法保证所指的对象仍然存活
例如：  

~~~ objc
NSNumber *number = [[NSNumber alloc] initWithInt:1234];
[array addObject:number];
[number release];
NSLog(@"number = %@",number);
~~~
调用 release 之后，其引用计数降至0，那么 number 对象所占内存也许会回收，那么再调用NSLog可能会使应用程序崩溃。这里说“可能”，是因为对象所占的内存在“解除分配”（deallocated）之后，只是放回“可用内存池”（avaliable pool）。如果执行 NSLog 时尚未覆写对象内存，那么该对象仍然有效，这时程序不会崩溃。

### 属性存取方法中的内存管理
~~~ objc
- (void)setFoo:(id)foo {
    [foo retain];
    [_foo release];
    _foo = foo;
}
~~~
这里需要注意的是必须先 retain 对象，然后再 release 。原因就是新对象和旧对象可能是同一个对象，这时如果先 release 这个对象，可能会导致系统永久回收对象。之后再 retain 也无法再复生。

### 自动释放池
调用 release 会立刻递减对象的保留计数，而且还有可能令系统回收此对象，然而有时候可以不调用它，改为调用 autorelease ，此方法会在稍后递减计数，通常是在下一次“事件循环”（event loop）时递减，不过也可能执行得更早些（why ？？后面会提到）。  
这个特性很有用，例如：  

~~~ objc
- (NSString *)stringValue {
    NSString *str = [[NSString alloc] initWithFormat:@"I am this: %@",self];
    return str;
}
~~~
在 MRC 环境下，此时 str 对象的引用计数会比期望值多1 ，因为 alloc 会使引用计数加1，但却没有释放。这时就应该用 autorelease 。此方法可以保证对象在跨越“方法调用边界”（method call boundary）后一定存活。实际上，释放操作会在清空最外层的自动释放池时执行，除非你有自己的自动释放池，否则这个时机指的就是当前线程的下一次事件循环。    

~~~ objc
- (NSString *)stringValue {
    NSString *str = [[NSString alloc] initWithFormat:@"I am this: %@",self];
    return [str autorelease];
}
~~~

### 引用循环
使用引用计数机制时，经常要注意的一个问题就是“引用循环”（retain cycle），也就是呈环状相互引用的多个对象（如下图）。这将导致内存泄露，因为循环中的对象其引用计数都不会为0。
![](http://ovsbvt5li.bkt.clouddn.com/18-5-8/55922608.jpg)

### 总结
引用计数机制通过可以递增递减的计数机制来管理内存。对象创建好之后，其引用计数至少为1。若引用计数为正，则对象继续存活。当引用计数降为0时，对象就被销毁了。  
在对象生命期中，其余对象通过引用来保留或释放此对象。保留与释放操作分别会递增及递减保留计数。

## 第30条：用 ARC 简化引用计数
在 MRC 环境下，下面代码会出现内存泄漏问题   

~~~ objc
if ([self showLogMsg]) {
	NSString *str = [[NSString alloc] initWithFormat:@"I am this: %@",self];
	NSLog(@"%@",str);
}
~~~
原因是 if 语句结束后，并没有释放 str 对象。所以我们必须手动去释放

~~~ objc
if ([self showLogMsg]) {
	NSString *str = [[NSString alloc] initWithFormat:@"I am this: %@",self];
	NSLog(@"%@",str);
	[str release];
}
~~~
而这个操作完全可以交给 ARC (Automatic Reference Counting)来完成，也就是在 ARC 环境下，编译器会在编译时会自动加上内存管理语句。  
由于 ARC 会自动执行retain、release、autorelease等操作，所以直接在 ARC 下调用这些内存管理方法是非法的。具体来说，不能调用下列方法：  
**retain  
release  
autorelease  
dealloc**  
实际上，ARC在调用这些方法时，并不通过普通的 Objective-C 消息派发机制，而是直接调用其底层C语言版本。这样做性能更好，因为保留及释放操作需要频繁执行，所以直接调用底层函数能节省很多CPU周期。  

### 使用 ARC 时必须遵循的方法命名规则
将内存管理语义在方法名中表示出来早已成为 Objective-C 的惯例，而 ARC 则将之确立为硬性规定。这些规则简单地体现在方法名上。若方法名以下列词语开头，则其返回的对象归调用者所有：  
**alloc  
new  
copy  
mutableCopy**  
归调用者所有的意思是：**调用上述四种方法的那段代码要负责释放方法所返回的对象。**
举个例子，演示了ARC的用法：  

~~~  objc
// 方法名以关键字 new 开头，ARC 不会加入 retain、release 或 autorelease 语句。
+ (EOCPerson *)newPerson {
	EOCPerson *person = [[EOCPerson alloc] init]; 
	return person; 
}

// 方法名不以关键字开头，ARC 会自动加上 autorelease 语句。
+ (EOCPerson *)somePerson {
	EOCPerson *person = [[EOCPerson alloc] init]; 
	return person; 
}

// ARC 会在函数末尾给 personOne 加上 release 语句。
- (void)doSomething {
	EOCPerson *personOne = [EOCPerson newPerson]; 
	EOCPerson *personTwo = [EOCPerson somePerson]; 
}
~~~
除了会自动调用“保留”与“释放”方法外，ARC 还可以执行一些手工操作很难甚至无法完成的优化。如果发现在同一个对象上执行多次“保留”与“释放”操作，那么ARC有时可以成对地移除这两个操作。  

一般，在方法中返回自动释放的对象时，要执行一个特殊函数。此时不直接调用对象的 autorelease 方法，而是改为调用 objc_autoreleaseReturnValue 。此函数会检视当前方法返回之后即将要执行的那段代码。若发现那段代码在返回的对象上执行 retain 操作，则设置全局数据结构（此数据结构的具体内容因处理器而异）中的一个标志位而不执行 autorelease 操作。与之相似，如果方法返回了一个自动释放的对象，而调用方法的代码要保留此对象，那么此时不直接执行 retain，而是改为执行objc_retainAutoreleaseReturnValue 函数。此函数要检测刚才提到的那个标志位，若已经置位，则不执行 retain 操作。设置并检测标志位，要比调用 autorelease 和 retain 更快。

### ARC 如何清理实例变量
ARC 会在 dealloc 方法中自动生成回收对象时所执行的代码。ARC 会借用 Objective-C++ 的一项特性来生成清理例程（cleanup routime）。回收 Objective-C++ 对象时，待回收的对象会调用所有C++对象的析构函数（destructor）。编译器如果发现某个对象里含有C++对象，就会生成名为.cxx_destruct的方法。而ARC则借助此特性，在该方法中生成清理内存所需的代码。  
如果有非 Objective-C 的对象，比如 CoreFoundation 中的对象或是由malloc()分配在堆中的内存，那么仍然需要手动清理。

### 总结
用ARC管理内存，可省去类中的许多的“样板代码”。  
ARC会在合适的地方插入“保留”及“释放”对象。  
CoreFoundation 对象不归 ARC 管理，开发者必须实时调用 CFRetain/CFRelease 手动释放。  