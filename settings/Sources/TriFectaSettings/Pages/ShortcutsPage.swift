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
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private let trackHeight: CGFloat = 4
  private let thumbSize: CGFloat = 18
  private let steps = TriColorMode.allCases.count

  @State private var dragFraction: Double?
  @State private var isDragging = false
  @State private var lastSampleX: CGFloat = 0
  @State private var lastSampleTime: TimeInterval = 0
  @State private var releaseVelocity: CGFloat = 0

  private var selectedIndex: Int {
    TriColorMode.allCases.firstIndex(of: mode) ?? 0
  }

  private func centerFraction(of index: Int) -> Double {
    (Double(index) + 0.5) / Double(steps)
  }

  private var settleSpring: Animation {
    reduceMotion ? .linear(duration: 0.1) : .spring(response: 0.35, dampingFraction: 0.8)
  }

  private var neutralSpring: Animation {
    reduceMotion ? .linear(duration: 0.12) : .spring(response: 0.3, dampingFraction: 1.0)
  }

  var body: some View {
    VStack(spacing: 6) {
      GeometryReader { geo in
        let width = geo.size.width
        let fraction = dragFraction ?? centerFraction(of: selectedIndex)
        let x = width * CGFloat(fraction)

        ZStack(alignment: .leading) {
          // 轨道（统一无色/淡色，无"进度"填充）
          RoundedRectangle(cornerRadius: trackHeight / 2)
            .fill(Color.primary.opacity(0.14))
            .frame(height: trackHeight)
            .frame(maxWidth: .infinity)

          Circle()
            .fill(Color.white)
            .frame(width: thumbSize, height: thumbSize)
            .shadow(
              color: .black.opacity(isDragging ? 0.28 : 0.18),
              radius: isDragging ? 4 : 2,
              x: 0, y: isDragging ? 3 : 1
            )
            .overlay(Circle().stroke(Color.primary.opacity(0.15), lineWidth: 0.5))
            .scaleEffect(isDragging ? 1.15 : 1.0)
            .offset(x: x - thumbSize / 2)
            .animation(neutralSpring, value: isDragging)
            .animation(isDragging ? nil : settleSpring, value: x)
        }
        .frame(height: thumbSize)   // 可点击/拖动区域
        .contentShape(Rectangle())
        .gesture(slideGesture(width: width))
      }
      .frame(height: thumbSize)

      // 三档标签（点击标签也能切换）
      HStack(spacing: 0) {
        ForEach(Array(TriColorMode.allCases.enumerated()), id: \.element) { _, m in
          Text(m.label)
            .font(.system(size: 11, weight: mode == m ? .semibold : .regular))
            .foregroundColor(mode == m ? theme.accent : .secondary)
            .frame(maxWidth: .infinity)
            .onTapGesture { withAnimation(neutralSpring) { mode = m } }
        }
      }
      .animation(neutralSpring, value: mode)
    }
  }

  private func slideGesture(width: CGFloat) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        let now = Date.timeIntervalSinceReferenceDate
        if !isDragging {
          isDragging = true
          lastSampleX = value.location.x
          lastSampleTime = now
          releaseVelocity = 0
        }
        let dt = now - lastSampleTime
        if dt > 0.0005 {
          releaseVelocity = (value.location.x - lastSampleX) / CGFloat(dt)
          lastSampleX = value.location.x
          lastSampleTime = now
        }
        let raw = value.location.x / width
        dragFraction = Double(rubberbanded(raw))
        updateMode(for: raw)
      }
      .onEnded { value in
        isDragging = false
        let raw = value.location.x / width
        let projected = raw + Double(releaseVelocity) / 1000 * 0.98 / (1 - 0.98) / Double(width)
        updateMode(for: projected)
        dragFraction = nil
        releaseVelocity = 0
      }
  }

  private func updateMode(for rawFraction: Double) {
    let idx = Int((rawFraction * Double(steps) - 0.5).rounded())
    let clamped = min(max(idx, 0), steps - 1)
    let target = TriColorMode.allCases[clamped]
    if target != mode {
      mode = target
    }
  }

  private func rubberbanded(_ fraction: Double) -> Double {
    let c = 0.55
    if fraction < 0 { return -(fraction * c / (1 + c * abs(fraction))) }
    if fraction > 1 { return 1 + (fraction - 1) * c / (1 + c * abs(fraction - 1)) }
    return fraction
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
          SettingRow("滑块模式回退键") {
            TriggerKeyField(keyCode: $state.groupColors.sliderBackKey)
          }
          SettingRow("", subtitle:
            "触发键默认为数字 1 左侧的 ` 键（显示为 ~），回退键默认为 Tab。敲入拼音后常驻显示某组二级菜单，" +
            "按触发键向后滑动一组、按回退键返回上一组；滑动到哪组，按 1/2/3 即选该组第 1/2/3 个。",
            divider: false) {
            EmptyView()
          }
        }
      }
    }
  }
}
