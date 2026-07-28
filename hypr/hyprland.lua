-- Hyprland loads hyprland.lua before the legacy hyprland.conf.
-- Keep this file as a small table of contents; config lives in modules/.
require("modules/env")
require("modules/monitors")
require("modules/options")
require("modules/gestures")
require("modules/animations")
require("modules/autostart")
require("modules/bindings")
