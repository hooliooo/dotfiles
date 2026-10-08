-- Built-in defaults cover the rest: grr (references), grt (type definition),
-- gri (implementation), grn (rename), gra (code action), K (hover), <C-s> (signature help, insert)
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

    opts.desc = "Goto Implementation"
    vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)

    opts.desc = "See available code actions"
    vim.keymap.set({ "n", "x" }, "<leader>ca", function()
      vim.lsp.buf.code_action()
    end, opts)

    opts.desc = "Rename"
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)

    opts.desc = "Show line diagnostics"
    vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)

    opts.desc = "Restart LSP"
    vim.keymap.set("n", "<leader>cl", "<cmd>lsp restart<CR>", opts)
  end,
})

-- sourcekit-lsp returns no inlay hints until it has indexed the file and doesn't
-- ask for a refresh afterwards, so re-request them whenever its indexing ends
vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("UserSourcekitInlayHints", {}),
  pattern = "end",
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "sourcekit" then
      return
    end
    for _, buf in ipairs(vim.lsp.get_buffers_by_client_id(client.id)) do
      if vim.lsp.inlay_hint.is_enabled({ bufnr = buf }) then
        vim.lsp.inlay_hint.enable(false, { bufnr = buf })
        vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      end
    end
  end,
})

-- Show LSP progress (e.g. indexing) as native progress messages
vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("UserLspProgress", {}),
  callback = function(ev)
    local value = ev.data.params.value
    vim.api.nvim_echo({ { value.message or "done" } }, false, {
      id = "lsp." .. ev.data.params.token,
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
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

-- roslyn: roslyn.nvim provides cmd/filetypes/root_dir and enables the server;
-- this only adds settings on top
vim.lsp.config("roslyn", {
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
      dotnet_analyzer_diagnostics_scope = "fullSolution",
      dotnet_compiler_diagnostics_scope = "fullSolution",
    },
  },
})

-- sourcekit
vim.lsp.config("sourcekit", {
  cmd = { "xcrun", "sourcekit-lsp" },
  filetypes = { "swift" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local dir = vim.fs.dirname(fname)
    local root = vim.fs.root(dir, { "Package.swift" }) or vim.fs.root(dir, { "buildServer.json" }) or vim.fs.root(dir, { ".git" })
    on_dir(root)
  end,
})

vim.lsp.enable({
  "lua_ls",
  "sourcekit",
  "taplo",
})

vim.lsp.inlay_hint.enable(true)
vim.lsp.codelens.enable(true)
