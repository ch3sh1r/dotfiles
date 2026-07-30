local env = {
	{ "XCURSOR_SIZE", "24" },
	{ "HYPRCURSOR_SIZE", "24" },

	-- Qt styling
	{ "QT_QPA_PLATFORM", "wayland" },
	{ "QT_QPA_PLATFORMTHEME", "qt6ct" },

	-- Prefer the built-in GPU first.
	{ "AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card2" },
}

for _, variable in ipairs(env) do
	hl.env(variable[1], variable[2])
end
