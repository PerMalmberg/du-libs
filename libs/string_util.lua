function split(str, pat)
    -- http://lua-users.org/wiki/SplitJoin

   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t, cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function round(num, numDecimalPlaces)
   local mult = 10^(numDecimalPlaces or 0)
   return math.floor(num * mult + 0.5) / mult
end

function removeDecimal(s)
   return s:gsub("%.%d", "")
end

function padLeft(s, width)
   if #s < width then
       s = string.rep('&nbsp;', width - #s) .. s
   end

   return s
end

function formatThousands(value)
   local formatted = value
   done = false

   while not done do
       formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
       done = k == 0
   end

   return formatted
end
