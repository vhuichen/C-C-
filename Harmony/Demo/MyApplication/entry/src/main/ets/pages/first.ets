@Entry
@Component
struct FirstDemo {
  @State message: string = 'Hello World';
  @State count: number = 0;

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(35)
          .fontWeight(FontWeight.Bold)
        Text(this.count.toString())
          .fontSize(35)
          .fontWeight(FontWeight.Bold)
        Button() {
          Text('点我+1')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 10
        })
        .onClick(() => {
          console.log("按钮被点击了！")
          this.count += 1
        })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%')
      }
      .width('100%')
    }
    .height('100%')

  }
}