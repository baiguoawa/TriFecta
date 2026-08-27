//
//  快捷键：～ 键三色开关、Shift 切换中英。
//
import SwiftUI

struct ShortcutsPage: View {
  @EnvironmentObject private var state: AppState

  var body: some View {
    PageScroll(title: "快捷键") {
      SettingCard {
        SettingRow("～ 键三色分组选字") {
          HStack(spacing: 8) {
            KeycapView(text: "~", systemImage: "function")
            Toggle("", isOn: $state.groupColors.enabled)
              .toggleStyle(.switch)
              .labelsHidden()
          }
        }
        SettingRow("Shift 切换中英", divider: false) {
          HStack(spacing: 8) {
            KeycapView(text: "Shift", systemImage: "arrow.up")
            Toggle("", isOn: $state.shiftEnabled)
              .toggleStyle(.switch)
              .labelsHidden()
          }
        }
      }
    }
  }
}
