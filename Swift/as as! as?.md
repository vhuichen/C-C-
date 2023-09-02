# Swift as as! as? 的理解

目前公司项目中用到的 Swift 比较少，所以对 Swift 的理解也很局限。这里把一些放在笔记中的内容整理下分享出来。

## as
编译时检测,有两个意思   
1、指定文字表达类型   
2、upcast（向上转型，转换成其父类类型）

~~~ swift
//指定 1 的类型为 CGFloat 类型，既变量 num 为 CGFloat 类型
let num = 1 as CGFloat
//
class Animal {}
class Dog: Animal {}
let dog = Dog()
dog as Animal  //把 dog 转换为 Animal 类型，向上转型成功，编译器不会报错
//
let dog: Animal = Dog()
dog as Dog //编译错误，此时的变量 dog 在编译时是 Animal 类型，只能向上转换，无法向下转换。
~~~

## as! as? 
运行时检测，downcast（向下转型，转换成其子类类型）   
只不过前者是强制解包，解包失败就崩溃   
后者是可选类型   

~~~ swift
//下面代码编译时均不会报错，因为 as! 和 as? 都是运行时检查的
let a: Animal = Animal()
a as! Dog
1 as! Dog
1 as? Dog
~~~

~~~ swift
class Dog: Animal {
    var name = "Spot"
}

let dog: Animal = Dog()
let dog1 = dog as? Dog //可选值
let dog2 = dog as! Dog //强制解压

dog1?.name //可选调用
dog2.name //直接调用
~~~

## 总结
1、`as` 在编译时检测，`as!` `as?` 在运行时检测   
2、`as` 可以用来指定文字表达类型以及向上转型   
3、`as!` `as?` 用来向下转型，`as?` 转型后为可选值，`as!` 相当于在这个可选值上强制解压（可能会导致崩溃）