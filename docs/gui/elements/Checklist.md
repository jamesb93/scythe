# Checklist
```lua
local Checklist = require(gui.elements.Checklist)
```
One or more options that can be individually toggled

| **Optional** | []() | []() |
| --- | --- | --- |
| name | string | The element's name. Must be unique. |
| x | number | Horizontal distance from the left side of the window, in pixels |
| y | number | Vertical distance from the top of the window, in pixels |
| w | number | Width, in pixels |
| h | number | Height, in pixels |
| caption | string |  |
| options | array | `{"Option 1", "Option 2", "Option 3"}` |
| selectedOptions | hash | Selected list options, of the form `{ 1 = true, 2 = false }` |
| horizontal | boolean | Lays the options out horizontally (defaults to `false`) |
| pad | number | Padding between the options (in pixels) |
| bg | string&#124;table | A color preset |
| textColor | string&#124;table | A color preset |
| fillColor | string&#124;table | A color preset |
| captionFont | number | A font preset |
| textFont | number | A font preset |
| optionSize | number | Size of the option bubbles (in pixels) |
| frame | boolean | Draws a frame around the list. |
| shadow | boolean | Draws the caption and list text with shadows |
<section class="segment">

### Checklist:val([newval, returnBool]) :id=checklist-val

Gets or sets the checklist's selected options.

| **Optional** | []() | []() |
| --- | --- | --- |
| newval | hash&#124;boolean | As a hash, sets the option state as per the class' `selectedOptions` parameter above. If the checklist only has one option, a boolean may be passed instead. |
| returnBool | boolean | If true, lists with only one option will have a boolean value returned directly. |

| **Returns** | []() |
| --- | --- |
| hash&#124;boolean | Returns the option state in the same form as the `selectedOptions` parameter above, or a single value if `returnBool` is set. |

</section>

----
_This file was automatically generated by Scythe's Doc Parser._