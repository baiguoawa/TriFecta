//
//  字体选择弹窗：搜索 + 列表 + 实时预览。
//
import SwiftUI
import AppKit

struct FontPickerSheet: View {
  @Binding var fontFace: String
  @Environment(\.dismiss) private var dismiss
  @Environment(\.appTheme) private var theme
  @State private var query = ""

  static let favoriteFonts = [
    "PingFang SC", "Songti SC", "Heiti SC", "STHeiti", "Kaiti SC",
    "Avenir", "Helvetica Neue", "Times New Roman", "Menlo", "Monaco",
  ]

  private var allFamilies: [String] {
    NSFontManager.shared.availableFontFamilies.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
  }

  private var filtered: [String] {
    guard !query.isEmpty else { return allFamilies }
    return allFamilies.filter { $0.localizedCaseInsensitiveContains(query) }
  }

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Text("选择字体")
          .font(.system(size: 15, weight: .semibold))
        Spacer()
      }
      TextField("搜索字体（如 PingFang）", text: $query)
        .textFieldStyle(.roundedBorder)

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          if query.isEmpty, !Self.favoriteFonts.isEmpty {
            sectionTitle("常用")
            ForEach(Self.favoriteFonts, id: \.self) { family in
              fontRow(family)
            }
            sectionTitle("全部")
          }
          let rest = filtered.filter { !(query.isEmpty && Self.favoriteFonts.contains($0)) }
          ForEach(rest, id: \.self) { family in
            fontRow(family)
          }
          if filtered.isEmpty {
            Text("没有匹配的字体")
              .font(.system(size: 12))
              .foregroundColor(.secondary)
              .padding(20)
          }
        }
        .padding(.vertical, 2)
      }
      .background(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(theme.card)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .stroke(Color.primary.opacity(0.08), lineWidth: 1)
      )

      Divider()

      // 实时预览 + 操作
      HStack(spacing: 12) {
        VStack(alignment: .leading, spacing: 2) {
          Text("今天天气真好，Hello 123")
            .font(.custom(fontFace, size: 24))
            .lineLimit(1)
          Text(fontFace)
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        }
        Spacer()
        Button("取消") { dismiss() }
        Button("完成") { dismiss() }
          .buttonStyle(.borderedProminent)
          .tint(theme.accent)
      }
    }
    .padding(18)
    .frame(width: 540, height: 480)
    .background(Color(nsColor: .windowBackgroundColor))
  }

  private func sectionTitle(_ title: String) -> some View {
    Text(title)
      .font(.system(size: 11, weight: .semibold))
      .foregroundColor(.secondary)
      .padding(.horizontal, 12)
      .padding(.top, 8)
      .padding(.bottom, 3)
  }

  private func fontRow(_ family: String) -> some View {
    let selected = fontFace == family
    return Button {
      fontFace = family
    } label: {
      HStack(spacing: 8) {
        Text(family.isEmpty ? " " : family)
          .font(.custom(family, size: 14))
          .lineLimit(1)
        Spacer()
        if selected {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(theme.accent)
        }
      }
      .padding(.vertical, 6)
      .padding(.horizontal, 12)
      .contentShape(Rectangle())
      .background(selected ? theme.accent.opacity(0.10) : Color.clear)
    }
    .buttonStyle(.plain)
  }
}
