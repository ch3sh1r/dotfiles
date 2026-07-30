local function focus_workspace(workspace)
	return function()
		hl.dispatch(hl.dsp.focus({ workspace = workspace }))
	end
end

hl.gesture({
	fingers = 3,
	direction = "right",
	action = focus_workspace("m+1"),
})

hl.gesture({
	fingers = 3,
	direction = "left",
	action = focus_workspace("m-1"),
})

hl.gesture({
	fingers = 4,
	direction = "down",
	action = "close",
})

hl.gesture({
	fingers = 4,
	direction = "up",
	action = "fullscreen",
})
