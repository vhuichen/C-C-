---
title: 《Effective Objective-C 2.0》第七章阅读笔记(2)  
date: 2018-05-29  
tags: [Effective Objective-C 2.0]  
category: "iOS开发"  

---

# <center>第七章：系统框架(2)</center>

## 第50条：构建缓存时选用 NSCache 而非 NSDictionary

#### 优点
1、当系统资源耗尽时，NSCache 可以自动删减缓存，而且还会优先删除最久没有使用的缓存。  
2、NSCache 并不会“拷贝”键，而是“保留”它。不拷贝键的原因是：很多时候，键都是由不支持拷贝操作的对象充当的。  
3、NSCache 是线程安全的。  
4、可以操控缓存删减其内容的时机，有两个与系统资源相关的尺度可供调整，其一是缓存中的对象总数，其二是所有对象的“总开销”（overroll cost）。  

下面代码演示缓存的用法：

~~~ objc
#import <Foundation/Foundation.h>

// Network fetcher class
typedef void(^EOCNetworkFercherCompletionHandler)(NSData *data);

@interface EOCNetworkFetcher : NSObject

- (id)initWithURL:(NSURL *)url;  
- (void)startWithCompletionHandler:(EOCNetworkFercherCompletionHandler)handler;  

@end
  
@implementation EOCClass {  
    NSCache *_cache;  
}
  
- (id)init {
    self = [super init];  
    if (self) {  
        _cache = [NSCache new];
        // 最多缓存 100 条数据
        _cache.countLimit = 100;
        // 最大缓存空间 5MB
        _cache.totalCostLimit = 5 * 1024 * 1024;
    };
    return self;  
}
  
- (void)downloadDataForURL:(NSURL *)url {  
    NSData *cachedData = [_cache objectForKey:url];  
    if (cachedData) {  
        // Cache hit
        [self useData:cachedData];  
    } else {
        // Cache miss
        EOCNetworkFetcher *fetcher = [[EOCNetworkFetcher alloc] initWithURL:url];  
        [fetcher startWithCompletionHandler:^(NSData *data) {  
            [_cache setObject:data forKey:url cost:data.length];  
            [self useData:cachedData];
        }];  
    }  
}  
@end  
~~~

#### NSPurgeableData
NSPurgeableData 和 NSCache 搭配起来用，效果很好。此类是 NSMutableData 的子类，而且实现了 NSDiscardableContent 协议。如果某个对象所占有的内存能够根据需要随时丢弃，那么就可以实现该协议所定义的接口。当系统资源紧张时可以把保存 NSPurgeableData 对象的那块内存释放掉。NSDiscardableContent 协议定义了名为 isContentDiscarded 的方法，用来查询相关内存是否已释放。  
如果需要访问某个 NSPurgeableData 对象，可以调用 beginContentAccess 方法，告诉它现在还不应该丢弃自己所占据的内存。用完之后，调用 endContentAccess 方法，告诉它在必要时可以丢弃自己所占据的内存了。

~~~ objc
- (void)downloadDataForURLTwo:(NSURL *)url {
	NSPurgeableData *cachedData = [_cache objectForKey:url];
	if (cachedData) {
		[cachedData beginContentAccess];
		[self useData:cacheData];
		[cachedData endContentAccess];
	} else {
		EOCNetworkFetcher *fetcher = [[EOCNetworkFetcher alloc] initWithURL:url];
		[fetcher startWithCompletionHandler:^(NSData *data) {
			NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
			[_cache setObject:purgeableData forKey:url cost:purgeableData.length];
			[self useData:purgeableData];
			[purgeableData endContentAccess];
		}];
	}
}
~~~
创建好 NSPurgeableData 后，其 “purge 引用计数”会多1，所以无需再调用 beginContentAccess 了，但使用完后必须调用 endContentAccess 方法，将多出来的 “1” 抵消掉。

### 总结
合理的使用 NSCache 可以提高程序的响应速度。

## 第51条：精简 initialize 和 load 的实现代码
有时候，类必须先执行某些初始化操作才能正常使用。在 Objective-C 中，绝大多数的类都继承自 NSObject 这个根类，该类有两个方法，可用来实现这种初始化操作。

### load
对于加入运行期系统中的每个类（class）及分类（category）来说，必定会调用此方法，而且仅调用一次。如果分类和其所属的类都定义了 load 方法，则先调用类里的，再调用分类的。  

执行 load 方法时，运行期系统处于“脆弱状态”（fragile state）。在执行子类的 load 方法之前，必定会先执行所有父类的 load 方法，而如果代码还依赖其他程序，那么程序库里相关类的 load 方法也必定会先执行。然而，根据某个给定的程序库，却无法判断出其中各个类的载入顺序。因此，在 load 方法中使用其他类是不安全的。  

load 方法不像普通方法那样，它不遵从那套继承规则。如果某个类本身没实现 load 方法，那么不管其各级父类是否实现此方法，系统都不会调用。此外，分类的其所属的类里，都可能出现 load 方法。此时两种实现代码都会调用，类的实现要比分类的实现先执行。

load 方法务必实现得精简一些，也就是要尽量减少其所执行操作，因为整个程序在执行 load 方法的时候都会阻塞。如果 load 方法中包含繁杂的代码，那么应用程序在执行期行就会变得无响应。也不要写等待锁，也不要调用可能会加锁的方法。

### initialize
只有在第一次给该类发送消息之前会调用 initialize 方法。

与 load 方法不同，运行系统在执行 initialize 方法时，是处于正常状态的。因此，从运行期系统完整角度上来讲，此时也可以安全使用并调用任意类中的任意方法。而且，运行期系统也能确保 initialize 方法在“线程安全的环境”中执行。这就是说，只有执行 initialize 的那个线程可以操作类或类实例。其他线程都要先阻塞，等着 initialize 执行完。

跟其他方法一样，如果某个类未实现 initialize 方法，而父类实现了，那么就会运行父类的代码。initialize 遵循通常的继承规则。所以应该在 initialize 方法中判断是否是当前类，代码如下：  

~~~ objc
+ (void)initialize {
	if(self == [EOCBaseClass class]) {
		// doSomething
	}
}
~~~

最后，initialize 和 load 一样，都应该实现的精简一些。可以用来初始化一些全局变量，

### 参考
之前写的文章 [iOS开发之理解load和initialize](https://vhuichen.github.io/2018/04/10/180410-iOS%E5%BC%80%E5%8F%91%E4%B9%8B%E7%90%86%E8%A7%A3load%E5%92%8Cinitialize/)

## 第52条：别忘了 NSTimer 会保留其目标对象
计时器要和“运行循环”（runloop）相关联，运行循环到时候会触发任务。创建 NSTimer 时，可以将其“预先安排”在当前的运行循环中，也可以先创建好，然后由开发者来调度。无论采用哪种方式，只有把计时器放在运行循环里，它才能正常触发任务。

使用 NSTimer 很容易会造成引用循环。看看下面的例子  

~~~ objc
#import <Foundation/Foundation.h>

@interface EOCClass : NSObject
- (void)startPolling;
- (void)stopPolling;
@end

// -- 

#import "EOCClass.h" 

@implementation EOCClass { 
	NSTimer *_pollTimer; 
} 

- (id)init { 
	return [super init]; 
} 

- (void)dealloc { 
	[_pollTimer invalidate]; 
} 

- (void)stopPolling { 
	[_pollTimer invalidate]; 
	_pollTimer = nil;
} 

- (void)startPolling { 
	_pollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(p_doPoll) userInfo:nil repeats:YES]; 
} 

- (void)p_doPoll { 
	// Poll the resource 
} 
@end
~~~
上面代码中 self 强引用了 _pollTimer ，而 _pollTimer 也强引用了 self 。所以就造成了引用循环。除非手动调用 stopPolling 这个方法，否则就会出现内存泄漏。但我们无法保证开发者一定会调用这个方法。

解决方法：

~~~ objc
#import <Foundation/Foundation.h> 
@interface NSTimer (EOCBlocksSupport) 

+ (NSTimer *)eoc_timerScheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeats:(BOOL)repeats;

@end

// --

#import "NSTimer+EOCBlocksSupport.h" 

@implementation NSTimer (EOCBlocksSupport) 

+ (NSTimer *)eoc_timerScheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeats:(BOOL)repeats { 
	return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(eoc_blockInvoke:) userInfo:[block copy] repeats:repeats]; 
}

+ (void)eoc_blockInvoke:(NSTimer *)timer { 
	void (^block) () = timer.userInfo; 
	block ? block() : nil;
}

- (void)startPolling {
	__weak EOCClass *weakSelf = self; 
	_pollTimer = [NSTimer eoc_timerScheduledTimerWithTimeInterval:5.0 block:^{ 
		EOCClass *strongSelf = weakSelf; 
		[strongSelf p_doPoll]; 
	} repeats:YES]; 
}

- (void)p_doPoll { 
	// Poll the resource 
} 

@end
~~~
使用这种方法捕获到 weakSelf ，这样 self 就可以正常释放了，self 释放后， weakSelf 也就变为 nil 。从而打破了引用循环。

### 补充
在项目中我使用另一种方法也可以用来解决这个问题，代码如下：  

~~~ objc
#import <Foundation/Foundation.h>

typedef void (^VCHTimerHandler)(id userInfo);

@interface VCHWeakTimer : NSObject

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(VCHTimerHandler)block
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;

@end

~~~

~~~ objc
#import "VCHWeakTimer.h"

@interface VCHWeakTimer()

@property(nonatomic,weak) id target;
@property(nonatomic,assign) SEL selector;

@end

@implementation VCHWeakTimer

- (void)fire:(id)obj {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.target performSelector:self.selector withObject:obj];
#pragma clang diagnostic pop
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats {
    VCHWeakTimer *weakTimer = [[VCHWeakTimer alloc] init];
    weakTimer.target = aTarget;
    weakTimer.selector = aSelector;
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:weakTimer
                                          selector:@selector(fire:)
                                          userInfo:userInfo
                                           repeats:repeats];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(VCHTimerHandler)block
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats {
    NSMutableArray *userInfoArray = [NSMutableArray arrayWithObject:[block copy]];
    if (userInfo != nil) {
        [userInfoArray addObject:userInfo];
    }
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(_timerBlockInvoke:)
                                       userInfo:userInfoArray
                                        repeats:repeats];
}

- (void)_timerBlockInvoke:(NSArray *)userInfo {
    VCHTimerHandler block = userInfo[0];
    id info = nil;
    if (userInfo.count == 2) {
        info = userInfo[1];
    }
    block ? block(info) : nil;
}

@end
~~~

## 总结
直接使用 NSTimer 可能会发生内存泄漏，一定要想办法处理掉这个问题。

# <center><font color = red>全书 · 完</font></center>