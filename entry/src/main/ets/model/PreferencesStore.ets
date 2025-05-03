import { preferences } from '@kit.ArkData'

const preferenceMap = new Map<string, PreferencesStore>()

export function getPreferences(context: Context, name: string): PreferencesStore {
  if (!preferenceMap.has(name)) {
    const instance = new PreferencesStore(context, name)
    preferenceMap.set(name, instance)
    return instance
  }
  return preferenceMap.get(name)!
}

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
}