/**
 * PermissionModule 的 C++ 侧包装（与 ArkTS 侧 modules/PermissionModule.ets 配套）。
 *
 * RNOH C-API 下 JS 调 ArkTS TurboModule 需要两侧同时注册：
 * - ArkTS 侧：PermissionPackage（modules/PermissionModule.ets），负责创建实例、实现方法；
 * - C++ 侧：本包，生成带方法表的 ArkTSTurboModule 子类（JS↔ArkTS 的桥）。
 *   methodMap_ 决定 JS 侧能调用哪些方法名（等价于 codegen 从 TS spec 生成的产物），
 *   缺它时 JS 报 "TypeError: undefined is not a function"。
 *
 * 承诺返回值（Promise）的方法用 ARK_ASYNC_METHOD_METADATA（走 callAsync），
 * 同步方法才用 ARK_METHOD_METADATA。
 */
#pragma once
#include <string>

#include "RNOH/Package.h"
#include "RNOH/ArkTSTurboModule.h"

namespace rnoh {

/** 手写的 "codegen spec"：只做方法名→调用器登记，实际逻辑在 ArkTS 侧 */
class PermissionModuleSpec : public ArkTSTurboModule {
public:
  PermissionModuleSpec(const ArkTSTurboModule::Context ctx,
                       const std::string name)
      : ArkTSTurboModule(ctx, name) {
    methodMap_ = {
        ARK_ASYNC_METHOD_METADATA(checkPermission, 1),
        ARK_ASYNC_METHOD_METADATA(requestPermission, 1),
    };
  }
};

class PermissionPackage : public Package {
public:
  PermissionPackage(Package::Context ctx) : Package(ctx) {}

  std::unique_ptr<TurboModuleFactoryDelegate>
  createTurboModuleFactoryDelegate() override {
    return std::make_unique<PermissionModuleFactoryDelegate>();
  }

private:
  class PermissionModuleFactoryDelegate : public TurboModuleFactoryDelegate {
  public:
    SharedTurboModule
    createTurboModule(Context ctx, const std::string& name) const override {
      if (name == "PermissionModule") {
        return std::make_shared<PermissionModuleSpec>(ctx, name);
      }
      return nullptr;
    }
  };
};

} // namespace rnoh
