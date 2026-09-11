local russian = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯфисвуапршолдьтщзйкыегмцчня"
local english = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

local langmap = {}
for index = 0, vim.fn.strchars(russian) - 1 do
  local from = vim.fn.strcharpart(russian, index, 1)
  local to = vim.fn.strcharpart(english, index, 1)
  langmap[from] = to
end

return {
  {
    "folke/which-key.nvim",
    config = function(_, opts)
      local which_key = require("which-key")
      which_key.setup(opts)

      -- which-key reads pending keys with getcharstr(), which bypasses 'langmap'.
      local state = require("which-key.state")
      local getchar = state.getchar

      state.getchar = function()
        local ok, char = getchar()
        return ok, langmap[char] or char
      end
    end,
  },
}
