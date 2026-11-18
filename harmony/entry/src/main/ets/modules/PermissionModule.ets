/**
 * 权限检测/申请 —— ArkTS 原生 TurboModule
 *
 * JS 侧封装见 src/services/permissions.ts，通过注册名 'PermissionModule' 查到本模块。
 * 使用前提：被检测的权限必须已在 harmony/entry/src/main/module.json5 的
 * requestPermissions 中声明——未声明的权限检测结果没有意义，申请会直接报错。
 */
import { RNOHPackage } from '@rnoh/react-native-openharmony';
import { AnyThreadTurboModule } from '@rnoh/react-native-openharmony/ts';
import type { AnyThreadTurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 用 AnyThreadTurboModule 而非 UITurboModule：本项目开启了 TurboModule worker
 * （EntryAbility.getRNOHWorkerScriptUrl），JS 跑在 worker 线程，worker 侧只查
 * AnyThread 工厂表，UI 线程的注册表它看不到。AnyThread 模块在 UI/worker 两种
 * 模式下都能被查到，且 ctx.uiAbilityContext 两种模式都有提供。
 */
export class PermissionModule extends AnyThreadTurboModule {
  public static readonly NAME = 'PermissionModule';

  constructor(ctx: AnyThreadTurboModuleContext) {
    super(ctx);
  }

  /**
   * 检测某个权限当前是否已被授予（纯查询，不弹任何窗）。
   * 安装时即授予的系统权限（如 INTERNET）恒为 true；
   * 用户权限（如定位、摄像头）取决于用户的授权状态。
   */
  public async checkPermission(permission: string): Promise<boolean> {
    const tokenId = this.getAccessTokenId();
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      // 本 SDK 中 checkAccessToken 声明为异步：Promise<GrantStatus>
      const status = await atManager.checkAccessToken(tokenId, permission as Permissions);
      return status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      return Promise.reject(new Error(
        `checkPermission('${permission}') failed: code=${e.code}, message=${e.message}`));
    }
  }

  /**
   * 检测并在未授予时向用户弹系统授权窗，返回最终是否已授予。
   * 用户拒绝时返回 false（此时应引导用户去系统设置手动开启）。
   */
  public async requestPermission(permission: string): Promise<boolean> {
    this.getAccessTokenId(); // 先自检；权限未在 module.json5 声明时下方调用会报错
    const atManager = abilityAccessCtrl.createAtManager();
    const permissionList: Array<Permissions> = [permission as Permissions];
    try {
      const result =
        await atManager.requestPermissionsFromUser(this.ctx.uiAbilityContext, permissionList);
      // authResults 里 0 表示该权限被授予，非 0 表示被拒绝
      const authResults = result.authResults;
      for (const authResult of authResults) {
        if (authResult !== 0) {
          return false;
        }
      }
      return true;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      return Promise.reject(new Error(
        `requestPermission('${permission}') failed: code=${e.code}, message=${e.message}`));
    }
  }

  /** 本应用的 accessTokenId（权限状态的载体），来自 bundleManager 同步查询 */
  private getAccessTokenId(): number {
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    const accessTokenId = bundleInfo.appInfo.accessTokenId;
    if (accessTokenId === undefined || accessTokenId === null) {
      throw new Error('PermissionModule: accessTokenId is unavailable');
    }
    return accessTokenId;
  }
}

/** 把 PermissionModule 注册进 RNOH（PackageProvider.ets 会用到） */
export class PermissionPackage extends RNOHPackage {
  override getAnyThreadTurboModuleFactoryByNameMap(): Map<string, (ctx: AnyThreadTurboModuleContext) => AnyThreadTurboModule | null> {
    return new Map<string, ((ctx: AnyThreadTurboModuleContext) => AnyThreadTurboModule)>()
      .set(PermissionModule.NAME, (ctx) => new PermissionModule(ctx));
  }
}
