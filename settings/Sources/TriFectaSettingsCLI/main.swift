//
//  冒烟 CLI：无 GUI 驱动核心逻辑（测试与 CI 用）。
//  用法：
//    trifecta-settings-cli dump
//    trifecta-settings-cli set <key>=<value> [<key>=<value> ...]
//    trifecta-settings-cli deploy
//    trifecta-settings-cli sync
//    trifecta-settings-cli restore
//    trifecta-settings-cli path
//  支持的 set 键：
//    style.color_scheme / style.candidate_list_layout / style.text_orientation
//    style.font_face / style.font_point / style.candidate_format
//    group_colors.enabled / group_colors.red / group_colors.yellow / group_colors.green
//    schema_list=a,b,c
//    input.full_shape=0|1        （默认方案的 full_shape reset）
//    input.simplified=0|1        （默认方案的简繁 reset）
//    shortcuts.shift=on|off
//

import Foundation
import TriFectaSettingsCore

func fail(_ msg: String) -> Never {
  FileHandle.standardError.write(Data("错误：\(msg)\n".utf8))
  exit(1)
}

func main() {
  let args = CommandLine.arguments
  guard args.count > 1 else {
    print("用法：trifecta-settings-cli <dump|set|deploy|sync|restore|path> ...")
    exit(1)
  }
  let repo = SettingsRepository()
  let command = args[1]

  switch command {
  case "dump":
    do {
      let model = try RimeModel.effectiveModel(paths: repo.paths)
      print("userDir: \(repo.paths.userDir.path)")
      print("imeApp: \(repo.paths.imeAppURL.path)")
      print("squirrelYaml: \(model.squirrelYamlSource == .user(repo.paths.userSquirrelYaml) ? "user" : "shared")")
      print("colorScheme: \(model.style.colorScheme)")
      print("candidateListLayout: \(model.style.candidateListLayout)")
      print("textOrientation: \(model.style.textOrientation)")
      print("fontFace: \(model.style.fontFace)")
      print("fontPoint: \(model.style.fontPoint)")
      print("candidateFormat: \(model.style.candidateFormat)")
      print("groupColorsEnabled: \(model.groupColors.enabled)")
      print("groupColors: \(RimeModel.hexDump(model.groupColors.red)) \(RimeModel.hexDump(model.groupColors.yellow)) \(RimeModel.hexDump(model.groupColors.green))")
      print("colorSchemes: \(model.colorSchemes.map { "\($0.0)(\($0.1))" }.joined(separator: ", "))")
      print("schemaList: \(model.schemaList.joined(separator: ","))")
      print("schemas: \(model.schemas.map { $0.id }.joined(separator: ","))")
      print("shiftEnabled: \(model.shiftEnabled)")
      for (id, resets) in model.switchResets.sorted(by: { $0.key < $1.key }) {
        print("switches[\(id)]: \(resets.sorted { $0.key < $1.key }.map { "@\($0.key)=\($0.value)" }.joined(separator: " "))")
      }
    } catch {
      fail(String(describing: error))
    }

  case "set":
    do {
      var style: StyleValues?
      var gc: GroupColorsValues?
      var schemaList: [String]?
      var shift: Bool?
      var resets: [String: [Int: Int]] = [:]
      let model = try RimeModel.effectiveModel(paths: repo.paths)
      for arg in args.dropFirst(2) {
        guard let eq = arg.firstIndex(of: "=") else { fail("参数格式应为 key=value：\(arg)") }
        let key = String(arg[..<eq])
        let value = String(arg[arg.index(after: eq)...])
        switch key {
        case "style.color_scheme", "style.candidate_list_layout", "style.text_orientation",
             "style.font_face", "style.candidate_format":
          var s = style ?? model.style
          switch key {
          case "style.color_scheme": s.colorScheme = value
          case "style.candidate_list_layout": s.candidateListLayout = value
          case "style.text_orientation": s.textOrientation = value
          case "style.font_face": s.fontFace = value
          default: s.candidateFormat = value
          }
          style = s
        case "style.font_point":
          guard let v = Double(value) else { fail("font_point 应为数字") }
          var s = style ?? model.style
          s.fontPoint = v
          style = s
        case "group_colors.enabled":
          var c = gc ?? model.groupColors
          guard value == "true" || value == "false" else { fail("enabled 应为 true/false") }
          c.enabled = value == "true"
          gc = c
        case "group_colors.red", "group_colors.yellow", "group_colors.green":
          var c = gc ?? model.groupColors
          guard let v = RimeModel.hexColorValue(value) else { fail("颜色应为 0xAABBGGRR 形式") }
          switch key {
          case "group_colors.red": c.red = v
          case "group_colors.yellow": c.yellow = v
          default: c.green = v
          }
          gc = c
        case "schema_list":
          schemaList = value.split(separator: ",").map(String.init)
        case "input.full_shape":
          guard let schemaID = model.schemaList.first,
                let idx = model.schemas.first(where: { $0.id == schemaID })?.fullShapeSwitch?.index else {
            fail("默认方案无 full_shape 开关")
          }
          var d = resets[schemaID] ?? [:]
          d[idx] = value == "1" ? 1 : 0
          resets[schemaID] = d
        case "input.simplified":
          guard let schema = model.schemas.first(where: { $0.id == model.schemaList.first }),
                let sw = schema.simplifiedSwitch else {
            fail("默认方案无简繁开关")
          }
          var d = resets[schema.id] ?? [:]
          d[sw.index] = value == "1" ? 1 : 0
          resets[schema.id] = d
        case "shortcuts.shift":
          guard value == "on" || value == "off" else { fail("shift 应为 on/off") }
          shift = value == "on"
        default:
          fail("未知键：\(key)")
        }
      }
      let changes = ChangeSet(style: style, groupColors: gc, schemaList: schemaList,
                              switchResets: resets.isEmpty ? nil : resets, shiftEnabled: shift)
      let outcome = try repo.apply(changes, deploy: false)
      print("已写入：\(outcome.filesWritten.map { $0.path }.joined(separator: " "))")
      print("squirrel.yaml 首次创建：\(outcome.squirrelYamlCreated)")
    } catch {
      fail(String(describing: error))
    }

  case "deploy":
    let running = Deployer.reload(paths: repo.paths)
    print(running ? "已向运行中的输入法投递重新部署通知" : "输入法未运行，已在 SharedSupport 目录后台执行 --build")

  case "sync":
    Deployer.syncUserData()
    print("已投递同步用户数据通知")

  case "restore":
    do {
      let moved = try repo.resetToBaseline()
      print(moved.isEmpty ? "无用户配置可还原" : "已还原：\(moved.map { $0.path }.joined(separator: " "))")
    } catch {
      fail(String(describing: error))
    }

  case "path":
    print("userDir: \(repo.paths.userDir.path)")
    print("imeApp: \(repo.paths.imeAppURL.path)")
    print("sharedSupport: \(repo.paths.sharedSupport.path)")

  default:
    fail("未知命令：\(command)")
  }
}

main()
