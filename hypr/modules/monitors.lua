local monitors = {
  -- Built-in display
  {
    output = "DSI-1",
    mode = "1200x1920@60.0",
    position = "4760x3046",
    scale = 1.5,
    transform = 3,
  },

  -- Saved external displays
  {
    output = "desc:Samsung Electric Company LF24T450F HK2TB07170",
    mode = "1920x1080@60.0",
    position = "4429x1966",
    scale = 1.0,
  },
  {
    output = "desc:Dell Inc. DELL U2724D 6JWF934",
    mode = "2560x1440@59.95",
    position = "2720x1053",
    scale = 1.0,
    transform = 3,
  },
  {
    output = "desc:Dell Inc. DELL U2724DE 7FV0B34",
    mode = "2560x1440@59.95",
    position = "4160x1606",
    scale = 1.0,
  },

  -- Fallback for new displays.
  {
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
  },
}

for _, monitor in ipairs(monitors) do
  hl.monitor(monitor)
end
