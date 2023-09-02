---
title: 《Effective Objective-C 2.0》第二章阅读笔记(1)  
date: 2018-04-17  
tags: [Effective Objective-C 2.0]  
category: "iOS开发"  

---

# <center>第二章：对象、消息、运行期(1)</center>
“对象”是基本构造单元，可以通过对象来存储数据和传递数据。对象之间传递数据并执行任务的过程就叫做“消息传递”。

## 第6条：理解 “属性” 这一概念
“属性” 是 Objective-C 的一项特性，用来封装对象中的数据。属性最终是通过实例变量来实现的，属性只是提供了一种简洁的抽象机制。

#### 对象布局
对象布局在编译期就已经确定了，当代码需要访问实例变量的时候，编译器会把其替换成偏移量，这个偏移量是“硬编码”，表示该变量距离对象内存起始地址有多远。  
当类增加了实例变量时，原来的偏移量就已经不再适用，所以这时候需要重新编译。偏移量保存在类对象中，会在运行时查找。

#### 应用程序二进制接口（Application Binary Interface，ABI）
> 应用程序二进制接口描述了应用程序和操作系统之间，一个应用和它的库之间，或者应用的组成部分之间的低层接口。ABI不同于应用程序接口（API），API定义了源代码和库之间的接口，因此同样的代码可以在支持这个API的任何系统中编译，然而ABI允许编译好的目标代码在使用兼容ABI的系统中无需改动就能运行。（百度百科）

ABI定义了许多内容（标准），其中一项就是生成代码时所应遵循的规范，有了这种规范，我们就可以在分类和实现文件定义实例变量，可以将实例变量从接口文件中移开，以便保护和类实现相关的内部信息。

#### @synthesize & @dynamic
~~~ objc
@implementation
@synthesize firstName = _myFirstName;
@dynamic firstName;
@end
~~~
@synthesize 用来指定实例变量的名称。  
@dynamic 告诉编译器不要自动生成实例变量，也不要生成 setter 和 getter 方法。这时编译器不会报错，而是在运行时查找。

#### 属性特质
原子性，读写权限，内存管理（assign、strong、weak、unsafe_unretained、copy），方法名

##### 原子性
iOS 开发的时候应该尽量使用 nonatomic，使用 atomic 会严重影响性能。
##### 读写权限
readwrite 同时生成setter 和 getter 方法。  
readonly 只生成 getter 方法。  
##### copy
当属性类型为 NSString 时，一定要用 copy 修饰，防止当传递过来的值是 NSMutableString 类型，从而可能会在不知情的情况下更改属性的值。

## 第7条：在对象内部尽量直接访问实例变量（感觉有歧义）
在对象外面，应该通过属性访问实例变量。在对象内部，除了几种特殊的情况下，读取实例变量应该采用直接访问的形式，设置实例变量则采用属性来设置。

#### 对象内部不要直接设置实例（有歧义）
这样做不会调用 setter 方法，也就绕过了相关属性定义的“内存管理语义”，比如使用了 copy 特质，直接访问不会拷贝该属性，只会保留新值并释放旧值。此外当设置了KVO时，直接设置实例也不会触发KVO。
#### 初始化时应该直接访问实例
如果父类初始化使用 setter 方法设置属性，而子类又重写了这个 setter 方法，那么子类初始化时，父类也会初始化，这时父类将会调用子类的 setter 方法。  
例外：如果待初始化的实例变量申明在父类中，而子类无法直接访问此实例变量，这时就需要调用 setter 方法了。
> dealloc 方法中也应该直接读写实例变量  

#### 懒加载
如果某个属性使用了懒加载，那就必须使用 getter 方法了。

## 第8条：理解 “对象同等性” 这一概念
“对象同等性” 可以理解为某种意义上两个对象相等，这个“相等”是我们自定义的。官方给我们定义了一些判断两个对象是否“相等”的方法

~~~ objc
// NSString
- (BOOL)isEqualToString:(NSString *)aString;

// NSData
- (BOOL)isEqualToData:(NSData *)other;

// NSDictionary
- (BOOL)isEqualToDictionary:(NSDictionary<KeyType, ObjectType> *)otherDictionary;
~~~

#### 对象完全相等
用 "==" 判断两个对象是否是同一个对象，这里判断的是指针。
#### 自定义 “相等”
通过 NSObject 协议中的两个方法自定义 “相等”。

~~~ objc
- (BOOL)isEqual:(id)object;  
@property (readonly) NSUInteger hash;
~~~
自定义一个 Person 类，包含一个 email 属性。

~~~ objc
@interface Person()
@property (nonatomic, copy) NSString *email;
@end
~~~

假定对象的 email 属性值相同，就认为这两个类“相同”，那么自定义方法如下：  

~~~ objc
- (BOOL)isEqualToPerson:(Person *)otherPerson {
    if (nil == otherPerson) return NO;
    if (self == otherPerson) return YES;
    
    if ([_email isEqualToString:otherPerson.email]) return YES;
    
    return NO;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) return NO;
    
    [self isEqualToPerson:object];
    
    return NO;
}

// 如果两个对象相等，则其哈希码一定相同。反之，如果哈希码相同，这两个对象不一定相同。
// 考虑到性能问题，hash 方法要保证高效率
- (NSUInteger)hash {
	// 此处逻辑可以自定义
    return [_email hash];
}

~~~

#### 典型应用
~~~ objc
// NSArray
- (BOOL)containsObject:(ObjectType)anObject;
// NSSet
- (BOOL)containsObject:(ObjectType)anObject;
~~~

使用 NSArray 调用 containsObject 这个方法，会直接调用 isEqual 方法判断两个对象是否相等。测试发现这里并没有调用 hash 方法，原因不明，例子如下：

~~~ objc
NSMutableArray *array = [NSMutableArray array];
Person *aPerson = nil;
for (int i = 0; i < 5; i++) {
	Person *p = [[Person alloc] initWithEmail:[NSString stringWithFormat:@"%zd",i]];
	[array addObject:p];
	aPerson = p;
}
if ([array containsObject:aPerson]) {
	NSLog(@"array has 'aPerson'");
}
~~~

再使用 NSSet 看看是怎么执行的。

~~~ objc
NSMutableSet *sets = [NSMutableSet set];
Person *aPerson = nil;
for (int i = 0; i < 5; i++) {
	Person *p = [[Person alloc] initWithEmail:[NSString stringWithFormat:@"%zd",i]];
	[sets addObject:p];
	aPerson = p;
}
if ([sets containsObject:aPerson]) {
	NSLog(@"array has 'aPerson'");
}
~~~
NSSet 在 addObject 和 containsObject 方法中都会调用 hash 方法。再 addObject 方法中会调用 isEqual 方法，而 containsObject 方法中则不再调用。NSArray 则是在 containsObject 方法中调用 isEqual 方法。

> 不同的集合会使用不同的逻辑判断是否“相等”。

#### 注意
在 NSSet 中， hash 方法是判断的第一步，应该保证此方法的高效性，同时也要考虑 **哈希碰撞** 发生的概率。






