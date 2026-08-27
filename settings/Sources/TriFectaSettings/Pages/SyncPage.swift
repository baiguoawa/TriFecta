//
//  同步用户数据：Rime 无内置同步配置，仅投递 SquirrelSyncNotification。
//
import SwiftUI
import TriFectaSettingsCore

struct SyncPage: View {
  @EnvironmentObject private var state: AppState
  @State private var syncing = false
  @State private var message: String?

  var body: some View {
    PageScroll(title: "同步", footer: "需先在 Rime 配置中启用 Git 仓库，否则仅弹出提示。") {
      SettingCard {
        SettingRow("同步用户数据",
                   subtitle: "备份词频与使用习惯", divider: false) {
          if syncing {
            ProgressView().controlSize(.small)
          } else {
            Button("同步用户数据") {
              syncing = true
              message = nil
              DispatchQueue.main.async {
                Deployer.syncUserData()
                message = "已投递同步请求（输入法进程后台执行）"
                syncing = false
              }
            }
          }
        }
        if let message = message {
          Text(message)
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
      }
    }
  }
}
