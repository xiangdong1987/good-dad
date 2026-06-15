# 驾照灵动岛 · 开发落地说明（P1–P3 已实现）

> 本轮已写出可运行骨架：悬浮岛(药丸) → 一键截屏 → 复用 `italian-license` skill → 悬浮结果小卡片。
> **仅 Android**。代码在沙箱里无法 `flutter analyze`（无 SDK），需在你机器上 `pub get` + 真机验证。

## 跑起来三步

```bash
flutter pub get          # 拉 flutter_overlay_window
flutter run              # 真机（录屏/悬浮窗在模拟器上不稳，建议真机）
```

然后:设置 →「驾照灵动岛」→ 打开开关 → 依次授权「悬浮窗」「录屏」→ 切到任意驾考 App/网页 → 点右侧小药丸。

## 改了/加了哪些文件

**Flutter**
- `lib/core/screen_capture/screen_capture_service.dart` — MethodChannel(`good_dad/screen_capture`) 封装:requestProjection / isProjectionActive / captureOnce / stop
- `lib/features/license_island/island_controller.dart` — 主 isolate 大脑:权限/FGS 开关 + 监听 overlay 的截屏请求 → 截屏 → **复用 `ItalianLicenseRunner.run`** → 结果回传
- `lib/features/license_island/island_overlay.dart` — overlay isolate UI:药丸 / loading / 结果卡片 / 错误卡片(复用 `CreamCard`/`Sticker`/`CreamPill`/`CreamButton`)
- `lib/features/settings/island_section.dart` — 设置页开关区
- `lib/main.dart` — 加 `overlayMain` 入口 + 启动恢复 + 实例化主侧监听
- `lib/features/settings/settings_page.dart` — 插入「驾照灵动岛」section
- `pubspec.yaml` — 加 `flutter_overlay_window: ^0.4.5`

**Android(原生)**
- `android/app/src/main/kotlin/com/xdd/good/dad/screencap/ScreenCaptureService.kt` — 前台服务 + MediaProjection + ImageReader 抓一帧 → JPEG
- `android/app/src/main/kotlin/com/xdd/good/dad/MainActivity.kt` — MethodChannel + 录屏授权 `onActivityResult`
- `android/app/src/main/AndroidManifest.xml` — 加 `SYSTEM_ALERT_WINDOW` / `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_MEDIA_PROJECTION` + service 声明

**未改动(直接复用)**:`italian_license_runner/prompt/models`、`assets/skills/italian-license/SKILL.md`、`skill_runner`。

## 两个 isolate 怎么协作(关键)

`flutter_overlay_window` 的悬浮 UI 在**独立 isolate**,没有 Riverpod/DB/LLM。所以:
- overlay 只画 UI;点药丸时先把自己缩成 1×1 隐藏(不入镜),再 `shareData({action:capture})`。
- 主 isolate 收到 → 等 200ms → 原生 `captureOnce()` → 跑 skill → `shareData({action:result,data})`。
- overlay 收到 result → resize 成卡片渲染。
- 通信统一走 `shareData(jsonEncode(...))` + `overlayListener`(两端都能收发)。

## 上真机后大概率要微调的点

1. **`flutter_overlay_window` 版本/API**:本代码按 0.4.x 写(`showOverlay/resizeOverlay/overlayListener/shareData/isPermissionGranted`)。若 `pub get` 拉到别的大版本,核对这几个方法签名即可。
2. **overlay 尺寸**:`island_overlay.dart` 顶部 `_bubble/_loading/_card` 的宽高是逻辑像素,不同机型/DPI 可能要调。
3. **截屏隐藏时机**:overlay 隐藏(60ms)+ 主侧等待(200ms)两个延时,若截图里还带着小岛,把主侧延时调大。
4. **国产 ROM**:小米/华为等需手动允许「后台弹出界面/自启动」,否则悬浮窗可能不显示。
5. **录屏重授权**:进程被杀后 projection 丢失,代码已在下次截屏时自动重新弹授权框。

## 还没做(P4,按需再来)

进入动效(下滑 8px + 贴纸 scale)、深色模式适配、`skillRuns` 落库(目前灵动岛路径走的是主 isolate 的 runner,**会落库**;若想区分来源可加字段)、隐私政策补充截屏条款、设置里加「测试截屏」按钮。
