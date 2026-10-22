local mason = require("mason")
local mason_tool_installer = require("mason-tool-installer")

mason.setup({
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry",
  },
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
  PATH = "append",
})

mason_tool_installer.setup({
  ensure_installed = {
    "codelldb",
    "csharpier",
    "dockerfile-language-server",
    "json-lsp",
    "ktlint",
    "lua-language-server",
    "roslyn",
    "taplo",
    "yaml-language-server",
  },
})
