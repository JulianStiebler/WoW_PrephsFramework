---@meta

--- LibButtonGlow-1.0 — animated spell-activation overlay glow for button frames.
---@class LibButtonGlow-1.0
LibButtonGlow = {}

--- Show the animated glow overlay on a button frame.
--- If a glow overlay is already playing its hide animation, it will be restarted.
---@param frame Frame The button frame to apply the glow to.
function LibButtonGlow.ShowOverlayGlow(frame) end

--- Hide the glow overlay on a button frame (plays the fade-out animation).
---@param frame Frame The button frame whose glow should be hidden.
function LibButtonGlow.HideOverlayGlow(frame) end
