import { NonNull } from "../types"

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