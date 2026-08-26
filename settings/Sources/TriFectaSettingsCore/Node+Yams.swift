//
//  Yams Node 便捷访问（mapping/sequence）。
//
import Foundation
import Yams

extension Node {
  /// mapping 形式的键值对（无则 nil）
  public var mapPairs: [(key: Node, value: Node)]? {
    if case .mapping(let m) = self {
      return m.map { ($0.key, $0.value) }
    }
    return nil
  }

  /// sequence 形式（无则 nil）
  public var seqNodes: [Node]? {
    if case .sequence(let s) = self { return Array(s) }
    return nil
  }

  public var scalarString: String? {
    if case .scalar(let s) = self { return s.string }
    return nil
  }
}
