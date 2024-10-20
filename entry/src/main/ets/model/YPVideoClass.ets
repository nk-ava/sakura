@Observed
export default class YPVideoClass {
  id: number
  title: string
  alias?: string
  preview: string
  star: string
  area: string
  time: string
  badge: string

  constructor(id: number, title: string, preview: string, star: string, area: string, time: string, badge: string) {
    this.id = id
    this.title = title
    this.preview = preview
    this.star = star
    this.area = area
    this.time = time
    this.badge = badge
  }

  setAlias(alias: string) {
    this.alias = alias
  }
}