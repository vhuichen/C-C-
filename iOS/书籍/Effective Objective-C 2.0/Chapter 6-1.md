---
title: 《Effective Objective-C 2.0》第六章阅读笔记(1)  
date: 2018-05-15  
tags: [Effective Objective-C 2.0]  
category: "iOS开发"  

---

# <center>第六章：块与大中枢派发(1)</center>

## 第37条：理解“块”这一概念
块与函数类似，只不过是直接定义在另一个函数里，和定义他的那个函数共享一个范围内的东西。  
块类型的语法结构如下：

~~~ objc
return_type (^block_name)(parameters)
~~~

#### 变量捕获
block 可以捕获外部变量，例如：  

~~~ objc
int additional = 5;
int (^addBlock)(int a, int b) = ^(int a, int b) {
    return a + b + additional;
};
int add = addBlock(2, 5);
~~~
block 捕获 additional 变量，仅仅是捕获 additional 那一刻的值，捕获了之后，如果外部 additional 的值改变了，此时并不会影响 block 内部 additional 的值，因为这个值是一个常量，分别存放在两个不同的内存中，是互不干扰的。如果尝试去修改此时 block 内部的additional 变量的值，编译器会报错。  
事实上，在 ARC 环境下，block 外部的 additional 变量是存放在栈中的，而 block 内部的 additional 变量则是存放在堆中的。  
那么，如果需要 block 内外共享一份内存呢？这时可以给变量加上 **__block** 关键字。  

#### __block 关键字修饰变量  
下面用 __block 关键字修饰 additional 变量，那么当外部的 additional 变量改变时，里面的 additional 值也会改变。因为这两个是同一个值。

~~~ objc
__block int additional = 5;
int (^addBlock)(int a, int b) = ^(int a, int b) {
    additional = 1;
    return a + b + additional;
};
int add = addBlock(2, 5);
~~~
用 __block 修饰的变量存放在堆中，和 block 中的 additional 共享同一份内存，是同一个数据。

#### 引用循环
如果在 block 中引用了某个对象，比如self，而这个对象正好直接或者间接引用了 block ，那么就会造成引用循环。  
所以一般在 block 中引用的变量都会使用弱引用。

#### 块的内部结构
块本身也是对象，在存放块对象的内存区域中，首个变量是指向Class对象的指针，该指针叫做isa。其余内存里含有块对象正常运转所需的各种信息。下图描述了块对象的内存布局。  
![](http://ovsbvt5li.bkt.clouddn.com/18-5-18/27886440.jpg)  

在内存布局中，最重要的就是invoke变量，这是个函数指针，指向块的实现代码。函数原型至少要接受一个void *型的参数，此参数代表块。

descriptor 变量是指向结构体的指针，每个块里都包含此结构体，其中声明了块对象的总体大小，还声明了 copy 与 dispose 这两个辅助函数所对应的函数指针。辅助函数在拷贝及丢弃块对象时运行，其中会执行一些操作，比方说，前者 copy 要保留捕获的对象，而后者 dispose 则将之释放。

block 会把它所捕获的所有变量都拷贝一份，拷贝的是指向这些对象的指针变量。invoke函数为何需要把块对象作为参数传进来呢？原因就在于，执行块时，要从内存中把这些捕获到的变量读出来。

#### 全局块、栈块及堆块
定义块时，其所占的内存区域是分配在栈中的。这就是说，块只在定义他的那个范围内有效。例如，下面这段代码会有问题：  

~~~ objc
void (^block)();
if ( /* ... */ ) {
    block = ^{
        NSLog(@"Block A");
    };
} else {
    block = ^{
        NSLog(@"Block B");
    };
}
block();
~~~
上面两个 block 都是分配在栈中的，当离开了作用域后，就会将其释放掉，也就是两个 block 只在 if else 内有效。所以离开了 if slse 后在执行 block的话就可能会出问题。若编译器未覆写待执行的 block，则程序照常运行，若覆写，则程序崩溃。

**其实这就是为什么 block 属性要使用 copy 修饰的原因。**给 block 发送 copy 消息将其拷贝。这样就可以把 block 从栈复制到堆了。拷贝后的 block，可以在定义它的范围之外使用。而且，一旦复制到堆上，块就成了带引用计数的对象了。后续的复制操作都不会真的执行复制，只是递增对象的引用计数。 

给上面的 block 发送 copy 消息就可以保证程序可以正确运行   

~~~ objc
void (^block)();
if ( /* ... */ ) {
    block = [^{
        NSLog(@"Block A");
    } copy];
} else {
    block = [^{
        NSLog(@"Block B");
    } copy];
}
block();
~~~
此时的 block 是分配到堆的，这样在 if else 外也可以使用。

#### 全局块
这种块不会捕捉任何状态（比如外围的变量等），运行时也无须有状态来参与。块所使用的整个内存区域，在编译期已经完全确定了，因此，全局块可以声明在全局内存里，而不需要在每次用到的时候于栈中创建。另外，全局块的拷贝操作是个空操作，因为全局块绝不可能为系统所回收。这种块实际上相当于单例。

~~~ objc
void (^block)() = ^{
    NSLog(@"This is a block");
};
~~~
此 block 所需的全部信息都能在编译期确定，所以可把它做成全局块。

### 要点
块可以分配在栈、堆或者全局上。分配在栈上的块可以拷贝到堆里，就和标准的 Objective-C 对象一样具备了引用计数。

## 第38条：为常用的块类型创建typedef
一开始我们定义 block 是这样的

~~~ objc
int (^variableName)(BOOL flag, int value) = ^(BOOL flag, int value) {
    return someInt;
};
~~~
这样做会有两个不友好的问题 

#### 不易读
如果我们提供的接口中有好几个 block ，每个 block 中又有好几个参数，这样会感觉比较难读。  
解决方法是给 block 类型定义一个别名  

~~~ objc
typedef int (^EOCSomeBlock)(BOOL flag, int value);

EOCSomeBlock block = ^(BOOL flag, int value) {
    return someInt;
};
~~~
这样使用起来就会简介很多。

#### 不易修改
当打算重构 block 的类型签名时，比方说，要给原来的 completion handler block 再加一个参数，如果没有使用别名的话，那么我们需要将所有使用了该 block 的地方都修改，这样显得过于繁杂。如果使用了别名的话，那么只需修改类型定义语句即可。

### 总结
当要在多个地方使用同种签名的 block 时，应该给该 block 定义一个别名，然后在需要的地方使用该别名定义 block 。

## 第39条：用 handler 块降低代码分散程度
程序在执行任务时，通常需要 “异步执行” ，这样做的好处在于：处理用户界面的显示及触摸操作所用的线程，不会因为要执行I/O或网络通信这类耗时的任务而阻塞。某些情况下，如果应用程序在一定时间内无响应，那么就会自动终止。“系统监控器”（system watchdog）在发现某个应用程序的主线程已经阻塞了一段时间之后，就会令其终止。  

通常有两种方式可以处理异步代码  

### delegate
使用 delegate 会使代码变得分散，当一个对象同时接收多个同种类型对象的委托时，还需要在委托方法中判断是哪个对象传来的委托。那么代码会变的更加复杂。delegate 一般用在一个委托对象有多个委托事件的情况下，比如：UITableView，其他情况可以使用 block 来实现。

### block
用 block 处理起来代码会变的更加清晰。block 可以令这种API变得更紧凑，同时也令开发者调用起来更加方便。

~~~ objc
- (void)vch_successWithComplete:(VCHAddNewDeviceComplete)complete failure:(VCHFailure)failure {
    [self vch_startWithComplete:^(id object) {
        // do something
        complete();
    } failure:^(NSString *error) {
        // do something
        failure(error);
    }];
}
~~~
这里我的处理方式是将成功和失败分开处理，也可以用一个 block 来处理两个两种情况，两种方法均有优劣。具体可多看看官方的做法。

### 总结
在创建对象时，可以使用内联的handler块将相关业务逻辑一并声明。使代码变得更加紧凑。  

## 第40条：用 block 引用其所属对象时不要出现引用循环
书中的例子比较长，我用项目中的一部分代码来替代，意思是一样的   

~~~ objc
self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
	[self queryFence];
}];
[self.tableView.mj_header beginRefreshing];
~~~
上面的代码会出现引用循环，self -> mj_header -> block -> self 。这个是初学时很容易犯的错误。这种情况下有两种比较常用的方法可以解决这个问题，一种就是用完 block 后，立即将其释放，另一种就是使用 __weak 关键字修饰某一环节。这里我使用第二种方法，代码如下  

~~~ objc
__weak typeof(self) weakSelf = self;
self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
	[weakSelf queryFence];
}];
[self.tableView.mj_header beginRefreshing];
~~~
此时 block 弱引用了 self ，这个循环也就被打破了。

### 总结
如果 block 所捕获的对象直接或间接的保留了 block 本身，那么就需要解除引用循环。