---
title: 《Effective Objective-C 2.0》第二章阅读笔记(2)  
date: 2018-04-20 
tags: [Effective Objective-C 2.0, 类族模式, 关联对象]  
category: "iOS开发"  

---

# <center>第二章：对象、消息、运行期(2)</center>

## 第9条：以 “类族模式” 模式隐藏实现细节
类族模式可以把实现细节隐藏在一套简单的公共接口后面。Objective-C 的系统框架普遍使用此模式。例如：UIButton NSArray NSNumber 等等。

#### 自定义 “类族模式”
定义一个 Person 基类以及三个子类 PersonA, PersonB, PersonC 。三个子类分别实现自己的 doWork 任务。

~~~ objc
// Person
@interface Person : NSObject
+ (instancetype)personWithType:(PersonType)personType;
- (void)doWork;
@end

@implementation Person
+ (instancetype)personWithType:(PersonType)personType {
    switch (personType) {
        case PersonTypeA:
            return [PersonA new];
            break;
        case PersonTypeB:
            return [PersonB new];
            break;
        case PersonTypeC:
            return [PersonC new];
            break;
    }
}

- (void)doWork {
    //SubClasses implement this
}
@end

//
// Subclass PersonA
@interface PersonA : Person

@end

@implementation PersonA

- (void)doWork {
    NSLog(@"do PersonA Work");
}

//
// Subclass PersonB
@interface PersonB : Person

@end

@implementation PersonB

- (void)doWork {
    NSLog(@"do PersonB Work");
}

//
// Subclass PersonC
@interface PersonC : Person

@end

@implementation PersonC

- (void)doWork {
    NSLog(@"do PersonC Work");
}

@end

~~~
接口调用如下：

~~~ objc
Person *personA = [Person personWithType:PersonTypeA];
Person *personB = [Person personWithType:PersonTypeB];
Person *personC = [Person personWithType:PersonTypeC];

NSLog(@"%@",[personA class]);
NSLog(@"%@",[personB class]);
NSLog(@"%@",[personC class]);

[personA doWork];
[personB doWork];
[personC doWork];

// 输出
// PersonA
// PersonB
// PersonC
// do PersonA Work
// do PersonB Work
// do PersonC Work
~~~
这样就只需要传入不同的 Type 就可以实现不同的任务。这种实现模式就叫做“类族模式”。

## 第10条：在既有类中使用关联对象存放自定义数据
可以通过“关联对象”这项特性，给某个类关联多个对象，这些对象可以通过 key 区分。在关联对象的时候需要指明对象的“存储策略”，用来维护相应的“内存管理语义”。“存储策略”由 objc_AssociationPolicy 这个枚举维护。下面给出 objc_AssociationPolicy 枚举的取值以及等效的 @property 属性。

~~~ objc
/**
 * Policies related to associative references.
 * These are options to objc_setAssociatedObject()
 */
typedef OBJC_ENUM(uintptr_t, objc_AssociationPolicy) {
    OBJC_ASSOCIATION_ASSIGN = 0,           /**< Specifies a weak reference to the associated object. */
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, /**< Specifies a strong reference to the associated object. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   /**< Specifies that the associated object is copied. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_RETAIN = 01401,       /**< Specifies a strong reference to the associated object.
                                            *   The association is made atomically. */
    OBJC_ASSOCIATION_COPY = 01403          /**< Specifies that the associated object is copied.
                                            *   The association is made atomically. */
};
~~~
![](http://ovsbvt5li.bkt.clouddn.com/18-4-20/99689322.jpg)
对应的3个方法为：

~~~ objc
// 设置关联对象
void objc_setAssociatedObject(id _Nonnull object, const void * _Nonnull key,id _Nullable value, objc_AssociationPolicy policy);
// 获取关联对象
id objc_getAssociatedObject(id _Nonnull object, const void * _Nonnull key);                         
// 移除关联对象
void objc_removeAssociatedObjects(id _Nonnull object)   
~~~

> 系统没有给出移除单个关联对象的接口，如果要移除某个关联对象，可以通过给该关联对象的 key 设置一个空值来实现。  
> void objc_setAssociatedObject(object, key, nil, policy);

#### 示例
当我们需要使用 UIAlertView 时，一般会这样写：

~~~ objc
- (void)showAlert {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"title" message:@"message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if (buttonIndex == 1) {
        
    }
}
~~~
当存在多个 UIAlertView 时，委托方法里面就需要对 alertView 进行判断。使用关联对象可以简化这里的逻辑

~~~ objc
#import <objc/runtime.h>

static const void *kAlertKey = @"kAlertKey";
- (void)showAlert {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"title" message:@"message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"confirm", nil];
	
	void (^block)(NSInteger) = ^(NSInteger buttonIndex) {
		if (buttonIndex == 0) {
            
		} else if (buttonIndex == 1) {
            
		}
	};
	objc_setAssociatedObject(alertView, kAlertKey, block, OBJC_ASSOCIATION_COPY);
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^block)(NSInteger) = objc_getAssociatedObject(alertView, kAlertKey);
    block(buttonIndex);
}
~~~

#### 注意
当关联对象需要捕获了其他变量，可能会造成引用循环。使用关联对象会降低代码的可读性，增加调试的难度。应谨慎使用。

## 第11条：理解 objc_msgSend 的作用
给对象发消息

~~~ objc
id returnValue = [someObject msgName:parameter];
~~~
编译器会转换为

~~~ objc
id returnValue = objc_msgSend(someObject, @selector(msgName:), parameter);
~~~
objc_msgSend 会在接受者类中搜寻“方法列表”，如果找到对应的方法，则转跳实现代码。如果没找到就沿着继承类向上找。如果最终还是找不到该方法，则进行“消息转发”。同时 objc_msgSend 还会将找到的方法缓存在“快速映射表”，如果下次还需要执行该方法，就会先从“快速映射表”中查找，这样执行起来会快很多。  
每个类都会有一张类似于字典一样的表格，方法名是 Key ，对应的 Value 则保存着函数指针。objc_msgSend 就是通过这个表格来寻找应该执行的方法并跳转其实现的。这些工作由“动态消息派发系统”来处理。
#### 尾调用优化
“尾调用”是指一个函数最后一项操作是调用另一个函数，即被调用的函数的返回值就是当前函数的返回值。如果函数在尾部调用的是自身，那么就叫做“尾递归”。    
尾调用优化是指不需要在当前调用栈上开辟新的栈空间，而是更新原有栈（原有栈的数据已经不需要了），再把调用函数的返回地址替换成当前函数的返回地址。  
使用“尾调用优化”技术，很大程度上可以避免了栈溢出。  