---
title: 《Effective Objective-C 2.0》第二章阅读笔记(3)  
date: 2018-04-23  
tags: [Effective Objective-C 2.0, 消息转发, 类对象本质]  
category: "iOS开发"  

---

# <center>第二章：对象、消息、运行期(3)</center>

## 第12条：理解消息转发机制
当一个对象接收到无法解读的消息后，就会开启“消息转发”机制。如果消息转发也无法解读消息，程序就会抛出异常：
> unrecognized selector sent to instance xxxx

消息转发分为两大阶段：
### 第一阶段：动态方法解析
征询接受者能否动态添加方法来处理这个消息。此时会调用以下两个方法之一：

~~~ objc
// 以类方法调用时触发
+ (BOOL)resolveClassMethod:(SEL)sel
// 以实例方法调用时触发
+ (BOOL)resolveInstanceMethod:(SEL)sel
~~~
如果需要在动态解析时处理消息，那么实现代码如下：

~~~ objc
void run(id self, SEL _cmd) {
    NSLog(@"missRun -- run");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == NSSelectorFromString(@"missRun")) {
        NSLog(@"sel == %@",NSStringFromSelector(sel));
        class_addMethod([self class], sel, (IMP)run, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

// 注意这里 class_addMethod 的第一个参数是 [self superclass]
+ (BOOL)resolveClassMethod:(SEL)sel {
    if (sel == NSSelectorFromString(@"missRun")) {
        NSLog(@"sel == %@",NSStringFromSelector(sel));
        class_addMethod([self superclass], sel, (IMP)run, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
~~~
外部调用  

~~~ objc
//Person *person = [[Person alloc] init];
//[person performSelector:NSSelectorFromString(@"missRun") withObject:nil];

[Person performSelector:NSSelectorFromString(@"missRun") withObject:nil];
~~~
此时在外部调用 missRun 方法，最终将会访问 **void run(id self, SEL _cmd)** 方法。
> IMP 指向的函数必须要有 **id self, SEL _cmd** 这两个参数。  

class_addMethod 的最后一个参数 **"v@:"** 中，v 表示返回值 void ， @ 表示第一个参数类型为 id ，: 表示 SEL 。具体可看文档 [Type Encodings](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)

### 第二阶段：完整的消息转发机制
接受者尝试能否将这条消息转发给其他接受者接收，如果不行就启用“完整的消息转发”。
#### 备用接受者
此时会调用下面的方法  

~~~ objc
- (id)forwardingTargetForSelector:(SEL)aSelector {
    Sutdent *student = [[Sutdent alloc] init];
    if ([student respondsToSelector:aSelector]) {
        return student;
    }
    return [super forwardingTargetForSelector:aSelector];
}
~~~

#### 完整的消息转发

~~~ objc
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == NSSelectorFromString(@"missRun")) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([anInvocation selector] == NSSelectorFromString(@"missRun")) {
        Sutdent *student = [[Sutdent alloc] init];
        [anInvocation invokeWithTarget:student];
    }
}
~~~

“备用接受者”和“完整的消息转发”区别在于，“完整的消息转发”中可以改变消息的内容。

### 消息转发流程图
![](http://ovsbvt5li.bkt.clouddn.com/18-4-24/55820526.jpg)
接受者在每一步均有机会处理消息，越到最后，处理的代价会越高。
### Demo
[GitHub: MessageForwarding](https://github.com/vhuichen/MessageForwarding.git)

## 第13条：用 “方法调配技术” 调试 “黑盒方法”（method swizzling）
类对象的方法列表会将“方法名”映射带相应的方法实现上，“动态消息派发系统”会根据这个表找到相应的方法。这些方法均以函数指针的方式表示。这种指针就是 IMP 。下图是 NSString 的部分方法映射表。   
![](http://ovsbvt5li.bkt.clouddn.com/18-4-24/29661179.jpg)  
Objective-C 运行时系统提供了几个方法可以用来操作这张表。开发者可以在运行时新增方法，改变方法对应的实现，也可以交换两个方法的具体实现。例如我们可以让方法映射表变成下图这样  
![](http://ovsbvt5li.bkt.clouddn.com/18-4-24/58460381.jpg)  
实现起来也是很简单的，创建一个 NSString 的分类，在 +load 方法中实现  

~~~ objc 
+ (void)load {
    Method originalMethod = class_getInstanceMethod([NSString class], @selector(lowercaseString));
    Method swappedMethod = class_getInstanceMethod([NSString class], @selector(uppercaseString));
    method_exchangeImplementations(originalMethod, swappedMethod);
}
~~~
调用

~~~ objc
NSString *string = @"This is a String";
NSLog(@"lowercaseString = %@",string.lowercaseString);
NSLog(@"uppercaseString = %@",string.uppercaseString);

// 输出
// lowercaseString = THIS IS A STRING
// uppercaseString = this is a string
~~~
此时 lowercaseString 和 uppercaseString 的方法实现已经替换过来了。  
lowercaseString 方法对应的是 uppercaseString 的方法实现。  
uppercaseString 方法对应的是 lowercaseString 的方法实现。  
所以打印出来的log是反过来的。当然这个没有什么意义。  

下面实现一个功能：每次调用 lowercaseString 都打印出相应的log出来  

~~~ objc 
+ (void)load {
    Method originalMethod = class_getInstanceMethod([NSString class], @selector(lowercaseString));
    Method swappedMethod = class_getInstanceMethod([NSString class], @selector(vch_lowercaseString));
    method_exchangeImplementations(originalMethod, swappedMethod);
}

- (NSString *)vch_lowercaseString {
    NSString *string = [self vch_lowercaseString];
    NSLog(@"----%@",string);
    return string;
}
~~~
调用

~~~ objc
NSString *string = @"This is a String";
NSLog(@"lowercaseString = %@",string.lowercaseString);

// 输出
// ----this is a string
// lowercaseString = this is a string
~~~
由于 lowercaseString 和 vch_lowercaseString 交换了方法实现，所以当我们调用 lowercaseString 方法的时候，执行的是 vch_lowercaseString 里面的方法。所以才会打印出 log 出来。  

### 用途
**使用 method swizzling “黑魔法”，开发者可以在原有实现中添加新的功能。**


## 第14条：理解 “类对象” 的本质
看看下面的两个语句  

~~~ objc
NSString *string0 = @"this is a string";
id string1 = @"this is a string";
~~~
两个语句都创建了一个 NSSring 类型的对象，在编译时，编译器会将 string0 按照 NSString 类型来检测，string1 按照 id 类型来检测。string0 直接调用 NSString 的方法编译器不会报错，string1 直接调用 NSString 的方法则编译器报错。 而在运行时两个对象表示的意思是一样的。

在 objc.h 中是这样定义 id 类型的

~~~ objc
// objc.h

/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;

/// Represents an instance of a class.
struct objc_object {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
};

/// A pointer to an instance of a class.
typedef struct objc_object *id;
~~~
可以看出 id 是 objc_object 结构体类型的指针，objc_object 包含了一个 Class 类型的变量 isa ，Class 是 objc_class 类型的指针。  
再看看 NSObject.h 中的定义

~~~ objc
// NSObject.h

@interface NSObject <NSObject> {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
    Class isa  OBJC_ISA_AVAILABILITY;
#pragma clang diagnostic pop
}
~~~
这里面包含了一个 Class 类型的变量 isa 。这个 Class 也就是 objc_class 类型的指针。  
事实上每个实例变量都会包含一个 objc_object 结构体，该结构体的第一个成员变量就是 isa 指针。既然是指针，那么 objc_class 也是一个对象，我们称之为“类对象”，这个类对象是一个单例，程序运行中只存在一份。   

再看看 runtime.h 是怎么定义 objc_class 结构体的。  

~~~ objc
// runtime.h

struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class _Nullable super_class                              OBJC2_UNAVAILABLE;
    const char * _Nonnull name                               OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
    struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
    struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
~~~
objc_class 的第一个成员变量也是 isa 指针。它指向的是类的元类（metaclass）。objc_class 负责保存类的实例变量、方法列表、缓存方法列表、协议列表等。元类（metaclass）则负责保存类方法列表。

### 继承体系图
![](http://ovsbvt5li.bkt.clouddn.com/18-4-25/33685437.jpg)  
每一个实例对象都有一个 isa 指针指向其类对象，用来表明其类型，类对象也有一个 isa 指针，指向其元类，元类同样存在一个 isa 指针，指向其根元类，根元类的 isa 指针则指向自身。这些类对象则构成了类的继承体系。

### 在继承体系中查询类型信息
**isMemberOfClass**  不包含父类，用来判断是否是某个特定类的实例。（需要考虑“类族”）  
**isKindOfClass**    包含父类，用来判断是否是某个特定类或者派生类的实例。  

### 总结
1、类本质也是一个对象（类对象）。  
2、类对象会在程序第一次使用时创建一次，是个单例。  
3、类对象是一种数据结构。存储了类的版本、描述信息、大小、变量列表、方法列表、方法缓存、协议列表等。  
4、元类中保存了类方法列表。
