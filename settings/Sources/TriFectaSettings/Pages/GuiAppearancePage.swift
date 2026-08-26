//
//  界面：设置窗口自身外观（与输入法外观分离）。
//
import SwiftUI

struct GuiAppearancePage: View {
  @EnvironmentObject private var themeManager: AppThemeManager
  @Environment(\.appTheme) private var theme

  var body: some View {
    PageScroll(title: "界面",
               subtitle: "本窗口的配色样式",
               footer: "只对本窗口生效，不影响输入法。") {
      SettingCard {
        HStack(spacing: 10) {
          ForEach(UiThemeMode.allCases) { m in
            modeCard(m)
          }
        }
        .padding(12)
      }

      SettingCard {
        SettingRow("主题预设", subtitle: "当前为\(themeManager.effectiveDark ? "深色" : "浅色")主题", divider: false) {
          GlassPopupPicker(
            options: NamedTheme.allCases,
            titleOf: { $0.title },
            selection: Binding(
              get: { themeManager.palette.named },
              set: { themeManager.setPreset($0) }
            ),
            width: 150
          )
          .frame(width: 150)
        }
      }

      SettingCard {
        SettingRow("强调色") {
          colorWell(slot: .accent, fallback: theme.accent)
        }
        SettingRow("背景") {
          colorWell(slot: .canvas, fallback: theme.canvas)
        }
        SettingRow("前景", divider: false) {
          colorWell(slot: .label, fallback: theme.label)
        }
      }
    }
  }

  private func colorWell(slot: AppThemeManager.ColorSlot, fallback: Color) -> some View {
    let palette = themeManager.palette
    let hex: String? = {
      switch slot {
      case .accent: return palette.accentHex
      case .canvas: return palette.canvasHex
      case .label: return palette.labelHex
      }
    }()
    return ColorPicker("", selection: Binding(
      get: { Color.rgba(hex) ?? fallback },
      set: { themeManager.set(slot: slot, hex: String($0.argbHex, radix: 16)) }
    ))
    .labelsHidden()
    .frame(width: 130)
    .fixedSize()
  }

  /// 模式预览卡（系统 / 浅色 / 深色；用当前预设配色绘制并带强调色色点）
  private func modeCard(_ m: UiThemeMode) -> some View {
    let selected = themeManager.mode == m
    let named = themeManager.palette.named
    let light = AppTheme.named(named, dark: false)
    let dark = AppTheme.named(named, dark: true)
    let previews: [(canvas: Color, card: Color, label: Color, accent: Color)] = {
      switch m {
      case .system: return [(light.canvas, light.card, light.label, light.accent),
                            (dark.canvas, dark.card, dark.label, dark.accent)]
      case .light: return [(light.canvas, light.card, light.label, light.accent)]
      case .dark: return [(dark.canvas, dark.card, dark.label, dark.accent)]
      }
    }()
    return Button {
      themeManager.setMode(m)
    } label: {
      VStack(spacing: 6) {
        HStack(spacing: 4) {
          ForEach(Array(previews.enumerated()), id: \.offset) { _, p in
            RoundedRectangle(cornerRadius: 6, style: .continuous)
              .fill(p.canvas)
              .overlay(
                VStack(alignment: .leading, spacing: 4) {
                  HStack(spacing: 3) {
                    Circle().fill(p.accent).frame(width: 6, height: 6)
                    Capsule().fill(p.label.opacity(0.85)).frame(width: 28, height: 5)
                  }
                  Capsule().fill(p.label.opacity(0.4)).frame(width: 24, height: 4)
                }
                .padding(6)
                , alignment: .topLeading)
              .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                  .stroke(p.label.opacity(0.12), lineWidth: 1)
              )
              .frame(height: 64)
          }
        }
        Text(m.title)
          .font(.system(size: 11, weight: selected ? .semibold : .regular))
          .foregroundColor(selected ? theme.accent : .secondary)
      }
      .padding(10)
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(theme.card)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .stroke(selected ? theme.accent : Color.primary.opacity(0.08),
                  lineWidth: selected ? 2 : 1)
      )
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}
