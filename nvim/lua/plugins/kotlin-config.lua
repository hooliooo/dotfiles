require("kotlin").setup({
  ft = { "kotlin" },
  root_markers = {
    "gradlew",
    ".git",
    "mvnw",
    "settings.gradle",
  },
  -- Passed verbatim via the IJ_JAVA_OPTIONS env var (no shell), so no escaping
  jvm_args = {
    "-Xmx2g",
    "-XX:MetaspaceSize=512M",
    "-XX:MaxMetaspaceSize=512M",
    "-XX:+HeapDumpOnOutOfMemoryError",
    "-Dfile.encoding=UTF-8",
  },
  inlay_hints = {
    parameters = true,
    parameters_compiled = true,
    types_property = true,
    types_variable = true,
    function_return = true,
    function_parameter = true,
    lambda_return = true,
    lambda_receivers_parameters = true,
  },
})

-- Attach-style JVM debugging: start the app/tests with --debug-jvm
-- (JDWP port 5005), then attach with this
vim.api.nvim_create_autocmd("FileType", {
  pattern = "kotlin",
  group = vim.api.nvim_create_augroup("UserKotlinConfig", {}),
  callback = function(ev)
    vim.keymap.set("n", "<leader>dK", function()
      vim.cmd("KotlinDebug")
    end, { buffer = ev.buf, desc = "Kotlin: attach debugger (JDWP 5005)" })
  end,
})
