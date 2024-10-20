export default class CONSTANTS {
  // zkk79
  static readonly ZKK79_HOST = "https://www.zkk79.com"
  static readonly ZKK79_SEARCH_FORMAT = "/search/%s----------%d---.html"
  static readonly ZKK79_DETAIL_FORMAT = "/dongman/%d.html"
  static readonly ZKK79_PLAY_FORMAT = "/dongmanplay/%d-%d-%d.html"
  // yhdm
  static readonly YHDM60_HOST = "http://www.yhdm60.com"
  static readonly YHDM60_QUERY_FORMAT =
    `http://119.91.99.54:8811/ssszz.php/ssszz.php?q=%s&other_kkk217=${encodeURIComponent("http://www.yhdm60.com")}`
  static readonly YHDM60_DETAIL_FORMAT = CONSTANTS.YHDM60_HOST + "/acg/%d/"
  static readonly YHDM_PLAY_FORMAT = CONSTANTS.YHDM60_HOST + "/acg/3736/1116.html?qp=%s"
  static readonly YHDM_EPISODE_FORMAT = "http://v.58hda.com:8077/ne2/s%d.js"
}