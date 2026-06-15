# 驾照灵动岛 · 技术实现方案

> 目标:做一个**类似 siyou ops 的系统级悬浮岛**。学车刷题时(在第三方驾考 App / 网页里),点一下悬浮岛 → **自动截当前屏 → 喂给已有的 `italian-license` skill → 悬浮小卡片秒出答案讲解**,全程不离开当前 App。
>
> 本轮交付:**设计稿(`docs/design-system/dynamic-island-license.html`)+ 本方案**。代码待本方案确认后再写。
> 平台:**Android only**(iOS 系统不允许跨 App 截屏,本特性在 iOS 不做;iOS 仍走 app 内拍照/选图老路径)。

---

## 1. 一句话架构

```
悬浮岛(WindowManager overlay)
   └─tap→ 隐藏自己 → MediaProjection 截一帧 → JPEG bytes
            └─→ 复用 ItalianLicenseRunner.run(rawImageBytes, profile)
                     └─→ ItalianLicenseResult(已有结构化模型)
                              └─→ 悬浮结果小卡片渲染(V/F·中译·讲解·词汇·语法)
```

**关键复用点**:`lib/features/italian_license/italian_license_runner.dart` 里的
`ItalianLicenseRunner.run({rawImageBytes, profile, userText})` 已经把
「压缩图 → 跑 italian-license skill → 解析 JSON → 返回 `ItalianLicenseResult`」全包了。
灵动岛只需要**搞到截屏 bytes + FamilyProfile**,然后调它即可 —— skill 侧零改动。

---

## 2. Android 需要的三块原生能力

| 能力 | API / 方案 | 说明 |
|---|---|---|
| 悬浮窗(浮在别的 App 上) | `SYSTEM_ALERT_WINDOW` + `WindowManager` overlay(`TYPE_APPLICATION_OVERLAY`) | 推荐用 **`flutter_overlay_window`** 包,直接用 Flutter widget 画小岛/卡片,复用 cream 组件 |
| 截当前整屏 | `MediaProjection` + `VirtualDisplay` + `ImageReader` 抓一帧 → `Bitmap` → JPEG | **无可靠纯 Flutter 包,必须写 Kotlin** + `MethodChannel` |
| 后台常驻 | 前台服务 FGS,type=`mediaProjection` | Android 10+ 强制;持有 projection 让用户**整场只授权一次** |

### 权限(`android/app/src/main/AndroidManifest.xml` 新增)
```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION"/> <!-- Android 14+ -->
<!-- POST_NOTIFICATIONS 已存在(FGS 通知需要) -->
```
```xml
<service
  android:name=".screencap.ScreenCaptureService"
  android:exported="false"
  android:foregroundServiceType="mediaProjection"/>
```
> 包名 `com.xdd.good.dad` 已确认。

---

## 3. 数据 / 进程流(含双引擎注意点)

`flutter_overlay_window` 的悬浮 UI 跑在**独立 Flutter 引擎/isolate**,里面**没有** Riverpod providers、DB、LLM 配置。所以重活必须放主引擎(由 FGS 保活):

1. 用户在 good-dad 设置里开启灵动岛 → 申请悬浮窗权限 → 申请录屏(MediaProjection)授权 → 起 FGS → 小岛出现并常驻。
2. 用户在驾考 App 里点小岛(overlay isolate)。
3. overlay 通过 `flutter_overlay_window` 的消息通道发 `capture` 事件给主引擎。
4. **主引擎**:`ScreenCaptureService.captureOnce()`(MethodChannel)→ 拿 JPEG bytes → 取当前 `FamilyProfile` → 调 `ItalianLicenseRunner.run(...)` → 得 `ItalianLicenseResult`。
5. 主引擎把结果(`result.toJson()`)回传 overlay isolate → 渲染悬浮小卡片。
6. 卡片「📸 再看一题」重复第 3 步;「收起」回到药丸态。

> 备选(更省事但 UI 受限):小岛/卡片**全用原生 Kotlin View** 画,主引擎只管截屏+skill,通过 `EventChannel` 推状态。代价是放弃复用 cream Flutter 组件。**推荐优先 `flutter_overlay_window`**,与设计系统一致性更好。

---

## 4. 落地文件清单(预计新增/改动)

```
lib/features/license_island/
  island_controller.dart        # Riverpod:权限态、FGS 开关、capture 触发、结果流
  island_overlay_entry.dart     # @pragma('vm:entry-point') overlayMain(); 画药丸+卡片
  island_widgets.dart           # FloatingBubble / CaptureBadge / ResultMiniCard(复用 CreamCard/Sticker/StatusTag)
lib/core/screen_capture/
  screen_capture_service.dart    # MethodChannel('good_dad/screen_capture') 封装:requestPermission / startFgs / captureOnce / stop
lib/features/settings/
  island_section.dart            # 设置页:开关 + 两步授权引导(对应设计稿①)

android/app/src/main/kotlin/com/xdd/good/dad/screencap/
  ScreenCaptureService.kt        # FGS + MediaProjection + VirtualDisplay + ImageReader 抓帧
  ScreenCapturePlugin.kt         # MethodChannel 注册、把 Activity result(consent intent)接回
MainActivity.kt                  # 注册 channel、转发 onActivityResult

android/app/src/main/AndroidManifest.xml   # 加权限 + service
docs/privacy-policy.md           # 补充"截屏数据"条款
```

复用、不动:`italian_license_runner.dart` / `italian_license_prompt.dart` / `italian_license_models.dart` / `assets/skills/italian-license/SKILL.md` / `skill_runner.dart`。

---

## 5. 分阶段计划

| Phase | 内容 | 验收 |
|---|---|---|
| **P0 ✅ 本轮** | 设计稿 + 本方案 | 你确认视觉与架构 |
| **P1 权限与外壳** | 设置开关 + 悬浮窗授权流 + 录屏授权流 + FGS 起停 + 小岛药丸出现(不截屏) | 小岛能浮在别的 App 上、可拖动、可关 |
| **P2 截屏打通** | Kotlin MediaProjection 抓一帧 → bytes → 接 `ItalianLicenseRunner` → 打日志/Toast 出 `ItalianLicenseResult` | 点小岛能在 log 看到正确解析的题目答案 |
| **P3 结果卡片** | 悬浮小卡片 UI(设计稿④)渲染结果;截屏前隐藏小岛;卡片可拖/可收;「再看一题」 | 端到端:点一下 → 卡片秒出答案 |
| **P4 打磨** | 错误态(看不清/网络/未授权)、loading、深色模式、进入动效(下滑 8px + scale 0.8→1.05→1)、国产 ROM 自启动引导、隐私政策更新 | 体验顺、异常不崩、合规 |

---

## 6. 必须注意的坑

1. **截图别把小岛拍进去**:`captureOnce` 前先把 overlay 全部 `INVISIBLE`,延迟 ~80ms 再抓帧,抓完恢复。否则答案图里会有小岛。
2. **MediaProjection 授权频率**:Android 14 起每次新建 projection 都要弹系统框;持有 projection 在 FGS 里**整场复用**,做到"开一次岛、授权一次、随便点"。App 被杀/重启需重授。
3. **FGS 常驻通知**:Android 强制,文案走 cream voice,例如「驾照小岛待命中,点一下看题」。
4. **双引擎无状态**:overlay isolate 不能直接读 DB/LLM 配置,所有 skill 调用放主引擎,结果序列化回传(用 `result.toJson()`)。
5. **LLM 视觉延迟**:vision 调用要几秒,卡片必须有 loading;失败回 `format=unknown` 文案「这张我不太确定是不是驾考题,换一张?」(SKILL.md 已定义)。
6. **隐私**:截屏=敏感数据,只在**用户点击时**截、只截一张、明确"看题中"指示、只发给已配置的 LLM;需更新隐私政策。
7. **国产 ROM**:小米/华为/OPPO 对悬浮窗 + 后台有额外限制,P4 提供"允许自启动/后台弹窗"引导。
8. **iOS**:本特性不在 iOS 提供(系统限制);iOS 维持 app 内拍照/选图进入 `italian_license_page`。

---

## 7. 待你拍板的两个小点

1. **悬浮 UI 技术选型**:`flutter_overlay_window`(能复用 cream 组件,推荐)vs 纯原生 Kotlin View(更稳但要重画 UI)。默认按推荐走。
2. **小岛触发**:单击即截(默认)?还是长按截、单击展开菜单(截图/收起/关闭)?默认单击即截、长按拖动、右滑收起。
