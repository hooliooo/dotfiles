-- Rustaceanvim Setup
-- The DAP adapter is not configured here: rustaceanvim auto-detects
-- Mason's codelldb (and falls back to codelldb/lldb-dap on PATH).

-- Show the release-build assembly of the function under the cursor via
-- cargo-show-asm (`cargo install cargo-show-asm`), with Rust source interleaved
local function show_asm()
  local node = vim.treesitter.get_node()
  while node and node:type() ~= "function_item" do
    node = node:parent()
  end
  local name_node = node and node:field("name")[1]
  if not name_node then
    vim.notify("Cursor is not inside a function", vim.log.levels.WARN)
    return
  end
  local fn_name = vim.treesitter.get_node_text(name_node, 0)

  local file = vim.api.nvim_buf_get_name(0)
  local root = vim.fs.root(file, "Cargo.toml")
  local pkg = root and vim.fn.readfile(vim.fs.joinpath(root, "Cargo.toml"))
  local pkg_name
  for _, line in ipairs(pkg or {}) do
    pkg_name = pkg_name or line:match('^name%s*=%s*"([^"]+)"')
  end
  if not pkg_name then
    vim.notify("No [package] Cargo.toml found for this file", vim.log.levels.WARN)
    return
  end

  -- Pick the artifact the file belongs to: src/main.rs or src/bin/* -> binary, else the lib
  local rel = file:sub(#root + 2)
  local bin = rel:match("^src/bin/([^/]+)%.rs$") or rel:match("^src/bin/([^/]+)/main%.rs$")
  if rel == "src/main.rs" then
    bin = pkg_name
  end
  local base = { "cargo", "asm", "-p", pkg_name, bin and ("--bin=" .. bin) or "--lib" }

  -- With no filter cargo asm lists every function as `<index> "<path>" [<lines>]`
  vim.notify("cargo asm: building " .. pkg_name .. " (release)...")
  vim.system(base, { cwd = root, text = true }, function(res)
    vim.schedule(function()
      local out = (res.stdout or "") .. (res.stderr or "")
      if res.code ~= 0 and not out:find("Try one of those") then
        vim.notify("cargo asm failed:\n" .. out, vim.log.levels.ERROR)
        return
      end
      local matches = {}
      for idx, path in out:gmatch('\n(%d+) "([^"]+)"') do
        if path:sub(-(#fn_name + 2)) == "::" .. fn_name then
          table.insert(matches, { idx = idx, path = path })
        end
      end
      local function open(m)
        vim.cmd("botright vnew")
        vim.fn.jobstart(vim.list_extend(vim.deepcopy(base), { "--rust", "--simplify", m.idx }), { cwd = root, term = true })
      end
      if not out:find("Try one of those") then
        -- Only one function in the artifact: cargo asm printed it directly
        open({})
      elseif #matches == 0 then
        vim.notify(
          ("No assembly for `%s` in the release build: it was inlined (small functions are, even `pub` ones) or is unused. Add #[inline(never)] to see it"):format(
            fn_name
          ),
          vim.log.levels.WARN
        )
      elseif #matches == 1 then
        open(matches[1])
      else
        vim.ui.select(matches, {
          prompt = "Function",
          format_item = function(m)
            return m.path
          end,
        }, function(m)
          if m then
            open(m)
          end
        end)
      end
    end)
  end)
end

-- This global variable IS the configuration for rustaceanvim
vim.g.rustaceanvim = {
  tools = {
    -- Run tests in the background; failures show up as diagnostics on the
    -- failing test (with the assertion message) instead of a terminal split
    test_executor = "background",
  },
  server = {
    on_attach = function(_, bufnr)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
      local function rust(...)
        local args = { ... }
        return function()
          vim.cmd.RustLsp(args)
        end
      end
      -- stylua: ignore start
      -- Rust-aware versions of the generic LSP keys
      map("n", "<leader>ca", rust("codeAction"), "Code action (grouped)")
      map("x", "<leader>ca", ":RustLsp codeAction<CR>", "Code action (grouped)")
      map("n", "K", rust("hover", "actions"), "Hover (with actions)")
      map("n", "J", rust("joinLines"), "Join lines (Rust-aware)")
      map("x", "J", ":RustLsp joinLines<CR>", "Join lines (Rust-aware)")
      -- Run / test / debug (rerun the last debug session with <leader>dl)
      map("n", "<leader>rr", rust("runnables"), "Runnables")
      map("n", "<leader>rR", function() vim.cmd.RustLsp({ "runnables", bang = true }) end, "Rerun last runnable")
      map("n", "<leader>rt", rust("testables"), "Testables")
      map("n", "<leader>rT", function() vim.cmd.RustLsp({ "testables", bang = true }) end, "Rerun last test")
      map("n", "<leader>rD", rust("debuggables"), "Debuggables")
      map("n", "<leader>rx", rust("debug"), "Debug target under cursor")
      -- Diagnostics / navigation / tools
      map("n", "<leader>re", rust("explainError"), "Explain error")
      map("n", "<leader>rd", rust("renderDiagnostic"), "Render diagnostic")
      map("n", "<leader>rm", rust("expandMacro"), "Expand macro")
      map("n", "<leader>rc", rust("openCargo"), "Open Cargo.toml")
      map("n", "<leader>ro", rust("openDocs"), "Open docs.rs for symbol")
      map("n", "<leader>rp", rust("parentModule"), "Parent module")
      map("n", "<leader>rk", rust("moveItem", "up"), "Move item up")
      map("n", "<leader>rj", rust("moveItem", "down"), "Move item down")
      map("n", "<leader>rA", show_asm, "Show assembly (release)")
      -- stylua: ignore end
    end,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = false,
          -- Separate target dir so cargo build/run/debug never block on
          -- rust-analyzer's check lock (and vice versa)
          targetDir = true,
        },
        check = { command = "clippy", allTargets = true },
        procMacro = { enable = true },
        -- diagnostics = { experimental = { enable = true } },
        inlayHints = {
          lifetimeElisionHints = { enable = "skip_trivial" },
        },
      },
    },
  },
}

-- Crates.nvim Setup
require("crates").setup({
  completion = { crates = { enabled = true } },
  lsp = { enabled = true, actions = true, completion = true, hover = true },
})

-- Cargo.toml keymaps (crates.nvim), also under <leader>r
vim.api.nvim_create_autocmd("BufRead", {
  group = vim.api.nvim_create_augroup("UserCratesKeymaps", {}),
  pattern = "Cargo.toml",
  callback = function(ev)
    local crates = require("crates")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("n", "<leader>rv", crates.show_versions_popup, "Crate versions")
    map("n", "<leader>rf", crates.show_features_popup, "Crate features")
    map("n", "<leader>ru", crates.upgrade_crate, "Upgrade crate")
    map("x", "<leader>ru", crates.upgrade_crates, "Upgrade selected crates")
    map("n", "<leader>rU", crates.upgrade_all_crates, "Upgrade all crates")
    map("n", "<leader>ro", crates.open_documentation, "Open docs.rs")
    map("n", "<leader>ri", crates.open_crates_io, "Open crates.io")
    map("n", "<leader>rg", crates.open_repository, "Open repository")
  end,
})
