---
title: 《Effective Objective-C 2.0》第四章阅读笔记  
date: 2018-05-02  
tags: [Effective Objective-C 2.0]  
category: "iOS开发"  

---

# <center>第四章：协议与分类</center>
Objective-C 语言有一项特性叫 “协议”（protocol），与 Java 的“接口”（interface）类似。
> Java接口是一系列方法的声明，是一些方法特征的集合，一个接口只有方法的特征没有方法的实现，因此这些方法可以在不同的地方被不同的类实现，而这些实现可以具有不同的行为（功能）。

protocol 定义了一套公用的接口，和 Java 的接口同样，一个接口只有方法特征没有方法的实现，不同的类可以实现不同的行为。本质上和 Java 的接口是相同的。  

Objective-C 不支持多重继承，所以我们可以将某个类应该实现的一系列方法定义在协议里面。协议最常见的用途就是实现委托模式。

“分类”也是 Objective-C 的一个重要特性。利用分类机制，我们无需继承子类即可直接为当前类添加方法。

## 第23条：通过委托与数据源协议进行对象间通信
对象之间的通信使用最广泛的就是“委托模式”。定义一套接口，某对象若想接受另一对象的委托，则需遵循此接口，以便其成为“委托对象”。此模式可将数据与业务逻辑解耦。
#### 定义
委托属性一定要用 weak 修饰，不然会造成循环引用。  

~~~ objc
@protocol PersonDelegate <NSObject>
@required
- (NSDate *)whatTimeIsIt;

@optional
- (BOOL)isNiceDay;

@end

@interface Person : NSObject

@property (nonatomic, weak) id<PersonDelegate> personDelegate;

@end

~~~
#### 实现
委托协议的方法一般会定义“可选的”（optional），当我们在调用这些方法之前就需要先判断委托对象是否有实现这个方法。

~~~ objc
@implementation Person

- (void)doWork {
    NSDate *date = [self.personDelegate whatTimeIsIt];
    NSLog(@"date = %@",date);
    if ([self.personDelegate respondsToSelector:@selector(isNiceDay)]) {
        BOOL isNiceDay = [self.personDelegate isNiceDay];
        NSLog(@"isNiceDay:%zd",isNiceDay);
    }
}

@end
~~~
如果需要经常调用某个可选方法，可以用一个状态变量来保存“是否实现这个方法”的状态，如果有多个可选方法也可以用结构体来保存状态。这样做可以大大提高程序效率。

#### 调用
委托对象需要先遵守这个协议。

~~~ objc
@interface ViewController () <PersonDelegate>

@end

@implementation ViewController

Person *person = [[Person alloc] initWithEmail:@"123@163.com"];
person.personDelegate = self;
[person doWork];

@end

// log
// date = Thu May  3 19:43:05 2018
// isNiceDay:1
~~~

## 第24条：将类的实现代码分散到便于管理的数个分类中
可以将类相同功能部分分散到单独的分类中，方便管理。也应该将私有方法放到名为 "private" 的分类中，以“隐藏”实现细节。官方的 NSString 就分成了好几个分类。

~~~ objc
@interface NSString : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>
// 0
@end

@interface NSString (NSStringExtensionMethods)
// 1
@end

@interface NSString (NSStringEncodingDetection)
// 2
@end

@interface NSString (NSItemProvider) <NSItemProviderReading, NSItemProviderWriting>
// 3
@end

@interface NSString (NSExtendedStringPropertyListParsing)
// 4
@end

@interface NSString (NSStringDeprecated)
// 5
@end
~~~

## 第25条：总是为第三方类的分类名称加前缀
向第三方类中添加分类时，应给分类名称以及方法加上项目专用的名称。

~~~ objc
@interface UIWindow (VCHAnimalWindow)

- (void)vch_setRootViewController:(UIViewController *)rootViewController withOglFlipSubtype:(NSString *)subtype;
- (void)vch_setRootViewController:(UIViewController *)rootViewController animalType:(NSString *)type subtype:(NSString *)subtype duration:(CFTimeInterval)duration;

@end
~~~
这样做很大程度上避免了分类方法和原类方法相同的可能。

## 第26条：勿在分类中申明属性
直接在分类中申明属性编译器只会给一个编译警告。  

~~~ objc
// 在分类中定义一个属性
@interface Person (Special)

@property (nonatomic, weak) NSString *name;

@end

// Property 'name' requires method 'name' to be defined - use @dynamic or provide a method implementation in this category
// Property 'name' requires method 'setName:' to be defined - use @dynamic or provide a method implementation in this category
~~~
提示使用 @dynamic 修饰属性或者提供属性的 getter 和 setter 方法。如果没有实现，那么程序会在运行时检测。

#### 关联对象
通过关联对象可以为分类实现属性的功能。使用时应注意内存管理问题。这种方法应该在必要的情况下才使用。

~~~ objc
- (void)setName:(NSString *)name {
    objc_setAssociatedObject(self, "kPersonSpecial_name", name, OBJC_ASSOCIATION_COPY);
}

- (NSString *)name {
    return objc_getAssociatedObject(self, "kPersonSpecial_name");
}
~~~

> 总之,在必要的情况下可以通过关联对象声明属性，但这种方法应该尽量少用。

## 第27条：使用 “class-continuation 分类” 隐藏实现细节
类中经常会包含一些无需对外公布的方法及实例变量。这些内容可以对外公布，并写明其为私有。Objective-C 的动态消息系统方式决定了其不可能实现真正的私有方法和私有实例变量。然而，我们最好还是只把确定需要公布的那部分内容公开。此时我们可以将这部分内容放到“class-continuation 分类”中。  
“class-continuation 分类” 与其他的分类不同，它必须定义在实现文件中，这是唯一能声明实例变量的分类，而且此分类没有特定的实现文件，其中的方法都应该定义在主实现文件里。  
若对象遵循的协议只应视为私有，也可在“class-continuation 分类”中声明。

~~~ objc
@interface ViewController () <PersonDelegate>
{
    int _count;
}

@property (nonatomic, copy) Person *person;

@end
~~~

## 第28条：通过协议提供匿名对象
协议定义了一系列方法，遵从此协议的对象应该实现它们，如果这些方法不是可选的，那么就必须实现。我们可以用协议把自己所写的API之中的实现细节隐藏起来，将返回的对象设计为遵从此协议的纯id类型。这样的话，想要隐藏的类名就不会出现在API之中了。若是接口背后有多个不同的实现类，而你又不想指明具体使用哪个类，那么可以考虑用这个办法，因为有时候这些类可能会变，有时候它们又无法容纳于标准的类继承体系中，因而不能以某个公共基类来统一表示。此概念称为“匿名对象”。   
例如在定义“受委托者”这个对象时，可以这样写：

~~~ objc
@property (nonatomic, weak) id <VCHDelegate> delegate;
~~~
任何遵循了 VCHDelegate 这个协议的对象都可以充当这个属性。对于具备此属性的类来说，delegate就是"匿名的"。   
处理数据库连接(database connection)的程序库也用这个思路，以匿名对象来表示从另一个库中所返回的对象。对于处理连接所用的那个类，你也许不想让外人知道其名字，因为不同的数据库可能要用到不同的类来处理。如果没办法令其都继承自同一基类，那么就得返回id类型。不过我们可以把所有数据库连接都具备的那些方法放到协议中，令返回的对象遵从此协议。协议可以这样写:

~~~ objc
@protocol EOCDatabaseConnection

- (void)connect;
- (void)disconnect;
- (BOOL)isConnected;
- (NSArray *)performQuery:(NSString *)query;

@end
~~~
然后可以用“数据库处理器”单例来提供数据库连接，接口可以这样写：   

~~~ objc
@protocol EOCDatabaseConnection;  

@interface EOCDatabaseManger:NSObject  

+ (id)sharedInstance;  
- (id<EOCDatabaseConnection>) connectionWithIdentifier:(NSString *)identifier;  

@end;  
~~~
这样的话，处理数据库连接所用的类的名称就不会泄漏了，有可能来自不同框架的那些类现在均可以经由同一个方法来返回。使用此API的人仅仅要求所返回的对象能用来连接、断开并查询数据库即可。至于使用的哪种数据库则不需要关心。如果后续需要更改数据库，那么此时也不需要更改接口。我们关心的并不是对象的类型，而是对象有没有实现相关的方法。
