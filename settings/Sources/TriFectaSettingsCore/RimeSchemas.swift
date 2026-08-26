//
//  扫描 SharedSupport 的 *.schema.yaml，解析 switches 结构。
//
import Foundation
import Yams

public struct SchemaSwitch: Equatable {
  /// 该开关在 schema `switches` 列表中的索引（写入 `"switches/@N/reset"` 补丁用）
  public let index: Int
  /// `name:` 形式的开关名（如 full_shape / simplification）
  public let name: String?
  /// `options:` 变体组（如 [zh_hant, zh_hans, ...]）
  public let options: [String]?
  /// 方案内声明的默认 reset（nil = 未声明，等价 0）
  public let reset: Int?
}

public struct SchemaInfo: Equatable {
  public let id: String
  public let displayName: String
  public let switches: [SchemaSwitch]

  /// 简繁开关：`simplification`（二态）或含 zh_hant/zh_hans 的变体组
  public var simplifiedSwitch: SchemaSwitch? {
    if let s = switches.first(where: { $0.name == "simplification" }) { return s }
    return switches.first { $0.options?.contains("zh_hans") == true && $0.options?.contains("zh_hant") == true }
  }

  public var fullShapeSwitch: SchemaSwitch? {
    switches.first { $0.name == "full_shape" }
  }
}

public enum RimeSchemas {
  /// 扫描目录（默认 SharedSupport）下所有 *.schema.yaml
  public static func scan(sharedSupport: URL) throws -> [SchemaInfo] {
    let files = (try? FileManager.default.contentsOfDirectory(
      at: sharedSupport, includingPropertiesForKeys: nil
    ))?.filter {
      $0.pathExtension == "yaml" && $0.lastPathComponent.hasSuffix(".schema.yaml")
    } ?? []
    var result: [SchemaInfo] = []
    for file in files.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
      let id = String(file.lastPathComponent.dropLast(".schema.yaml".count))
      if let info = try? parseSchema(id: id, yamlURL: file) {
        result.append(info)
      }
    }
    return result
  }

  public static func parseSchema(id: String, yamlURL: URL) throws -> SchemaInfo {
    let text = try String(contentsOf: yamlURL, encoding: .utf8)
    return try parseSchema(id: id, yamlText: text, baseURL: yamlURL.deletingLastPathComponent())
  }

  /// 单文件解析（测试用，不做 __include 解析）
  public static func parseSchema(id: String, yamlText: String) throws -> SchemaInfo {
    try parseSchema(id: id, yamlText: yamlText, baseURL: nil)
  }

  private static func parseSchema(id: String, yamlText: String, baseURL: URL?, depth: Int = 0) throws -> SchemaInfo {
    guard depth <= 4 else {
      throw YamlLineEditor.EditorError.malformed("schema \(id) __include 层级过深")
    }
    guard let ownNode = try Yams.compose(yaml: yamlText) else {
      throw YamlLineEditor.EditorError.malformed("schema \(id) 解析失败")
    }

    // 解析 __include（整文件继承）
    var merged = ownNode
    if let includeName = ownNode["__include"]?.scalarString,
       let baseURL = baseURL,
       let includeFile = includeName.split(separator: "/").first,
       !includeFile.isEmpty {
      let includeFile = String(includeFile).hasSuffix(":") ? String(includeFile.dropLast()) : String(includeFile)
      // Rime 的 __include 是"配置名"（无 .yaml 扩展名），实际文件带 .yaml
      let includeURL = baseURL.appendingPathComponent(includeFile + ".yaml")
      if FileManager.default.fileExists(atPath: includeURL.path),
         let includeText = try? String(contentsOf: includeURL, encoding: .utf8),
         let includeNode = try? Yams.compose(yaml: includeText) {
        merged = try mergeNodes(base: includeNode, overlay: ownNode)
      }
    }

    // 应用 __patch 中的 "switches/@N/reset"（列表索引补丁，官方语法）
    // 注：__patch 元键在 mergeNodes 中被剔除，改从原始 ownNode 读取
    var patched = merged
    try applySwitchResetPatches(&patched, patchesFrom: ownNode)

    let displayName = patched["schema"]?["name"]?.string ?? patched["name"]?.string ?? id
    var switches: [SchemaSwitch] = []
    if let seq = patched["switches"]?.seqNodes {
      for (i, item) in seq.enumerated() {
        let name = item["name"]?.string
        let options = item["options"]?.seqNodes?.map { $0.scalarString ?? "" }
        let reset = item["reset"]?.int
        switches.append(SchemaSwitch(index: i, name: name, options: options, reset: reset))
      }
    }
    return SchemaInfo(id: id, displayName: displayName, switches: switches)
  }

  /// overlay 覆盖 base（顶层键合并），忽略 __include/__patch 元键
  private static func mergeNodes(base: Node, overlay: Node) throws -> Node {
    guard case let .mapping(baseMap) = base, case let .mapping(overlayMap) = overlay else {
      return overlay
    }
    var pairs: [(Node, Node)] = baseMap.map { ($0.key, $0.value) }
    let metaKeys: Set<String> = ["__include", "__patch"]
    for (k, v) in overlayMap {
      let keyStr = k.scalarString ?? ""
      if metaKeys.contains(keyStr) { continue }
      if let foundIdx = pairs.firstIndex(where: { $0.0.scalarString == keyStr }) {
        pairs[foundIdx] = (k, v)
      } else {
        pairs.append((k, v))
      }
    }
    return Node(pairs)
  }

  /// 应用 `__patch` 列表里形如 "switches/@N/reset": v 的补丁
  private static func applySwitchResetPatches(_ node: inout Node, patchesFrom source: Node) throws {
    guard let patchSeq = source["__patch"]?.seqNodes else { return }
    for patchMap in patchSeq {
      for (key, value) in patchMap.mapPairs ?? [] {
        guard let path = key.scalarString,
              path.hasPrefix("switches/@"), path.hasSuffix("/reset"),
              let idxStr = Int(path.dropFirst("switches/@".count).dropLast("/reset".count)),
              let reset = value.int else { continue }
        let resetNode = Node.scalar(Node.Scalar(String(reset), Tag(Tag.Name.int)))
        if case let .sequence(seq) = node["switches"] ?? Node.sequence(.init([])), seq.indices.contains(idxStr) {
          var items = Array(seq)
          var item = items[idxStr]
          item["reset"] = resetNode
          items[idxStr] = item
          node["switches"] = Node(items)
        }
      }
    }
  }

}
