---
title: 《Effective Objective-C 2.0》第三章阅读笔记  
date: 2018-04-26  
tags: [Effective Objective-C 2.0]  
category: "iOS开发"  

---

# <center>第三章：接口与 API 设计</center>

## 第15条：用前缀避免命名冲突
选择与公司、应用程序或二者皆有关联的名称作为类名的前缀，并在所有的代码中使用这一前缀。也不仅仅是类名，应用程序中所有名称都应该加前缀。  
> 苹果宣称保留使用所有“两个字母前缀”的权利，所以我们的前缀必须多于两个字母。  

### 顶级符号
在编译好的目标文件中，类实现文件所用的纯 C 函数和全局变量的名称要算作“顶级符号”。比如在类中创建了名为 “completion” 的纯 C 函数，会编译成 “_completion” 存在符号表中。此时如果在别的文件中也创建一个名为 “completion” 的函数，就会发出一个 “duplicate symbol” 的错误。

### 避免第三方库冲突
如果两个第三方库同时引入了相同的第三方库，那么就可能会出现 “duplicate symbol” 的错误。  
**当自己的第三方库引入了别的第三方库的时候，应该给那份第三方库的代码加上自己的前缀。（😆。。。没看懂）**

## 第16条：提供 “指定初始化方法”
那些可以为对象提供必要信息以便其能完成工作的初始化方法就叫“指定初始化方法”，这类初始化方法一般在后面会有 NS_DESIGNATED_INITIALIZER 这个宏定义。  

#### 相关文章
之前已经写过一篇相关的文章，可以去这篇文章看看 [iOS开发之Designated Initializer(指定初始化方法)](https://vhuichen.github.io/2018/03/31/180331-iOS%E5%BC%80%E5%8F%91%E4%B9%8BDesignated%20Initializer/)

#### 补充
如果子类的指定初始化方法和父类的指定初始化方法不一样，那么需要在子类中重写父类的初始化方法。

## 第17条：实现 description 方法
description 方法定义在 NSObject 的协议里面。当想打印某个对象的时候，通常我们会这样做

~~~ objc
Person *p = [[Person alloc] initWithEmail:@"123@163.com"];
NSLog(@"%@",p);

// 输出
// <Person: 0x109ea6170>
~~~
直接打印对象实际上就是调用了 description 方法。所以我们只需要重写这个方法就可以打印出感兴趣的信息出来。  

#### description
~~~ objc
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, email = %@>", [self class], self, _email];
}

// 输出
// <Person: 0x12bd4f090, email = 123@163.com>
~~~
如上，只要我们重写了 description 方法，就可以打印出特定的信息出来。

#### debugDescription
在合适的地方加入断点，然后在调试控制台输入lldb的 "po" 命令，就可以打印出 debugDescription 里面的信息出来

~~~ objc
- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p, email = %@>", [self class], self, _email];
}

// 输出
// <Person: 0x113dbff50, email = 123@163.com>
// (lldb) po p
// <Person: 0x113dbff50, email = 123@163.com>
// (lldb) 
~~~
一般我们可以在 description 里面打印主要的信息，而在 debugDescription 里面打印更详细的信息。

## 第18条：尽量使用不可变对象
如果属性是不可变的，那么就应该将它设置成 readonly 。  
如果把可变对象放到 collection 中，然后又修改其内容，那么很容易破坏 collection 的内部结构，比如：NSSet  
> 看使用场景，把代码设计成最合逻辑的。

## 第19条：使用清晰而协调的命名方式
1、命名要清晰、易懂。  
2、命名不要太啰嗦。  
3、驼峰命名（类名首字母要大些，并且要加上前缀）。  
4、是否要简写要看具体情况。  
5、加前缀，尽量避免命名冲突。  

## 第20条：为私有方法名加前缀
由于 Objective-C 没有 private 关键字。如果父类的私有方法和子类的方法重名了，那么父类的私有方法将无法执行。
苹果自己是通过在私有方法前加下划线（_）来标识的，因此我们就不能再这样做了。  
### 怎样有效避免这个问题
文章给出两个方法。
#### 加前缀 "p_"  
即 private 的首字母加下划线作为前缀。
#### 项目前缀加下划线
比如我的项目前缀是 "VCH"，那么就可以加 "vch_" 作为前缀。不过其实分类的方法很多也是使用前缀加下划线来区别原类的。

## 第21条：理解 Objective-C 错误模型

### 致命性错误 使用 @throw
只有在极端情况下，才使用 @throw 抛出异常，同时也就意味着程序结束，崩溃。

~~~ objc
@throw [NSException exceptionWithName:@"errorName" reason:@"errorReason" userInfo:@{@"key":@"value"}];
~~~
### 非致命性错误 返回 nil 或 0
一般对于一些非致命性错误，可以返回 nil 或 0 来提示。

### NSError
当我们进行一些网络请求时，会返回一些错误，此时可以通过 NSError 把错误信息封装起来，再交给接受者处理。

#### Error domain
错误的范围，一般会定义一个全局变量来指示。

#### Error code
错误码，一般用一个枚举表示。

#### Error info
包含错误的额外信息，字典类型。

#### Error 常见处理方法
##### 交给委托处理
可以把错误传递给委托对象处理，至于怎么去处理这个错误由委托对象决定。

##### 返回给调用者
也可以通过返回值、block等将错误返回给调用者，交由调用者处理错误。

## 第22条：理解 NSCopying 协议
当我们自己的类需要支持拷贝操作时，就需要实现 NSCopying 协议，协议就一个方法。

~~~ objc
@protocol NSCopying

- (id)copyWithZone:(nullable NSZone *)zone;

@end
~~~
具体实现如下

~~~ objc
// .h
@interface Person : NSObject<NSCopying>

- (instancetype)initWithEmail:(NSString *)email;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *name;

@end

// .m
- (id)copyWithZone:(NSZone *)zone {
    Person *person = [[[self class] allocWithZone:zone] initWithEmail:_email];
    person.name = [_name copy];
    return person;
}
~~~
使用 NSCopying 协议复制出来的对象是不可变的。

### NSMutableCopying 协议
当我们需要复制的是可变对象时，就需要实现 NSMutableCopying 这个协议。

~~~ objc
@protocol NSMutableCopying

- (id)mutableCopyWithZone:(nullable NSZone *)zone;

@end
~~~
如果自定义对象分可变版本和不可变版本，那么就要同时实现 NSCopying 和 NSMutableCopying 协议。

### 深拷贝 & 浅拷贝
浅拷贝只会复制指针，拷贝后的对象和原始对象为同一对象。深拷贝则是将对象也拷贝了一份。Foundation 框架下所有的 collection 类在默认情况下都执行浅拷贝。实现 collection 深拷贝的方法类似如下

~~~ objc
- (instancetype)initWithSet:(NSSet<ObjectType> *)set copyItems:(BOOL)flag;
- (instancetype)initWithArray:(NSArray<ObjectType> *)array copyItems:(BOOL)flag;
~~~
