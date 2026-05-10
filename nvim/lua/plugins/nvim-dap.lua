-- 1. Helper function for "Run with Args"
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  local args_str = type(args) == "table" and table.concat(args, " ") or args

  config = vim.deepcopy(config)
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str))
    if config.type and config.type == "java" then
      return new_args
    end
    return require("dap.utils").splitstr(new_args)
  end
  return config
end

-- 2. Setup DAP Virtual Text
require("nvim-dap-virtual-text").setup({})

-- 3. Setup DAP UI
local dap, dapui = require("dap"), require("dapui")
dapui.setup({})
require("dap-cs").setup()

-- Auto open/close UI
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- 4. VSCode launch.json support
local vscode = require("dap.ext.vscode")
local json = require("plenary.json")
vscode.json_decode = function(str)
  return vim.json.decode(json.json_strip_comments(str))
end

-- 5. Highlight and Signs (Visual markers)
vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "DapStoppedLine" })

-- 6. Keymaps (Integrated with Which-Key descriptions)
local map = vim.keymap.set
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
map("n", "<leader>dc", function() dap.continue() end, { desc = "Continue" })
map("n", "<leader>da", function() dap.continue({ before = get_args }) end, { desc = "Run with Args" })
map("n", "<leader>di", function() dap.step_into() end, { desc = "Step Into" })
map("n", "<leader>do", function() dap.step_out() end, { desc = "Step Out" })
map("n", "<leader>dO", function() dap.step_over() end, { desc = "Step Over" })
map("n", "<leader>dt", function() dap.terminate() end, { desc = "Terminate" })
map("n", "<leader>du", function() dapui.toggle() end, { desc = "Dap UI" })
map({"n", "v"}, "<leader>de", function() dapui.eval() end, { desc = "Eval" })
