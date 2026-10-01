local vault_path = vim.fn.expand("~/Documents/obsidian")

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    cond = function()
      return vim.fn.isdirectory(vault_path) == 1
    end,
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "personal",
          path = vault_path,
        },
      },
      daily_notes = {
        enabled = true,
        folder = "Journal/Daily",
        date_format = "YYYY-MM-DD",
        workdays_only = false,
      },
    },
  },
}
