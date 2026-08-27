//
//  快捷键：～ 键三色分组选词（触发键设置）。
//
import SwiftUI
import AppKit

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
        Text(isListening ? "请按下触发键" : "点击设置")
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

struct ShortcutsPage: View {
  @EnvironmentObject private var state: AppState

  var body: some View {
    PageScroll(title: "快捷键") {
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
    }
  }
}
