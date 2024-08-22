---
title: 《Effective Objective-C 2.0》第一章阅读笔记  
date: 2018-04-13  
tags: [Effective Objective-C 2.0,]  
category: "iOS开发"  

---

# <center>第一章：熟悉 Objective-C 语言</center>

## 第1条：了解 Objective-C 语言的起源

#### 消息结构

Objective-C 使用的是“消息结构”（messaging structure）而非“函数调用”（function calling）。  
使用消息结构的语言，其运行时所执行的代码由运行环境决定。而使用函数调用的语言，则由编译器决定。  
> 在C/C++中，如果使用的函数是多态，那么运行时会根据“虚方法表”（virtual table）来查找应该执行哪个函数实现。而采用消息结构的语言则都是在运行的时候才查找要执行的方法。

#### 运行期组件（runtime component）
Objective-C 中重要工作都由运行期组件完成，而非编译器。里面包含了面向对象所需的全部数据结构及函数。其本质是与开发者所编写的代码相链接的动态库。

#### 对象内存分配
对象所占有的内存总是分配到堆空间（Head）中，而指向对象的指针则是分配到栈（stack）中。分配到堆中的内存必须进行管理，分配到栈上用于保存对象地址的内存，则会在栈帧弹出时自动处理。  
当遇到非指针类型变量的时候，变量可能会分配到栈空间，比如：结构体。

## 第2条：在类的头文件中尽量少引用其他头文件

#### 向前声明（forward declaring）
如果只需要知道有那么一个类名，则不需要引用该类名的头文件（不需要知道其他细节），这时可以向前声明该类，既使用：
> @class className;  

然后在实现文件中引入该头文件。这样可以降低类与类之间的耦合。   
引入头文件的时机应该尽量延后，只有当确定要引用该头文件的时候才引用。将大量的头文件引入到头文件中，会增加文件之间的依赖性，从而增加编译时间。   

#### 循环引用
向前申明可以解决两个类之间的循环引用。文章说道：
> 使用 #import 虽然不会导致引用循环，但却意味着两个类有一个不能被正确编译。

不过，这句话我。。。。无法理解！！！  

#### 头文件需要引用协议
如果要使用某个协议，则不能使用向前声明，为了不引用整个头文件，可以将协议放到“class-continuation 分类”中，或者单独放到一个文件中，然后使用 #import 引用头文件，这样就不会出现上面说的问题。

## 第3条：多用字面量语法，少用与之等价的方法
使用字面量语法可以缩减代码长度，提高代码可读性。也要确保创建对象的时候不能为nil。  

~~~ objc
NSString *string0 = [[NSString alloc] initWithString:@"123"];
NSString *string1 = @"123";
    
NSNumber *number0 = [NSNumber numberWithInt:1];
NSNumber *number1 = @1;
    
NSArray *array0 = [NSArray arrayWithObjects:@"cat", @"dog", @"fish", nil];
NSString *cat0 = [array0 objectAtIndex:0];
NSArray *array1 = @[@"cat", @"dog", @"fish"];
NSString *cat1 = array1[0];
    
NSDictionary *dictionary0 = [NSDictionary dictionaryWithObjectsAndKeys:@"key0", @"value0", @"key1", @"value1", nil];
NSString *value0 = [dictionary0 objectForKey:@"key0"];
	
NSDictionary *dictionary1 = @{@"key0":@"value0", @"key1":@"value1"};
NSString *value1 = dictionary1[@"key1"];
~~~

## 第4条：多用类型常量，少用 #define 预处理指令
#### 使用 #define 无法确定类型信息
比如下面的代码用 #define 无法预知 kAnimationDuration 的数据类型，不利于编写开发文档。   

~~~ objc
#define kAnimationDuration 0.1
static const NSTimeInterval kAnimationDuration = 0.1;
static const float kAnimationDuration = 0.1;
~~~

#### static const 修饰
如果一个变量用 static const 修饰，那么编译器不会创建符号，而是会像 #define 预处理指令一样，在编译的时候将所有的变量替换成常值。

#### extern 声明全局变量
使用 static const 修饰的变量只能在本文件内使用，但有时候需要对外公布这个变量，比如该变量作为“通知”的key的时候，此时可以稍微改一下。  

~~~ objc
// .h文件 声明一个变量
extern NSString *const VCHLoginNotification;
// .m文件 定义一个变量
NSString *const VCHLoginNotification = @"kLoginNotification";
~~~
这种变量会保存在“全局符号表”中。为了避免命名冲突，这种变量应该加上类名前缀。

#### 判断 const 修饰的是对象还是指针(自己理解)
const 修饰的是右边的第一个字符  

~~~ objc
float const valueFloat0 = 0.1; //[1]
const float valueFloat1 = 0.1; //[2]
NSString const * string0 = @"abc"; //[3]
NSString * const string1 = @"abc"; //[4]
const NSString * string2 = @"abc"; //[5]
const NSString * const string3 = @"abc"; //[6]
const NSString const * string4 = @"abc"; //[7]
~~~
[1] const 右边第一个字符是 valueFloat0，表示 valueFloat0 里面的值是不变的。valueFloat0  不能是左值。   
[2] const 右边第一个字符是 float，而 float 指的就是 valueFloat1，所以 valueFloat1 的值是不变的。valueFloat1 不能是左值。   
[3] const 右边第一个字符是 string0，string0 是一个指针，所以 string0 指向的地址是不变的。string0 不能是左值。  
[4] const 右边第一个字符是 string1（指针），所以 string1 指向的地址是不变的。string1 不能是左值。  
[5] const 右边第一个字符是 NSString，表示的是 @"abc" 这个对象，所以 @"abc 是不可变对象。不可以通过 string2 这个指针来修改它指向的对象的内容。(这里刚好 @"abc" 是不能修改的，就算指向的对象是可以被修改的，也不能通过 const 修饰的指针去修改)  
[6] 第一个 const 右边第一个字符是 NSString， 等同于 [5]。第二个 const 等同于 [4]。  
[7] 等同于 [6]  

## 第5条：用枚举表示状态、选项、状态码
枚举可以提高代码可读性。   

~~~ objc
// 状态、状态码
typedef NS_ENUM(NSInteger, UIViewAnimationTransition) {
    UIViewAnimationTransitionNone,
    UIViewAnimationTransitionFlipFromLeft,
    UIViewAnimationTransitionFlipFromRight,
    UIViewAnimationTransitionCurlUp,
    UIViewAnimationTransitionCurlDown,
};

// 可组合选项
typedef NS_OPTIONS(NSUInteger, UIViewAutoresizing) {
    UIViewAutoresizingNone                 = 0,
    UIViewAutoresizingFlexibleLeftMargin   = 1 << 0,
    UIViewAutoresizingFlexibleWidth        = 1 << 1,
    UIViewAutoresizingFlexibleRightMargin  = 1 << 2,
    UIViewAutoresizingFlexibleTopMargin    = 1 << 3,
    UIViewAutoresizingFlexibleHeight       = 1 << 4,
    UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};
~~~
enum 用来表示状态，options 用来表示可组合的选项。

#### 注意
1、用枚举处理 switch 的时候不要实现 default 分支。这样加入新的分支后，编译器就会提示开发者。











