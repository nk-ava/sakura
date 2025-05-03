import { AbilityConstant, errorManager, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, window } from '@kit.ArkUI';
import { AvoidRect } from '../types';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    errorManager.on("error", {
      onUnhandledException(errMsg) {
        hilog.error(0x0000, "unhandledException", errMsg)
      },
      onException(err: Error) {
        if (err.name === 'prompt') {
          promptAction.showToast({
            message: err.message
          })
        }
      }
    })
    errorManager.on("unhandledRejection", (err: Error) => {
      hilog.error(0x0000, "unhandledRejection", "%{public}s: %{public}s", err.message, err.stack)
    })
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      const mainWin = windowStage.getMainWindowSync()
      mainWin.setWindowLayoutFullScreen(true)
      const sysAvoid = mainWin.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      const navAvoid = mainWin.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      const topHeight = px2vp(sysAvoid.topRect.height || navAvoid.topRect.height)
      const bottomHeight = px2vp(sysAvoid.bottomRect.height || navAvoid.bottomRect.height)
      AppStorage.setOrCreate<AvoidRect>("rect", {
        topHeight,
        bottomHeight
      })
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
