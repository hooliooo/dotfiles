-- SwiftPM tasks (build/test/lint into quickfix, run in a terminal) and
-- debugging via Xcode's lldb-dap

local function package_root()
  local root = vim.fs.root(0, "Package.swift")
  if not root then
    vim.notify("No Package.swift found above this file", vim.log.levels.WARN)
  end
  return root
end

local function progress(title, msg, status)
  vim.api.nvim_echo({ { msg } }, false, { id = "swift." .. title, kind = "progress", source = "swift", title = title, status = status })
end

-- Swift Testing reports only the file name ("recorded an issue at Foo.swift:6:5"),
-- so look it up inside the package
local function resolve(root, name)
  if name:sub(1, 1) == "/" then
    return name
  end
  for _, dir in ipairs({ "Tests", "Sources" }) do
    local found = vim.fs.find(name, { path = vim.fs.joinpath(root, dir), type = "file", limit = 1 })[1]
    if found then
      return found
    end
  end
  return vim.fs.joinpath(root, name)
end

-- Parses compiler/swiftlint (file:line:col: error: msg), XCTest (file:line: error: msg)
-- and Swift Testing (recorded an issue at File.swift:line:col: msg) output
local function parse(root, output)
  local items, seen = {}, {}
  for line in output:gsub("\27%[[%d;]*m", ""):gmatch("[^\n]+") do
    local file, lnum, col, kind, msg = line:match("^(/[^:]+):(%d+):(%d+): (%a+): (.+)$")
    if not file then
      file, lnum, kind, msg = line:match("^(/[^:]+):(%d+): (%a+): (.+)$")
    end
    if not file then
      file, lnum, col, msg = line:match("recorded an issue at ([^:]+):(%d+):(%d+): (.+)$")
      kind = file and "error"
    end
    if file and (kind == "error" or kind == "warning") then
      local key = table.concat({ file, lnum, col or "", msg }, ":")
      if not seen[key] then
        seen[key] = true
        table.insert(items, {
          filename = resolve(root, file),
          lnum = tonumber(lnum),
          col = tonumber(col) or 1,
          type = kind:sub(1, 1):upper(),
          text = msg,
        })
      end
    end
  end
  return items
end

local function run_task(title, cmd, root)
  progress(title, "running", "running")
  vim.system(cmd, { cwd = root, text = true }, function(res)
    vim.schedule(function()
      local items = parse(root, (res.stdout or "") .. "\n" .. (res.stderr or ""))
      vim.fn.setqflist({}, " ", { title = title, items = items })
      if #items > 0 then
        progress(title, #items .. " issue(s)", "failed")
        -- Open the list without moving the cursor out of the code
        vim.cmd("botright cwindow | wincmd p")
      elseif res.code ~= 0 then
        progress(title, "failed (exit " .. res.code .. ")", "failed")
      else
        progress(title, "done", "success")
        vim.cmd("cclose")
      end
    end)
  end)
end

local function swift_run(root)
  vim.cmd("botright 15new")
  vim.fn.jobstart({ "swift", "run" }, { cwd = root, term = true })
  vim.cmd("startinsert")
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "swift",
  group = vim.api.nvim_create_augroup("UserSwiftConfig", {}),
  callback = function(ev)
    local function map(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = ev.buf, desc = desc })
    end
    -- stylua: ignore start
    map("<leader>wb", function() local r = package_root(); if r then run_task("swift build", { "swift", "build" }, r) end end, "Build (quickfix)")
    map("<leader>wt", function() local r = package_root(); if r then run_task("swift test", { "swift", "test" }, r) end end, "Test (quickfix)")
    map("<leader>wr", function() local r = package_root(); if r then swift_run(r) end end, "Run in terminal")
    map("<leader>wl", function()
      -- Lint also works outside SwiftPM (e.g. Xcode projects with a .swiftlint.yml)
      local r = vim.fs.root(0, { "Package.swift", ".swiftlint.yml", ".git" }) or vim.fn.getcwd()
      local cmd = { "swiftlint", "lint", "--quiet", "--reporter", "xcode" }
      -- Without a config swiftlint also lints .build/, so stick to the sources
      if not vim.uv.fs_stat(vim.fs.joinpath(r, ".swiftlint.yml")) then
        for _, path in ipairs({ "Sources", "Tests", "Package.swift" }) do
          if vim.uv.fs_stat(vim.fs.joinpath(r, path)) then
            table.insert(cmd, path)
          end
        end
      end
      run_task("swiftlint", cmd, r)
    end, "Lint (quickfix)")
    -- stylua: ignore end
  end,
})

-- Debugging: lldb-dap ships with Xcode
local dap = require("dap")

dap.adapters["lldb-dap"] = {
  type = "executable",
  command = "xcrun",
  args = { "lldb-dap" },
  name = "lldb-dap",
}

-- Runs inside nvim-dap's coroutine, so the build doesn't block the UI
local function build_and_pick_executable()
  local root = package_root()
  if not root then
    return dap.ABORT
  end
  local co = coroutine.running()
  local function await(cmd)
    vim.system(cmd, { cwd = root, text = true }, function(res)
      vim.schedule(function()
        coroutine.resume(co, res)
      end)
    end)
    return coroutine.yield()
  end

  progress("swift build", "building for debug", "running")
  if await({ "swift", "build" }).code ~= 0 then
    progress("swift build", "failed, see <leader>wb", "failed")
    return dap.ABORT
  end
  progress("swift build", "done", "success")

  local bin = vim.trim(await({ "swift", "build", "--show-bin-path" }).stdout)
  local ok, desc = pcall(vim.json.decode, await({ "swift", "package", "describe", "--type", "json" }).stdout)
  local exes = {}
  for _, product in ipairs(ok and desc.products or {}) do
    if product.type.executable ~= nil then
      table.insert(exes, product.name)
    end
  end

  if #exes == 0 then
    vim.notify("No executable products in this package", vim.log.levels.WARN)
    return dap.ABORT
  elseif #exes == 1 then
    return vim.fs.joinpath(bin, exes[1])
  end
  vim.schedule(function()
    vim.ui.select(exes, { prompt = "Executable to debug" }, function(choice)
      coroutine.resume(co, choice)
    end)
  end)
  local choice = coroutine.yield()
  return choice and vim.fs.joinpath(bin, choice) or dap.ABORT
end

dap.configurations.swift = {
  {
    name = "Build and debug executable",
    type = "lldb-dap",
    request = "launch",
    program = build_and_pick_executable,
    cwd = "${workspaceFolder}",
    args = {},
    stopOnEntry = false,
  },
  {
    name = "Attach to process",
    type = "lldb-dap",
    request = "attach",
    pid = function()
      return require("dap.utils").pick_process()
    end,
  },
}
