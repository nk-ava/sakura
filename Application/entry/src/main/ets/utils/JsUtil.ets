import { NonNull } from "../types"
import { cryptoFramework } from "@kit.CryptoArchitectureKit"
import buffer from "@ohos.buffer"

export function debounce(fn: Function, delay: number = 50, ...args: NonNull[]) {
  let timer = -1
  return () => {
    clearTimeout(timer)
    timer = setTimeout(() => [
      fn(...args)
    ], delay)
  }
}

export function throttle(fn: Function, delay: number = 50, ...args: NonNull[]) {
  let timer = -1
  return () => {
    if (timer !== -1) {
      return
    }
    timer = setTimeout(() => {
      fn(...args)
      timer = -1
    }, delay)
  }
}

export function md5(text: string) {
  const md = cryptoFramework.createMd("MD5");
  md.updateSync({ data: new Uint8Array(buffer.from(text, "utf-8").buffer) })
  return md.digestSync().data.join('')
}