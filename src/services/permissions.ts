/**
 * 权限检测/申请 —— JS 侧封装
 *
 * 原生实现在 harmony/entry/src/main/ets/modules/PermissionModule.ets
 * （ArkTS TurboModule，注册名 'PermissionModule'）。
 * 类比 Vue：services ≈ 封装浏览器/原生 API 的组合层，界面只 import 这里，
 * 不直接接触原生模块。
 *
 * 注意：要检测的权限必须先在 harmony/entry/src/main/module.json5 的
 * requestPermissions 里声明，否则检测永远返回 false、申请会直接报错。
 */
import { TurboModuleRegistry } from 'react-native';
import type { TurboModule } from 'react-native';

/** 与 ArkTS 侧 PermissionModule 的方法一一对应（名字必须完全一致） */
interface PermissionModuleSpec extends TurboModule {
  checkPermission(permission: string): Promise<boolean>;
  requestPermission(permission: string): Promise<boolean>;
}

const native = TurboModuleRegistry.getEnforcing<PermissionModuleSpec>('PermissionModule');

/**
 * 检测权限是否已授予（不弹窗）。
 * 例：await checkPermission('ohos.permission.INTERNET')
 */
export function checkPermission(permission: string): Promise<boolean> {
  return native.checkPermission(permission);
}

/** 检测并在未授予时向用户弹系统授权窗，返回最终是否已授予 */
export function requestPermission(permission: string): Promise<boolean> {
  return native.requestPermission(permission);
}
