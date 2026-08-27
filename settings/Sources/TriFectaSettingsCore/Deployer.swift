//
//  保存后让配置立即生效：投递 SquirrelReloadNotification 通知运行中的输入法，
//  未运行时改在 SharedSupport 目录直接跑 `Squirrel --build`。
//
import Foundation
import AppKit

public enum Deployer {
  public static let imeBundleID = "im.rime.inputmethod.Squirrel"

  public static var isIMERunning: Bool {
    !NSRunningApplication.runningApplications(withBundleIdentifier: imeBundleID).isEmpty
  }

  /// 触发重新部署；返回输入法是否在运行。
  @discardableResult
  public static func reload(paths: ConfigPaths = .autodetect()) -> Bool {
    let running = isIMERunning
    if running {
      DistributedNotificationCenter.default().postNotificationName(
        .init("SquirrelReloadNotification"),
        object: nil,
        userInfo: nil,
        deliverImmediately: true
      )
    } else {
      // 后台重建（不阻塞）
      let process = Process()
      process.executableURL = paths.imeExecutable
      process.arguments = ["--build"]
      process.currentDirectoryURL = paths.sharedSupport
      process.standardOutput = FileHandle.nullDevice
      process.standardError = FileHandle.nullDevice
      try? process.run()
    }
    return running
  }

  /// 同步用户数据：复用输入法监听的通知（等价 Squirrel --sync）
  public static func syncUserData() {
    DistributedNotificationCenter.default().postNotificationName(
      .init("SquirrelSyncNotification"),
      object: nil,
      userInfo: nil,
      deliverImmediately: true
    )
  }
}
