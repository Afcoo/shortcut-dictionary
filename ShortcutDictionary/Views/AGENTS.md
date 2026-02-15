# Views Knowledge Base

**Last Updated:** 2026-02-15

## OVERVIEW

SwiftUI views + WKWebView wrapper. Settings tabs in `Settings/`, reusable sheets in `Sheets/`, toolbar components in `Components/`.

## STRUCTURE

```
Views/
├── DictionaryView.swift      # Main dict container (WebDictView + toolbar)
├── WebDictView.swift         # WKWebView NSViewRepresentable + Coordinator
├── SettingsView.swift        # NavigationSplitView root for settings
├── OnboardingView.swift      # First-launch flow
├── Settings/                 # general/shortcut/dictionary/chat/appearance/info pages
├── Sheets/                   # DictActivation, CustomDict, License
└── Components/               # DictToolbar, DictToolbarV2, ToolbarButton
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add settings page | `Settings/*.swift` + `SettingsPage` enum in `SettingsView.swift` | Register title/icon + switch case |
| Add dict/chat activation UI | `Sheets/DictActivationSettingSheet.swift` | Mode-based toggle (`dictionary`/`chat`) |
| Add custom dict form field | `Sheets/CustomDictSettingSheet.swift` | Persist via `WebDictManager.saveCustomDict` |
| Toolbar behavior changes | `Components/DictToolbar.swift`, `Components/DictToolbarV2.swift` | Keep mode sync + context menu behavior |
| Page mode rendering logic | `DictionaryView.swift` | Dual web containers + visibility gate |
| Web script injection/reload | `WebDictView.Coordinator` | `.updateText`/`.reloadDict` handlers |

## CONVENTIONS

### SwiftUI Patterns
- `@AppStorage(SettingKeys.foo.rawValue)` for settings binding
- `.id([deps])` to force view refresh on dependency change
- View modifiers as extensions: `.setViewColoredBackground()`, `.setDictViewContextMenu()`
- Mode-safe rendering: keep dictionary/chat views mounted, switch with opacity + hit testing

### WebDictView Coordinator
- `WKScriptMessageHandler` for JS→Swift: ESC key closes window
- `WKNavigationDelegate` for load errors with exponential backoff retry
- NotificationCenter observers: `.updateText`, `.reloadDict`
- Use mode filtering on notifications to avoid cross-page script injection
- Keep pending text until first successful `didFinish` if window opened before load complete

### Liquid Glass (macOS 26+)
- `DictToolbarV2` for glass toolbar style
- `DictToolbar` for pre-Tahoe fallback
- Check: `if #available(macOS 26.0, *), isLiquidGlassEnabled`
- Inset alignment with web content: `WKWebView.obscuredContentInsets.top = 52`

## INTERACTIONS

| Flow | Producer | Consumer |
|------|----------|----------|
| Shortcut mode change | `ShortcutManager` (`.pageModeChanged`) | `DictionaryView` updates `selectedPageMode` |
| Text injection | `ShortcutManager` (`.updateText`) | `WebDictView.Coordinator` executes per-site script |
| Reload request | Toolbar/Menubar/Settings (`.reloadDict`) | `WebDictView.Coordinator` reloads current mode page |

## TESTING NOTES

- Current test targets are template-level and do not cover view flows.
- For view changes, perform manual smoke checks: mode switch, reload, popup sheets, onboarding progression.

## ANTI-PATTERNS

- Do not reintroduce removed legacy files (for example `DummyView.swift`).
- Do not remove `context.coordinator.parent = self` in `updateNSView`.
- Do not bypass mode checks in notification handlers.
- Do not disable activation guard that ensures at least one dict/chat stays active.
