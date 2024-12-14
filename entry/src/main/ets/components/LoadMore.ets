@Builder
function defaultBuildParam() {
}

@Component
export default struct LoadMore {
  @Prop noMoreMsg: string = "我也是有底线的"
  @Prop ended: boolean = false
  @BuilderParam buildBottom: () => void = defaultBuildParam

  build() {
    Column() {
      Row() {
        if (this.ended) {
          Text(this.noMoreMsg)
        } else {
          Image($r("app.media.thumb_up"))
            .width(20)
            .aspectRatio(1)
          Text("正在加载")
        }
      }
      .justifyContent(FlexAlign.Center)
      .width("100%")
      .height(40)
      this.buildBottom()
    }
    .width("100%")
  }
}