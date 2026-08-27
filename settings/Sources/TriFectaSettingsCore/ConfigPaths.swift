//
//  设置 app 涉及的所有路径解析。
//
import Foundation

public struct ConfigPaths: Equatable {
  public let userDir: URL
  public let imeAppURL: URL

  public init(userDir: URL, imeAppURL: URL) {
    self.userDir = userDir
    self.imeAppURL = imeAppURL
  }

  /// 默认路径。输入法包按 bundle id 探测，找不到时退回硬编码路径（与 main 源码一致）。
  public static func autodetect() -> ConfigPaths {
    let userDir = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Library", isDirectory: true)
      .appendingPathComponent("Rime", isDirectory: true)
    let fallback = URL(fileURLWithPath: "/Library/Input Methods/Squirrel.app", isDirectory: true)
    let imeDir = (try? FileManager.default.contentsOfDirectory(
      at: URL(fileURLWithPath: "/Library/Input Methods", isDirectory: true),
      includingPropertiesForKeys: nil
    ))?.first { url in
      url.pathExtension == "app"
        && Bundle(url: url)?.bundleIdentifier == Deployer.imeBundleID
    } ?? fallback
    return ConfigPaths(userDir: userDir, imeAppURL: imeDir)
  }

  // MARK: 输入法包内资源

  public var sharedSupport: URL {
    imeAppURL.appendingPathComponent("Contents", isDirectory: true)
      .appendingPathComponent("SharedSupport", isDirectory: true)
  }

  public var imeExecutable: URL {
    imeAppURL.appendingPathComponent("Contents", isDirectory: true)
      .appendingPathComponent("MacOS", isDirectory: true)
      .appendingPathComponent("Squirrel")
  }

  public var imeInfoPlist: URL {
    imeAppURL.appendingPathComponent("Contents", isDirectory: true)
      .appendingPathComponent("Info.plist")
  }

  // MARK: 用户配置文件

  public var userSquirrelYaml: URL {
    userDir.appendingPathComponent("squirrel.yaml")
  }

  /// Rime 官方认可的用户级补丁文件（官方定制指南：default.custom.yaml）
  public var userDefaultCustomYaml: URL {
    userDir.appendingPathComponent("default.custom.yaml")
  }

  public func userSchemaCustomYaml(_ schemaID: String) -> URL {
    userDir.appendingPathComponent("\(schemaID).custom.yaml")
  }

  // MARK: SharedSupport 基线

  public var sharedSquirrelYaml: URL {
    sharedSupport.appendingPathComponent("squirrel.yaml")
  }

  public var sharedDefaultYaml: URL {
    sharedSupport.appendingPathComponent("default.yaml")
  }
}
