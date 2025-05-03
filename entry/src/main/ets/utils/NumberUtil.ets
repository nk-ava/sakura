export function byte2MB(value: number, precision: number = 2) {
  return (value / 1024 / 1024).toFixed(precision)
}