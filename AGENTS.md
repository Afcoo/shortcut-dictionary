# PROJECT KNOWLEDGE BASE

**Last Updated:** 2026-02-15

## OVERVIEW

macOS menubar-first SwiftUI dictionary app. Global shortcuts open a reusable `NSWindow` with `WKWebView`, copy selected text, and inject it into dictionary or chat services.

## STRUCTURE

```
shortcut-dictionary/
├── ShortcutDictionary/
│   ├── ApplicationDelegate.swift      # @main entry + NSApplicationDelegate lifecycle
│   ├── Managers/                      # Window/Shortcut/Menubar/WebDict singletons
│   ├── Views/                         # Dictionary, WebView wrapper, settings, sheets, toolbar
│   ├── Constants/                     # SettingKeys, default dict/chat services, notifications
│   ├── Extensions/                    # Color/background/context-menu helpers
│   ├── Assets.xcassets/
│   ├── Info.plist
│   └── ShortcutDictionary.entitlements
├── ShortcutDictionaryTests/           # Swift Testing (currently template-level)
├── ShortcutDictionaryUITests/         # XCTest UI tests (template-level)
├── en.lproj/, ko.lproj/               # Localized InfoPlist strings
├── ShortcutDictionary.xcodeproj/
└── AGENTS.md
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add or change settings key | `ShortcutDictionary/Constants/SettingKeys.swift` | Keep defaults in `defaultValue` and access via `@AppStorage` |
| Add dictionary provider | `ShortcutDictionary/Constants/DefaultWebDicts.swift` | Define `WebDict` + paste script/postScript |
| Add chat provider | `ShortcutDictionary/Constants/DefaultChatServices.swift` | Uses same `WebDict` model with mode=`chat` |
| Manage active dict/chat sets | `ShortcutDictionary/Managers/WebDictManager.swift` | Persists activated IDs and custom prompts |
| Global shortcut and copy flow | `ShortcutDictionary/Managers/ShortcutManager.swift` | KeyboardShortcuts + CGEvent copy + notifications |
| Window behavior and placement | `ShortcutDictionary/Managers/WindowManager.swift` | Reusable dict/settings/onboarding/about windows |
| Dictionary/chat UI switch | `ShortcutDictionary/Views/DictionaryView.swift` | Mode gate + toolbar variant + page sync |
| WKWebView injection/retry logic | `ShortcutDictionary/Views/WebDictView.swift` | Notification handlers + JS execution + retry |
| Settings tabs | `ShortcutDictionary/Views/SettingsView.swift` + `Views/Settings/*` | Sidebar-driven pages: general/shortcut/dictionary/chat/appearance/info |

## CODE MAP

| Symbol | Type | Role |
|--------|------|------|
| `AppDelegate` | `NSApplicationDelegate` | App lifecycle, onboarding gate, initial window launch |
| `WindowManager.shared` | Singleton | Dict/settings/onboarding/about window lifecycle + placement |
| `ShortcutManager.shared` | Singleton | Dict/chat shortcut registration, selected-text copy, mode switching |
| `MenubarManager.shared` | Singleton | Status item + app menu + quick mode/dict switching |
| `WebDictManager.shared` | Singleton + `ObservableObject` | Built-in/custom dicts, chat services, activation and prompt persistence |
| `SettingKeys` | Enum | Canonical settings key space + defaults |
| `WebDict` | Struct | Common model for dictionary/chat targets and script generation |
| `ChatPrompt` | Struct | Prompt wrappers for chat mode auto-input |
| `DictionaryView` | SwiftUI View | Top-level dictionary/chat container + toolbar selection |
| `WebDictView.Coordinator` | NSObject | Notification-driven text injection + key handling + retry backoff |

## CONVENTIONS

### Swift Style
- Korean-first user-facing text/comments
- Format Swift files with SwiftFormat using the repo config (`swiftformat . --config .swiftformat`) before finalizing changes.
- `@AppStorage(SettingKeys.xxx.rawValue)` for setting bindings
- Typed default extraction pattern: `SettingKeys.foo.defaultValue as! Bool/String/Double`
- Singleton pattern: `static var shared = ClassName()` (or `static let` in manager)
- Window and manager logic grouped with `extension` blocks by concern

### Commit Message Style
- Use a head-first subject line that starts with the purpose or conclusion.
- Write commit subjects and body bullets in Korean by default.
- Keep the commit body as bullet-only detail lines prefixed with `-` (no narrative sentences).
- For Korean body bullets, avoid endings like `-함`; use concise phrase endings instead.

### Architecture
- No Storyboard. SwiftUI + AppKit (`NSWindow`, `NSMenu`, `WKWebView`) hybrid.
- Notification-driven cross-component sync:
  - `.updateText` (`text`, `mode`) to inject copied text
  - `.reloadDict` (`mode`) to reload active web view
  - `.pageModeChanged` to switch dictionary/chat page mode
- Dictionary and chat share one `WebDict` pipeline; mode decides source/target set.

### Windowing/macOS Specifics
- Dict window is reusable (`isReleasedWhenClosed = false`) and chromeless.
- Mouse-relative placement supports 9 anchors + gap + in-screen clamping.
- Out-click close uses global monitor (`NSEvent.addGlobalMonitorForEvents`).
- Liquid Glass UI path (macOS 26+): `DictToolbarV2`, toolbar-attached window styling, extra content insets.

## SETTINGS KEY MATRIX

| Key | Type | Default | Primary Owner |
|-----|------|---------|---------------|
| `isGlobalShortcutEnabled` | Bool | `false` | `ShortcutSettingsView`, `ShortcutManager` |
| `isChatShortcutEnabled` | Bool | `false` | `ShortcutSettingsView`, `ShortcutManager` |
| `isCopyPasteEnabled` | Bool | `false` | `ShortcutSettingsView`, `ShortcutManager` |
| `isFastSearchEnabled` | Bool | `false` | `ShortcutSettingsView`, `WebDictView.Coordinator` |
| `isMenuItemEnabled` | Bool | `true` | `GeneralSettingsView`, `MenubarManager` |
| `isAlwaysOnTop` | Bool | `false` | `DictionarySettingsView`, `WindowManager` |
| `isToolbarEnabled` | Bool | `true` | `AppearanceSettingsView`, `DictionaryView` |
| `isEscToClose` | Bool | `true` | `DictionarySettingsView`, `WebDictView.Coordinator` |
| `isOutClickToClose` | Bool | `true` | `DictionarySettingsView`, `WindowManager` |
| `isShowOnMousePos` | Bool | `true` | `DictionarySettingsView`, `WindowManager` |
| `isShowOnScreenCenter` | Bool | `false` | `DictionarySettingsView`, `WindowManager` |
| `dictWindowCursorPlacement` | String | `center` | `DictionarySettingsView`, `WindowManager` |
| `dictWindowCursorGap` | Double | `12.0` | `DictionarySettingsView`, `WindowManager` |
| `isDictWindowKeepInScreen` | Bool | `true` | `DictionarySettingsView`, `WindowManager` |
| `backgroundColor` | String(hex) | `#FFFFFF` | `AppearanceSettingsView`, `WebDictView` |
| `backgroundDarkColor` | String(hex) | `#1E1E1E` | `AppearanceSettingsView`, `WebDictView` |
| `isBackgroundTransparent` | Bool | `true` | `AppearanceSettingsView`, background modifiers |
| `dictViewPadding` | Double | `0.0` (macOS 26+) / `8.0` | `AppearanceSettingsView`, `DictionaryView` |
| `isLiquidGlassEnabled` | Bool | `true` (macOS 26+) / `false` | `AppearanceSettingsView`, `DictionaryView`, `WindowManager` |
| `selectedDict` | String(id) | `daum_eng` | `DictionarySettingsView`, toolbar components |
| `selectedChat` | String(id) | `chatgpt` | `ChatSettingsView`, toolbar components |
| `selectedPageMode` | String | `dictionary` | `ShortcutManager`, `DictionaryView`, toolbars |
| `activatedDicts` | Data(JSON set ids) | empty | `WebDictManager`, `DictActivationSettingSheet` |
| `activatedChats` | Data(JSON set ids) | empty | `WebDictManager`, `DictActivationSettingSheet` |
| `customDictData` | Data(JSON) | empty | `WebDictManager`, `CustomDictSettingSheet` |
| `isChatEnabled` | Bool | `true` | `ChatSettingsView`, `DictionaryView`, `ShortcutManager` |
| `selectedChatPromptID` | String(id) | `none` | `ChatSettingsView`, `WebDictView.Coordinator` |
| `customChatPromptsData` | Data(JSON array) | empty | `WebDictManager`, `ChatSettingsView` |
| `isMobileView` | Bool | `true` | `DictionarySettingsView`, `WebDictView` |
| `hasCompletedOnboarding` | Bool | `false` | `OnboardingView`, `AppDelegate` |

## NOTIFICATION CONTRACT

| Notification | Sender | Required Payload | Consumers |
|--------------|--------|------------------|-----------|
| `.updateText` | `ShortcutManager` | `userInfo["text"] as String`, `userInfo["mode"] as String` | `WebDictView.Coordinator` |
| `.reloadDict` | Toolbar/Menubar/Settings | Optional `userInfo["mode"] as String` | `WebDictView.Coordinator` |
| `.pageModeChanged` | `ShortcutManager` | `object as String` (`"dictionary"` or `"chat"`) | `DictionaryView` |

- Keep key strings centralized in `NotificationUserInfoKey`.
- Prefer mode-scoped notifications to avoid cross-page side effects.

## ANTI-PATTERNS

- Do not create one-off `UserDefaults` keys outside `SettingKeys`.
- Do not bypass `WebDictManager` for activation/prompt persistence logic.
- Do not remove `context.coordinator.parent = self` in `WebDictView.updateNSView`.
- Do not block the main thread in clipboard polling/copy flow.
- Do not forget `isReleasedWhenClosed` policy for reusable windows.

## COMMANDS

```bash
# Build app
xcodebuild -project ShortcutDictionary.xcodeproj -scheme ShortcutDictionary -configuration Release build

# Run tests (unit + UI attached to app scheme)
xcodebuild -project ShortcutDictionary.xcodeproj -scheme ShortcutDictionary -destination 'platform=macOS' test

# Run only unit tests
xcodebuild -project ShortcutDictionary.xcodeproj -scheme ShortcutDictionary -destination 'platform=macOS' -only-testing:ShortcutDictionaryTests test

# Format Swift files
swiftformat . --config .swiftformat

# Open project in Xcode
open ShortcutDictionary.xcodeproj
```

## DEPENDENCIES

| Package | Purpose |
|---------|---------|
| [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) | Global shortcut registration and recorder UI |
| [LaunchAtLogin-Modern](https://github.com/sindresorhus/LaunchAtLogin-Modern) | Login item toggle in General settings |

## NOTES

- Accessibility permission is required for auto copy/paste flow (`CGEvent` copy command).
- App sandbox is enabled (`network.client`, `user-selected.read-only`).
- Deployment targets in project: App macOS 13.5+, unit/UI test targets macOS 15.0+.
- There is a known TODO for back/forward navigation controls in toolbar components.

## RELEASE CHECKLIST

- Build release: `xcodebuild -project ShortcutDictionary.xcodeproj -scheme ShortcutDictionary -configuration Release build`
- Run app tests: `xcodebuild -project ShortcutDictionary.xcodeproj -scheme ShortcutDictionary -destination 'platform=macOS' test`
- Verify Accessibility flow: shortcut trigger -> copy selected text -> auto paste in active web view
- Verify mode switching: dictionary/chat toggle from toolbar, shortcut, and menubar all stay in sync
- Verify window behavior: center/mouse placement, in-screen clamp, out-click close, ESC close
- Verify settings persistence: relaunch app and confirm selected dict/chat/prompt/theme/activation state
