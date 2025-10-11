@Builder
export function buildSettingView() {
  SettingView()
}

@Component
export default struct SettingView {
  build() {
    Column() {
      ForEach(Array.from("this is setting menu test"), (item: string, index) => {
        Text(item)
          .fontSize(20)
          .width("100%")
          .padding(20)
      })
    }
  }
}