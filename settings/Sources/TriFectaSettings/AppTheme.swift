//
//  设置窗口主题：预设 + 可选覆盖色（ARGB），跟随系统明暗。
//
import SwiftUI
import AppKit

// MARK: - 主题（纯渲染值）

struct AppTheme: Equatable {
  var accent: Color
  var canvas: Color   // 窗口背景
  var card: Color     // 卡片背景
  var label: Color    // 主文字
  var secondaryLabel: Color
  var isDark: Bool
}

// MARK: - 预设

enum NamedTheme: String, Codable, CaseIterable, Identifiable {
  case native, paper, enterpriseGreen
  var id: String { rawValue }
  var title: String {
    switch self {
    case .native: return "原生"
    case .paper: return "暖纸"
    case .enterpriseGreen: return "企业绿"
    }
  }
}

extension AppTheme {
  static func named(_ theme: NamedTheme, dark: Bool) -> AppTheme {
    switch (theme, dark) {
    case (.native, false):
      return AppTheme(accent: .hex(0xFF007AFF), canvas: .hex(0xFFF2F2F4), card: .hex(0xFFFFFFFF),
                      label: .hex(0xFF1C1C1E), secondaryLabel: .hex(0xFF8A8A8E), isDark: false)
    case (.native, true):
      return AppTheme(accent: .hex(0xFF0A84FF), canvas: .hex(0xFF1E1E20), card: .hex(0xFF2A2A2C),
                      label: .hex(0xFFF2F2F4), secondaryLabel: .hex(0xFF8E8E93), isDark: true)
    case (.paper, false):
      return AppTheme(accent: .hex(0xFFB56B3B), canvas: .hex(0xFFFBF7EF), card: .hex(0xFFFFFDF8),
                      label: .hex(0xFF2E2B23), secondaryLabel: .hex(0xFF8A8272), isDark: false)
    case (.paper, true):
      return AppTheme(accent: .hex(0xFFE49886), canvas: .hex(0xFF201C19), card: .hex(0xFF2A2522),
                      label: .hex(0xFFF7EFE5), secondaryLabel: .hex(0xFFB0A599), isDark: true)
    case (.enterpriseGreen, false):
      return AppTheme(accent: .hex(0xFF07C160), canvas: .hex(0xFFFFFFFF), card: .hex(0xFFF1F9F4),
                      label: .hex(0xFF16301F), secondaryLabel: .hex(0xFF6E7F78), isDark: false)
    case (.enterpriseGreen, true):
      return AppTheme(accent: .hex(0xFF2BC38A), canvas: .hex(0xFF101714), card: .hex(0xFF17221D),
                      label: .hex(0xFFE5F4EB), secondaryLabel: .hex(0xFF8FA69A), isDark: true)
    }
  }

  /// 合成主题：预设为基底，覆盖色逐项替换（非法/缺失一律回退基底色）
  static func composed(named theme: NamedTheme, dark: Bool,
                       accentHex: String?, canvasHex: String?, labelHex: String?) -> AppTheme {
    let base = AppTheme.named(theme, dark: dark)
    let accent = Color.rgba(accentHex) ?? base.accent
    let canvas = Color.rgba(canvasHex) ?? base.canvas
    let label = Color.rgba(labelHex) ?? base.label
    let isDark = Color.rgba(canvasHex).map { $0.luminance < 0.5 } ?? dark
    return AppTheme(accent: accent,
                    canvas: canvas,
                    card: AppTheme.cardTint(for: canvas, dark: isDark),
                    label: label,
                    secondaryLabel: label.opacity(0.6),
                    isDark: isDark)
  }

  private static func cardTint(for canvas: Color, dark: Bool) -> Color {
    if dark {
      return canvas.blend(toward: .hex(0xFF2A2A2A), amount: 0.35)
    } else {
      return canvas.blend(toward: .hex(0xFFFFFFFF), amount: 0.55)
    }
  }
}

extension Color {
  /// 0xAARRGGBB（界面直观 ARGB 顺序；与 Rime 配置的 0xAABBGGRR 无关）
  static func rgba(_ value: UInt32) -> Color {
    let a = CGFloat((value >> 24) & 0xFF) / 255
    let r = CGFloat((value >> 16) & 0xFF) / 255
    let g = CGFloat((value >> 8) & 0xFF) / 255
    let b = CGFloat(value & 0xFF) / 255
    return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
  }

  /// 0x00000000AARRGGBB 的 8 位小写十六进制（界面存储用）
  var argbHex: UInt32 {
    let ns = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
    let a = UInt32((ns.alphaComponent * 255).rounded()) & 0xFF
    let r = UInt32((ns.redComponent * 255).rounded()) & 0xFF
    let g = UInt32((ns.greenComponent * 255).rounded()) & 0xFF
    let b = UInt32((ns.blueComponent * 255).rounded()) & 0xFF
    return (a << 24) | (r << 16) | (g << 8) | b
  }

  /// hex 字符串（8 位 ARGB）→ 颜色；解析失败返回 nil
  static func rgba(_ hex: String?) -> Color? {
    guard let hex = hex, let value = UInt32(hex, radix: 16) else { return nil }
    return Color.rgba(value)
  }
}

private extension Color {
  static func hex(_ value: UInt32) -> Color {
    Color.rgba(value)
  }

  func blend(toward other: Color, amount: CGFloat) -> Color {
    let a = NSColor(self).usingColorSpace(.deviceRGB) ?? .white
    let b = NSColor(other).usingColorSpace(.deviceRGB) ?? .white
    let mix: (CGFloat, CGFloat) -> CGFloat = { $0 + ($1 - $0) * amount }
    return Color(red: mix(a.redComponent, b.redComponent),
                 green: mix(a.greenComponent, b.greenComponent),
                 blue: mix(a.blueComponent, b.blueComponent),
                 opacity: mix(a.alphaComponent, b.alphaComponent))
  }
}

// MARK: - 环境注入

private struct AppThemeKey: EnvironmentKey {
  static let defaultValue = AppTheme.named(.native, dark: false)
}

extension EnvironmentValues {
  var appTheme: AppTheme {
    get { self[AppThemeKey.self] }
    set { self[AppThemeKey.self] = newValue }
  }
}

// MARK: - 明暗模式

enum UiThemeMode: String, Codable, CaseIterable, Identifiable {
  case system, light, dark
  var id: String { rawValue }
  var title: String {
    switch self {
    case .system: return "跟随系统"
    case .light: return "浅色"
    case .dark: return "深色"
    }
  }
}

// MARK: - 状态（值类型 Palette）

/// 一套明暗模式下的主题状态：预设 + 可选覆盖色（nil = 跟随预设）
struct ThemePalette: Equatable, Codable {
  var named: NamedTheme = .native
  var accentHex: String?
  var canvasHex: String?
  var labelHex: String?

  mutating func adoptPreset(_ theme: NamedTheme) {
    named = theme
    accentHex = nil
    canvasHex = nil
    labelHex = nil
  }
}

final class AppThemeManager: ObservableObject {
  @Published private(set) var mode: UiThemeMode
  @Published private(set) var light: ThemePalette
  @Published private(set) var dark: ThemePalette

  private let defaults = UserDefaults.standard

  init() {
    mode = UiThemeMode(rawValue: defaults.string(forKey: "ui.mode") ?? "") ?? .system
    light = Self.load("ui.light") ?? ThemePalette(named: .native)
    dark = Self.load("ui.dark") ?? ThemePalette(named: .native)
  }

  // MARK: 查询

  var effectiveDark: Bool {
    switch mode {
    case .light: return false
    case .dark: return true
    case .system:
      return NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }
  }

  /// 当前生效的调色板（跟随 UI 呈现的明暗）
  var palette: ThemePalette {
    effectiveDark ? dark : light
  }

  /// 当前主题（渲染用）
  var theme: AppTheme {
    let p = palette
    return AppTheme.composed(named: p.named, dark: effectiveDark,
                             accentHex: p.accentHex, canvasHex: p.canvasHex, labelHex: p.labelHex)
  }

  // MARK: 修改（单点提交，自动持久化 + 刷新）

  enum ColorSlot {
    case accent, canvas, label
  }

  /// 修改当前模式调色板的某一块颜色（hex 字符串直接存取）
  func set(slot: ColorSlot, hex: String?) {
    commit { palette in
      switch slot {
      case .accent: palette.accentHex = hex
      case .canvas: palette.canvasHex = hex
      case .label: palette.labelHex = hex
      }
    }
  }

  /// 切换预设（顺带清空当前模式的自定义覆盖色）
  func setPreset(_ theme: NamedTheme) {
    commit { $0.adoptPreset(theme) }
  }

  func setMode(_ newMode: UiThemeMode) {
    mode = newMode
    defaults.set(newMode.rawValue, forKey: "ui.mode")
    objectWillChange.send()
  }

  // MARK: 内部

  private func commit(_ mutate: (inout ThemePalette) -> Void) {
    if effectiveDark {
      var p = dark
      mutate(&p)
      dark = p
      Self.save(p, "ui.dark")
    } else {
      var p = light
      mutate(&p)
      light = p
      Self.save(p, "ui.light")
    }
    objectWillChange.send()
  }

  private static func save(_ palette: ThemePalette, _ key: String) {
    let data = try? JSONEncoder().encode(palette)
    UserDefaults.standard.set(data, forKey: key)
  }

  private static func load(_ key: String) -> ThemePalette? {
    guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
    return try? JSONDecoder().decode(ThemePalette.self, from: data)
  }
}

// MARK: - 颜色工具

extension Color {
  var luminance: CGFloat {
    let ns = NSColor(self).usingColorSpace(.deviceRGB) ?? NSColor(self)
    return 0.2126 * ns.redComponent + 0.7152 * ns.greenComponent + 0.0722 * ns.blueComponent
  }
}
