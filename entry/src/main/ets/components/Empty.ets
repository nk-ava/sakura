@Component
export default struct Empty {
  @Prop visible: boolean = false

  build() {
    if (this.visible) {
      Column() {
        Text("内容为空")
      }
      .justifyContent(FlexAlign.Center)
      .width("100%")
      .height("100%")
      .position({
        top: 0,
        left: 0
      })
    }
  }
}