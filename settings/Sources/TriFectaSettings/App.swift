//
//  TriFecta 设置窗口入口。
//
import SwiftUI
import AppKit

@main
struct TriFectaSettingsApp: App {
  @StateObject private var state = AppState()
  @StateObject private var themeManager = AppThemeManager()

  init() {
    // 包内 app（LSUIElement）：激活窗口到最前
    DispatchQueue.main.async {
      NSApp.activate(ignoringOtherApps: true)
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(state)
        .environmentObject(themeManager)
        .environment(\.appTheme, themeManager.theme)
        .tint(themeManager.theme.accent)
        .frame(minWidth: WindowMetrics.minWidth, minHeight: WindowMetrics.minHeight)
        .onAppear { state.reload() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
          if !state.isDirty {
            state.reload()
          }
        }
    }
    .windowStyle(.hiddenTitleBar)
    .defaultSize(width: 920, height: 640)   // 大屏友好：默认窗口更大
    // 可自由缩放：仅受 minWidth/minHeight 约束
    .commands {
      CommandGroup(replacing: .saveItem) {
        Button("保存并应用") { state.save() }
          .keyboardShortcut("s", modifiers: .command)
          .disabled(!state.isDirty)
      }
    }
  }
}
