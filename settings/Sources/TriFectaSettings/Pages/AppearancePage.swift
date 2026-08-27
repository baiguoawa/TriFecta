//
//  外观：候选框主题、布局、字体、候选格式、三色配色。
//
import SwiftUI

struct AppearancePage: View {
  @EnvironmentObject private var state: AppState
  @Environment(\.appTheme) private var theme
  @State private var showFontPicker = false

  var body: some View {
    PageScroll(title: "外观") {
      SettingCard {
        SettingRow("主题", divider: false) {
          GlassPopupPicker(
            options: state.colorSchemes.map { $0.id },
            titleOf: { id in state.colorSchemes.first { $0.id == id }?.name ?? id },
            selection: $state.style.colorScheme,
            width: 190
          )
          .frame(width: 190)
        }
      }

      SettingCard {
        SettingRow("候选布局") {
          Picker("", selection: $state.style.candidateListLayout) {
            Text("横排").tag("linear")
            Text("竖排").tag("vertical")
          }
          .pickerStyle(.segmented)
          .frame(width: 150)
        }
        SettingRow("文字方向") {
          Picker("", selection: $state.style.textOrientation) {
            Text("水平").tag("horizontal")
            Text("垂直").tag("vertical")
          }
          .pickerStyle(.segmented)
          .frame(width: 130)
        }
        SettingRow("字体") {
          Button {
            showFontPicker = true
          } label: {
            Text(state.style.fontFace)
              .frame(minWidth: 150)
          }
          .buttonStyle(.bordered)
        }
        SettingRow("字号") {
          HStack(spacing: 6) {
            Slider(value: $state.style.fontPoint, in: 8...32, step: 1)
              .frame(width: 130)
            TextField("", value: $state.style.fontPoint, format: .number)
              .textFieldStyle(.roundedBorder)
              .frame(width: 48)
              .multilineTextAlignment(.trailing)
          }
        }
        SettingRow("候选格式", subtitle: "候选词的显示样式", divider: false) {
          VStack(alignment: .trailing, spacing: 4) {
            GlassPopupPicker(
              options: [
                "[label]. [candidate] [comment]",
                "[label]. [candidate]",
                "[candidate] [comment]",
                "[candidate]",
              ],
              titleOf: { template in
                switch template {
                case "[label]. [candidate] [comment]": return "编号 + 候选词 + 拼音"
                case "[label]. [candidate]": return "编号 + 候选词"
                case "[candidate] [comment]": return "候选词 + 拼音"
                case "[candidate]": return "仅候选词"
                default: return template
                }
              },
              selection: $state.style.candidateFormat,
              width: 180
            )
            .frame(width: 180)
            Text(formatPreview)
              .font(.system(size: 11))
              .foregroundColor(.secondary)
              .lineLimit(1)
          }
          .frame(width: 260)
        }
      }

      SettingCard {
        SettingRow("三色分组配色",
                   subtitle: "候选多时按 ～ 键分组选字（红/黄/绿）") {
          Toggle("启用", isOn: $state.groupColors.enabled)
            .toggleStyle(.switch)
        }
        GroupColorRow(title: "第一组（红）", value: $state.groupColors.red)
        GroupColorRow(title: "第二组（黄）", value: $state.groupColors.yellow)
        GroupColorRow(title: "第三组（绿）", value: $state.groupColors.green, divider: false)
      }
    }
    .sheet(isPresented: $showFontPicker) {
      FontPickerSheet(fontFace: $state.style.fontFace)
    }
  }

  /// 候选格式实时预览：把模板里的 [label]/[candidate]/[comment] 换成示例
  private var formatPreview: String {
    var s = state.style.candidateFormat
    s = s.replacingOccurrences(of: "[label]", with: "1")
    s = s.replacingOccurrences(of: "[candidate]", with: "拼音")
    s = s.replacingOccurrences(of: "[comment]", with: "pīn yīn")
    s = s.replacingOccurrences(of: "%c", with: "1")
    s = s.replacingOccurrences(of: "%@", with: "拼音 pīn yīn")
    return "效果：\(s)"
  }
}
