@Observed
export default class ZPVideoClass {
  id: number
  title: string
  alias: string
  preview: string
  type: string
  category: string
  area: string
  time: string
  summary: string
  badge: string

  constructor(id: number, title: string, alias: string, preview: string, type: string, category: string, area: string,
    time: string, summary: string, badge: string) {
    this.id = id;
    this.title = title;
    this.alias = alias;
    this.preview = preview;
    this.type = type;
    this.category = category;
    this.area = area;
    this.time = time;
    this.summary = summary;
    this.badge = badge;
  }
}