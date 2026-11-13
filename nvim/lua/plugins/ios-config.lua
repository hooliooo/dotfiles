-- iOS development: xcodebuild.nvim (build/run on simulator or device, tests, coverage,
-- debugging) plus Instruments profiling via xctrace and XCTest performance metrics.
-- Open nvim at the project root and run <leader>iS once per project.
-- Physical devices need iOS 17+ (installs and launches go through devicectl).

local function progress(title, msg, status)
  vim.api.nvim_echo({ { msg } }, false, { id = "xcodebuild", kind = "progress", source = "xcodebuild", title = title, status = status })
end

require("xcodebuild").setup({
  logs = {
    -- Live test progress ("Running tests [12/40]") as a progress message, like LSP indexing
    notify_progress = function(message)
      progress("xcodebuild", message, "running")
    end,
  },
  code_coverage = { enabled = true },
  integrations = {
    -- Only needed for devices below iOS 17
    pymobiledevice = { enabled = false },
    telescope_nvim = { enabled = false },
    fzf_lua = { enabled = false },
    snacks_nvim = { enabled = true },
  },
})

-- Uses Xcode's lldb-dap. Sets dap.configurations.swift = { "iOS App Debugger" }, which
-- must stay first: xcodebuild.nvim always starts dap.configurations.swift[1]
local xcode_dap = require("xcodebuild.integrations.dap")
xcode_dap.setup()

local function settings()
  return require("xcodebuild.project.config").settings
end

---------------------------------------------------------------------------
-- Profiling: record an Instruments trace with xctrace, then open it in Instruments
---------------------------------------------------------------------------
local preferred_templates = {
  "Time Profiler",
  "Allocations",
  "Leaks",
  "Swift Concurrency",
  "SwiftUI",
  "Animation Hitches",
  "App Launch",
  "Network",
}
local templates_cache

local function list_templates()
  if templates_cache then
    return templates_cache
  end
  local out = vim.system({ "xcrun", "xctrace", "list", "templates" }, { text = true }):wait().stdout or ""
  local available = {}
  for line in out:gmatch("[^\n]+") do
    if not line:match("^==") and vim.trim(line) ~= "" then
      available[vim.trim(line)] = true
    end
  end
  local result = {}
  for _, name in ipairs(preferred_templates) do
    if available[name] then
      table.insert(result, name)
      available[name] = nil
    end
  end
  local rest = vim.tbl_keys(available)
  table.sort(rest)
  templates_cache = vim.list_extend(result, rest)
  return templates_cache
end

local function traces_dir()
  return vim.fs.joinpath(vim.fn.getcwd(), ".nvim", "traces")
end

-- Trace bundle names, newest first (names end in a timestamp)
local function list_traces()
  local traces = {}
  for name, kind in vim.fs.dir(traces_dir()) do
    if kind == "directory" and name:match("%.trace$") then
      table.insert(traces, name)
    end
  end
  local function stamp(name)
    return name:match("%d+%-%d+%.trace$") or ""
  end
  table.sort(traces, function(a, b)
    return stamp(a) > stamp(b)
  end)
  return traces
end

-- mode: "launch" starts the app under the profiler (needed for App Launch),
-- "attach" profiles the already running app
local function profile(mode)
  local s = settings()
  if not (s.destination and s.appPath and s.productName) then
    vim.notify("Configure (<leader>iS) and build (<leader>ib) the app first", vim.log.levels.WARN)
    return
  end
  if mode == "launch" and not vim.uv.fs_stat(s.appPath) then
    vim.notify("No build at " .. s.appPath .. ", build first (<leader>ib)", vim.log.levels.WARN)
    return
  end

  vim.ui.select(list_templates(), { prompt = "Instruments template" }, function(template)
    if not template then
      return
    end
    local dir = traces_dir()
    vim.fn.mkdir(dir, "p")
    local out = vim.fs.joinpath(dir, ("%s-%s-%s.trace"):format(s.productName, template:gsub("%s+", "-"), os.date("%Y%m%d-%H%M%S")))

    local cmd = { "xcrun", "xctrace", "record", "--no-prompt", "--template", template, "--device", s.destination, "--output", out }
    if mode == "launch" then
      local simulator = require("xcodebuild.core.constants").is_simulator(s.platform)
      if simulator then
        -- xctrace launches by path, so the latest build has to be on the simulator
        vim.system({ "xcrun", "simctl", "boot", s.destination }):wait()
        local install = vim.system({ "xcrun", "simctl", "install", s.destination, s.appPath }, { text = true }):wait()
        if install.code ~= 0 then
          vim.notify("simctl install failed:\n" .. (install.stderr or ""), vim.log.levels.ERROR)
          return
        end
      end
      vim.list_extend(cmd, { "--launch", "--", s.appPath })
    else
      vim.list_extend(cmd, { "--attach", s.productName })
    end

    vim.cmd("botright 12new")
    vim.fn.jobstart(cmd, {
      term = true,
      on_exit = function()
        vim.schedule(function()
          if vim.uv.fs_stat(out) then
            vim.ui.open(out)
          else
            vim.notify("xctrace produced no trace, see its terminal output", vim.log.levels.WARN)
          end
        end)
      end,
    })
    vim.notify(template .. ": recording, press <C-c> in the terminal to stop and open Instruments")
    vim.cmd("startinsert")
  end)
end

local function open_trace()
  local traces = list_traces()
  if #traces == 0 then
    vim.notify("No traces in " .. traces_dir(), vim.log.levels.WARN)
    return
  end
  vim.ui.select(traces, { prompt = "Open trace in Instruments" }, function(choice)
    if choice then
      vim.ui.open(vim.fs.joinpath(traces_dir(), choice))
    end
  end)
end

---------------------------------------------------------------------------
-- Benchmarks: XCTest measure {} results from the last test run, in the quickfix list
---------------------------------------------------------------------------
-- e.g. /path/PerfTests.swift:15: Test Case '-[App.PerfTests testSort]' measured [Time, seconds]
--      average: 0.012, relative standard deviation: 4.5%, values: [...], ..., baselineAverage: 0.010, ...
local function parse_metrics()
  local path = require("xcodebuild.project.appdata").original_logs_filepath
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return {}
  end
  local items = {}
  for _, line in ipairs(lines) do
    local test, metric, avg, rsd = line:match("Test Case '(.-)' measured %[(.-)%] average: ([^,]+), relative standard deviation: ([^,]+)")
    if test then
      local file, lnum = line:match("^(/[^:]+):(%d+): ")
      local baseline = line:match("baselineAverage: ([%d%.]+)")
      -- "-[Target.Class testName]" -> "Class.testName"
      local class, name = test:match("^%-%[(%S+) (%S+)%]$")
      test = class and (class:match("[^.]+$") .. "." .. name) or test
      local text = ("%s  %s avg %s ±%s"):format(test, metric, avg, rsd)
      if baseline then
        text = text .. "  (baseline " .. baseline .. ")"
      end
      table.insert(items, { filename = file, lnum = tonumber(lnum) or 1, type = "I", text = text })
    end
  end
  return items
end

local function show_metrics()
  local items = parse_metrics()
  if #items == 0 then
    vim.notify("No measure {} results in the last test run", vim.log.levels.WARN)
    return
  end
  vim.fn.setqflist({}, " ", { title = "XCTest performance metrics", items = items })
  vim.cmd("botright copen")
end

vim.api.nvim_create_autocmd("User", {
  pattern = "XcodebuildTestsFinished",
  group = vim.api.nvim_create_augroup("UserXcodebuildMetrics", {}),
  callback = function()
    local count = #parse_metrics()
    if count > 0 then
      vim.notify(count .. " performance metric(s) recorded, <leader>im to view")
    end
  end,
})

---------------------------------------------------------------------------
-- Cleanup: DerivedData and profiling traces. Test/build .xcresult bundles need no
-- cleanup: xcodebuild.nvim replaces them on every run
---------------------------------------------------------------------------
local KEEP_TRACES = 3

local function delete_derived_data_all()
  local dir = vim.fs.normalize("~/Library/Developer/Xcode/DerivedData")
  if vim.fn.confirm("Delete everything in " .. dir .. "?", "&Yes\n&No", 2) ~= 1 then
    return
  end
  progress("DerivedData", "deleting", "running")
  -- Contents only: Xcode expects the folder itself to exist
  local entries = vim.fn.glob(dir .. "/*", true, true)
  vim.system(vim.list_extend({ "rm", "-rf" }, entries), {}, function(res)
    vim.schedule(function()
      if res.code == 0 then
        progress("DerivedData", "deleted, rebuild to restore indexing", "success")
      else
        progress("DerivedData", "rm failed (exit " .. res.code .. ")", "failed")
      end
    end)
  end)
end

local function delete_traces(traces)
  for _, name in ipairs(traces) do
    vim.fn.delete(vim.fs.joinpath(traces_dir(), name), "rf")
  end
  vim.notify(("Deleted %d trace(s)"):format(#traces))
end

local function cleanup()
  local traces = list_traces()
  local actions = {
    {
      "DerivedData: this project",
      function()
        vim.cmd("XcodebuildCleanDerivedData")
      end,
    },
    { "DerivedData: all projects", delete_derived_data_all },
  }
  if #traces > 0 then
    local size = vim.trim(vim.fn.system({ "du", "-sh", traces_dir() }):match("^%S+") or "?")
    table.insert(actions, {
      ("Profiling traces: delete all (%d, %s)"):format(#traces, size),
      function()
        delete_traces(traces)
      end,
    })
    if #traces > KEEP_TRACES then
      table.insert(actions, {
        ("Profiling traces: keep newest %d (delete %d)"):format(KEEP_TRACES, #traces - KEEP_TRACES),
        function()
          delete_traces(vim.list_slice(traces, KEEP_TRACES + 1))
        end,
      })
    end
  end
  vim.ui.select(actions, {
    prompt = "Clean up",
    format_item = function(item)
      return item[1]
    end,
  }, function(choice)
    if choice then
      choice[2]()
    end
  end)
end

---------------------------------------------------------------------------
-- Keymaps
---------------------------------------------------------------------------
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- stylua: ignore start
map("n", "<leader>ii", "<cmd>XcodebuildPicker<cr>", "All actions")
map("n", "<leader>iS", "<cmd>XcodebuildSetup<cr>", "Setup project")
map("n", "<leader>is", "<cmd>XcodebuildSelectScheme<cr>", "Select scheme")
map("n", "<leader>iv", "<cmd>XcodebuildSelectDevice<cr>", "Select device/simulator")
map("n", "<leader>iP", "<cmd>XcodebuildSelectTestPlan<cr>", "Select test plan")
map("n", "<leader>iX", "<cmd>XcodebuildOpenInXcode<cr>", "Open in Xcode")

map("n", "<leader>ib", "<cmd>XcodebuildBuild<cr>", "Build")
map("n", "<leader>iB", "<cmd>XcodebuildCleanBuild<cr>", "Clean build")
map("n", "<leader>ix", cleanup, "Clean up (DerivedData, traces)")
map("n", "<leader>ir", "<cmd>XcodebuildBuildRun<cr>", "Build & run")
map("n", "<leader>iR", "<cmd>XcodebuildRun<cr>", "Run without building")
map("n", "<leader>ik", "<cmd>XcodebuildCancel<cr>", "Cancel action")
map("n", "<leader>il", "<cmd>XcodebuildToggleLogs<cr>", "Toggle logs")
map("n", "<leader>ia", "<cmd>XcodebuildCodeActions<cr>", "Xcode code actions")

map("n", "<leader>it", "<cmd>XcodebuildTestNearest<cr>", "Test nearest")
map("v", "<leader>it", "<cmd>XcodebuildTestSelected<cr>", "Test selected")
map("n", "<leader>iT", "<cmd>XcodebuildTestClass<cr>", "Test class")
map("n", "<leader>ig", "<cmd>XcodebuildTestTarget<cr>", "Test target")
map("n", "<leader>iA", "<cmd>XcodebuildTest<cr>", "Test all (test plan)")
map("n", "<leader>if", "<cmd>XcodebuildTestFailing<cr>", "Rerun failing tests")
map("n", "<leader>i.", "<cmd>XcodebuildTestRepeat<cr>", "Repeat last tests")
map("n", "<leader>ie", "<cmd>XcodebuildTestExplorerToggle<cr>", "Test explorer")
map("n", "<leader>ic", "<cmd>XcodebuildToggleCodeCoverage<cr>", "Toggle coverage marks")
map("n", "<leader>iC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", "Coverage report")
map("n", "<leader>in", "<cmd>XcodebuildFailingSnapshots<cr>", "Failing snapshots")

map("n", "<leader>id", xcode_dap.build_and_debug, "Build & debug")
map("n", "<leader>iD", xcode_dap.debug_without_build, "Debug without building")
map("n", "<leader>iy", xcode_dap.debug_func_test, "Debug nearest test")
map("n", "<leader>iY", xcode_dap.debug_class_tests, "Debug class tests")

map("n", "<leader>ip", function() profile("launch") end, "Profile (launch app)")
map("n", "<leader>io", function() profile("attach") end, "Profile (attach to running app)")
map("n", "<leader>iO", open_trace, "Open recorded trace")
map("n", "<leader>im", show_metrics, "Performance metrics (last test run)")

map("n", "<leader>iw", "<cmd>XcodebuildPreviewGenerateAndShow<cr>", "SwiftUI preview")
map("n", "<leader>iW", "<cmd>XcodebuildPreviewToggle<cr>", "Toggle preview")
-- stylua: ignore end

-- In an Xcode app project, <leader>dc starts the app under the debugger instead of
-- prompting for a configuration (SwiftPM packages keep the regular picker)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "swift",
  group = vim.api.nvim_create_augroup("UserIosDap", {}),
  callback = function(ev)
    vim.keymap.set("n", "<leader>dc", function()
      local dap = require("dap")
      if dap.session() or not require("xcodebuild.project.config").is_app_configured() then
        dap.continue()
      else
        xcode_dap.build_and_debug()
      end
    end, { buffer = ev.buf, desc = "Continue / build & debug app" })
  end,
})
