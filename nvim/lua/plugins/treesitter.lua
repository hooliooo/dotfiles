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
  "tsx",
  "typescript",
  "vim",
  "yaml",
}

treesitter.install(ensure_installed)

vim.treesitter.language.register("markdown", "noice")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype
    -- enable indentation only for real languages
    if ft == "kotlin" then
      -- Bypass Tree-sitter and enforce native smartindent for Kotlin
      vim.bo[buf].indentexpr = ""
      vim.bo[buf].smartindent = true
      vim.bo[buf].cindent = false
    elseif ft ~= "yaml" and ft ~= "markdown" then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.bo[buf].smartindent = false
      vim.bo[buf].cindent = false
    end

    local lang = vim.treesitter.language.get_lang(ft)

    if not lang then
      return
    end

    -- load parser safely
    local ok_add = pcall(vim.treesitter.language.add, lang)
    if not ok_add then
      return
    end

    -- start treesitter safely
    pcall(vim.treesitter.start, buf, lang)
  end,
})
