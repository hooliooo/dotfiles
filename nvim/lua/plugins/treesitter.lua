local treesitter = require("nvim-treesitter")

local ensure_installed = {
  "bash",
  "c",
  "c_sharp",
  "css",
  "dockerfile",
  "gitignore",
  "go",
  "html",
  "http",
  "java",
  "json",
  "kotlin",
  "lua",
  "markdown",
  "markdown_inline",
  "regex",
  "rust",
  "swift",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "yaml",
}

treesitter.install(ensure_installed)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype

    if ft == "kotlin" then
      -- Bypass Tree-sitter and enforce native smartindent for Kotlin
      vim.bo[buf].indentexpr = ""
      vim.bo[buf].smartindent = true
      vim.bo[buf].cindent = false
    elseif ft == "cs" then
      -- nvim-treesitter has no c_sharp indents query, so its indentexpr is a no-op.
      -- Use native cindent (brace-based) instead — ideal for C#.
      vim.bo[buf].indentexpr = ""
      vim.bo[buf].smartindent = false
      vim.bo[buf].cindent = true
    end

    local lang = vim.treesitter.language.get_lang(ft)
    if not lang or not pcall(vim.treesitter.language.add, lang) or not pcall(vim.treesitter.start, buf, lang) then
      return
    end

    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

    -- Tree-sitter indentation only where the parser ships an indents query;
    -- everything else keeps the filetype's own indent settings
    if ft ~= "kotlin" and ft ~= "cs" and ft ~= "yaml" and ft ~= "markdown" and vim.treesitter.query.get(lang, "indents") then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.bo[buf].smartindent = false
      vim.bo[buf].cindent = false
    end
  end,
})
