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
      picker = {
        name = "snacks.picker",
      },
    },
  },
}
