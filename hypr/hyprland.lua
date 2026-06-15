-- ==============================================================================
--  Hyprland 0.55 Lua Config
-- ==============================================================================
require("colors")

-- -- Monitor -------------------------------------------------------------------
hl.monitor({
    output = "...",
})

-- -- Programs ------------------------------------------------------------------
local terminal      = "alacritty"
local menu          = "rofi -show run"
local browser       = "vivaldi"
local musicplayer   = "spotify-launcher"
local musicplayernl = "Spotify"
local onlinechat    = "discord"
local filemanager   = "dolphin"
local codeeditor    = "vscodium-wayland"
local pcbeditor     = "kicad"
local d3design      = "freecad"

-- -- Autostart -----------------------------------------------------------------
local data_home = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")


hl.on("hyprland.start", function()
  hl.exec_cmd(browser)
  hl.exec_cmd(musicplayer)
  hl.exec_cmd(onlinechat)
  hl.exec_cmd("qs")
  hl.exec_cmd(data_home .. "/quickshell-dotfiles/scripts/backgroundSwicher/init_wallpaper.sh")
  
  -- clipboard watchers
  hl.exec_once("wl-paste --type text --watch cliphist store")
  hl.exec_once("wl-paste --type image --watch cliphist store")
  hl.exec_once("wl-clip-persist --clipboard regular")
end)

-- -- Environment Variables -----------------------------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- -- Setup (Input, General, Decoration, etc.) ----------------------------------

hl.config({
  general = {
    gaps_in     = 5,
    gaps_out    = 10,
    border_size = 2,
    layout      = "dwindle",
    allow_tearing = false,

    col = {
      active_border   = { colors = {colors.primary, colors.secondary}, angle = 45 },
      inactive_border = colors.surface,
    },
  },
  decoration = {
    rounding = 8,
    blur = {
      enabled  = true,
      size     = 4,
      passes   = 1,
      vibrancy = 0.1696,
    }
  },
  animations = { enabled = false },
  dwindle    = { preserve_split = true },
  input = {
    kb_layout          = "us",
    numlock_by_default = true,
    follow_mouse       = 1,
    sensitivity        = 0,
    touchpad = {
      natural_scroll       = false,
      disable_while_typing = true,
    }
  },
})

-- -- Window Rules --------------------------------------------------------------
hl.window_rule({
  match = { class = "my-window" },
  border_size = 10
})

hl.window_rule({
  match = { class = musicplayernl },
  workspace = "9 silent"
})

hl.window_rule({
  match = { class = onlinechat },
  workspace = "9 silent"
})

-- ==============================================================================
--  Keybindings
-- ==============================================================================


local M = "SUPER"

-- Launch Programs
hl.bind(M .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(M .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(M .. " + E",      hl.dsp.exec_cmd(browser))
hl.bind(M .. " + L",      hl.dsp.exec_cmd(musicplayer))
hl.bind(M .. " + I",      hl.dsp.exec_cmd(onlinechat))
hl.bind(M .. " + F",      hl.dsp.exec_cmd(filemanager))
hl.bind(M .. " + C",      hl.dsp.exec_cmd(codeeditor))
hl.bind(M .. " + P",      hl.dsp.exec_cmd(pcbeditor))
hl.bind(M .. " + O",      hl.dsp.exec_cmd(d3design))

-- Clipboard GUI
hl.bind(M .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

-- Screenshot tools
hl.bind("Print",       hl.dsp.exec_cmd('sh -c "hyprshot -m region --raw --freeze | satty --filename -"'))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd('sh -c "hyprshot -m active --raw | satty --filename -"'))

-- Window Management
hl.bind(M .. " + Q", hl.dsp.window.kill())
hl.bind(M .. " + A", hl.dsp.window.fullscreen())
hl.bind(M .. " + S", hl.dsp.window.float({ action = "toggle" }))
hl.bind(M .. " + U", hl.dsp.window.pseudo())
hl.bind(M .. " + J", hl.dsp.layout("togglesplit"))

-- Move Focus
hl.bind(M .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(M .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(M .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(M .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move Windows
hl.bind(M .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(M .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(M .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(M .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Workspaces 1-9
for i = 1, 9 do
  hl.bind(M .. " + " .. i,         hl.dsp.focus({ workspace = i }))
  hl.bind(M .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Scroll Workspaces
hl.bind(M .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse Binds (Move & Resize)
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))

-- Exit
hl.bind(M .. " + SHIFT + L", hl.dsp.exit())