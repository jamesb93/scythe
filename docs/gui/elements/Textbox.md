# Textbox
```lua
local Textbox = require(gui.elements.Textbox)
```


| **Optional** | []() | []() |
| --- | --- | --- |
| caption | string |  |
| retval | string | The textbox's content |
| pad | number | Padding between the caption and textbox |
| color | string&#124;table | A color preset |
| bg | string&#124;table | A color preset |
| captionFont | number | A font preset |
| textFont | number&#124;string | A font preset. **Must** be a monospaced font. |
| captionPosition | string | Caption positioning - one of _left_, _right_, _top_, _bottom_. |
| undoLimit | number | Undo states to keep. Defaults to `20`. |
| shadow | boolean | Draw the caption with a shadow. Defaults to `true`. |
| validator | func | If present, will be called with the textbox's content whenever focus is lost (clicking outside, pressing Enter). If the validator returns `false` or `nil`, the textbox will reset to the previous undo state. |
| validateOnType | boolean | Calls the validator repeatedly as the user types; use this for restricting the range of characters that can be entered. Defaults to `false`. |

<section class="segment">

### Textbox:val([newval]) :id=textbox-val

Get or set the textbox's content

| **Optional** | []() | []() |
| --- | --- | --- |
| newval | string | New content |

| **Returns** | []() |
| --- | --- |
| string | The textbox's content |

</section>
<section class="segment">

### Textbox:recalculateWindow() :id=textbox-recalculatewindow

Updates several internal values. If `w` or `textFont` are changed, this
method should be called afterward.

</section>

----
_This file was automatically generated by Scythe's Doc Parser._
