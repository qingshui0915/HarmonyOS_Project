import { abilityAccessCtrl, common, Permissions } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
/**
 * 申请权限
 * @param permissions
 * @param context
 * @returns
 */
export function regPermissionsFromUser(permissions: Array<Permissions>,
  context: common.UIAbilityContext): Promise<number> {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  //requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
  return new Promise((resolve: (value: number) => void, reject: () => void) => {
    atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      let grantstatus: Array<number> = data.authResults;
      let length: number = grantstatus.length;
      for (let i = 0; i < length; i++) {
        if (grantstatus[i] = 0) {
          //用户授权，可以继续访问目标操作工
          console.log(`用户授权，可以继续访问目标操作`)
          resolve(1)
        } else {
          //用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
          console.log(`用户拒绝授权`)
          resolve(0)
          return;
        }
      }
      //授权成功
    }).catch((err: BusinessError) => {
      console.error(`failed to request permissions from user, Code is ${err.code}, message is ${err.message}`);
      resolve(-1)
    })
  })
}