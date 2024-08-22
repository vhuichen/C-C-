---
title: 《Effective Objective-C 2.0》第六章阅读笔记(2)  
date: 2018-05-23  
tags: [Effective Objective-C 2.0]  
category: "iOS开发"  

---

# <center>第六章：块与大中枢派发(2)</center>

## 第41条：多用派发队列，少用同步锁
如果有多个线程要执行同一份代码，那么有时可能会出问题。这种情况下，通常要使用锁来实现同步机制。在GCD出现之前，一般有两种方式可以实现同步  

### 原始方法：synchronized & NSLock

~~~ objc
- (void)synchronizedMethod {
    @synchronized (self) {
        // Safe
    }
}
~~~

~~~ objc
_lock = [[NSLock alloc] init];
- (void)synchronizedMethod {
    [_lock lock];
    // Safe
    [_lock unlock];
}
~~~
滥用 @synchronized(self) 会很危险，因为所有同步块都会彼此抢夺同一个锁。要是有很多个属性都这么写的话，那么每个属性的同步块都要等其他所有同步块执行完毕才能执行。两种方法的使用效率都不高，并且处理不当会造成死锁。

### 改进方法：串行同步队列

~~~ objc
_syncQueue = dispatch_queue_create("com.vhuichen.syncQueue", NULL);

- (NSString *)someString { 
	__block NSString *localSomeString; 
	dispatch_sync(_syncQueue, ^{ 
		localSomeString = _someString; 
	});
	return localSomeString;
}

- (void)setSomeString:(NSString *)someString { 
	dispatch_sync(_syncQueue, ^{ 
		_someString = someString; 
	});
}
~~~
这里有一种方案就是可以把 setter 方法改成异步执行，提升程序的执行速度。

~~~ objc
- (void)setSomeString:(NSString *)someString { 
	dispatch_async(_syncQueue, ^{ 
		_someString = someString; 
	});
}
~~~
这里需要考虑的是：执行异步派发时，需要拷贝块。若拷贝块所需的时间明显超过执行块所花的时间，那么这种做法将比原来的更慢。只有当拷贝块所花的时间远低于执行块所花的时间时，可以考虑这种异步方法。

### 最优方案：dispatch_barrier
事实上，获取值时可以多个同时进行，设置值和获取值不能同时进行。利用这个特点，我们可以对代码再次优化。

~~~ objc
_syncQueue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL); 

- (NSString *)someString {
	__block NSString *localSomeString;
	dispatch_sync(_syncQueue, ^{
		localSomeString = _someString;
	});
	return localSomeString;
}

- (void)setSomeString:(NSString *)someString {
	// 这是使用 async 还是 sync 取决于 block 的业务逻辑复杂度，上面有解释
	dispatch_barrier_async(_syncQueue, ^{
		_someString = someString;
	});
}
~~~
上面的代码，我们创建的是一个并行队列。读取操作可以并行，但写入操作是单独执行的，因为给它加了栅栏，代码的执行逻辑如下图  
![](http://ovsbvt5li.bkt.clouddn.com/18-5-24/62516339.jpg)  

### 总结
使用GCD实现同步方式，比使用 synchronized 或 NSLock 更高效。

## 第42条：多用 GCD，少用 performSelector 系列方法
performSelector 有几个缺点。

#### 可能会引起内存泄漏
看下面一段代码

~~~ objc
SEL selector;
if (/* ... */) {
	selector = @selector(newObject);
} else if (/* ... */) {
	selector = @selector(copy); 
} else {
	selector = @selector(someProperty);
}
id ret = [object performSelector:selector];
~~~
编译器会发出如下警示信息  

~~~ objc
warning:PerformSelector may cause a leak because its selector is unknown
~~~
原因在于，编译器并不知道将要调用的选择子的方法签名及返回值。由于编译器不知道方法名，所以就没办法运用 ARC 的内存管理规则来判定返回值是不是应该释放。鉴于此，ARC采用了比较谨慎的做法，就是不添加释放操作。然而这么做可能导致内存泄漏，因为方法在返回对象时可能已经将其保留了。

#### 返回值只能是 void 或对象类型
如果想返回整数或浮点数等类型的值，那么就需要执行一些复杂的转换操作。如果返回的是结构体，则不能使用 performSelector 。

#### 传入参数有限制
传入参数必须为对象类型，最多只有两个限制。

### 改进（GCD）

~~~ objc
[self performSelectorOnMainThread:@selector(aSelector) withObject:nil waitUntilDone:NO];
~~~
上面的功能可以通过 GCD 来实现 

~~~ objc
dispatch_async(dispatch_get_main_queue(), ^{
	[self aSelector];
});
~~~
其它 performSelector 的方法也一样可以用 GCD 的方法代替。

## 第43条：掌握 GCD 及 NSOperationQueue 的使用时机

### 使用 NSOperationQueue 优点
#### 取消某个操作
使用 NSOperationQueue ，想要取消操作队列是很容易的。运行任务之前，可以在 NSOperation 对象上调用 cancel 方法，该方法会设置对象内的标志位，用以表明此任务不需执行，不过，已经启动的任务无法取消。GCD 则无法直接取消。

#### 指定操作间的依赖关系
一个操作可以依赖其他多个操作。开发者能够制定操作之间的依赖体系，使特定的操作必须在另外一个操作顺利执行完毕后方可执行。

#### 通过键值观测机制监控 NSOperation 对象的属性
NSOperation 对象有许多属性都适合通过键值观测机制（KVO）来监听。比如可以通过 isCancelled 属性来判断任务是否已取消，又比如可以通过 isFinished 属性来判断任务是否已完成。

#### 指定操作的优先级
操作的优先级表示此操作与队列中其他操作之间的优先级关系。优先级高的操作先执行，优先级低的后执行。

#### 重用 NSOperation 对象
系统内置了一些 NSOperation 的子类（比如 NSBlockOperation）以供开发者调用，要是不想用这些子类，可以自己创建。这些类就是普通的 Objective-C 对象，能够存放任何信息。对象在执行时可以充分利用存于其中的信息，而且还可以随意调用定义在类中的方法。NSOperation 类符合软件开发中的“不重复”（Don’t Repeat Yourself，DRY）原则。

### 总结
GCD 操作简单，NSOperation 则功能更多。熟练掌握两种方式，在各种各样的场景中运用自如。
