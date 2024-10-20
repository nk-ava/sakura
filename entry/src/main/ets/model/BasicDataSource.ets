export default class BasicDataSource<T> implements IDataSource {
  protected originData: T[]
  private listeners: DataChangeListener[] = []

  constructor()

  constructor(data: T[])

  constructor(data?: T[]) {
    this.originData = data ?? []
  }

  get data() {
    return this.originData
  }

  set data(val: T[]) {
    this.originData = val
  }

  totalCount(): number {
    return this.originData.length
  }

  getData(index: number): T {
    return this.originData[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener)
    if (index >= 0) {
      this.listeners.splice(index, 1)
    }
  }

  dataIndexOf(value: T): number {
    return this.originData.indexOf(value)
  }

  // 通知数据改变
  notifyModify(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  notifyMove(from: number, to: number) {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }

  notifyReload() {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  notifyAdd(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  notifyRemove(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  // 定义数组修改方法
  pushData(value: T) {
    const index = this.originData.length
    this.originData.push(value)
    this.notifyAdd(index)
  }

  addData(index: number, value: T) {
    this.originData.splice(index, 0, value)
    this.notifyAdd(index)
  }

  popData() {
    const index = this.originData.length - 1
    this.originData.pop()
    this.notifyRemove(index)
  }

  removeData(index: number) {
    this.originData.splice(index, 1)
    this.notifyRemove(index)
  }

  modifyData(index: number, value: T) {
    this.originData.splice(index, 1, value)
    this.notifyModify(index)
  }

  swapData(from: number, to: number) {
    const temp: T = this.originData[from]
    this.originData[from] = this.originData[to]
    this.originData[to] = temp
    this.notifyMove(from, to)
  }

  reloadData() {
    this.notifyReload()
  }
}