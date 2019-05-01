-- NoIndex: true

local Buffer = require("gui.buffer")

local Font = require("public.font")
local Color = require("public.color")
local Math = require("public.math")
local GFX = require("public.gfx")
local Text = require("public.text")
local Table, T = require("public.table"):unpack()
require("public.string")

-- Listbox - New
local Listbox = require("gui.element"):new()
Listbox.__index = Listbox
Listbox.defaultProps =  {
  name = "listbox",
  type = "Listbox",

  x = 0,
  y = 0,
  w = 96,
  h = 128,

  list = {},
  retval = {},

  caption = "",
  pad = 4,

  bg = "elmBg",
  captionBg = "windowBg",
  color = "txt",

  -- Scrollbar fill
  fillColor = "elmFill",

  captionFont = 3,

  textFont = 4,

  windowY = 1,

  windowH = nil,
  windowW = nil,
  charW = nil,

  shadow = nil,

}

function Listbox:new(props)

	local list = self:addDefaultProps(props)

  return self:assignChild(list)
end


function Listbox:init()

	-- If we were given a CSV, process it into a table
	if type(self.list) == "string" then self.list = self.list:split(",") end

	local w, h = self.w, self.h

	self.buffer = Buffer.get()

	gfx.dest = self.buffer
	gfx.setimgdim(self.buffer, -1, -1)
	gfx.setimgdim(self.buffer, w, h)

	Color.set(self.bg)
	gfx.rect(0, 0, w, h, 1)

	Color.set("elmFrame")
	gfx.rect(0, 0, w, h, 0)


end


function Listbox:onDelete()

	Buffer.release(self.buffer)

end


function Listbox:draw()

	-- Some values can't be set in :init() because the window isn't
	-- open yet - measurements won't work.
	if not self.windowH then self:recalculateWindow() end

	-- Draw the caption
	if self.caption and self.caption ~= "" then self:drawCaption() end

	-- Draw the background and frame
	gfx.blit(self.buffer, 1, 0, 0, 0, self.w, self.h, self.x, self.y)

	-- Draw the text
	self:drawText()

	-- Highlight any selected items
	self:drawSelection()

	-- Vertical scrollbar
	if #self.list > self.windowH then self:drawScrollbar() end

end


function Listbox:val(newval)

	if newval then
    if type(newval) == "table" then

      for i = 1, #self.list do
        self.retval[i] = newval[i] or nil
      end

    elseif type(newval) == "number" then

      newval = math.floor(newval)
      for i = 1, #self.list do
        self.retval[i] = (i == newval)
      end

    end

		self:redraw()

	else

		if self.multi then
      -- return self.retval

      return Table.reduce(
        self.list,
        function(acc, _, i)
          if (self.retval[i] ~= nil) then
            acc[i] = true
          else
            acc[i] = false
          end

          return acc
        end,
        T{}
      )
    else
      -- luacheck: ignore 512 (loop executing once)
			for k in pairs(self.retval) do
				return k
			end
		end

	end

end


---------------------------------
------ Input methods ------------
---------------------------------


function Listbox:onMouseUp(state)

	if not self:isOverScrollBar(state.mouse.x) then

		local item = self:getListItem(state.mouse.y)

		if self.multi then

			-- Ctrl
			if state.mouse.cap & 4 == 4 then

				self.retval[item] = not self.retval[item]

			-- Shift
			elseif state.mouse.cap & 8 == 8 then

				self:selectRange(item)

			else

				self.retval = {[item] = true}

			end

		else

			self.retval = {[item] = true}

		end

	end

	self:redraw()

end


function Listbox:onMouseDown(state, scroll)

	-- If over the scrollbar, or we came from :onDrag with an origin point
	-- that was over the scrollbar...
	if scroll or self:isOverScrollBar(state.mouse.x) then

    local windowCenter = Math.round(
      ((state.mouse.y - self.y) / self.h) * #self.list
    )
		self.windowY = math.floor(Math.clamp(
      1,
      windowCenter - (self.windowH / 2),
      #self.list - self.windowH + 1
    ))

		self:redraw()

	end

end


function Listbox:onDrag(state, last)

	if self:isOverScrollBar(last.mouse.x) then

		self:onMouseDown(state, true)

	else

	-- Drag selection?
	end

	self:redraw()

end


function Listbox:onWheel(state)

	local dir = state.mouse.wheelInc > 0 and -1 or 1

	-- Scroll up/down one line
	self.windowY = Math.clamp(
    1,
    self.windowY + dir,
    math.max(#self.list - self.windowH + 1, 1)
  )

	self:redraw()

end


---------------------------------
-------- Drawing methods---------
---------------------------------


function Listbox:drawCaption()

	Font.set(self.captionFont)
	local strWidth = gfx.measurestr(self.caption)
	gfx.x = self.x - strWidth - self.pad
	gfx.y = self.y + self.pad
	Text.drawBackground(self.caption, self.captionBg)

	if self.shadow then
		Text.drawWithShadow(self.caption, self.color, "shadow")
	else
		Color.set(self.color)
		gfx.drawstr(self.caption)
	end

end


function Listbox:drawText()

	Color.set(self.color)
	Font.set(self.textFont)

	local outputText = {}
	for i = self.windowY, math.min(self:windowBottom() - 1, #self.list) do

		local str = tostring(self.list[i]) or ""
    outputText[#outputText + 1] = self:formatOutput(str)

	end

	gfx.x, gfx.y = self.x + self.pad, self.y + self.pad
  local r = gfx.x + self.w - 2*self.pad
  local b = gfx.y + self.h - 2*self.pad

	gfx.drawstr( table.concat(outputText, "\n"), 0, r, b)

end


function Listbox:drawSelection()

  local adjustedX = self.x + self.pad
  local adjustedY = self.y + self.pad

  local w = self.w - 2 * self.pad
  local itemY

	Color.set("elmFill")
	gfx.a = 0.5
	gfx.mode = 1

	for i = 1, #self.list do

		if self.retval[i] and i >= self.windowY and i < self:windowBottom() then

			itemY = adjustedY + (i - self.windowY) * self.charH
			gfx.rect(adjustedX, itemY, w, self.charH, true)

		end

	end

	gfx.mode = 0
	gfx.a = 1

end


function Listbox:drawScrollbar()

	local x, y, w, h = self.x, self.y, self.w, self.h
	local sx, sy, sw, sh = x + w - 8 - 4, y + 4, 8, h - 12


	-- Draw a gradient to fade out the last ~16px of text
  Color.set("elmBg")

  local scrollOffset = sx - 15
  local scrollY1 = y + 2
  local scrollY2 = y + h - 4

	for i = 0, 15 do
		gfx.a = i / 15
		gfx.line(scrollOffset + i, scrollY1, scrollOffset + i, scrollY2)
	end

	gfx.rect(sx, y + 2, sw + 2, h - 4, true)

	-- Draw slider track
	Color.set("tabBg")
	GFX.roundRect(sx, sy, sw, sh, 4, 1, 1)
	Color.set("elmOutline")
	GFX.roundRect(sx, sy, sw, sh, 4, 1, 0)

	-- Draw slider fill
	local fh = (self.windowH / #self.list) * sh - 4
	if fh < 4 then fh = 4 end
	local fy = sy + ((self.windowY - 1) / #self.list) * sh + 2

	Color.set(self.fillColor)
	GFX.roundRect(sx + 2, fy, sw - 4, fh, 2, 1, 1)

end


---------------------------------
-------- Helpers ----------------
---------------------------------


-- Updates internal values for the window size
function Listbox:recalculateWindow()

	Font.set(self.textFont)

  self.charW, self.charH = gfx.measurestr("_")
	self.windowH = math.floor((self.h - 2*self.pad) / self.charH)
	self.windowW = math.floor(self.w / self.charW)

end


-- Get the bottom edge of the window (in rows)
function Listbox:windowBottom()

	return self.windowY + self.windowH

end


-- Determine which item the user clicked
function Listbox:getListItem(y)

	Font.set(self.textFont)

  local item = math.floor((y - (self.y + self.pad)) /	self.charH)
    + self.windowY

	return Math.clamp(1, item, #self.list)

end


-- Is the mouse over the scrollbar (true) or the text area (false)?
function Listbox:isOverScrollBar(x)

	return (#self.list > self.windowH and x >= (self.x + self.w - 12))

end


-- Selects from the first selected item to the current mouse position
function Listbox:selectRange(mouse)

	-- Find the first selected item
	local first
	for k in pairs(self.retval) do
		first = first and math.min(k, first) or k
	end

	if not first then first = 1 end

	self.retval = {}

	-- Select everything between the first selected item and the mouse
	for i = mouse, first, (first > mouse and 1 or -1) do
		self.retval[i] = true
	end

end

return Listbox
