-- ==============================================================================
--  Hyprland 0.55 Lua Config (Best Practices)
--  Colors: Veilige matugen loader met fallback defaults
-- ==============================================================================

-- 1. Veilige color loader met fallback
local colors_path = os.getenv("HOME") .. "/.config/hypr/colors.lua"
local colors = {
  primary   = "ffb0d0ff",
  secondary = "e1bdc9ff",
  tertiary  = "191114ff",
  surface   = "191114ff",
  background= "191114ff",
  foreground= "ffffffcc",
}

local ok, loaded = pcall(loadfile, colors_path)
if ok and loaded then
  local loaded_colors = loaded()
  if loaded_colors then colors = loaded_colors end
end

-- -- Monitor -------------------------------------------------------------------
-- "preferred" en "auto" zijn nog steeds geldige strings in 0.55
hl.monitor("", "preferred", "auto", 1)

-- -- Programs ------------------------------------------------------------------
local terminal    = "alacritty"
local menu        = "rofi -show run"
local browser     = "vivaldi"
local musicplayer = "spotify-launcher"
local onlinechat  = "discord"
local filemanager = "dolphin"
local codeeditor  = "vscodium-wayland"
local pcbeditor   = "kicad"
local d3design    = "freecad"

-- -- Autostart -----------------------------------------------------------------
local data_home = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")

-- 0.55 best practice: gebruik hl.on("hyprland.start", ...) voor autostart
hl.on("hyprland.start", function()
  hl.exec_cmd(browser)
  hl.exec_cmd(musicplayer)
  hl.exec_cmd(onlinechat)
  hl.exec_cmd("qs")
  hl.exec_cmd(data_home .. "/quickshell-dotfiles/scripts/backgroundSwicher/init_wallpaper.sh")
  
  -- clipboard watchers (worden alleen gestart als ze nog niet lopen)
  hl.exec_once("wl-paste --type text --watch cliphist store")
  hl.exec_once("wl-paste --type image --watch cliphist store")
  hl.exec_once("wl-clip-persist --clipboard regular")
end)

-- -- Environment Variables -----------------------------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- -- Setup (Input, General, Decoration, etc.) ----------------------------------
hl.setup({
  input = {
    kb_layout = "us",
    numlock_by_default = true,
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = false,
      disable_while_typing = true,
    }
  },
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    layout = "dwindle",
    allow_tearing = false,
  },
  decoration = {
    rounding = 8,
    blur = {
      enabled = true,
      size = 4,
      passes = 1,
      vibrancy = 0.1696,
    }
  },
  animations = {
    enabled = false,
  },
  dwindle = {
    preserve_split = true,
  }
})

-- ==============================================================================
--  KLEUREN (Na hl.setup om de col table te initialiseren)
-- ==============================================================================
col.active_border = {colors.primary, colors.secondary, 45}
col.inactive_border = {colors.surface, 0.8}
col.background = colors.background
col.foreground = colors.foreground

-- -- Window Rules --------------------------------------------------------------
hl.window_rule({
  match = { class = "my-window" },
  border_size = 10
})

hl.window_rule({
  match = { class = musicplayer },
  workspace = "9 silent"
})

hl.window_rule({
  match = { class = onlinechat },
  workspace = "9 silent"
})

-- ==============================================================================
--  Keybindings (Hyprland 0.55 best practices)
-- ==============================================================================
-- 0.55 best practice: gebruik directe string combinaties i.p.v. concatenatie
-- Dit voorkomt fouten en is leesbaarder

-- Launch Programs
hl.bind("SUPER", "Return", "exec", terminal)
hl.bind("SUPER", "Space",  "exec", menu)
hl.bind("SUPER", "E",      "exec", browser)
hl.bind("SUPER", "L",      "exec", musicplayer)
hl.bind("SUPER", "I",      "exec", onlinechat)
hl.bind("SUPER", "F",      "exec", filemanager)
hl.bind("SUPER", "C",      "exec", codeeditor)
hl.bind("SUPER", "P",      "exec", pcbeditor)
hl.bind("SUPER", "O",      "exec", d3design)

-- Clipboard GUI
hl.bind("SUPER", "V", "exec", "cliphist list | rofi -dmenu | cliphist decode | wl-copy")

-- Screenshot tools
hl.bind("",      "Print", "exec", 'sh -c "hyprshot -m region --raw --freeze | satty --filename -"')
hl.bind("SHIFT", "Print", "exec", 'sh -c "hyprshot -m active --raw | satty --filename -"')

-- Window Management
hl.bind("SUPER", "Q", "killactive")
hl.bind("SUPER", "A", "fullscreen")
hl.bind("SUPER", "S", "togglefloating")
hl.bind("SUPER", "U", "pseudo")
hl.bind("SUPER", "J", "layoutmsg", "togglesplit")

-- Move Focus
hl.bind("SUPER", "left",  "movefocus", "l")
hl.bind("SUPER", "right", "movefocus", "r")
hl.bind("SUPER", "up",    "movefocus", "u")
hl.bind("SUPER", "down",  "movefocus", "d")

-- Move Windows
hl.bind("SUPER SHIFT", "left",  "movewindow", "l")
hl.bind("SUPER SHIFT", "right", "movewindow", "r")
hl.bind("SUPER SHIFT", "up",    "movewindow", "u")
hl.bind("SUPER SHIFT", "down",  "movewindow", "d")

-- Workspaces 1-9
for i = 1, 9 do
  local key = tostring(i)
  hl.bind("SUPER", key, "workspace", key)
  hl.bind("SUPER SHIFT", key, "movetoworkspace", key)
end

-- Scroll Workspaces
hl.bind("SUPER", "mouse_down", "workspace", "e+1")
hl.bind("SUPER", "mouse_up",   "workspace", "e-1")

-- Mouse Binds (Move & Resize)
hl.bindm("SUPER", "mouse:272", "movewindow")
hl.bindm("SUPER", "mouse:273", "resizewindow")

-- Audio Binds
hl.bind("", "XF86AudioRaiseVolume", "exec", "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+")
hl.bind("", "XF86AudioLowerVolume", "exec", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
hl.bind("", "XF86AudioMute",        "exec", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
hl.bind("", "XF86AudioMicMute",     "exec", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")

-- Brightness Binds
hl.bind("", "XF86MonBrightnessUp",   "exec", "brightnessctl set 5%+")
hl.bind("", "XF86MonBrightnessDown", "exec", "brightnessctl set 5%-")

-- Exit Hyprland
hl.bind("SUPER SHIFT", "L", "exit")
