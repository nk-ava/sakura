@Component
export default struct Loading {
  @Prop loading: boolean

  build() {
    if (this.loading) {
      Column() {
        Text("正在加载")
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor("rgba(255,255,255,0.8)")
      .width("100%")
      .height("100%")
      .position({
        top: 0,
        left: 0
      })
    }
  }
}