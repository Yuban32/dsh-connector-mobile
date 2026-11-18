# DS Connector · HarmonyOS 手机端

DS Connector 手机端应用**独立仓库**（`dsh-connector-mobile`）：扫码/粘贴邀约入网、已配对设备管理。配套的桌面插件 `@dsh-connector` 在另一仓库（原 `ds-connector` 仓库的 `main` 分支），两端按 [architecture.md](architecture.md) §2 的协议契约互操作。

## 当前状态（2026-11-16）

- ✅ React Native on HarmonyOS 开发链路跑通（模拟器 x86_64 + Metro 热更新）
- ✅ Tab 导航骨架（首页/数据/设置，react-navigation v7）
- ⬜ 一期目标：扫码/粘贴入网闭环 + 已配对设备管理（协议契约见 [docs/architecture.md](docs/architecture.md) §2）
- 应用包名：`com.yuban32.dshconnector`

## 仓库结构（2026-11-18 起工程根 = 仓库根）

```
docs/architecture.md         # v1 设计：§2 协议契约（互操作权威）＋ ArkTS 历史方案（已切换 RN）
package.json / app.json /    # 应用工程根就在仓库根（React Native 0.84 + RNOH 0.84.3）
index.js / App.tsx
├── 开发环境启动教程.md       # ← 把环境跑起来，从这里开始（四份教程都在仓库根）
├── RN-HarmonyOS-入门教程.md  # 完整入门 + 踩坑全记录 + 排错决策树
├── 移动开发规范.md           # 写代码的约定（Vue 开发者视角）
├── 项目目录架构设计.md       # 工程结构、双包管理器、构建流水线、禁改清单
├── src/                     # JS 代码目录（screens / navigation / components …）
└── harmony/                 # 鸿蒙壳工程（DevEco 可独立打开构建）
```

## 技术要点（细节见各文档）

- **RNOH core/CLI 精确钉死 0.84.3**；三方库上游/移植版按 peer 配对钉版本，禁 `^` 漂移（入门教程 §6.9/§6.14）
- **Metro 端口固定 8098**（8081 常被 WinNAT 排除段吞掉，入门教程 §6.8）
- **双 ABI**：arm64-v8a（真机）+ x86_64（模拟器）
- **Git Bash 构建须大写盘符 cd 且与命令同链**（入门教程 §6.13）

## 快速启动

```bash
pnpm install
cd harmony && ohpm install --all && cd ..    # 先关 Metro 和 DevEco Studio
pnpm start                                   # 终端 A：Metro @8098
cd "J:/Development/HarmonyOS/dsh-connector-mobile" && pnpm run harmony   # 终端 B：构建+安装+启动
```

完整步骤（含模拟器创建、端口转发、依赖安装、排错速查）：**[开发环境启动教程.md](../开发环境启动教程.md)**。
