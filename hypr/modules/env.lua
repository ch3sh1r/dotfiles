local env = {
	{ "XCURSOR_SIZE", "24" },
	{ "HYPRCURSOR_SIZE", "24" },

	-- Qt styling
	{ "QT_QPA_PLATFORM", "wayland" },
	{ "QT_QPA_PLATFORMTHEME", "qt6ct" },
}

for _, variable in ipairs(env) do
	hl.env(variable[1], variable[2])
end
