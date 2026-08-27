//
//  合并多个 YAML 配置为设置页所需的当前有效值。
//
import Foundation
import Yams

public enum SquirrelYamlSource: Equatable {
  case user(URL)
  case shared(URL)
}

public struct StyleValues: Equatable {
  public var colorScheme: String
  public var candidateListLayout: String   // 候选列表布局，linear 横排，vertical 竖排
  public var textOrientation: String       // 文字方向，horizontal 水平，vertical 垂直
  public var fontFace: String
  public var fontPoint: Double
  public var candidateFormat: String

  public init(colorScheme: String, candidateListLayout: String, textOrientation: String,
              fontFace: String, fontPoint: Double, candidateFormat: String) {
    self.colorScheme = colorScheme
    self.candidateListLayout = candidateListLayout
    self.textOrientation = textOrientation
    self.fontFace = fontFace
    self.fontPoint = fontPoint
    self.candidateFormat = candidateFormat
  }

  /// 与 SharedSupport 基线一致的缺省 UI 值（readStyle 回退与 AppState 初始快照共用）
  public static let defaults = StyleValues(
    colorScheme: "native", candidateListLayout: "linear", textOrientation: "horizontal",
    fontFace: "Avenir", fontPoint: 15, candidateFormat: "[label]. [candidate] [comment]"
  )
}

/// 三色分组的工作模式。
public enum TriColorMode: String, Equatable, CaseIterable {
  case trigger = "trigger"   // 触发键打开三色一级菜单
  case dwell = "dwell"       // 常驻：无触发键自动打开一级菜单
  case slider = "slider"     // 滑块：常驻显示某组二级菜单, 触发键平移组
}

public struct GroupColorsValues: Equatable {
  public var enabled: Bool
  public var red: UInt32
  public var yellow: UInt32
  public var green: UInt32
  /// 三色分组的触发键：mac keyCode（数字）。默认 50 = ` 键（UI 显示为 ~）。
  /// 主程序据此拦截该键在候选展开时进入三色的功能。（触发模式）
  public var triggerKey: Int
  /// 当前模式：trigger / dwell / slider。
  public var mode: TriColorMode
  /// 常驻模式：第1组第2个候选的选字键（默认 50 = ` 键，UI 显示 ~）。
  public var dwellSecondKey: Int
  /// 常驻模式：第1组第3个候选的选字键（默认 48 = Tab）。
  public var dwellThirdKey: Int
  /// 常驻模式：进第2/3组二级菜单后，用 1/2/3 选词，还是用 `~/tab（与第1组一致）。
  public var dwellUseDefaultKeysInGroup: Bool
  /// 滑块模式：触发键（默认 50 = ` 键，UI 显示 ~）。
  public var sliderTriggerKey: Int
  /// 滑块模式：回退键（返回上一组，默认 48 = Tab）。
  public var sliderBackKey: Int

  public init(enabled: Bool, red: UInt32, yellow: UInt32, green: UInt32,
              triggerKey: Int = 50,
              mode: TriColorMode = .trigger,
              dwellSecondKey: Int = 50,
              dwellThirdKey: Int = 48,
              dwellUseDefaultKeysInGroup: Bool = false,
              sliderTriggerKey: Int = 50,
              sliderBackKey: Int = 48) {
    self.enabled = enabled
    self.red = red
    self.yellow = yellow
    self.green = green
    self.triggerKey = triggerKey
    self.mode = mode
    self.dwellSecondKey = dwellSecondKey
    self.dwellThirdKey = dwellThirdKey
    self.dwellUseDefaultKeysInGroup = dwellUseDefaultKeysInGroup
    self.sliderTriggerKey = sliderTriggerKey
    self.sliderBackKey = sliderBackKey
  }

  /// 与 sources/SquirrelView.swift 硬编码值一致（0xAABBGGRR：alpha、blue、green、red）
  public static let defaults = GroupColorsValues(
    enabled: true, red: 0xAD2933F0, yellow: 0xAD00B8F2, green: 0xAD45BD24
  )
}

public struct EffectiveModel {
  public let style: StyleValues
  public let colorSchemes: [(id: String, name: String)]
  public let groupColors: GroupColorsValues
  public let schemas: [SchemaInfo]
  public let schemaList: [String]
  /// 用户是否已自定义方案列表（未自定义时显示推荐默认：简中 + 繁中）
  public let schemaListCustomized: Bool
  /// schemaID -> switchIndex -> 有效 reset（含 schema 默认）
  public let switchResets: [String: [Int: Int]]
  /// schemaID -> 用户 custom 文件里显式声明过 reset 的开关索引（区分"用户已保存"与"schema 默认"）
  public let userResetPatchKeys: [String: Set<Int>]
  public let squirrelYamlSource: SquirrelYamlSource
  public let userSquirrelYamlExists: Bool
}

public enum RimeModel {
  // MARK: 基础读取

  /// 解析 YAML 文本为 Node
  public static func compose(_ text: String) throws -> Node {
    guard let node = try Yams.compose(yaml: text) else {
      throw YamlLineEditor.EditorError.malformed("YAML 解析失败")
    }
    return node
  }

  public static func boolScalar(_ node: Node?) -> Bool? {
    guard let s = node?.string?.lowercased() else { return nil }
    switch s {
    case "true", "yes", "on", "1": return true
    case "false", "no", "off", "0": return false
    default: return nil
    }
  }

  /// 解析 0xAABBGGRR / 0xBBGGRR 十六进制字符串为 UInt32（6 位补全 alpha，与输入法解析一致）
  public static func hexColorValue(_ s: String) -> UInt32? {
    guard s.lowercased().hasPrefix("0x") else { return nil }
    let hex = String(s.dropFirst(2))
    guard (hex.count == 8 || hex.count == 6), hex.allSatisfy({ $0.isHexDigit }) else { return nil }
    if hex.count == 8 {
      return UInt32(hex, radix: 16)
    }
    return 0xFF000000 | (UInt32(hex, radix: 16) ?? 0)
  }

  public static func hexColor(_ node: Node?) -> UInt32? {
    guard let s = node?.string else { return nil }
    return hexColorValue(s)
  }

  /// 解析整数值（用于 group_colors/trigger_key 这类 keyCode）。
  public static func intScalar(_ node: Node?) -> Int? {
    guard let s = node?.string else { return nil }
    return Int(s.trimmingCharacters(in: .whitespaces))
  }

  public static func hexDump(_ value: UInt32) -> String {
    String(format: "0x%08X", value)
  }

  // MARK: squirrel.yaml 读取

  /// 读取用户级 squirrel.yaml；不存在时读 SharedSupport 基线（等价输入法的 fallback）
  public static func loadSquirrelYaml(paths: ConfigPaths) throws -> (source: SquirrelYamlSource, node: Node) {
    let userURL = paths.userSquirrelYaml
    if FileManager.default.fileExists(atPath: userURL.path) {
      let text = try String(contentsOf: userURL, encoding: .utf8)
      return (.user(userURL), try compose(text))
    }
    let text = try String(contentsOf: paths.sharedSquirrelYaml, encoding: .utf8)
    return (.shared(paths.sharedSquirrelYaml), try compose(text))
  }

  public static func readStyle(_ node: Node) -> StyleValues {
    let style = node["style"]
    let d = StyleValues.defaults
    let schemeID = style?["color_scheme"]?.string ?? d.colorScheme
    // color_scheme 可能带引号或不是合法方案；全部原样给 UI，由 UI 兜底显示
    let layout = style?["candidate_list_layout"]?.string ?? d.candidateListLayout
    let orientation = style?["text_orientation"]?.string ?? d.textOrientation
    let fontFace = style?["font_face"]?.string ?? d.fontFace
    let fontPoint = style?["font_point"]?.float.map { $0 } ?? style?["font_point"]?.int.map { Double($0) } ?? d.fontPoint
    let format = style?["candidate_format"]?.string ?? d.candidateFormat
    return StyleValues(colorScheme: schemeID, candidateListLayout: layout,
                       textOrientation: orientation, fontFace: fontFace,
                       fontPoint: fontPoint, candidateFormat: format)
  }

  public static func readColorSchemes(_ node: Node) -> [(id: String, name: String)] {
    guard let pairs = node["preset_color_schemes"]?.mapPairs else { return [] }
    return pairs.map { (key, value) -> (id: String, name: String) in
      (id: key.scalarString ?? "", name: value["name"]?.string ?? key.scalarString ?? "")
    }
    .sorted { $0.id < $1.id }
  }

  public static func readGroupColors(_ node: Node) -> GroupColorsValues {
    let gc = node["group_colors"]
    let defaults = GroupColorsValues.defaults
    return GroupColorsValues(
      enabled: boolScalar(gc?["enabled"]) ?? defaults.enabled,
      red: hexColor(gc?["red"]) ?? defaults.red,
      yellow: hexColor(gc?["yellow"]) ?? defaults.yellow,
      green: hexColor(gc?["green"]) ?? defaults.green,
      triggerKey: intScalar(gc?["trigger_key"]) ?? defaults.triggerKey,
      mode: TriColorMode(rawValue: gc?["mode"]?.string ?? "") ?? defaults.mode,
      dwellSecondKey: intScalar(gc?["dwell_second_key"]) ?? defaults.dwellSecondKey,
      dwellThirdKey: intScalar(gc?["dwell_third_key"]) ?? defaults.dwellThirdKey,
      dwellUseDefaultKeysInGroup: boolScalar(gc?["dwell_use_default_keys_in_group"]) ?? defaults.dwellUseDefaultKeysInGroup,
      sliderTriggerKey: intScalar(gc?["slider_trigger_key"]) ?? defaults.sliderTriggerKey,
      sliderBackKey: intScalar(gc?["slider_back_key"]) ?? defaults.sliderBackKey
    )
  }

  // MARK: default.custom.yaml / default.yaml

  /// 推荐默认方案：只留一个朙月拼音（luna_pinyin），并通过简繁开关 reset=1
  /// 推荐默认只留一个朙月拼音并强制简体（不挂一堆方案）。
  public static let recommendedSchemaList = ["luna_pinyin"]

  /// 读取用户级 custom 文件的 patch 内容（文件不存在返回 nil）
  public static func readCustomPatch(paths: ConfigPaths, fileName: String) throws -> Node? {
    let url = paths.userDir.appendingPathComponent(fileName)
    guard FileManager.default.fileExists(atPath: url.path) else { return nil }
    let text = try String(contentsOf: url, encoding: .utf8)
    let node = try compose(text)
    return node["patch"]
  }

  /// 有效 schema_list：用户 patch 的 schema_list 优先；未自定义时使用推荐默认
  /// （简中 + 繁中两个最佳方案，而非 SharedSupport 基线的一大堆）
  public static func readSchemaList(paths: ConfigPaths) throws -> [String] {
    if let patch = try readCustomPatch(paths: paths, fileName: "default.custom.yaml"),
       let seq = patch["schema_list"]?.seqNodes {
      let ids = seq.compactMap { $0["schema"]?.string }
      if !ids.isEmpty { return ids }
    }
    return recommendedSchemaList
  }

  /// 用户是否已自定义方案列表（default.custom.yaml 存在 patch.schema_list）
  public static func isSchemaListCustomized(paths: ConfigPaths) throws -> Bool {
    if let patch = try readCustomPatch(paths: paths, fileName: "default.custom.yaml"),
       let seq = patch["schema_list"]?.seqNodes, !seq.isEmpty {
      return true
    }
    return false
  }

  /// 某 schema 开关的有效 reset（用户 <schema>.custom.yaml 的 "switches/@N/reset" 优先），
  /// 一并返回用户显式声明过的索引（用于区分"用户已保存"与"schema 默认值"）。
  public static func readSwitchResets(paths: ConfigPaths, schema: SchemaInfo) throws -> (resets: [Int: Int], patchKeys: Set<Int>) {
    var resets: [Int: Int] = [:]
    for sw in schema.switches {
      resets[sw.index] = sw.reset ?? 0
    }
    var patchKeys: Set<Int> = []
    if let patch = try readCustomPatch(paths: paths, fileName: "\(schema.id).custom.yaml"),
       let mapping = patch.mapPairs {
      for (key, value) in mapping {
        guard let keyStr = key.string, keyStr.hasPrefix("switches/@"), keyStr.hasSuffix("/reset") else { continue }
        let mid = keyStr.dropFirst("switches/@".count).dropLast("/reset".count)
        guard let idx = Int(mid) else { continue }
        resets[idx] = value.int
        patchKeys.insert(idx)
      }
    }
    return (resets, patchKeys)
  }

  // MARK: 汇总

  public static func effectiveModel(paths: ConfigPaths) throws -> EffectiveModel {
    let (source, node) = try loadSquirrelYaml(paths: paths)
    let schemas = try RimeSchemas.scan(sharedSupport: paths.sharedSupport)
    let schemaList = try readSchemaList(paths: paths)
    var switchResets: [String: [Int: Int]] = [:]
    var userResetPatchKeys: [String: Set<Int>] = [:]
    for schema in schemas {
      let (resets, patchKeys) = try readSwitchResets(paths: paths, schema: schema)
      switchResets[schema.id] = resets
      if !patchKeys.isEmpty { userResetPatchKeys[schema.id] = patchKeys }
    }
    return EffectiveModel(
      style: readStyle(node),
      colorSchemes: readColorSchemes(node),
      groupColors: readGroupColors(node),
      schemas: schemas,
      schemaList: schemaList,
      schemaListCustomized: try isSchemaListCustomized(paths: paths),
      switchResets: switchResets,
      userResetPatchKeys: userResetPatchKeys,
      squirrelYamlSource: source,
      userSquirrelYamlExists: FileManager.default.fileExists(atPath: paths.userSquirrelYaml.path)
    )
  }
}
