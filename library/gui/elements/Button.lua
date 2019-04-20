-- NoIndex: true

--[[	Lokasenna_GUI - Button class

    For documentation, see this class's page on the project wiki:
    https://github.com/jalovatt/Lokasenna_GUI/wiki/TextEditor

    Creation parameters:
	name, z, x, y, w, h, caption, func[, ...]

]]--

local Buffer = require("gui.buffer")

local Font = require("public.font")
local Color = require("public.color")
local GFX = require("public.gfx")
local Table = require("public.table")
local Config = require("gui.config")

local Element = require("gui.element")

-- Button - New
local Button = Element:new()
Button.__index = Button
Button.defaultProps = {
  type = "Button",

  x = 0,
  y = 0,
  w = 96,
  h = 24,

  caption = "Button",
  font = 3,
  col_txt = "txt",
  col_fill = "elm_frame",

  func = function () end,
  params = {},
  state = 0,
}

function Button:new(props)

  local button = self:addDefaultProps(props)

  return self:assignChild(button)
end


function Button:init()
	self.buff = self.buff or Buffer.get()

	gfx.dest = self.buff
	gfx.setimgdim(self.buff, -1, -1)
  gfx.setimgdim(self.buff, 2*self.w + 4, self.h + 2)

	Color.set(self.col_fill)
	GFX.roundrect(1, 1, self.w, self.h, 4, 1, 1)
	Color.set("elm_outline")
	GFX.roundrect(1, 1, self.w, self.h, 4, 1, 0)

	local r, g, b, a = table.unpack(Color.colors["shadow"])
	gfx.set(r, g, b, 1)
	GFX.roundrect(self.w + 2, 1, self.w, self.h, 4, 1, 1)
	gfx.muladdrect(self.w + 2, 1, self.w + 2, self.h + 2, 1, 1, 1, a, 0, 0, 0, 0 )
end


function Button:ondelete()

	Buffer.release(self.buff)

end



-- Button - Draw.
function Button:draw()

	local x, y, w, h = self.x, self.y, self.w, self.h
	local state = self.state

	-- Draw the shadow if not pressed
	if state == 0 then

		for i = 1, Config.shadow_size do

			gfx.blit(self.buff, 1, 0, w + 2, 0, w + 2, h + 2, x + i - 1, y + i - 1)

		end

	end

	gfx.blit(self.buff, 1, 0, 0, 0, w + 2, h + 2, x + 2 * state - 1, y + 2 * state - 1)

	-- Draw the caption
	Color.set(self.col_txt)
	Font.set(self.font)

  local str = self:formatOutput(self.caption)
  str = str:gsub([[\n]],"\n")

	local str_w, str_h = gfx.measurestr(str)
	gfx.x = x + 2 * state + ((w - str_w) / 2)
	gfx.y = y + 2 * state + ((h - str_h) / 2)
	gfx.drawstr(str)

end


-- Button - Mouse down.
function Button:onmousedown()
	self.state = 1
	self:redraw()
end


function Button:onmouseup(state)
	self.state = 0

	-- If the mouse was released on the button, run func
	if self:isInside(state.mouse.x, state.mouse.y) then

		self.func(table.unpack(self.params))

	end
	self:redraw()
end

function Button:ondoubleclick()

	self.state = 0

end

function Button:onmouser_up(state)

	if self:isInside(state.mouse.x, state.mouse.y) and self.r_func then

		self.r_func(table.unpack(self.r_params))

	end
end


-- Button - Execute (extra method)
-- Used for allowing hotkeys to press a button
function Button:exec(r)

	if r then
		self.r_func(table.unpack(self.r_params))
	else
		self.func(table.unpack(self.params))
	end

end

return Button
