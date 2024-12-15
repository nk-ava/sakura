export function debounce(fn: Function, delay: number = 50) {
  let timer = -1
  return () => {
    clearTimeout(timer)
    timer = setTimeout(() => [
      fn()
    ], delay)
  }
}

export function throttle(fn: Function, delay: number = 50) {
  let timer = -1
  return () => {
    if (timer !== -1) {
      return
    }
    timer = setTimeout(() => {
      fn()
      timer = -1
    }, delay)
  }
}