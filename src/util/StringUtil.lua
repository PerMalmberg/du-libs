local SU = {}

function SU.CoSplit(str, pat)
   -- http://lua-users.org/wiki/SplitJoin

   local t = {} -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t, cap)
      end
      last_end = e + 1
      s, e, cap = str:find(fpat, last_end)
      coroutine.yield()
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function SU.Round(num, numDecimalPlaces)
   local mult = 10 ^ (numDecimalPlaces or 0)
   return math.floor(num * mult + 0.5) / mult
end

function SU.RemoveDecimal(s)
   return s:gsub("%.%d", "")
end

function PadLeft(s, width)
   if #s < width then
      s = string.rep('&nbsp;', width - #s) .. s
   end

   return s
end

function SU.FormatThousands(value)
   local formatted = value
   local k
   local done = false

   while not done do
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
      done = k == 0
   end

   return formatted
end

function SU.Trim(s)
   return s:match "^%s*(.-)%s*$"
end

---Splits the string into parts, honoring " and ' as quote chars to make multi-word arguments
---@param s string
---@return string[]
function SU.SplitQuoted(s)
   local function isQuote(c) return c == '"' or c == "'" end

   local function isSpace(c) return c == " " end

   local function add(target, v)
      v = SU.Trim(v)
      if v:len() > 0 then
         table.insert(target, #target + 1, v)
      end
   end

   local inQuote = false
   local parts = {} ---@type string[]
   local current = ""

   for c in s:gmatch(".") do
      if isSpace(c) and not inQuote then
         -- End of non-quoted part
         add(parts, current)
         current = ""
      elseif isQuote(c) then
         if inQuote then
            -- End of quote
            add(parts, current)
            current = ""
            inQuote = false
         else
            -- End current, start quoted
            add(parts, current)
            current = ""
            inQuote = true
         end
      else
         current = current .. c
      end
   end

   -- Add whatever is at the end of the string.
   add(parts, current)

   return parts
end

return SU
