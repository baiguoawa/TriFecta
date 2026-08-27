-- quote.lua
-- 单双引号左右交替 + 超时重置（Rime / librime-lua）
-- 行为：中文模式下按一次'输出左引号，短时间再按输出右引号，再按回左引号；
--      超过 RESET_SECONDS 无输入则重置为输出左引号。
-- 用法（scheme）：processors 中加入  - lua_processor@*quote
local quote = {}

-- 需要记录各自输出状态的引号
local state = {}   -- key_repr -> 是否"已出左(下个应出右)"
local last  = {}   -- key_repr -> 上次时间
local RESET_SECONDS = 2.0

local function map(name)
  if name == "apostrophe" then
    return { left = "‘", right = "’", entry = "apostrophe" }
  end
  if name == "quotedbl" or name == "quotation" or name == "quotedbl" then
    return { left = "“", right = "”", entry = "quotedbl" }
  end
  return nil
end

function quote.init(env)
  -- 可选：从配置读取 reset 秒数
  local sec = env.engine.schema.config:get_double('quote/auto_reset_seconds')
  if sec and sec > 0 then RESET_SECONDS = sec end
end

function quote.func(key, env)
  if key:release() then
    return 1  -- kNoop
  end
  local repr = key:repr()
  local m = map(repr) or map(string.lower(repr or ""))
  if not m then
    return 1  -- kNoop，继续后续处理器（非引号键）
  end

  local t = os.clock()
  local shouldLeft = true
  if state[m.entry] and (t - (last[m.entry] or -999)) < RESET_SECONDS then
    shouldLeft = false
  end
  last[m.entry] = t
  state[m.entry] = shouldLeft

  env.engine:commit_text(shouldLeft and m.left or m.right)
  return 0  -- kAccepted，消费该键
end

return quote
