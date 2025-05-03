export default class CONSTANTS {
  // zkk79
  static readonly ZKK79_HOST = "https://www.zkk79.com"
  static readonly ZKK79_SEARCH_FORMAT = "/search/%s----------%d---.html"
  static readonly ZKK79_DETAIL_FORMAT = "/dongman/%d.html"
  static readonly ZKK79_PLAY_FORMAT = "/dongmanplay/%d-%d-%d.html"
  static readonly ZKK79_PAGESIZE = 10
  static readonly PROMPT_ACTION_TIPS: Record<string, string> = {
    '-10001': '网址解析出错',
    '-10002': '加入下载任务失败',
    '-10003': '下载失败'
  }
  static readonly EMPTY_FUNCTION = () => {
  }
}