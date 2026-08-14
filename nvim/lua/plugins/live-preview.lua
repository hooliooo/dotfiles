require("livepreview.config").set({
  -- Telescope, mini.pick and snacks are all installed; without this the plugin
  -- picks whichever it finds first.
  picker = "snacks",

  -- Resolve the webroot from the previewed file's directory rather than the cwd,
  -- so relative image/asset links in nested docs still work.
  dynamic_root = true,
})

-- `:LivePreview start` / `close` / `pick`. HTML only refreshes on write, unlike
-- Markdown/AsciiDoc/SVG which update as you type. Uncomment to autosave HTML on
-- leaving insert mode. Deliberately not on TextChanged: every write runs
-- conform's format_on_save, and this would fire it on each keystroke.
-- vim.api.nvim_create_autocmd("InsertLeavePre", {
--   pattern = "*.html",
--   command = "silent! write",
-- })
