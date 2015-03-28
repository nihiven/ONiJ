function love.conf(t)
	t.console = true                  		-- Attach a console (boolean, Windows only)
    t.window.width = 1280 					-- window width
    t.window.height = 720 					-- window height
	t.window.title = "One Night in Japan"	-- The window title (string)
	t.window.borderless = false        		-- Remove all border visuals from the window (boolean)
	t.modules.physics = false          		-- disable the physics module (boolean)
	t.modules.joystick = false				-- disable the joystick module (boolean)
	t.window.fsaa = 0                  -- The number of samples to use with multi-sampled antialiasing (number)
end
