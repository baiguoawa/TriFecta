//
//  快捷键：三色分组选字 —— 模式切换 + 各模式快捷键设置。
//
import SwiftUI
import AppKit
import TriFectaSettingsCore

/// 把 mac keyCode 转成用于展示的键名（默认触发键 50 = ` 键，UI 显示为 ~）。
func keycapDisplay(forKeyCode code: Int) -> String {
  switch code {
  case 50: return "~"                       // ` 键（数字1左侧）
  case 48: return "⇥ Tab"
  case 36: return "↩ Return"
  case 49: return "␣ Space"
  case 51: return "⌫ Delete"
  case 53: return "⎋ Esc"
  case 122: return "F1"
  case 120: return "F2"
  case 99: return "F3"
  case 118: return "F4"
  case 96: return "F5"
  case 97: return "F6"
  case 98: return "F7"
  case 100: return "F8"
  case 101: return "F9"
  case 109: return "F10"
  case 103: return "F11"
  case 111: return "F12"
  case 123: return "←"
  case 124: return "→"
  case 125: return "↓"
  case 126: return "↑"
  case 116: return "Page Up"
  case 121: return "Page Down"
  default:
    // 字母键（mac keyCode 无法稳定逆映射字符，回退为 Key 数字）
    return "Key \(code)"
  }
}

/// 触发键输入框：显示当前触发键，点击后监听下一次 keyDown 并更新绑定。
struct TriggerKeyField: View {
  @Binding var keyCode: Int
  @State private var isListening = false
  @State private var monitor: Any?

  var body: some View {
    Button {
      beginListening()
    } label: {
      HStack(spacing: 6) {
        KeycapView(text: keycapDisplay(forKeyCode: keyCode), systemImage: "command")
        Text(isListening ? "请按下按键" : "点击设置")
          .font(.system(size: 11))
          .foregroundColor(isListening ? Color.accentColor : .secondary)
        Image(systemName: isListening ? "record.circle" : "keyboard")
          .font(.system(size: 11, weight: .semibold))
          .foregroundColor(isListening ? Color.accentColor : .secondary)
      }
    }
    .buttonStyle(.plain)
    .onDisappear { stopListening() }
  }

  private func beginListening() {
    if isListening { stopListening(); return }
    isListening = true
    monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
      let code = Int(event.keyCode)
      stopListening()
      keyCode = code
      return nil   // 吞掉该事件，避免同时触发其它按键作用
    }
  }

  private func stopListening() {
    if let monitor = monitor {
      NSEvent.removeMonitor(monitor)
      self.monitor = nil
    }
    isListening = false
  }
}

/// 三模式滑动切换（触发 / 常驻 / 滑块）。单滑块拖到某档即激活该模式、关闭其余，
/// 直观体现"同时只有一个模式生效"。拖动/点击整个滑条即可切换，无需精准点文字。
/// 滑条是"切换器"而非"进度条"，轨道统一无色；滑块中心对齐每一档模式名称的中间。
struct ModeSwitcher: View {
  @Binding var mode: TriColorMode
  @Environment(\.appTheme) private var theme

  private let trackHeight: CGFloat = 4
  private let thumbSize: CGFloat = 18

  var body: some View {
    VStack(spacing: 6) {
      GeometryReader { geo in
        let trackWidth = geo.size.width
        let steps = TriColorMode.allCases.count           // 3 档
        let selectedIndex = TriColorMode.allCases.firstIndex(of: mode) ?? 0
        // 档位中心对齐三档名称的中间：1/6、3/6、5/6（与下方 label 三等分一致）
        let centerX = trackWidth * (CGFloat(selectedIndex) + 0.5) / CGFloat(steps)

        ZStack(alignment: .leading) {
          // 轨道（统一无色/淡色，无"进度"填充）
          RoundedRectangle(cornerRadius: trackHeight / 2)
            .fill(Color.primary.opacity(0.14))
            .frame(height: trackHeight)
            .frame(maxWidth: .infinity)
          // 圆形滑块（中心对齐当前档名称）
          Circle()
            .fill(Color.white)
            .frame(width: thumbSize, height: thumbSize)
            .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
            .overlay(Circle().stroke(Color.primary.opacity(0.15), lineWidth: 0.5))
            .offset(x: centerX - thumbSize / 2)
        }
        .frame(height: thumbSize)   // 可点击/拖动区域
        .contentShape(Rectangle())
        .gesture(
          DragGesture(minimumDistance: 0)
            .onChanged { value in
              // 把点击/拖动位置映射到各档中心（1/6、3/6、5/6），落到最近档
              let t = value.location.x / trackWidth
              let idx = Int((t * CGFloat(steps) - 0.5).rounded())
              mode = TriColorMode.allCases[min(max(idx, 0), steps - 1)]
            }
        )
      }
      .frame(height: thumbSize)

      // 三档标签（点击标签也能切换）
      HStack(spacing: 0) {
        ForEach(Array(TriColorMode.allCases.enumerated()), id: \.element) { _, m in
          Text(m.label)
            .font(.system(size: 11, weight: mode == m ? .semibold : .regular))
            .foregroundColor(mode == m ? theme.accent : .secondary)
            .frame(maxWidth: .infinity)
            .onTapGesture { withAnimation(.easeInOut(duration: 0.15)) { mode = m } }
        }
      }
    }
  }
}

extension TriColorMode {
  var label: String {
    switch self {
    case .trigger: return "触发模式"
    case .dwell: return "常驻模式"
    case .slider: return "滑块模式"
    }
  }
}

struct ShortcutsPage: View {
  @EnvironmentObject private var state: AppState

  var body: some View {
    PageScroll(title: "快捷键") {
      // 顶部：三模式滑块切换
      ModeSwitcher(mode: $state.groupColors.mode)

      // 下方：仅显示当前模式的快捷键设置
      switch state.groupColors.mode {
      case .trigger:
        SettingCard {
          SettingRow("～ 键三色分组选字") {
            HStack(spacing: 8) {
              TriggerKeyField(keyCode: $state.groupColors.triggerKey)
              Toggle("", isOn: $state.groupColors.enabled)
                .toggleStyle(.switch)
                .labelsHidden()
            }
          }
          SettingRow("", subtitle:
            "触发键默认为数字 1 左侧的 ` 键（显示为 ~）。点击后按下任意键即可替换触发键；" +
            "候选展开时，触发键将被拦截并进入三色选字，不再执行它原有的功能。",
            divider: false) {
            EmptyView()
          }
        }

      case .dwell:
        SettingCard {
          SettingRow("常驻模式触发组内选词") {
            HStack(spacing: 8) {
              TriggerKeyField(keyCode: $state.groupColors.dwellSecondKey)
              Text("第2个")
            }
          }
          SettingRow("第3个候选键") {
            TriggerKeyField(keyCode: $state.groupColors.dwellThirdKey)
          }
          SettingRow("进入第2/3组后仍用 `~/tab 选词", divider: false) {
            Toggle("", isOn: $state.groupColors.dwellUseDefaultKeysInGroup)
              .toggleStyle(.switch)
              .labelsHidden()
          }
        }

      case .slider:
        SettingCard {
          SettingRow("滑块模式触发键") {
            TriggerKeyField(keyCode: $state.groupColors.sliderTriggerKey)
          }
          SettingRow("", subtitle:
            "敲入拼音后常驻显示某组二级菜单，按触发键向后滑动一组；滑动到哪组，按 1/2/3 即选该组第 1/2/3 个。",
            divider: false) {
            EmptyView()
          }
        }
      }
    }
  }
}
