@Component
export default struct EmptyComponent {
  build() {
    Column() {
      Text("数据为空")
    }
    .width("100%")
    .height("100%")
  }
}