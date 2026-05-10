vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Buffer local mappings
    local opts = { buffer = ev.buf, silent = true }
    -- Keymaps
    opts.desc = "Goto Definition"
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

    opts.desc = "Goto Declaration"
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

    opts.desc = "References"
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

    opts.desc = "Goto Implementation"
    vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)

    opts.desc = "Goto Type Definition"
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

    opts.desc = "See available code actions"
    vim.keymap.set({ "n", "x" }, "<leader>ca", function()
      vim.lsp.buf.code_action()
    end, opts)

    opts.desc = "Rename"
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)

    opts.desc = "Show buffer diagnostics"
    vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

    opts.desc = "Show line diagnostics"
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

    opts.desc = "Show documentation for what is under cursor"
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    opts.desc = "Restart LSP"
    vim.keymap.set("n", "<leader>rs", ":lsp restart<CR>", opts)

    vim.keymap.set("i", "<C-h>", function()
      vim.lsp.buf.signature_help()
    end, opts)
  end,
})

-- Configure and enable LSP servers
-- lua_ls
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      completion = {
        callSnippet = "Replace",
      },
    },
  },
})

-- roslyn

local roslyn_cmd = {
  "roslyn",
  "--stdio",
  "--logLevel=Information",
  "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
  -- "--razorSourceGenerator=" .. vim.fs.joinpath(rzls_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
  -- "--razorDesignTimePath=" .. vim.fs.joinpath(rzls_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets"),
  "--extension",
  -- vim.fs.joinpath(rzls_path, "RazorExtension", "Microsoft.VisualStudioCode.RazorExtension.dll"),
}
vim.lsp.config("roslyn", {
  cmd = roslyn_cmd,
  -- handlers = require("rzls.roslyn_handlers"),
  filetypes = { "cs" },
  root_markers = { { ".sln", ".csproj", "project.json" }, ".git" },
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,

      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
    ["csharp|completion"] = {
      dotnet_show_name_completion_suggestions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
    },
    ["csharp|background_analysis"] = {
      background_analysis = {
        dotnet_analyzer_diagnostics_scope = "fullSolution",
        dotnet_compiler_diagnostics_scope = "fullSolution",
      },
    },
  },
})

-- sourcekit
vim.lsp.config("sourcekit", {
  cmd = { "sourcekit-lsp" },
  filetypes = { "swift" },
  root_markers = { ".git", "compile_commands.json", ".sourcekit-lsp", "Package.swift" },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = true },
    },
    textDocument = {
      diagnostic = {
        dynamicRegistration = true,
        relatedDocumentSupport = true,
      },
    },
  },
})

vim.lsp.enable({
  "lua_ls",
  "roslyn",
  "sourcekit",
})
