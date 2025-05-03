export function srcNameFromUrl(url: string) {
  const srcName = url.match(/\/([^\/\.]*)\.?[^\/]*$/)
  return srcName?.[1] || `url_src_name_${Date.now()}`
}