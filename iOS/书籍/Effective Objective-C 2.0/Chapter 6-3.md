---
title: 《Effective Objective-C 2.0》第六章阅读笔记(3)  
date: 2018-05-24  
tags: [Effective Objective-C 2.0, GCD]  
category: "iOS开发"  

---

# <center>第六章：块与大中枢派发(3)</center>

## 第44条：通过 Dispatch Group，根据系统资源状况来执行任务
dispatch group 是 GCD 的一项特性，能够把任务分组。调用者可以等待这组任务执行完毕，也可以在提供回调函数之后继续往下执行，这组任务完成时，调用者会得到通知。通过这个功能可以把将要并发执行的多个任务合为一组，于是调用者就可以知道这些任务何时才能全部执行完毕。

#### 创建 dispatch group

~~~ objc
dispatch_group_t group = dispatch_group_create();
~~~

想把任务分组，有两种办法。

~~~ objc
void dispatch_group_async(dispatch_group_t group, dispatch_queue_t queue, dispatch_block_t block);
~~~

~~~ objc
dispatch_group_enter(dispatch_group_t group);
// task
dispatch_group_leave(dispatch_group_t group);
~~~
判断任务完成也有两种方法  
第一种方法是同步的，等到所有任务完成，才能继续往下执行。  

~~~ objc
void dispatch_group_wait(dispatch_group_t group, dispatch_time_t timeout);
~~~
第二种方法是异步的，当所有的任务执行完成，就会触发这个通知。  

~~~ objc
void dispatch_group_notify(dispatch_group_t group, dispatch_queue_t queue, dispatch_block_t block);
~~~

如果想令数组中的每个对象都执行某项任务，并且想等待所有任务执行完毕，那么就可以使用这个GCD特性来实现。同时还可以给任务加上优先级。

~~~ objc
dispatch_queue_t lowPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0); 
dispatch_queue_t highPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0); 
dispatch_group_t dispatchGroup = dispatch_group_create();

NSArray *lowPriorityObject;
NSArray *highPriorityObject;

for (id object in lowPriorityObject) { 
	dispatch_group_async(dispatchGroup, lowPriorityQueue, ^{ 
		[object task];
	}); 
}

for (id object in highPriorityObject) { 
	dispatch_group_async(dispatchGroup, highPriorityQueue, ^{ 
		[object task]; 
	}); 
}

dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{ 
	
});
~~~
> 除了像上面这样把任务提交到并发队列之外，也可以把任务提交至各个串行队列中，并用 dispatch group 跟踪其执行状况。如果所有任务都排在同一个串行队列里面，那么 dispatch group 就用处不大了。因为此时，任务总要逐个执行，所以只需在提交完全部任务之后再提交一个块即可，这样做与通过 notify 函数等待 dispatch group 执行完毕后再回调块是等效的。

#### dispatch_apply
dispatch_apply 也是并发，并且是阻塞的，所以有时候我们完全可以使用 dispatch_apply 来代替 dispatch group 来执行任务。

~~~ objc
dispatch_queue_t queue = dispatch_queue_create("com.vhuichen.queue", NULL); 
dispatch_apply(count, queue, ^(size_t i) { 
	//Perform task 
});
~~~

### 总结
当有一组任务需要执行时，可以将这一组任务加到 dispatch group 中，当所有任务执行完成后会收到一个通知。

## 第45条：使用 dispath_once 来执行只需运行一次的线程安全代码
单例模式（singleton）是我们常用的一种开发模式，常见的一种写法如下：  

~~~ objc
+ (instancetype)sharedInstance { 
	static id sharedInstance = nil; 
	@synchronized (self) { 
		if (!sharedInstance) { 
			sharedInstance = [[self alloc] init]; 
		} 
	} 
	return sharedInstance; 
}
~~~
也可以通过 GCD 的 dispath_once 来实现，dispath_once 是线程安全的。

~~~ objc
+ (instancetype)sharedInstance { 
	static id sharedInstance = nil; 
	static dispatch_once_t onceToken; 
	dispatch_once(&onceToken, ^{ 
		sharedInstance = [[self alloc] init]; 
	});
	return sharedInstance; 
}
~~~
> 使用 dispath_once 方式比 @synchronized 方式要快很多

## 第46条：不要使用 dispatch_get_current_queue
使用 GCD 时，经常需要判断当前代码正在哪个队列上执行，文档提供了这个函数：  

~~~ objc
dispatch_queue_t dispatch_get_current_queue();
~~~
iOS6.0 开始已经正式弃用此函数了。这个函数有个典型的错误用法，就是用它来检测当前队列是不是某个特定的队列，试图以此来避免执行同步派发时可能遇到的死锁问题。  
下面两个存取方法，用串行队列保证实例变量的访问是线程安全的。  

~~~ objc
- (NSString *)someString {
	__block NSString *localSomeString;
	dispatch_sync(_syncQueue, ^{
		localSomeString = _someString;
	});
	return localSomeString;
}

- (void)setSomeString:(NSString *)someString {  
	dispatch_async(_syncQueue, ^{
		_someString = someString;
	});
}
~~~
这种写法的问题在于，getter 方法可能会死锁（当 getter 方法恰好就是 _syncQueue 时）。  
可以将上面的代码稍作修改，只需先判断当前队列是否为 _syncQueue 队列，如果是就不派发，直接执行。这样做就可以另其变得“可重入”

~~~ objc
- (NSString *)someString {
	__block NSString *localSomeString;
	dispatch_block_t accessorBlock = ^{
		localSomeString = _someString;
	};
   
	if (dispatch_get_current_queue() == _syncQueue) {
		accessorBlock();
	} else {
		dispatch_sync(_syncQueue, accessorBlock);  
	}
	return localSomeString;
}
~~~
这样做好像是可以解决问题，但有些情况下还是会出现死锁问题，例如下面的例子：  

~~~ objc
dispatch_queue_t queueA = dispatch_queue_create("com.vhuichen.queueA", NULL);  
dispatch_queue_t queueB = dispatch_queue_create("com.vhuichen.queueB", NULL);  

dispatch_sync(queueA, ^{
	dispatch_sync(queueB, ^{
		dispatch_block_t block = ^{ /* ... */ };
		if (dispatch_get_current_queue() == queueA) {
			block();
		} else {
			dispatch_sync(queueA, block);
		}
	});
});
~~~
上面的代码依然会出现死锁。也就是说想通过 dispatch_get_current_queue 来避免死锁问题是不可能的。  

有的 API 可令开发者指定运行回调时所用的队列，但实际上却会把回调块安排在内部的串行同步队列上，而内部队列的目标队列又是开发者所提供的那个队列，那么就会出现死锁。使用 API 的开发者认为在回调块里调用 dispatch_get_current_queue 返回的“当前队列”，总是调用 API 时指定的那个，但实际返回的却是 API 内部的那个队列。  

要解决这个问题，最好的办法是通过 GCD 所提供的功能来设定“队列特有数据”（ queue_specific data ），此功能可以把任意数据以键值对的形式关联到队列里。假如根据指定的键值对获取不到关联数据，那么系统会沿着层级体系一直向上找，直到找到数据或者到达根队列为止。看看下面的例子：

~~~ objc
dispatch_queue_t queueA = dispatch_queue_create("com.vhuichen.queueA", NULL);
dispatch_queue_t queueB = dispatch_queue_create("com.vhuichen.queueB", NULL);

static int kQueueSpecific;
CFStringRef queueSpecificValue = CFSTR("queueA");
dispatch_queue_set_specific(queueA, &kQueueSpecific, (void *)queueSpecificValue,  (dispatch_function_t)CFRelease);

dispatch_sync(queueB, ^{
	dispatch_block_t block = ^{ NSLog(@"no deadlock"); };
	CFStringRef retrievedValue = dispatch_get_specific(&kQueueSpecific);
	if (retrievedValue) {
		block();
	} else {
		dispatch_sync(queueA, block);
	}
});
~~~
使用 “队列特有数据”（ queue_specific data ）则可以避免由不可重入引发的死锁。  

### 总结
dispatch_get_current_queue 函数无法解决由不可重入引发的死锁问题，但“队列特有数据”（ queue_specific data ）可以解决此问题。


