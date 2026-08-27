//
//  关于：版本信息、GitHub 链接、检查更新。
//
import SwiftUI
import AppKit

struct AboutPage: View {
  @EnvironmentObject private var state: AppState
  @Environment(\.appTheme) private var theme

  private enum Links {
    static let repo = "https://github.com/thesadbee/TriFecta"
    static let releases = "https://github.com/thesadbee/TriFecta/releases"
  }

  private var imeVersion: String {
    let plist = NSDictionary(contentsOf: state.repo.paths.imeInfoPlist) as? [String: Any]
    let short = plist?["CFBundleShortVersionString"] as? String ?? "—"
    let build = plist?["CFBundleVersion"] as? String ?? "—"
    return "\(short) (\(build))"
  }

  private var settingsVersion: String {
    let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
    return short
  }

  private func open(_ url: String) {
    if let u = URL(string: url) {
      NSWorkspace.shared.open(u)
    }
  }

  var body: some View {
    PageScroll(title: "关于", footer: "TriFecta：基于 Rime/Squirrel 的 macOS 中文输入法（GPL-3.0）") {
      SettingCard {
        VStack(spacing: 10) {
          Image(systemName: "character.book.closed.fill")
            .font(.system(size: 44))
            .foregroundColor(theme.accent)
          Text("TriFecta")
            .font(.system(size: 22, weight: .semibold))
            .foregroundColor(theme.accent)
          Text("输入法 \(imeVersion) · 设置 \(settingsVersion)")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        Divider()
        SettingRow("GitHub 仓库", icon: "arrow.up.right.square") {
          Button("打开") { open(Links.repo) }
        }
        SettingRow("Rime Wiki（上游文档）", icon: "book") {
          Button("打开") { open("https://github.com/rime/home/wiki") }
        }
        SettingRow("检查更新", icon: "arrow.triangle.2.circlepath", divider: false) {
          Button("查看 Releases") { open(Links.releases) }
        }
      }
    }
  }
}
