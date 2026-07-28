local curves = {
  easeOutQuint = {
    { 0.23, 1 },
    { 0.32, 1 },
  },
  easeInOutCubic = {
    { 0.65, 0.05 },
    { 0.36, 1 },
  },
  linear = {
    { 0, 0 },
    { 1, 1 },
  },
  almostLinear = {
    { 0.5, 0.5 },
    { 0.75, 1.0 },
  },
  quick = {
    { 0.15, 0 },
    { 0.1, 1 },
  },
}

for name, points in pairs(curves) do
  hl.curve(name, {
    type = "bezier",
    points = points,
  })
end

local animations = {
  { leaf = "global", speed = 10, bezier = "default" },
  { leaf = "border", speed = 5.39, bezier = "easeOutQuint" },
  { leaf = "windows", speed = 4.79, bezier = "easeOutQuint" },
  { leaf = "windowsIn", speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" },
  { leaf = "windowsOut", speed = 1.49, bezier = "linear", style = "popin 87%" },
  { leaf = "fadeIn", speed = 1.73, bezier = "almostLinear" },
  { leaf = "fadeOut", speed = 1.46, bezier = "almostLinear" },
  { leaf = "fade", speed = 3.03, bezier = "quick" },
  { leaf = "layers", speed = 3.81, bezier = "easeOutQuint" },
  { leaf = "layersIn", speed = 4, bezier = "easeOutQuint", style = "fade" },
  { leaf = "layersOut", speed = 1.5, bezier = "linear", style = "fade" },
  { leaf = "fadeLayersIn", speed = 1.79, bezier = "almostLinear" },
  { leaf = "fadeLayersOut", speed = 1.39, bezier = "almostLinear" },
  { leaf = "workspaces", speed = 1.94, bezier = "almostLinear", style = "fade" },
  { leaf = "workspacesIn", speed = 1.21, bezier = "almostLinear", style = "fade" },
  { leaf = "workspacesOut", speed = 1.94, bezier = "almostLinear", style = "fade" },
}

for _, animation in ipairs(animations) do
  animation.enabled = true
  hl.animation(animation)
end
