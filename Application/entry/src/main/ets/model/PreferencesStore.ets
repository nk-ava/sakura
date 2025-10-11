import { preferences } from '@kit.ArkData'

export class PreferencesStore {
  private store: preferences.Preferences

  constructor(context: Context, name: string) {
    this.store = preferences.getPreferencesSync(context, {
      name: name
    })
  }

  get s(): preferences.Preferences {
    return this.store
  }

  getAllList<T>() {
    return this.s.getAll().then((all) => {
      return Object.values(all) as T[]
    })
  }

  getAllListSync<T>() {
    const obj = this.s.getAllSync();
    return Object.values(obj) as T[];
  }
}