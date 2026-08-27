//
//  TestFixtures.swift
//  TriFectaSettingsTests
//
//  内嵌测试基线（取官方 data/squirrel.yaml / default.yaml 的关键片段）。
//

import Foundation

enum Fixtures {
  /// 官方 squirrel.yaml 的核心片段：注释、未知键、21 个配色中的几个、app_options
  static let squirrelYaml = """
  # Squirrel settings
  # encoding: utf-8

  config_version: '1.0'

  # options: last | default | _custom_
  # last: the last used latin keyboard layout
  keyboard_layout: last

  # for veteran chord-typist
  chord_duration: 0.1  # seconds

  # options: always | never | appropriate
  show_notifications_when: appropriate

  status_icon:
    show: true

  style:
    color_scheme: native
    # Optional: define both light and dark color schemes to match system appearance
    #color_scheme_dark: solarized_dark

    # horizontal is Deprecated since 0.36, Squirrel 0.15, removed since 1.0.1
    candidate_list_layout: linear  # linear(横排) close to native macOS candidate bar
    text_orientation: horizontal  # horizontal | vertical
    inline_preedit: true
    inline_candidate: false
    memorize_size: true
    mutual_exclusive: false
    translucency: true
    show_paging: false

    corner_radius: 16
    hilited_corner_radius: 12
    border_height: -2
    border_width: -2
    line_spacing: 1
    spacing: 1
    shadow_size: 0
    #surrounding_extra_expansion: 0

    candidate_format: '[label]. [candidate] [comment]'

    font_face: 'Avenir'
    font_point: 15

  preset_color_schemes:
    native:
      name: 系統配色

    aqua:
      name: 碧水／Aqua
      author: 佛振 <chen.sst@gmail.com>
      text_color: 0x606060
      back_color: 0xeeeceeee
      candidate_text_color: 0x000000
      hilited_text_color: 0x000000
      hilited_candidate_text_color: 0xffffff
      hilited_candidate_back_color: 0xeefa3a0a
      comment_text_color: 0x5a5a5a
      hilited_comment_text_color: 0xfcac9d

    azure:
      name: 青天／Azure
      author: 佛振 <chen.sst@gmail.com>
      text_color: 0xcfa677
      candidate_text_color: 0xffeacc
      back_color: 0xee8b4e01
      hilited_text_color: 0xffeacc
      hilited_candidate_text_color: 0x7ffeff
      hilited_candidate_back_color: 0x00000000
      comment_text_color: 0xc69664

  # 用户自定义方案开关（未知键，设置 app 不得破坏）
  unknown_user_key:
    keep: true

  app_options:
    com.apple.Spotlight:
      ascii_mode: true
    com.googlecode.iterm2:
      ascii_mode: true
      no_inline: true
  """

  /// 官方 SharedSupport default.yaml 片段
  static let defaultYaml = """
  # Rime default settings
  # encoding: utf-8

  config_version: '0.50'

  schema_list:
    - schema: luna_pinyin_simp
    - schema: luna_pinyin
    - schema: bopomofo
    - schema: cangjie5
    - schema: stroke
    - schema: terra_pinyin

  switcher:
    caption: 〔方案選單〕
    hotkeys:
      - Control+grave
      - Control+Shift+grave
      - F4
    save_options:
      - full_shape
      - ascii_punct
      - simplification
      - extended_charset
      - zh_hant
      - zh_hans
      - zh_hant_tw
    fold_options: true
    abbreviate_options: true
    option_list_separator: '／'

  menu:
    page_size: 5

  ascii_composer:
    good_old_caps_lock: true
    switch_key:
      Shift_L: inline_ascii
      Shift_R: inline_ascii
      Control_L: noop
      Control_R: noop
      Caps_Lock: clear
      Eisu_toggle: clear
  """

  /// luna_pinyin.schema.yaml 的 switches 片段
  static let lunaPinyinSchema = """
  schema:
    schema_id: luna_pinyin
    name: 朙月拼音
    version: "0.21"
  switches:
    - name: ascii_mode
      reset: 0
      states: [ 中文, 西文 ]
      abbrev: [ 中, Ａ ]
    - name: full_shape
      states: [ 半角, 全角 ]
    - options:
        - zh_hant
        - zh_hans
        - zh_hant_hk
        - zh_hant_tw
      states:
        - 傳統漢字
        - 简化字
        - 香港字形
        - 臺灣字形
      abbrev: [ 漢, 简, 港, 臺 ]
    - name: ascii_punct
      states: [ 。，, ．， ]
  """

  /// 带 __include + __patch 的完整方案（如 luna_pinyin_simp）
  static let simpSchema = """
  # Rime schema
  __include: luna_pinyin.schema:/
  __patch:
    - switches/@2/reset: 1
    - luna_pinyin_simp.custom:/patch?
  schema:
    schema_id: luna_pinyin_simp
    name: 朙月拼音·简化字
  """

  /// terra_pinyin.schema.yaml 的 switches 片段
  static let terraPinyinSchema = """
  schema:
    schema_id: terra_pinyin
    name: 地球拼音
  switches:
    - name: ascii_mode
      reset: 0
      states: [ 中文, 西文 ]
      abbrev: [ 中, Ａ ]
    - name: full_shape
      states: [ 半角, 全角 ]
    - name: simplification
      states: [ 漢字, 汉字 ]
    - name: ascii_punct
      states: [ 。，, ．， ]
  """
}
