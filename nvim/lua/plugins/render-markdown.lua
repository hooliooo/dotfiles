-- Define colors
local color1_bg = "#ff757f"
local color2_bg = "#4fd6be"
local color3_bg = "#7dcfff"
local color4_bg = "#ff9e64"
local color5_bg = "#7aa2f7"
local color6_bg = "#c0caf5"
local color_fg = "#1F2335"

-- Heading backgrounds. Re-applied on ColorScheme because `:colorscheme`
-- (run in init.lua after plugins load) clears custom highlight groups.
local function set_headline_hl()
  for i, bg in ipairs({ color1_bg, color2_bg, color3_bg, color4_bg, color5_bg, color6_bg }) do
    vim.api.nvim_set_hl(0, "Headline" .. i .. "Bg", { fg = color_fg, bg = bg, bold = true })
  end
end
set_headline_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_headline_hl })

require("render-markdown").setup({
  file_types = { "markdown" },
  -- Render markdown inside blink.cmp completion/documentation popups
  -- (replaces the removed win_config.floating.rendered_by_cmp option)
  completions = {
    blink = { enabled = true },
  },

  restart_highlighter = true,
  heading = {
    sign = true,
    icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
    width = "block",
    right_pad = 1,
    -- left_pad = 1,
    -- position = "inline",

    backgrounds = {
      "Headline1Bg",
      "Headline2Bg",
      "Headline3Bg",
      "Headline4Bg",
      "Headline5Bg",
      "Headline6Bg",
    },
  },
  code = {
    sign = false,
    width = "block",
    right_pad = 1,
  },
  bullet = { enabled = true },
  checkbox = {
    enabled = true,
    unchecked = { icon = " 󰄱 " },
    checked = { icon = " 󰱒 " },
  },
  anti_conceal = { ignore = { head_background = true } },
  html = {
    comment = {
      conceal = false,
    },
  },
})
