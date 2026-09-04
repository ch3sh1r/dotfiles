return {
	{
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/obsidian",
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
