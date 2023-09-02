---
title: 《Effective Objective-C 2.0》第七章阅读笔记(1)  
date: 2018-05-28  
tags: [Effective Objective-C 2.0]  
category: "iOS开发"  

---

# <center>第七章：系统框架(1)</center>

## 第47条：熟悉系统框架

#### Foundation
Foundation 框架中的类，使用 NS 这个前缀，此前缀是在 Objective-C 语言用作 NeXTSTEP 操作系统的编程语言时首度确定的。Foundation 框架是 Objective-C 应用程序的基础。Foundation 框架不仅提供了 collection 等基础核心功能，而且还提供了字符串处理这样的复杂功能。

#### CoreFoundation
CoreFoundation 框架不是 Objective-C 框架，但它却是 Objective-C 应用程序时所应熟悉的重要框架，Foundation 框架中的许多功能，都可以在此框架中找到对应的 C 语言 API。CoreFoundation 与 Foundation 名字相似、联系紧密。能做到“无缝桥接”，可以把 CoreFoundation 框架中的 C 语言数据结构平滑转换为 Foundation 中的 Objective-C 对象，也可以反向转换。比如：NSString 与 CFString 可以互转。

#### CFNetWork
此框架提供了 C 语言级别的网络通信能力，它将"BSD套接字"（BSD socket）抽象成易于使用的网络接口。而 Foundation 则将该框架里的部分内容封装为 Objective-C 语言的接口，以便于进行网络通信，例如可以用 NSURLConnection 从 URL 中下载数据。

#### CoreAudio
该框架所提供的 C 语言 API 可用来操作设备上的音频硬件。这个框架属于比较难用的那种，因为音频处理本身就很复杂。所幸由这套 API 可以抽象出另外一套 Objective-C 式的 API，用后者来处理音频问题会更简单些。

#### AVFoundation
此框架所提供的 Objective-C 对象可用来回放并录制音频及视频，比如能够在 UI 视图类里播放视频。

#### CoreData
此框架提供的 Objective-C 接口可以将对象放入数据库，便于持久保存。CoreData 会处理数据的获取及存储事宜，而且可以跨越 Mac OS X 及 iOS 平台。

#### CoreText
此框架提供的 C 语言接口可以高效执行文字排版及渲染操作。

#### UIKit
我们可能会编写使用 UI 框架的 Mac OS X 或 iOS 应用程序。这两个平台的核心 UI 框架分别叫做 Appkit 及 UIKit，它们都提供了构建在Foundation 与 CoreFoundation 之上的 Objective-C 类。框架里含有 UI 元素，也含有粘合机制，令开发者可将所有相关内容组装为应用程序。

#### CoreAnimation
CoreAnimation 是用 Objective-C 语言写成的，它提供了一些工具，而 UI 框架则用这些工具来渲染图形并播放动画。开发者编程时可能从来不会深入到这种级别，不过知道该该框架总是好的。CoreAnimation 本身并不是框架，它是 QuartzCore 框架的一部分。然而在框架的国度里，CoreAnimation 仍应算作“一等公民”(first-class citizen)。

#### CoreGraphics
CoreGraphics 框架以 C 语言写成，其中提供了 2D 渲染所必备的数据结构与函数。例如，其中定义了 CGPoint、CGSize、CGRect 等数据结构，而 UIKit 框架中 UIView 类在确定视图控件之间的相对位置时，这些数据结构都要用到。

### 总结
系统框架给我们提供了构建应用程序所需的核心功能。  
Objective-C 编程经常需要使用底层的 C 语言级 API。好处是可以绕过 Objective-C 运行期系统，从而提供执行速度。  
由于 ARC 只负责 Objective-C 对象，所以使用 C 语言级别的 API 时尤其要注意内存管理问题。

## 第48条：多用块枚举，少用 for 循环
在编程中经常需要列举 collection 中的元素，当前的 Objective-C 语言有很多种办法实现此功能，比较常用的有，标准 C 语言循环， Objective-C 2.0 的快速遍历，以及“块”循环。

### for 循环
~~~ objc
// Dictionary
NSArray *anArray = /*...*/;
for (int i = 0; i < anArray.count; i++) {
	id object = anArray[i];
	// Do something with 'object'
}

// NSDictionary
NSDictionary *aDictionary = /*...*/;
NSArray *keys = [aDictionary allKeys];
for (int i = 0; i < keys.count; i++) {
	id key = keys[i];
	id value = aDictionary[key];
	// Do something with 'key' and 'value'
}

// NSSet
NSSet *aSet = /*...*/;
NSArray *objects = [aSet allObjects];
for (int i = 0; i < objects.count; i++) {
	id object = objects[i];
	// Do something with 'object'
}
~~~
for 循环的缺点就是有时需要创建额外的对象才能完成遍历。  

在这里，字典与 set 都是"无序的"（ unordered ），所以无法根据特定的整数下标来直接访问其中的值。于是，就需要先获取字典里的所有键或是 set 里的所有对象，这两种情况下，都可以在获取到的有序数组上遍历，以便借此访问原字典及原 set 中得值。创建这个附加数组会有额外的开销，而且还会多创建一个数组对象，它会保留 collection 中得所有元素对象。

### 快速遍历
Objective-C 2.0 引入了快速遍历这一功能。快速遍历语法更简洁，它为 for 循环开设了 in 关键字。这个关键字大幅简化了遍历 collection 所需的语法。

~~~ objc
// NSArray
NSArray *anArray = /* ... */;
for (id object in anArray) {
	// Do something with 'object'
}

// NSDictionary 
NSDictionary *aDictionary = /* ... */; 
for (id key in aDictionary) { 
	id value = aDictionary[key]; 
	// Do something with 'key' and 'value' 
}

// NSSet
NSSet *aSet = /* ... */;
for (id object in aSet) {
	// Do something with 'object'
}
~~~
这种遍历方式简单且效率高，然而如果在遍历字典时需要同时获取键与值，那么会多出来一步。而且，与传统 for 循环不同，这种遍历方式无法轻松获取当前遍历操作所针对的下标。

### 基于块的遍历方式
在当前的 Objective-C 语言中，最新引入的一种做法就是基于块来遍历。NSArray、NSDictionary、NSSet 中定义了下面这个方法，可以实现最基本的遍历功能：  

~~~ objc
// NSArray
- (void)enumerateObjectsUsingBlock:(void(^)(id object, NSUInteger idx, BOOL *stop))block;
// NSDictionary
- (void)enumerateKeysAndObjectsUsingBlock:(void(^)(id key, id object, BOOL *stop))block;
// NSSet
- (void)enumerateObjectsUsingBlock:(void(^)(id object, BOOL *stop))block;
~~~
NSArray 对应的块有三个参数，分别是当前迭代所针对的对象、所针对的下标，以及指向布尔值的指针。前两个参数的含义不言而喻。而通过第三个参数所提供的机制，开发者可以终止遍历操作。其他两个类似。    
使用下面代码可以遍历数组   

~~~ objc
// NSArray
NSArray *anArray = /* ... */;
[anArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
	// Do something with 'object'
	if (shouldStop) {
		*stop = YES;
	}
}];

// NSDictionary
NSDictionary *aDictionary = /* ... */;
[aDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
	// Do something with 'key' and 'object'
	if (shouldStop) {
		*stop = YES;
	}
}];

// NSSet
NSSet *aSet = /* ... */;
[aSet enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
	// Do something with 'object'
	if (shouldStop) {
		*stop = YES;
	}
}];
~~~
遍历时可以直接从 block 里获取更多信息。在遍历数组时，可以知道当前所针对的下标。遍历有序 NSSet（NSOrderedSet）时也一样。而在遍历字典时，无须额外编码，即可同时获取键与值，因而省去了根据给定键来获取对应值这一步。用这种方式遍历字典，可以同时得知键与值，这很可能比其他方式快很多，因为在字典内部的数据结构中，键与值本来就是存储在一起的。同时，使用这种方法能够修改 block 的方法名，以免进行类型转换的操作，从效果上讲，相当于把本来需要执行的类型转换操作交给block方法签名来做。

用此方式也可以执行反向遍历。数组、字典、set都实现了前述方法的另一个版本，使开发者可向其传入“选项掩码”（option mask）：   

~~~ objc
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)options usingBlock:(void(^)(id obj, NSUInteger idx, BOOL *stop))block; 
- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)options usingBlock: (void(^)(id key, id obj, BOOL *stop))block;
~~~
NSEnumerationOptions 类型是个 enum，其各种取值可用“按位或”（bitwise OR）连接，用以表明遍历方式。

总体来看，block 枚举法拥有其他遍历方式都具备的优势，而且还能带来更多好处。与快速遍历法相比，它要多用一些代码，可是却能提供遍历时所针对的下标，在遍历字典时也能同时提供键与值，而且还有选项可以开启并发迭代功能。

## 第49条：对自定义其内存管理语义的 collection 使用无缝桥接
使用 “无缝桥接” 技术，可以在定义于 Foundation 框架中的 Objective-C 类和定义于 CoreFoundation 框架中 C 数据结构之间相互转换。   

下面代码演示了简单的无缝桥接：

~~~ objc
NSArray *anNSArray = @[@1,@2,@3,@4,@5];  
CFArrayRef aCFArray = (__bridge CFArrayRef)anNSArray;  
NSLog(@"size of array = %li",CFArrayGetCount(aCFArray));  
// Output：size of array = 5
~~~
转换操作中的 \_\_bridge 告诉 ARC 如何处理所涉及的 Objective-C 对象。\_\_bridge 本身的意思是：ARC 仍然具备这个 Objective-C 对象的所有权。而 \_\_bridge_retained 则与之相反，意味着 ARC 将交出对象的所有权。若是前面那段代码改用它来实现，那么用完数组之后就要加上CFRelease(aCFArray)以释放其内存。与之相似，反向转换可通过 __bridge_transfer 来实现。那么，为什么需要桥接呢？那是因为Foundation 框架中 Objective-C 类所具备的某些功能，是 CoreFoundation 框架中 C 数据结构所不具备的，反之亦然。