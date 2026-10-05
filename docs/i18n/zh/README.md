# Vidrado

**让桌面更安静，让思绪更清晰。**

Vidrado 是一款原生 macOS 菜单栏应用，可模糊并调暗后台窗口，同时让当前活动窗口保持清晰。它完全在你的 Mac 上运行，无需账户或订阅，也不会进行追踪或屏幕录制。

[下载](https://github.com/tonhadaplaces/vidrado/releases) · [报告问题](https://github.com/tonhadaplaces/vidrado/issues/new?template=bug_report.yml) · [参与贡献](../../../AGENTS.md)

**语言：** [English](../../../README.md) · [中文](../zh/README.md) · [हिन्दी](../hi/README.md) · [Español](../es/README.md) · [العربية](../ar/README.md) · [Français](../fr/README.md) · [বাংলা](../bn/README.md) · [Português](../pt/README.md) · [Bahasa Indonesia](../id/README.md) · [اردو](../ur/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md) · [Русский](../ru/README.md)

## 使用效果

![Vidrado 专注控制面板](../../../docs/screenshots/focus.png)

| 应用规则 | 偏好设置 |
| --- | --- |
| ![使用真实灰度图标的应用规则](../../../docs/screenshots/apps.png) | ![偏好设置和自动行为](../../../docs/screenshots/preferences.png) |

## 功能

- 实时模糊、调暗后台窗口，或同时应用两种效果；提供便捷的强度滑块，以及轻度、均衡和深度三个级别。
- 在应用和 Spaces 之间切换时，活动窗口始终保持清晰。
- 按应用设置规则：自动柔化后台窗口、让某个应用保持清晰，或在其处于活动状态时暂停专注效果。真实应用图标以灰度显示。
- 在所有显示器上或仅在当前活动显示器上应用专注效果；保留对齐的窗口和 Split View。
- 可选择在全屏、屏幕共享、持续捕获或显示器镜像期间暂停效果。
- 可自定义的全局快捷键、可选的摇动光标手势，以及登录时启动。
- 可保存的预设和本地偏好设置。
- 支持十三种界面语言。Vidrado 使用系统的首选语言；若该语言不受支持，则回退到英语。阿拉伯语和乌尔都语采用从右到左的布局。

## 安装

需要 **macOS 14 或更新版本**。从 [Releases](https://github.com/tonhadaplaces/vidrado/releases) 下载 DMG，打开后将 **Vidrado** 拖入 **Applications（应用程序）**。

当前分发版本使用 **ad hoc 签名**，且**未经 Apple 公证**。如果 macOS 阻止打开你从此仓库下载的 Vidrado 应用，请仅移除该应用的隔离属性：

```sh
xattr -dr com.apple.quarantine /Applications/Vidrado.app
```

然后重新打开 Vidrado。此命令不会对应用进行公证，也不会更改系统范围内的 Gatekeeper 设置。你也可以选择在本地构建。自动发布的 DMG 支持 **Apple silicon 和 Intel**。

## 使用

点击菜单栏中的重叠窗口图标，打开专注控制面板。**⌥⌘B** 可在任何位置切换专注效果。右键点击菜单栏图标，或按住 Option 点击该图标，也可以切换效果。

点击滑块按钮或按 **⌘,** 打开偏好设置。在**让部分应用保持清晰**中选择应用。其他效果滑块、预设和光标手势位于**更多选项**中。按 **⌘W** 关闭设置窗口；Vidrado 会继续在菜单栏中运行。**⌘Q** 可退出应用。

## 构建和测试

使用 Xcode 或 Command Line Tools，以及 Swift 5.9 或更新版本：

```sh
git clone git@github.com:tonhadaplaces/vidrado.git
cd vidrado
swift run Vidrado --settings
./scripts/build.sh
swift test
./scripts/test.sh
./scripts/package.sh
```

`build.sh` 构建并签名 `dist/Vidrado.app`。`package.sh` 生成 `dist/Vidrado.dmg` 及其 SHA-256 校验和。默认构建目标为当前 Mac 的架构。使用 `VIDRADO_UNIVERSAL=1 ./scripts/package.sh` 可构建同时支持 Apple silicon 和 Intel 的版本。

`swift test` 运行核心 XCTest 测试。完整测试脚本还会在 debug 和 release 配置下运行原生检查。这些检查需要未锁定的图形会话、一个普通的前台窗口，并且 Vidrado 必须已停止运行。GitHub CI 运行核心测试并验证应用构建；图形界面检查在本地运行。

参与贡献前，请阅读[仓库指南](../../../AGENTS.md)和[验证说明](../../../TESTING.md)。请通过拉取请求提交更改：`main` 要求至少一次批准、CI 通过，以及所有审查讨论均已解决。

## 自动发布

经过审查的更改合并到 `main` 后，在 `Resources/Info.plist` 中将 `CFBundleShortVersionString` 和 `CFBundleVersion` 更新为新版本，然后推送与之匹配的标签：

```sh
git switch main
git pull --ff-only origin main
git tag v1.0.0
git push origin v1.0.0
```

将 `1.0.0` 替换为要发布的版本号。GitHub Actions 会测试代码、构建通用应用、验证已签名的应用包和 DMG，并发布 DMG 及其 SHA-256 校验和。工作流会检查标签是否位于 `main` 上，并与应用版本匹配。无需付费 Apple Developer 凭据；发布版本仍受上述 ad hoc 签名限制。

## 隐私和技术限制

Vidrado 读取窗口元数据，并在活动窗口下方放置不可交互的覆盖层。macOS 合成器将效果应用于实时后台内容。它不会读取你的文档、捕获屏幕帧或通过网络发送数据，也不需要辅助功能权限。

模糊、裁剪、共享检测和 Spaces 元数据使用在运行时解析的私有 SkyLight 函数。这些函数的可用性可能随 macOS 更新而变化，因此该实现不适合 Mac App Store。平铺窗口检测基于几何信息。此效果仅改变视觉呈现，不能用来隐藏录制内容中的敏感信息。

## 许可证和致谢

[GNU AGPL-3.0](../../../LICENSE)。使用 Swift、SwiftUI 和 AppKit 构建；没有外部运行时依赖。Inter 根据 [SIL Open Font License](../../../Sources/VidradoCore/Resources/Brand/Inter-OFL.txt) 分发。Lucide 设计图标使用 ISC 许可证；请参阅[第三方声明](../../../THIRD_PARTY_NOTICES.md)。

灵感来自 [Defocus](https://defocus.me/)。Vidrado 是独立实现，未使用 Defocus 的源代码。界面源文件以 [`design.pen`](../../../design.pen) 的形式提交到仓库。
