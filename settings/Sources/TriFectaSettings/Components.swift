//
//  设置窗口通用控件：卡片行、下拉、键帽、玻璃按钮。
//
import SwiftUI
import AppKit
import TriFectaSettingsCore

/// TriFecta/微信输入法品牌绿
extension Color {
  static let weTypeGreen = Color(red: 0.05, green: 0.72, blue: 0.45)
}

/// 白色圆角卡片（微信输入法设置右侧的"分组行"样式）
struct SettingCard<Content: View>: View {
  @Environment(\.appTheme) private var theme
  @ViewBuilder var content: Content

  var body: some View {
    VStack(spacing: 0) {
      content
    }
    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(theme.card)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .stroke(Color.primary.opacity(0.07), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 1)
  }
}

/// 卡片内的一行：可选图标 + 标题（+ 说明）+ 右侧控件
struct SettingRow<Trailing: View>: View {
  @Environment(\.appTheme) private var theme
  let title: String
  var subtitle: String?
  var icon: String?
  var divider: Bool
  @ViewBuilder var trailing: Trailing

  init(_ title: String, subtitle: String? = nil, icon: String? = nil,
       divider: Bool = true,
       @ViewBuilder trailing: () -> Trailing) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self.divider = divider
    self.trailing = trailing()
  }

  var body: some View {
    HStack(alignment: .center, spacing: 10) {
      if let icon = icon {
        Image(systemName: icon)
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(theme.accent)
          .frame(width: 24, height: 24)
          .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
              .fill(theme.accent.opacity(0.13))
          )
      }
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 13, weight: .medium))
        if let subtitle = subtitle {
          Text(subtitle)
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .lineLimit(2)
        }
      }
      Spacer(minLength: 12)
      trailing
        .frame(maxWidth: 300, alignment: .trailing)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 11)
    if divider {
      Divider()
    }
  }
}

/// 玻璃下拉选择（NSPopUpButton 包装：macOS 26 自动液态玻璃样式，
/// 原生"按住弹出→拖动选择→松开"交互；深色模式下可加光晕）。
/// 光晕用 SwiftUI shadow（外层留白，避免 layer 阴影被容器裁切）。
/// 系统原生下拉（NSPopUpButton：保持系统自己的外观与"按住弹出→拖动选择"行为；
/// 右侧箭头用主题强调色覆盖）
struct GlassPopupPicker<T: Hashable>: View {
  @Environment(\.appTheme) private var theme
  let options: [T]
  let titleOf: (T) -> String
  @Binding var selection: T
  var width: CGFloat = 170

  var body: some View {
    PopupNSView(options: options, titleOf: titleOf, selection: $selection, width: width)
      .frame(width: width)
      .overlay(alignment: .trailing) {
        Image(systemName: "chevron.up.chevron.down")
          .font(.system(size: 8, weight: .bold))
          .foregroundColor(theme.accent)
          .padding(.trailing, 8)
          .allowsHitTesting(false)
      }
  }
}

private struct PopupNSView<T: Hashable>: NSViewRepresentable {
  let options: [T]
  let titleOf: (T) -> String
  @Binding var selection: T
  var width: CGFloat

  func makeCoordinator() -> Coordinator { Coordinator(self) }

  func makeNSView(context: Context) -> NSPopUpButton {
    let button = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: width, height: 24), pullsDown: false)
    button.target = context.coordinator
    button.action = #selector(Coordinator.changed(_:))
    button.controlSize = .regular
    if let cell = button.cell as? NSPopUpButtonCell {
      cell.arrowPosition = .noArrow   // 箭头改由 SwiftUI 主题色绘制
    }
    return button
  }

  func updateNSView(_ button: NSPopUpButton, context: Context) {
    // 缓存比较：选项/选中值未变时不重建菜单（否则每个无关状态变化都会让下拉抽搐）
    if context.coordinator.lastOptions != options {
      button.removeAllItems()
      for option in options {
        button.addItem(withTitle: titleOf(option))
      }
      context.coordinator.lastOptions = options
    }
    if context.coordinator.lastSelection != selection || context.coordinator.lastOptions == nil {
      button.selectItem(at: options.firstIndex(of: selection) ?? 0)
      context.coordinator.lastSelection = selection
    }
    // 硬定 NSView frame：无论 Auto Layout 怎么推 intrinsic，都严格贴合宽度
    button.frame.size = NSSize(width: width, height: max(button.frame.height, 24))
  }

  final class Coordinator: NSObject {
    var parent: PopupNSView
    var lastOptions: [T]?
    var lastSelection: T?
    init(_ parent: PopupNSView) { self.parent = parent }
    @objc func changed(_ sender: NSPopUpButton) {
      let index = sender.indexOfSelectedItem
      if index >= 0 && index < parent.options.count {
        parent.selection = parent.options[index]
      }
    }
  }
}

/// 页面容器：大标题 + 卡片堆 + 说明
struct PageScroll<Content: View>: View {
  let title: String
  var subtitle: String?
  var footer: String?
  @ViewBuilder var content: Content

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 14) {
        VStack(alignment: .leading, spacing: 3) {
          Text(title)
            .font(.system(size: 19, weight: .semibold))
          if let subtitle = subtitle {
            Text(subtitle)
              .font(.system(size: 12))
              .foregroundColor(.secondary)
          }
        }
        .padding(.bottom, 2)
        content
        if let footer = footer {
          Text(footer)
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
            .padding(.top, 2)
        }
      }
      .padding(22)
      .frame(maxWidth: 640, alignment: .leading)
      .frame(maxWidth: .infinity, alignment: .top)
    }
    .background(EmbeddedScrollerStyler())
  }
}

/// 把 SwiftUI ScrollView 底层的 NSScrollView 设置为"嵌入背景的覆盖式滚动条"：
/// 滚动时显现、静止后自动隐藏（不受系统"始终显示滚动条"影响的强制 overlay 样式）。
struct EmbeddedScrollerStyler: NSViewRepresentable {
  func makeNSView(context: Context) -> NSView {
    let view = NSView()
    DispatchQueue.main.async {
      apply(to: view)
    }
    return view
  }

  func updateNSView(_ view: NSView, context: Context) {
    DispatchQueue.main.async {
      apply(to: view)
    }
  }

  private func apply(to view: NSView) {
    guard let scroll = Self.findScrollView(from: view) else { return }
    scroll.drawsBackground = false
    scroll.backgroundColor = .clear
    scroll.scrollerStyle = .overlay
    scroll.hasVerticalScroller = true
    scroll.verticalScroller?.controlSize = .small
  }

  private static func findScrollView(from view: NSView?) -> NSScrollView? {
    var current = view
    while let v = current {
      if let scroll = v as? NSScrollView { return scroll }
      current = v.superview
    }
    return nil
  }
}

// MARK: 颜色转换（0xAABBGGRR ↔ SwiftUI Color）

extension Color {
  init(rimeHex value: UInt32) {
    let alpha = CGFloat((value >> 24) & 0xFF) / 255
    let blue = CGFloat((value >> 16) & 0xFF) / 255
    let green = CGFloat((value >> 8) & 0xFF) / 255
    let red = CGFloat(value & 0xFF) / 255
    self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
  }

  var rimeHex: UInt32 {
    let ns = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
    let a = UInt32((ns.alphaComponent * 255).rounded()) & 0xFF
    let b = UInt32((ns.blueComponent * 255).rounded()) & 0xFF
    let g = UInt32((ns.greenComponent * 255).rounded()) & 0xFF
    let r = UInt32((ns.redComponent * 255).rounded()) & 0xFF
    return (a << 24) | (b << 16) | (g << 8) | r
  }
}

/// 红/黄/绿三色选择行
struct GroupColorRow: View {
  let title: String
  @Binding var value: UInt32
  var divider: Bool = true

  var body: some View {
    SettingRow(title, divider: divider) {
      ColorPicker("", selection: Binding(
        get: { Color(rimeHex: value) },
        set: { value = $0.rimeHex }
      ))
      .labelsHidden()
      .frame(width: 130)
    }
  }
}

/// 键帽（快捷键可视化）
struct KeycapView: View {
  let text: String
  var systemImage: String?

  var body: some View {
    HStack(spacing: 4) {
      if let systemImage = systemImage {
        Image(systemName: systemImage).font(.system(size: 10, weight: .semibold))
      }
      Text(text)
        .font(.system(size: 11, weight: .semibold))
    }
    .padding(.horizontal, 9)
    .padding(.vertical, 4)
    .background(
      RoundedRectangle(cornerRadius: 6, style: .continuous)
        .fill(Color(nsColor: .controlBackgroundColor))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 6, style: .continuous)
        .stroke(Color.primary.opacity(0.15), lineWidth: 0.5)
    )
  }
}

// MARK: 液态玻璃操作按钮（macOS 26+；旧系统回退原生样式）

/// 一组液态玻璃按钮容器
struct GlassActionGroup<Content: View>: View {
  var spacing: CGFloat = 8
  @ViewBuilder var content: Content

  var body: some View {
    if #available(macOS 26.0, *) {
      GlassEffectContainer(spacing: spacing) {
        content
      }
    } else {
      HStack(spacing: spacing) { content }
    }
  }
}

/// 液态玻璃芯片按钮（prominent = 主操作）
struct GlassActionButton: View {
  @Environment(\.appTheme) private var theme
  let title: String
  var systemImage: String?
  var prominent = false
  let action: () -> Void

  @ViewBuilder private var labelContent: some View {
    HStack(spacing: 6) {
      if let systemImage = systemImage {
        Image(systemName: systemImage)
          .font(.system(size: 11, weight: .bold))
          .foregroundColor(prominent ? theme.accent : .secondary)
      }
      Text(title)
        .font(.system(size: 12, weight: .medium))
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 8)
    .contentShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
  }

  var body: some View {
    if #available(macOS 26.0, *) {
      // 自绘玻璃芯片：regular 玻璃 + 圆角 11（比 glassProminent 的黑块更具液态感）
      Button(action: action) { labelContent }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: .rect(cornerRadius: 11))
    } else {
      if prominent {
        Button(action: action) { labelContent }
          .buttonStyle(.borderedProminent)
          .tint(.weTypeGreen)
          .controlSize(.large)
      } else {
        Button(action: action) { labelContent }
          .buttonStyle(.bordered)
          .tint(.accentColor)
          .controlSize(.large)
      }
    }
  }
}
