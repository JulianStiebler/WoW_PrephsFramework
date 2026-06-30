--[[
    <PrephsFramework_Core/UI/UI_Factory.lua>
    Copyright (C) <2026> <Prephmage / Prephalia>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    -- Additional Metadata --
    Author:  <Prephmage>
    GitHub: https://github.com/JulianStiebler/WoW_PrephsFramework
--]]

---@meta _
local addonName, ns = ...

---@class PrephsFramework
local Core = ns.PF

---@class PrephsFramework.UI
local UI = Core.UI

---@type PrephsFramework.Logger
local logger = Core.Logger

---@class PrephsFramework.data.mapData.zoneDB
local zoneDB = Core.data.mapData and Core.data.mapData.zoneDB

---@class PrephsFramework.UI.Factory
local Factory = UI.Factory


local ipairs = ipairs
local pairs = pairs
local CreateFrame = CreateFrame
local math = math
local IsMouseButtonDown = IsMouseButtonDown
local MouseIsOver = MouseIsOver
local tostring = tostring
local string = string
local UIDropDownMenu_SetWidth = UIDropDownMenu_SetWidth
local UIDropDownMenu_SetText = UIDropDownMenu_SetText
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local UIParent = UIParent
local table = table
local type = type


---@class ManagedFrame : Frame
---@field isLayoutManaged boolean|nil
---@field layoutOffset number|nil
---@field inUse boolean|nil
---@field frameType string|nil
---@field sequence number|nil
---@field groupName string|nil

---@class ManagedFontString : FontString
---@field isLayoutManaged boolean|nil
---@field layoutOffset number|nil
---@field inUse boolean|nil
---@field sequence number|nil
---@field groupName string|nil

---@class PrephsFramework.UI.CheckboxFrame : ManagedFrame
---@field checkbox CheckButton
---@field text FontString

---@class PrephsFramework.UI.CheckboxWithCogFrame : ManagedFrame
---@field checkbox CheckButton
---@field text FontString
---@field cogBtn Button

---@class PrephsFramework.UI.EditBoxFrame : ManagedFrame
---@field label FontString
---@field editBox EditBox

---@class PrephsFramework.UI.SliderFrame : ManagedFrame
---@field label FontString
---@field slider Slider
---@field valueText FontString

---@class PrephsFramework.UI.DropdownFrame : ManagedFrame
---@field label FontString
---@field dropdown Frame

---@class PrephsFramework.UI.ColorBox : Button
---@field bg Texture

---@class PrephsFramework.UI.ColorPickerFrame : ManagedFrame
---@field label FontString
---@field colorBox PrephsFramework.UI.ColorBox

---@class PrephsFramework.UI.SeparatorFrame : ManagedFrame
---@field line Texture

---@class PrephsFramework.UI.SuppressionPopup : Frame, BackdropTemplate
---@field cogBtn Button? The cog button this popup is anchored to
---@field zoneMenu Frame? Zone selection submenu frame

-- Frame Pools
---@class PrephsFramework.UI.Factory.Pools
Factory.Pools = Factory.Pools or {
    Label = {},
    Checkbox = {},
    EditBox = {},
    Slider = {},
    Dropdown = {},
    ColorPicker = {},
    Button = {},
    Separator = {},
    CheckboxWithCog = {},
    SuppressionPopup = {},
    EditableList = {},
    CheckboxGroup = {},
}

---@param frame any
---@param frameType string
local function ResetFrame(frame, frameType)
    if not frame then return end
    
    -- Reset properties
    frame:Hide()
    frame:ClearAllPoints()
    
    -- Reset layout properties
    frame.isLayoutManaged = nil
    frame.layoutOffset = nil
    
    -- Type-specific resets
    if frameType == "Label" then
        frame:SetText("")
        frame:SetParent(nil)
        
    elseif frameType == "Checkbox" or frameType == "CheckboxWithCog" then
        frame:SetParent(nil)
        frame:SetAlpha(1)
        if frame.checkbox then
            frame.checkbox:SetChecked(false)
        end
        if frame.text then
            frame.text:SetText("")
        end
    elseif frameType == "EditBox" then
        frame:SetParent(nil)
        frame:SetAlpha(1)
        if frame.editBox then
            frame.editBox:SetText("")
        end
    elseif frameType == "Slider" then
        frame:SetParent(nil)
        frame:SetAlpha(1)
        if frame.slider then
            frame.slider:SetScript("OnValueChanged", nil)
            frame.slider:SetValue(0)
        end
    elseif frameType == "Button" then
        frame:SetParent(nil)
        frame:SetAlpha(1)
        frame:SetText("")
    elseif frameType == "SuppressionPopup" then
        frame:SetParent(nil)
        frame:SetAlpha(1)
        local children = {frame:GetChildren()}
        for _, child in ipairs(children) do
            child:Hide()
            child:ClearAllPoints()
        end
    elseif frameType == "Separator" then
        frame:SetParent(nil)

    elseif frameType == "EditableList" or frameType == "CheckboxGroup" then
        -- Hide and detach all child frames/regions recursively
        local children = {frame:GetChildren()}
        for _, child in ipairs(children) do
            child:Hide()
            child:ClearAllPoints()
            child:SetParent(nil)
        end
        local regions = {frame:GetRegions()}
        for _, region in ipairs(regions) do
            region:Hide()
        end
        frame:SetParent(nil)
        frame:SetAlpha(1)
    end
    
    frame.inUse = false
end

---@param frameType string Frame pool type key
---@param parent Frame Parent frame to attach to
---@return ManagedFrame|ManagedFontString|nil
function Factory:AcquireFrame(frameType, parent)
    local pool = self.Pools[frameType]
    if not pool then
        logger:error("Unknown frame type requested from pool: %s", tostring(frameType))
        return nil
    end
    
    -- Try to find an unused frame in the pool
    for _, frame in ipairs(pool) do
        if not frame.inUse then
            frame.inUse = true
            frame:SetParent(parent)
            frame:Show()
            return frame
        end
    end
    
    -- No free frame found, create a new one
    local newFrame = self:CreateFrameOfType(frameType, parent)
    if newFrame then
        newFrame.inUse = true
        newFrame.frameType = frameType
        table.insert(pool, newFrame)
    end
    
    return newFrame
end

---@param frame ManagedFrame|ManagedFontString|nil
function Factory:ReleaseFrame(frame)
    if not frame or not frame.frameType then return end
    ResetFrame(frame, frame.frameType)
end

function Factory:ReleaseAllFrames()
    for frameType, pool in pairs(self.Pools) do
        for _, frame in ipairs(pool) do
            if frame.inUse then
                ResetFrame(frame, frameType)
            end
        end
    end
end

---@param frameType string Frame pool type key
---@param parent Frame Parent frame
---@return any
function Factory:CreateFrameOfType(frameType, parent)
    if frameType == "Label" then
        return parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        
    elseif frameType == "Checkbox" then
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(600, 24)
        
        frame.checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        frame.checkbox:SetPoint("LEFT", 0, 0)
        
        frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.text:SetPoint("LEFT", frame.checkbox, "RIGHT", 5, 0)
        
        return frame
        
    elseif frameType == "CheckboxWithCog" then
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(600, 24)
        
        frame.checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        frame.checkbox:SetPoint("LEFT", 0, 0)
        
        frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.text:SetPoint("LEFT", frame.checkbox, "RIGHT", 5, 0)
        
        frame.cogBtn = CreateFrame("Button", nil, frame)
        frame.cogBtn:SetSize(20, 20)
        frame.cogBtn:SetPoint("LEFT", frame.text, "RIGHT", 10, 0)
        frame.cogBtn:SetNormalTexture("Interface\\Icons\\Trade_Engineering")
        frame.cogBtn:SetHighlightTexture("Interface\\Icons\\Trade_Engineering")
        frame.cogBtn:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.cogBtn:GetHighlightTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        frame.cogBtn:GetHighlightTexture():SetAlpha(0.5)
        
        return frame
        
    elseif frameType == "EditBox" then
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(600, 50)
        
        frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.label:SetPoint("TOPLEFT", 0, 0)
        
        frame.editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        frame.editBox:SetPoint("TOPLEFT", 0, -20)
        frame.editBox:SetSize(300, 20)
        frame.editBox:SetAutoFocus(false)
        
        return frame
        
    elseif frameType == "Slider" then
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(600, 60)
        
        frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.label:SetPoint("TOPLEFT", 0, 0)
        
        frame.slider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
        frame.slider:SetPoint("TOPLEFT", 0, -20)
        frame.slider:SetWidth(300)
        frame.slider:SetObeyStepOnDrag(true)
        
        frame.valueText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.valueText:SetPoint("TOP", frame.slider, "BOTTOM", 0, -5)
        
        return frame
        
    elseif frameType == "Dropdown" then
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(600, 50)
        
        frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.label:SetPoint("TOPLEFT", 0, 0)
        
        frame.dropdown = CreateFrame("Frame", "PrephsFramework_Dropdown_" .. math.random(1, 999999), frame, "UIDropDownMenuTemplate")
        frame.dropdown:SetPoint("TOPLEFT", -15, -20)
        
        return frame
        
    elseif frameType == "ColorPicker" then
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(600, 50)
        
        frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.label:SetPoint("TOPLEFT", 0, 0)
        
        frame.colorBox = CreateFrame("Button", nil, frame)
        frame.colorBox:SetSize(40, 20)
        frame.colorBox:SetPoint("TOPLEFT", 0, -25)
        
        frame.colorBox.bg = frame.colorBox:CreateTexture(nil, "BACKGROUND")
        frame.colorBox.bg:SetAllPoints()
        
        return frame
        
    elseif frameType == "Button" then
        local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        button:SetSize(150, 30)
        return button
    elseif frameType == "Separator" then
        local frame = CreateFrame("Frame", nil, parent)
        frame:SetSize(600, 8)

        local line = frame:CreateTexture(nil, "ARTWORK")
        line:SetHeight(1)
        line:SetPoint("LEFT", 0, 0)
        line:SetPoint("RIGHT", 0, 0)
        line:SetColorTexture(0.4, 0.4, 0.4, 0.8)
        frame.line = line

        return frame
    end
    
    return nil
end

---@param parent Frame Parent frame for the separator
---@return PrephsFramework.UI.SeparatorFrame|nil
function Factory:CreateSeparator(parent)
    local frame = self:AcquireFrame("Separator", parent)
    if not frame then return nil end
    ---@cast frame PrephsFramework.UI.SeparatorFrame

    UI.elementSequence = UI.elementSequence + 1
    frame.sequence = UI.elementSequence

    frame.isLayoutManaged = true
    frame.layoutOffset = nil

    return frame
end

---@param scrollChild Frame? The scroll child to lay out (defaults to self.ScrollChild)
function UI:RefreshLayout(scrollChild)
    scrollChild = scrollChild or self.ScrollChild
    if not scrollChild then return end
    
    -- Collect all managed elements (both Frames and FontStrings)
    local managedChildren = {}
    
    -- Get FontStrings (includes labels)
    local regions = {scrollChild:GetRegions()}
    for _, region in ipairs(regions) do
        if region.GetObjectType and region:GetObjectType() == "FontString" then
            ---@cast region ManagedFontString
            if region.isLayoutManaged and region.inUse then
                table.insert(managedChildren, region)
            end
        end
    end
    
    -- Get Frames (includes all other widgets)
    local children = {scrollChild:GetChildren()}
    for _, child in ipairs(children) do
        ---@cast child ManagedFrame
        if child:IsShown() and child.isLayoutManaged and child.inUse then
            table.insert(managedChildren, child)
        end
    end
    
    -- Sort by creation sequence to maintain proper order
    table.sort(managedChildren, function(a, b)
        return (a.sequence or 0) < (b.sequence or 0)
    end)
    
    local lastElement = nil
    local totalHeight = 15
    local baseMargin = 12
    
    -- Position each managed element
    for _, element in ipairs(managedChildren) do
        element:ClearAllPoints()
        if not lastElement then
            element:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
        else
            local spacing = math.abs(element.layoutOffset or baseMargin)
            element:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -spacing)
        end
        lastElement = element
        local elementHeight = element:GetHeight()
        local spacing = math.abs(element.layoutOffset or baseMargin)
        totalHeight = totalHeight + elementHeight + spacing
    end
    
    scrollChild:SetHeight(math.max(totalHeight, 600))
end

---@param parent Frame The parent frame to create the widget in
---@param element UIElement The element config
---@param db table|nil The database table for fallback get/set
---@param persistFn function|nil Optional callback(key, value) called after DB write
---@return ManagedFrame|ManagedFontString|nil The created widget
function Factory:RenderElement(parent, element, db, persistFn)
    local widget = nil

    local function getValue()
        if element.get then return element.get() end
        if element.key and db then return db[element.key] end
        return nil
    end

    local function setValue(value)
        if element.set then
            element.set(value)
        elseif element.key and db then
            db[element.key] = value
            if persistFn then persistFn(element.key, value) end
        end
        if element.onUpdate then element.onUpdate(value) end
    end

    if element.type == "Checkbox" then
        widget = self:CreateCheckbox(
            parent,
            element.label or element.key,
            getValue(),
            function(checked) setValue(checked) end
        )

    elseif element.type == "EditBox" then
        widget = self:CreateEditBox(
            parent,
            element.label or element.key,
            getValue(),
            function(text) setValue(text) end
        )

    elseif element.type == "Slider" then
        widget = self:CreateSlider(
            parent,
            element.label or element.key,
            element.min or 0,
            element.max or 100,
            element.step or 1,
            getValue() or element.default,
            function(value) setValue(value) end
        )

    elseif element.type == "Dropdown" then
        widget = self:CreateDropdown(
            parent,
            element.label or element.key,
            element.options or {},
            getValue(),
            function(value) setValue(value) end
        )

    elseif element.type == "DependentDropdown" then
        widget = self:CreateDependentDropdown(
            parent,
            element.label or element.key,
            element.options or {},
            getValue(),
            function(value) setValue(value) end,
            element.isOptionDisabled
        )

    elseif element.type == "ColorPicker" then
        local r, g, b
        if element.get then
            r, g, b = element.get()
        elseif element.key and db and db[element.key] then
            local color = db[element.key]
            if type(color) == "table" then
                r, g, b = color.r or color[1], color.g or color[2], color.b or color[3]
            end
        end

        widget = self:CreateColorPicker(
            parent,
            element.label or element.key,
            r, g, b,
            function(newR, newG, newB)
                if element.set then
                    element.set(newR, newG, newB)
                elseif element.key and db then
                    db[element.key] = {r = newR, g = newG, b = newB}
                    if persistFn then persistFn(element.key, {r = newR, g = newG, b = newB}) end
                end
                if element.onUpdate then element.onUpdate(newR, newG, newB) end
            end
        )

    elseif element.type == "Label" then
        local text = element.label
        if type(text) == "function" then text = text() end
        local font = element.font
        if not font and element.fontSize then
            if element.fontSize == "large" then
                font = "GameFontNormalLarge"
            elseif element.fontSize == "small" then
                font = "GameFontNormalSmall"
            end
        end
        widget = self:CreateLabel(parent, text, font, element.color)

    elseif element.type == "Button" then
        widget = self:CreateButton(parent, element.label or element.text, element.callback or element.onClick)

    elseif element.type == "EditableList" then
        -- Build initial entries from DB value
        local currentList = getValue() or {}
        local initialEntries = {}
        for _, item in ipairs(currentList) do
            -- Each stored item is { id = ..., displayText = ... }
            if type(item) == "table" then
                table.insert(initialEntries, item)
            else
                -- Raw id stored, try to resolve display text
                local resolvedId, resolvedName
                if element.resolveFunc then
                    resolvedId, resolvedName = element.resolveFunc(tostring(item))
                end
                local display = resolvedName and (resolvedName .. " (" .. tostring(item) .. ")") or tostring(item)
                table.insert(initialEntries, { id = item, displayText = display })
            end
        end

        widget = self:CreateEditableList(
            parent,
            element.label or element.key or "List",
            initialEntries,
            element.resolveFunc or function(input) return input, nil end,
            function(entries)
                -- Store simplified list of {id, displayText} in DB
                local toStore = {}
                for _, e in ipairs(entries) do
                    table.insert(toStore, { id = e.id, displayText = e.displayText })
                end
                setValue(toStore)
            end,
            element.inputHint
        )

    elseif element.type == "CheckboxGroup" then
        -- Get the current state table from DB
        local currentStates = getValue() or {}

        widget = self:CreateCheckboxGroup(
            parent,
            element.label or element.key or "Group",
            currentStates._enabled ~= false,
            element.children or {},
            function(mainChecked)
                local states = getValue() or {}
                states._enabled = mainChecked
                setValue(states)
                if element.onMainChanged then element.onMainChanged(mainChecked) end
            end,
            function(childKey, childChecked)
                local states = getValue() or {}
                states[childKey] = childChecked
                setValue(states)
                if element.onChildChanged then element.onChildChanged(childKey, childChecked) end
            end,
            currentStates,
            element.collapsible
        )

    elseif element.type == "Spacer" then
        local spacer = CreateFrame("Frame", nil, parent)
        spacer:SetSize(1, element.height or 10)
        spacer:Show()
        spacer.inUse = true
        spacer.frameType = "Spacer"
        UI.elementSequence = UI.elementSequence + 1
        spacer.sequence = UI.elementSequence
        spacer.isLayoutManaged = true
        spacer.layoutOffset = nil
        widget = spacer
    end

    if widget then widget:Show() end

    -- Render description below the widget if provided
    if widget and element.description then
        local desc = self:CreateLabel(parent, element.description, "GameFontNormalSmall", {0.6, 0.6, 0.6})
        if desc then
            desc:Show()
            widget = desc
        end
    end

    -- Render a separator after this element if requested
    if widget and element.showSeparator then
        local sep = self:CreateSeparator(parent)
        if sep then sep:Show() end
    end

    return widget
end

---@param parent Frame The parent frame to create the label in
---@param text string Display text
---@param font string? FontObject name (e.g. "GameFontNormal")
---@param color table|nil RGB color table {r,g,b} or {[1],[2],[3]}
---@return ManagedFontString|nil
function Factory:CreateLabel(parent, text, font, color)
    local label = self:AcquireFrame("Label", parent)
    if not label then return nil end
    
    UI.elementSequence = UI.elementSequence + 1
    label.sequence = UI.elementSequence
    
    label:SetFontObject(font or "GameFontNormal")
    label:SetText(text)
    if color then
        label:SetTextColor(color.r or color[1] or 1, color.g or color[2] or 1, color.b or color[3] or 1)
    else
        label:SetTextColor(1, 1, 1)
    end
    label:SetJustifyH("LEFT")
    label:SetWidth(600)
    
    label.isLayoutManaged = true
    label.layoutOffset = nil
    
    return label
end

---@param parent Frame
---@param label string Display label text
---@param checked boolean Whether initially checked
---@param onChanged fun(checked: boolean)? Callback when toggled
---@return PrephsFramework.UI.CheckboxFrame|nil
function Factory:CreateCheckbox(parent, label, checked, onChanged)
    local frame = self:AcquireFrame("Checkbox", parent)
    if not frame then return nil end
    ---@cast frame PrephsFramework.UI.CheckboxFrame
    
    UI.elementSequence = UI.elementSequence + 1
    frame.sequence = UI.elementSequence
    
    frame.checkbox:SetChecked(checked)
    frame.text:SetText(label)
    
    frame.checkbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        if onChanged then
            onChanged(isChecked)
        end
    end)
    
    frame.isLayoutManaged = true
    frame.layoutOffset = nil
    
    return frame
end

---@param parent Frame
---@param label string Display label text
---@param checked boolean Whether initially checked
---@param onChanged fun(checked: boolean)? Callback when toggled
---@param onCogClick fun(frame: PrephsFramework.UI.CheckboxWithCogFrame, cogBtn: Button)? Callback when cog button is clicked
---@return PrephsFramework.UI.CheckboxWithCogFrame|nil
function Factory:CreateCheckboxWithCog(parent, label, checked, onChanged, onCogClick)
    local frame = self:AcquireFrame("CheckboxWithCog", parent)
    if not frame then return nil end
    ---@cast frame PrephsFramework.UI.CheckboxWithCogFrame
    
    UI.elementSequence = UI.elementSequence + 1
    frame.sequence = UI.elementSequence
    
    frame.checkbox:SetChecked(checked)
    frame.text:SetText(label)
    
    frame.checkbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        if onChanged then
            onChanged(isChecked)
        end
    end)
    
    frame.cogBtn:SetScript("OnClick", function()
        if onCogClick then
            onCogClick(frame, frame.cogBtn)
        end
    end)
    
    frame.isLayoutManaged = true
    frame.layoutOffset = nil
    
    return frame
end

---@param parent Frame
---@param label string Display label text
---@param value string? Initial text value
---@param onChanged fun(text: string)? Callback when text changes
---@return PrephsFramework.UI.EditBoxFrame|nil
function Factory:CreateEditBox(parent, label, value, onChanged)
    local frame = self:AcquireFrame("EditBox", parent)
    if not frame then return nil end
    ---@cast frame PrephsFramework.UI.EditBoxFrame
    
    UI.elementSequence = UI.elementSequence + 1
    frame.sequence = UI.elementSequence
    
    frame.label:SetText(label)
    frame.editBox:SetText(value or "")
    
    frame.editBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        if onChanged then
            onChanged(self:GetText())
        end
    end)
    
    frame.editBox:SetScript("OnEditFocusLost", function(self)
        if onChanged then
            onChanged(self:GetText())
        end
    end)
    
    frame.isLayoutManaged = true
    frame.layoutOffset = nil
    
    return frame
end

---@param parent Frame
---@param label string Display label text
---@param min number Minimum slider value
---@param max number Maximum slider value
---@param step number Step increment
---@param value number? Initial value
---@param onChanged fun(value: number)? Callback when value changes
---@return PrephsFramework.UI.SliderFrame|nil
function Factory:CreateSlider(parent, label, min, max, step, value, onChanged)
    local frame = self:AcquireFrame("Slider", parent)
    if not frame then return nil end
    ---@cast frame PrephsFramework.UI.SliderFrame
    
    UI.elementSequence = UI.elementSequence + 1
    frame.sequence = UI.elementSequence
    
    frame.label:SetText(label)
    frame.slider:SetMinMaxValues(min, max)
    frame.slider:SetValueStep(step)
    frame.slider:SetValue(value or min)
    frame.valueText:SetText(tostring(value or min))
    
    frame.slider:SetScript("OnValueChanged", function(self, val)
        val = math.floor(val / step + 0.5) * step
        frame.valueText:SetText(string.format("%.2f", val))
        if onChanged then
            onChanged(val)
        end
    end)
    
    frame.isLayoutManaged = true
    frame.layoutOffset = nil
    
    return frame
end

---@param parent Frame
---@param label string Display label text
---@param options string[] List of dropdown options
---@param selected string? Initially selected option
---@param onChanged fun(value: string)? Callback when selection changes
---@return PrephsFramework.UI.DropdownFrame|nil
function Factory:CreateDropdown(parent, label, options, selected, onChanged)
    local frame = self:AcquireFrame("Dropdown", parent)
    if not frame then return nil end
    ---@cast frame PrephsFramework.UI.DropdownFrame
    
    UI.elementSequence = UI.elementSequence + 1
    frame.sequence = UI.elementSequence
    
    frame.label:SetText(label)
    
    UIDropDownMenu_SetWidth(frame.dropdown, 200)
    UIDropDownMenu_SetText(frame.dropdown, selected or "Select...")
    
    UIDropDownMenu_Initialize(frame.dropdown, function(self, level)
        for _, option in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option
            info.func = function(self)
                UIDropDownMenu_SetText(frame.dropdown, option)
                if onChanged then
                    onChanged(option)
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    frame.isLayoutManaged = true
    frame.layoutOffset = nil
    
    return frame
end

--- Create a dropdown whose entries can be dynamically disabled based on
--- external state (e.g. another setting's current value).
---
--- Delegates to CreateDropdown for frame creation and layout, then overrides
--- the menu initializer to support greyed-out entries.
---
--- `isOptionDisabled` is called each time the dropdown opens.  For every option
--- it should return **nil / false** when the option is selectable, or a
--- **string** (the reason) when it should be greyed-out.  Greyed-out entries
--- show the reason as a suffix and cannot be clicked.
---
---@param parent Frame
---@param label string
---@param options string[]
---@param selected string|nil
---@param onChanged fun(value: string)?
---@param isOptionDisabled fun(option: string): string|nil  Return reason string to disable, nil to enable
---@return PrephsFramework.UI.DropdownFrame|nil
function Factory:CreateDependentDropdown(parent, label, options, selected, onChanged, isOptionDisabled)
    local frame = self:CreateDropdown(parent, label, options, selected, onChanged)
    if not frame then return nil end

    -- Override the menu initializer with disabled-option awareness
    UIDropDownMenu_Initialize(frame.dropdown, function(self, level)
        for _, option in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            local reason = isOptionDisabled and isOptionDisabled(option)
            if reason then
                info.text         = option .. "  |cff808080(" .. reason .. ")|r"
                info.disabled     = true
                info.notCheckable = true
            else
                info.text = option
                info.func = function(self)
                    UIDropDownMenu_SetText(frame.dropdown, option)
                    if onChanged then
                        onChanged(option)
                    end
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return frame
end

---@param parent Frame
---@param label string Display label text
---@param r number? Red channel (0-1)
---@param g number? Green channel (0-1)
---@param b number? Blue channel (0-1)
---@param onChanged fun(r: number, g: number, b: number)? Callback when color changes
---@return PrephsFramework.UI.ColorPickerFrame|nil
function Factory:CreateColorPicker(parent, label, r, g, b, onChanged)
    local frame = self:AcquireFrame("ColorPicker", parent)
    if not frame then return nil end
    ---@cast frame PrephsFramework.UI.ColorPickerFrame
    
    UI.elementSequence = UI.elementSequence + 1
    frame.sequence = UI.elementSequence
    
    frame.label:SetText(label)
    frame.colorBox.bg:SetColorTexture(r or 1, g or 1, b or 1)
    
    frame.colorBox:SetScript("OnClick", function()
        local info = {
            swatchFunc = function()
                local newR, newG, newB = ColorPickerFrame:GetColorRGB()
                frame.colorBox.bg:SetColorTexture(newR, newG, newB)
                if onChanged then
                    onChanged(newR, newG, newB)
                end
            end,
            hasOpacity = false,
            r = r,
            g = g,
            b = b,
        }
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
    
    frame.isLayoutManaged = true
    frame.layoutOffset = nil
    
    return frame
end

---@param parent Frame
---@param label string Button text
---@param onClick fun()? Click handler
---@return ManagedFrame|nil
function Factory:CreateButton(parent, label, onClick)
    local button = self:AcquireFrame("Button", parent)
    if not button then return nil end
    
    UI.elementSequence = UI.elementSequence + 1
    button.sequence = UI.elementSequence
    
    button:SetText(label)
    
    if onClick then
        button:SetScript("OnClick", onClick)
    end
    
    button.isLayoutManaged = true
    button.layoutOffset = nil
    
    return button
end

---@param anchorFrame Button The cog button to anchor the popup to
---@param moduleID moduleID
---@param featureName string
---@param suppressionFlags SuppressionFlags
---@param featureDB table Feature database table for storing suppression state
---@return PrephsFramework.UI.SuppressionPopup popup The created suppression popup frame
function Factory:CreateSuppressionPopup(anchorFrame, moduleID, featureName, suppressionFlags, featureDB)
    -- Close any existing popup first
    if UI.currentSuppressionPopup and UI.currentSuppressionPopup:IsShown() then
        UI.currentSuppressionPopup:Hide()
    end
    
    -- Create popup frame
    ---@type PrephsFramework.UI.SuppressionPopup
    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(300, 200)
    popup:SetPoint("LEFT", anchorFrame, "RIGHT", 10, 0)
    popup:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    popup:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    popup:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    popup:SetFrameStrata("DIALOG")
    popup:EnableKeyboard(false)  -- Ensure keyboard input doesn't block game controls
    popup:EnableMouse(true)      -- But still allow mouse interaction
    popup:Hide()
    
    -- Store reference to current popup
    UI.currentSuppressionPopup = popup
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        popup:Hide()
        UI.currentSuppressionPopup = nil
    end)
    
    -- Close when clicking outside (check every frame when shown)
    popup:SetScript("OnShow", function(self)
        local mouseWasDown = false
        self:SetScript("OnUpdate", function(self, elapsed)
            local mouseIsDown = IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")
            -- Check popup itself AND any child zone menu
            local mouseOverPopup = MouseIsOver(self) or (self.zoneMenu and MouseIsOver(self.zoneMenu))
            
            -- Only close if: mouse button was just pressed (not previously down) AND mouse is outside popup
            if mouseIsDown and not mouseWasDown and not mouseOverPopup then
                self:Hide()
                UI.currentSuppressionPopup = nil
                self:SetScript("OnUpdate", nil)
            end
            
            mouseWasDown = mouseIsDown
        end)
    end)
    
    popup:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
        if UI.currentSuppressionPopup == self then
            UI.currentSuppressionPopup = nil
        end
    end)
    
    -- Title
    local title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Suppression Settings")
    
    local yOffset = -40
    
    -- Create checkboxes for each suppression flag
    if suppressionFlags.inRaid ~= nil then
        local cb = CreateFrame("CheckButton", nil, popup, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 10, yOffset)
        cb:SetChecked(featureDB._suppressInRaid or false)
        
        local text = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        text:SetText("Suppress in Raid")
        
        cb:SetScript("OnClick", function(self)
            featureDB._suppressInRaid = self:GetChecked()
            Core:OnSuppressionChanged(moduleID, featureName)
        end)
        
        yOffset = yOffset - 25
    end
    
    if suppressionFlags.inGroup ~= nil then
        local cb = CreateFrame("CheckButton", nil, popup, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 10, yOffset)
        cb:SetChecked(featureDB._suppressInGroup or false)
        
        local text = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        text:SetText("Suppress in Dungeon Group")
        
        cb:SetScript("OnClick", function(self)
            featureDB._suppressInGroup = self:GetChecked()
            Core:OnSuppressionChanged(moduleID, featureName)
        end)
        
        yOffset = yOffset - 25
    end
    
    if suppressionFlags.inInstance ~= nil then
        local cb = CreateFrame("CheckButton", nil, popup, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 10, yOffset)
        cb:SetChecked(featureDB._suppressInInstance or false)
        
        local text = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        text:SetText("Suppress in Instance")
        
        cb:SetScript("OnClick", function(self)
            featureDB._suppressInInstance = self:GetChecked()
            Core:OnSuppressionChanged(moduleID, featureName)
        end)
        
        yOffset = yOffset - 25
    end
    
    -- Zone suppression dropdown
    if suppressionFlags.inZones ~= nil then
        -- Initialize zone table if needed
        if not featureDB._suppressInZones then
            featureDB._suppressInZones = {}
        end
        
        local zoneLabel = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        zoneLabel:SetPoint("TOPLEFT", 10, yOffset)
        zoneLabel:SetText("Suppress in Zones:")
        
        yOffset = yOffset - 20
        
        -- Create zone dropdown button
        local zoneBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
        zoneBtn:SetSize(180, 22)
        zoneBtn:SetPoint("TOPLEFT", 10, yOffset)
        zoneBtn:SetText("Select Zones...")
        
        -- ADD THIS: Count indicator for active zone suppressions
        local zoneCount = 0
        for _ in pairs(featureDB._suppressInZones) do
            zoneCount = zoneCount + 1
        end
        
        local countLabel = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        countLabel:SetPoint("LEFT", zoneBtn, "RIGHT", 10, 0)
        if zoneCount > 0 then
            countLabel:SetText("|cff00ff00(" .. zoneCount .. " active)|r")  -- Green text
        else
            countLabel:SetText("|cff808080(none)|r")  -- Gray text
        end
        
        -- Create zone menu frame
        local zoneMenu = CreateFrame("Frame", nil, popup, "BackdropTemplate")
        popup.zoneMenu = zoneMenu  -- Store reference for click-outside detection
        zoneMenu:SetSize(250, 300)
        zoneMenu:SetPoint("TOPLEFT", zoneBtn, "BOTTOMLEFT", 0, -2)
        zoneMenu:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        zoneMenu:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
        zoneMenu:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        zoneMenu:SetFrameStrata("TOOLTIP")
        zoneMenu:Hide()
        
        -- Scroll frame for zones
        local scrollFrame = CreateFrame("ScrollFrame", nil, zoneMenu, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 8, -8)
        scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
        
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(210, 1)
        scrollFrame:SetScrollChild(scrollChild)
        
        -- Populate zone checkboxes
        local zoneY = 0
        if zoneDB then
            -- Build sorted list of zones
            local zoneList = {}
            for uiMapID, zoneInfo in pairs(zoneDB) do
                table.insert(zoneList, {
                    id = uiMapID,
                    name = zoneInfo.name
                })
            end
            
            -- Sort alphabetically by name
            table.sort(zoneList, function(a, b) return a.name < b.name end)
            
            -- Create checkboxes for each zone
            for _, zone in ipairs(zoneList) do
                local zoneCB = CreateFrame("CheckButton", nil, scrollChild, "UICheckButtonTemplate")
                zoneCB:SetPoint("TOPLEFT", 5, zoneY)
                zoneCB:SetChecked(featureDB._suppressInZones[zone.id] or false)
                
                local zoneText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                zoneText:SetPoint("LEFT", zoneCB, "RIGHT", 5, 0)
                zoneText:SetText(zone.name)
                zoneText:SetWidth(180)
                zoneText:SetJustifyH("LEFT")
                
                zoneCB:SetScript("OnClick", function(self)
                    featureDB._suppressInZones[zone.id] = self:GetChecked() or nil
                    Core:OnSuppressionChanged(moduleID, featureName)
                    
                    -- UPDATE the count label
                    local newCount = 0
                    for _ in pairs(featureDB._suppressInZones) do
                        newCount = newCount + 1
                    end
                    if newCount > 0 then
                        countLabel:SetText("|cff00ff00(" .. newCount .. " active)|r")
                    else
                        countLabel:SetText("|cff808080(none)|r")
                    end
                end)
                
                zoneY = zoneY - 20
            end
        end
        
        scrollChild:SetHeight(math.abs(zoneY))
        
        -- Toggle menu visibility
        zoneBtn:SetScript("OnClick", function()
            if zoneMenu:IsShown() then
                zoneMenu:Hide()
            else
                zoneMenu:Show()
            end
        end)
        
        -- Hide menu when clicking outside
        zoneMenu:SetScript("OnShow", function(self)
            local mouseWasDown = false
            self:SetScript("OnUpdate", function(self)
                local mouseIsDown = IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")
                local mouseOverMenu = MouseIsOver(self) or MouseIsOver(zoneBtn)
                
                -- Only close if click initiated outside menu
                if mouseIsDown and not mouseWasDown and not mouseOverMenu then
                    self:Hide()
                    self:SetScript("OnUpdate", nil)
                end
                
                mouseWasDown = mouseIsDown
            end)
        end)
        
        yOffset = yOffset - 30
        
        -- Increase popup size to accommodate zones
        popup:SetHeight(math.max(200, math.abs(yOffset) + 20))
    end
    
    return popup
end

-- ============================================================================
-- EditableList Component
-- ============================================================================

---@param parent Frame
---@param label string Header label
---@param entries table[] Initial entries ({id, displayText}[])
---@param resolveFunc fun(input: string): (number|string|nil), (string|nil)
---@param onListChanged fun(entries: table[])? Callback when list changes
---@param inputHint string? Placeholder text
---@return ManagedFrame|nil
function Factory:CreateEditableList(parent, label, entries, resolveFunc, onListChanged, inputHint)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(600, 30) -- will be resized dynamically
    frame.inUse = true
    frame.frameType = "EditableList"
    UI.elementSequence = UI.elementSequence + 1
    frame.sequence = UI.elementSequence
    frame.isLayoutManaged = true
    frame.layoutOffset = nil

    -- Internal copy of entries
    local listEntries = {}
    for _, e in ipairs(entries) do
        table.insert(listEntries, { id = e.id, displayText = e.displayText })
    end

    -- Header label
    local headerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerText:SetPoint("TOPLEFT", 0, 0)
    headerText:SetText(label)

    -- Row container
    local rowContainer = CreateFrame("Frame", nil, frame)
    rowContainer:SetPoint("TOPLEFT", 0, -20)
    rowContainer:SetSize(600, 1)

    local rowFrames = {}

    local function RefreshHeight()
        local rowCount = #listEntries
        local inputHeight = 30
        local headerHeight = 20
        local rowHeight = rowCount * 22
        local totalHeight = headerHeight + rowHeight + inputHeight + 10
        rowContainer:SetHeight(math.max(rowHeight, 1))
        frame:SetHeight(totalHeight)
    end

    local function RebuildRows()
        -- Hide existing rows
        for _, row in ipairs(rowFrames) do
            row:Hide()
            row:SetParent(nil)
        end
        rowFrames = {}

        for i, entry in ipairs(listEntries) do
            local row = CreateFrame("Frame", nil, rowContainer)
            row:SetSize(550, 20)
            row:SetPoint("TOPLEFT", 0, -((i - 1) * 22))

            local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            text:SetPoint("LEFT", 5, 0)
            local displayStr = entry.displayText
                and (entry.displayText .. " (" .. tostring(entry.id) .. ")")
                or tostring(entry.id)
            text:SetText(displayStr)

            local removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            removeBtn:SetSize(20, 20)
            removeBtn:SetPoint("RIGHT", -2, 0)
            removeBtn:SetText("X")
            removeBtn:SetScript("OnClick", function()
                table.remove(listEntries, i)
                RebuildRows()
                if onListChanged then onListChanged(listEntries) end
            end)

            row:Show()
            table.insert(rowFrames, row)
        end

        RefreshHeight()
    end

    -- Input row
    local inputRow = CreateFrame("Frame", nil, frame)
    inputRow:SetSize(600, 28)

    local inputBox = CreateFrame("EditBox", nil, inputRow, "InputBoxTemplate")
    inputBox:SetSize(250, 20)
    inputBox:SetPoint("LEFT", 0, 0)
    inputBox:SetAutoFocus(false)
    if inputHint then
        inputBox:SetText(inputHint)
        inputBox:SetTextColor(0.5, 0.5, 0.5)
        inputBox:SetScript("OnEditFocusGained", function(self)
            if self:GetText() == inputHint then
                self:SetText("")
                self:SetTextColor(1, 1, 1)
            end
        end)
        inputBox:SetScript("OnEditFocusLost", function(self)
            if self:GetText() == "" then
                self:SetText(inputHint)
                self:SetTextColor(0.5, 0.5, 0.5)
            end
        end)
    end

    local addBtn = CreateFrame("Button", nil, inputRow, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 22)
    addBtn:SetPoint("LEFT", inputBox, "RIGHT", 5, 0)
    addBtn:SetText("Add")

    local function AddEntry()
        local raw = inputBox:GetText()
        if not raw or raw == "" or raw == inputHint then return end

        local id, displayName = resolveFunc(raw)
        if id == nil then
            print("|cffFF0000[AutoQuest]|r Invalid input: " .. raw)
            return
        end

        -- Duplicate check
        for _, e in ipairs(listEntries) do
            if tostring(e.id) == tostring(id) then return end
        end

        table.insert(listEntries, { id = id, displayText = displayName })
        inputBox:SetText("")
        RebuildRows()
        if onListChanged then onListChanged(listEntries) end
    end

    addBtn:SetScript("OnClick", AddEntry)
    inputBox:SetScript("OnEnterPressed", function(self)
        AddEntry()
        self:ClearFocus()
    end)

    -- Position input row after row container using OnUpdate to track dynamic height
    inputRow:SetScript("OnShow", function()
        inputRow:ClearAllPoints()
        inputRow:SetPoint("TOPLEFT", rowContainer, "BOTTOMLEFT", 0, -5)
    end)
    inputRow:SetPoint("TOPLEFT", rowContainer, "BOTTOMLEFT", 0, -5)

    RebuildRows()

    return frame
end

-- ============================================================================
-- CheckboxGroup Component
-- ============================================================================

---@param parent Frame
---@param label string Main checkbox label text
---@param mainChecked boolean Whether the main checkbox is initially checked
---@param children CheckboxGroupChildConfig[] List of child checkbox configurations
---@param onMainChanged fun(checked: boolean)? Callback when main checkbox is toggled
---@param onChildChanged fun(key: string, checked: boolean)? Callback when a child checkbox is toggled
---@param childStates table<string, boolean>? Initial child states keyed by child key
---@param collapsible boolean? Whether the group can be collapsed/expanded
---@return ManagedFrame|nil
function Factory:CreateCheckboxGroup(parent, label, mainChecked, children, onMainChanged, onChildChanged, childStates, collapsible)
    local frame = CreateFrame("Frame", nil, parent)
    local childCount = #children
    local expandedHeight = 26 + (childCount * 22) + 6
    local collapsedHeight = 26
    local isCollapsed = collapsible == true -- start collapsed when collapsible

    frame:SetSize(600, isCollapsed and collapsedHeight or expandedHeight)
    frame.inUse = true
    frame.frameType = "CheckboxGroup"
    UI.elementSequence = UI.elementSequence + 1
    frame.sequence = UI.elementSequence
    frame.isLayoutManaged = true
    frame.layoutOffset = nil

    childStates = childStates or {}

    -- Collapse/expand arrow (only when collapsible)
    local collapseArrow
    if collapsible then
        collapseArrow = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        collapseArrow:SetPoint("TOPLEFT", 0, -5)
        collapseArrow:SetText(isCollapsed and "|cffAAAAAA[+]|r" or "|cffAAAAAA[-]|r")
    end

    -- Main toggle checkbox
    local mainCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    mainCB:SetPoint("TOPLEFT", collapsible and 14 or 0, 0)
    mainCB:SetChecked(mainChecked)

    local mainText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainText:SetPoint("LEFT", mainCB, "RIGHT", 3, 0)
    mainText:SetText(label)

    -- Child container
    local childContainer = CreateFrame("Frame", nil, frame)
    childContainer:SetPoint("TOPLEFT", collapsible and 34 or 20, -26)
    childContainer:SetSize(550, childCount * 22)

    if isCollapsed then
        childContainer:Hide()
    end

    local childCheckboxes = {}

    -- Toggle collapsed state
    local function SetCollapsed(collapsed)
        isCollapsed = collapsed
        if collapsed then
            childContainer:Hide()
            frame:SetHeight(collapsedHeight)
            if collapseArrow then collapseArrow:SetText("|cffAAAAAA[+]|r") end
        else
            childContainer:Show()
            frame:SetHeight(expandedHeight)
            if collapseArrow then collapseArrow:SetText("|cffAAAAAA[-]|r") end
        end
        -- Trigger layout refresh so elements below reposition
        UI:RefreshLayout(parent)
    end

    -- Clickable collapse toggle region
    if collapsible then
        local toggleBtn = CreateFrame("Button", nil, frame)
        toggleBtn:SetPoint("TOPLEFT", 0, 0)
        toggleBtn:SetPoint("RIGHT", mainCB, "LEFT", 0, 0)
        toggleBtn:SetHeight(26)
        toggleBtn:SetScript("OnClick", function()
            SetCollapsed(not isCollapsed)
        end)

        -- Also allow clicking the label to toggle
        local labelBtn = CreateFrame("Button", nil, frame)
        labelBtn:SetPoint("LEFT", mainText, "LEFT", 0, 0)
        labelBtn:SetPoint("RIGHT", mainText, "RIGHT", 0, 0)
        labelBtn:SetHeight(20)
        labelBtn:SetScript("OnClick", function()
            SetCollapsed(not isCollapsed)
        end)
    end

    local function UpdateChildStates()
        local enabled = mainCB:GetChecked()
        for _, childData in ipairs(childCheckboxes) do
            childData.checkbox:SetEnabled(enabled)
            childData.frame:SetAlpha(enabled and 1 or 0.4)
        end
    end

    -- Create child checkboxes
    for i, childConfig in ipairs(children) do
        local childFrame = CreateFrame("Frame", nil, childContainer)
        childFrame:SetSize(550, 22)
        childFrame:SetPoint("TOPLEFT", 0, -((i - 1) * 22))

        local cb = CreateFrame("CheckButton", nil, childFrame, "UICheckButtonTemplate")
        cb:SetPoint("LEFT", 0, 0)

        local initialChecked = childStates[childConfig.key]
        if initialChecked == nil then
            initialChecked = childConfig.default or false
        end
        cb:SetChecked(initialChecked)

        local text = childFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", cb, "RIGHT", 3, 0)
        text:SetText(childConfig.label)

        cb:SetScript("OnClick", function(self)
            if onChildChanged then
                onChildChanged(childConfig.key, self:GetChecked())
            end
        end)

        table.insert(childCheckboxes, { checkbox = cb, frame = childFrame, key = childConfig.key })
    end

    -- Main toggle handler
    mainCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        UpdateChildStates()
        if onMainChanged then onMainChanged(checked) end
    end)

    UpdateChildStates()

    return frame
end

-- ============================================================================
-- CardContainer Component
-- ============================================================================
-- A managed layout element that holds collapsible, reorderable "card" frames,
-- optionally organised into collapsible **sections** (groups with a header).
--
-- Ordering uses a single flat list: sections without a header have their
-- entries promoted to individual items, while sections with a header are
-- treated as a single grouped item.  All items — individual cards and
-- section groups — share one reorder list, so groups can be interleaved
-- freely between individual cards.
--
-- Within a section group, child cards have their own sub-ordering.
--
-- Usage:
--   local container = Factory:CreateCardContainer(scrollChild, {
--       persistCollapsed        = tbl, -- table<key, bool>  card collapse
--       persistOrder            = tbl, -- table<secKey, string[]>  child order within sections
--       persistSectionCollapsed = tbl, -- table<secKey, bool>  section collapse
--       persistSectionOrder     = tbl, -- string[]  flat ordering (cards + section groups)
--       cardPadding      = 6,
--       sectionPadding   = 12,
--       cardLineHeight   = 14,
--       maxLinesPerCard  = 30,
--   })
--   container:Populate(sections, configFns)
--     sections = ordered array of {
--         _key         = "sectionKey",
--         _header      = table|nil,      -- data for header (nil → entries promoted to flat items)
--         _entries     = { {_key=…, …}, … },
--         _collapsible = true|false,     -- default true
--     }
--     configFns = {
--         header = function(card, headerData, isSectionCollapsed),
--         card   = function(card, cardData, isCardCollapsed),
--     }
-- ============================================================================

local CARD_DEFAULTS = {
    cardPadding     = 6,
    sectionPadding  = 12,
    cardLineHeight  = 14,
    maxLinesPerCard = 30,
    cardBgAlpha     = 0.75,
}

-- Internal card pool per container
local function ReleaseCard(card)
    card._inUse = false
    card:Hide()
    card:ClearAllPoints()
    for i = 1, #card._lines do
        card._lines[i]:Hide()
        card._lines[i]:SetText("")
    end
    if card._editBoxes then
        for _, eb in ipairs(card._editBoxes) do
            eb:Hide()
            eb:ClearAllPoints()
            eb:SetText("")
            eb:SetScript("OnEnterPressed", nil)
            eb:SetScript("OnEditFocusLost", nil)
            eb._inUse = false
        end
    end
    card._toggleBtn:Hide()
    card._upBtn:Hide()
    card._dnBtn:Hide()
end

local function ReleaseAllCards(pool)
    for _, card in ipairs(pool) do
        if card._inUse then ReleaseCard(card) end
    end
end

local function AcquireCard(pool, parent, maxLines)
    for _, card in ipairs(pool) do
        if not card._inUse then
            card._inUse = true
            card:SetParent(parent)
            return card
        end
    end

    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card._inUse = true

    card._editBoxes = {}
    card._lines = {}
    for i = 1, maxLines do
        local fs = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetJustifyH("LEFT")
        fs:Hide()
        card._lines[i] = fs
    end

    card._toggleBtn = CreateFrame("Button", nil, card)
    card._toggleBtn:SetPoint("TOPLEFT",  card, "TOPLEFT",  0, 0)
    card._toggleBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)
    card._toggleBtn:SetHeight(20)

    card._upBtn = CreateFrame("Button", nil, card)
    card._upBtn:SetSize(14, 14)
    card._upBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -22, -3)
    card._upBtn:SetFrameLevel(card:GetFrameLevel() + 5)
    card._upFs = card._upBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    card._upFs:SetAllPoints()

    card._dnBtn = CreateFrame("Button", nil, card)
    card._dnBtn:SetSize(14, 14)
    card._dnBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -3)
    card._dnBtn:SetFrameLevel(card:GetFrameLevel() + 5)
    card._dnFs = card._dnBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    card._dnFs:SetAllPoints()

    pool[#pool + 1] = card
    return card
end

---@class CardContainerConfig
---@field persistCollapsed table<string, boolean>? Persisted collapse states keyed by card key
---@field persistOrder table<string, string[]>? Persisted card order per section (secKey → array of card keys)
---@field persistSectionCollapsed table<string, boolean>? Persisted section collapse states
---@field persistSectionOrder string[]? Persisted section ordering
---@field cardPadding number? Pixels between cards (default 6)
---@field sectionPadding number? Pixels gap between sections (default 12)
---@field cardLineHeight number? Pixels per text line (default 14)
---@field maxLinesPerCard number? Pre-allocated lines per card (default 30)
---@field cardBgAlpha number? Card background alpha (default 0.75)

---@class CardContainerFrame : ManagedFrame
---@field Populate fun(self: CardContainerFrame, sections: table[], configFns: table)

---@param parent Frame The scroll child to create the container in
---@param config CardContainerConfig?
---@return CardContainerFrame
function Factory:CreateCardContainer(parent, config)
    config = config or {}
    local padding     = config.cardPadding             or CARD_DEFAULTS.cardPadding
    local secPad      = config.sectionPadding          or CARD_DEFAULTS.sectionPadding
    local lineH       = config.cardLineHeight          or CARD_DEFAULTS.cardLineHeight
    local maxLines    = config.maxLinesPerCard          or CARD_DEFAULTS.maxLinesPerCard
    local bgAlpha     = config.cardBgAlpha             or CARD_DEFAULTS.cardBgAlpha
    local collapsed        = config.persistCollapsed        or {}
    local cardOrder        = config.persistOrder            or {} -- table<secKey, string[]>
    local sectionCollapsed = config.persistSectionCollapsed or {}
    local sectionOrder     = config.persistSectionOrder     or {}

    local container = CreateFrame("Frame", nil, parent)
    container:SetWidth(parent:GetWidth() or 600)
    container:SetHeight(1) -- sized dynamically

    UI.elementSequence = UI.elementSequence + 1
    container.sequence = UI.elementSequence
    container.isLayoutManaged = true
    container.layoutOffset = nil
    container.inUse = true
    container.frameType = "CardContainer"

    local cardPool = {}
    local currentSections  = nil
    local currentConfigFns = nil

    -- Helpers: keep ordering arrays up-to-date
    local function EnsureInSectionOrder(key)
        for _, k in ipairs(sectionOrder) do if k == key then return end end
        sectionOrder[#sectionOrder + 1] = key
    end

    local function EnsureInCardOrder(orderTbl, key)
        for _, k in ipairs(orderTbl) do if k == key then return end end
        orderTbl[#orderTbl + 1] = key
    end

    -- Install NextLine / AddEditBox helpers for one render pass of a card.
    -- Returns a function that yields the final content height.
    local function SetupCardLines(card, cardW)
        local lineIdx = 0
        local lineY   = -6

        function card:NextLine(text, font)
            lineIdx = lineIdx + 1
            if lineIdx > maxLines then return 0 end
            local lh = (font == "GameFontNormal" or font == "GameFontHighlight") and 16 or lineH
            local fs = self._lines[lineIdx]
            fs:SetFontObject(font or "GameFontNormalSmall")
            fs:SetWidth(cardW - 20)
            fs:ClearAllPoints()
            fs:SetPoint("TOPLEFT", self, "TOPLEFT", 10, lineY)
            fs:SetText(text)
            fs:Show()
            lineY = lineY - lh
            return lh
        end

        function card:AddEditBox(placeholder, currentText, width, height, onChanged)
            local ebW = width  or (cardW - 30)
            local ebH = height or 22
            local eb
            for _, existing in ipairs(self._editBoxes) do
                if not existing._inUse then eb = existing; break end
            end
            if not eb then
                eb = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
                eb:SetAutoFocus(false)
                eb:SetFontObject("GameFontNormalSmall")
                self._editBoxes[#self._editBoxes + 1] = eb
            end
            eb._inUse = true
            eb:SetSize(ebW, ebH)
            eb:ClearAllPoints()
            eb:SetPoint("TOPLEFT", self, "TOPLEFT", 14, lineY - 2)
            eb:SetText(currentText or "")
            eb:Show()
            if onChanged then
                eb:SetScript("OnEnterPressed", function(self) self:ClearFocus(); onChanged(self:GetText()) end)
                eb:SetScript("OnEditFocusLost", function(self) onChanged(self:GetText()) end)
            end
            lineY = lineY - (ebH + 4)
            return eb
        end

        return function() return (-lineY) + 6 end
    end

    -- Refresh: release all cards, re-create from current data.
    -- Uses a flat ordering model: sections without a header have their
    -- entries promoted to individual items; sections with a header are
    -- a single grouped item.  All items share one reorder list so
    -- section groups can be interleaved freely between individual cards.
    local function Refresh()
        ReleaseAllCards(cardPool)

        if not currentSections or not currentConfigFns then
            container:SetHeight(1)
            UI:RefreshLayout(parent)
            return
        end

        -- ── Build flat item list ────────────────────────────────────
        local flatItems = {}
        for _, section in ipairs(currentSections) do
            if not section._header then
                -- Promote entries from headerless sections to flat items
                for _, entry in ipairs(section._entries or {}) do
                    flatItems[#flatItems + 1] = {
                        type = "card",
                        key  = entry._key,
                        data = entry,
                    }
                end
            else
                flatItems[#flatItems + 1] = {
                    type    = "section",
                    key     = section._key,
                    section = section,
                }
            end
        end

        -- ── Apply flat ordering from sectionOrder ───────────────────
        -- Prune stale keys that no longer match any flat item …
        local currentKeys = {}
        for _, item in ipairs(flatItems) do currentKeys[item.key] = true end
        for i = #sectionOrder, 1, -1 do
            if not currentKeys[sectionOrder[i]] then
                table.remove(sectionOrder, i)
            end
        end
        -- … then ensure every current item is represented.
        for _, item in ipairs(flatItems) do
            EnsureInSectionOrder(item.key)
        end

        local flatPosMap = {}
        for i, k in ipairs(sectionOrder) do flatPosMap[k] = i end
        table.sort(flatItems, function(a, b)
            return (flatPosMap[a.key] or 999) < (flatPosMap[b.key] or 999)
        end)

        local C_LABEL = "|cffAAAAAA"
        local C_VALUE = "|cffFFD100"
        local C_RESET = "|r"
        local totalH  = 0

        for flatIdx, item in ipairs(flatItems) do

            if item.type == "section" then
                -- ── Section group (header + children) ───────────────
                local section   = item.section
                local secKey    = section._key
                local isSecCol  = sectionCollapsed[secKey] or false
                local collapsible = section._collapsible ~= false

                -- Extra gap before a section group
                if totalH > 0 then totalH = totalH + secPad end

                -- Section header card
                if section._header and currentConfigFns.header then
                    local card  = AcquireCard(cardPool, container, maxLines)
                    local cardW = container:GetWidth() - 4
                    local getH  = SetupCardLines(card, cardW)

                    card:SetWidth(cardW)
                    card:SetPoint("TOPLEFT", container, "TOPLEFT", 2, -totalH)
                    card:SetBackdrop({
                        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
                        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                        edgeSize = 8,
                        insets   = { left = 2, right = 2, top = 2, bottom = 2 },
                    })
                    card:SetBackdropColor(0.08, 0.08, 0.12, bgAlpha)
                    card:SetBackdropBorderColor(0.3, 0.3, 0.4, 0.5)

                    -- Section toggle (collapse children)
                    card._toggleBtn:Show()
                    if collapsible then
                        card._toggleBtn:SetScript("OnClick", function()
                            sectionCollapsed[secKey] = not sectionCollapsed[secKey]
                            Refresh()
                        end)
                    else
                        card._toggleBtn:SetScript("OnClick", nil)
                    end

                    -- Flat reorder — section moves as a whole unit
                    if flatIdx > 1 then
                        card._upFs:SetText(C_LABEL .. "^" .. C_RESET)
                        card._upBtn:SetScript("OnEnter", function() card._upFs:SetText(C_VALUE .. "^" .. C_RESET) end)
                        card._upBtn:SetScript("OnLeave", function() card._upFs:SetText(C_LABEL .. "^" .. C_RESET) end)
                        card._upBtn:SetScript("OnClick", function()
                            for i, k in ipairs(sectionOrder) do
                                if k == secKey and i > 1 then
                                    sectionOrder[i], sectionOrder[i - 1] = sectionOrder[i - 1], sectionOrder[i]
                                    break
                                end
                            end
                            Refresh()
                        end)
                        card._upBtn:Show()
                    end
                    if flatIdx < #flatItems then
                        card._dnFs:SetText(C_LABEL .. "v" .. C_RESET)
                        card._dnBtn:SetScript("OnEnter", function() card._dnFs:SetText(C_VALUE .. "v" .. C_RESET) end)
                        card._dnBtn:SetScript("OnLeave", function() card._dnFs:SetText(C_LABEL .. "v" .. C_RESET) end)
                        card._dnBtn:SetScript("OnClick", function()
                            for i, k in ipairs(sectionOrder) do
                                if k == secKey and i < #sectionOrder then
                                    sectionOrder[i], sectionOrder[i + 1] = sectionOrder[i + 1], sectionOrder[i]
                                    break
                                end
                            end
                            Refresh()
                        end)
                        card._dnBtn:Show()
                    end

                    currentConfigFns.header(card, section._header, isSecCol)

                    local cardH = getH()
                    card:SetHeight(cardH)
                    card:Show()
                    totalH = totalH + cardH + padding
                end

                -- ── Section child cards ─────────────────────────────
                if not isSecCol then
                    local entries = section._entries or {}
                    cardOrder[secKey] = cardOrder[secKey] or {}
                    local curOrder = cardOrder[secKey]
                    for _, e in ipairs(entries) do EnsureInCardOrder(curOrder, e._key) end
                    local childPosMap = {}
                    for i, k in ipairs(curOrder) do childPosMap[k] = i end
                    table.sort(entries, function(a, b)
                        return (childPosMap[a._key] or 999) < (childPosMap[b._key] or 999)
                    end)

                    for cardIdx, data in ipairs(entries) do
                        local card  = AcquireCard(cardPool, container, maxLines)
                        local key   = data._key
                        local isCol = collapsed[key] or false
                        local cardW = container:GetWidth() - 4
                        local getH  = SetupCardLines(card, cardW)

                        card:SetWidth(cardW)
                        card:SetPoint("TOPLEFT", container, "TOPLEFT", 2, -totalH)
                        card:SetBackdrop({
                            bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
                            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                            edgeSize = 8,
                            insets   = { left = 2, right = 2, top = 2, bottom = 2 },
                        })
                        if data._highlight then
                            card:SetBackdropColor(0.05, 0.12, 0.18, math.min(bgAlpha * 2, 1.0))
                            card:SetBackdropBorderColor(0.4, 0.7, 1.0, 0.5)
                        else
                            card:SetBackdropColor(0.06, 0.06, 0.08, bgAlpha)
                            card:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.4)
                        end

                        card._toggleBtn:Show()
                        card._toggleBtn:SetScript("OnClick", function()
                            collapsed[key] = not collapsed[key]
                            Refresh()
                        end)

                        -- Reorder within section
                        if cardIdx > 1 then
                            card._upFs:SetText(C_LABEL .. "^" .. C_RESET)
                            card._upBtn:SetScript("OnEnter", function() card._upFs:SetText(C_VALUE .. "^" .. C_RESET) end)
                            card._upBtn:SetScript("OnLeave", function() card._upFs:SetText(C_LABEL .. "^" .. C_RESET) end)
                            card._upBtn:SetScript("OnClick", function()
                                for i, k in ipairs(curOrder) do
                                    if k == key and i > 1 then
                                        curOrder[i], curOrder[i - 1] = curOrder[i - 1], curOrder[i]
                                        break
                                    end
                                end
                                Refresh()
                            end)
                            card._upBtn:Show()
                        end
                        if cardIdx < #entries then
                            card._dnFs:SetText(C_LABEL .. "v" .. C_RESET)
                            card._dnBtn:SetScript("OnEnter", function() card._dnFs:SetText(C_VALUE .. "v" .. C_RESET) end)
                            card._dnBtn:SetScript("OnLeave", function() card._dnFs:SetText(C_LABEL .. "v" .. C_RESET) end)
                            card._dnBtn:SetScript("OnClick", function()
                                for i, k in ipairs(curOrder) do
                                    if k == key and i < #curOrder then
                                        curOrder[i], curOrder[i + 1] = curOrder[i + 1], curOrder[i]
                                        break
                                    end
                                end
                                Refresh()
                            end)
                            card._dnBtn:Show()
                        end

                        currentConfigFns.card(card, data, isCol)

                        local cardH = getH()
                        card:SetHeight(cardH)
                        card:Show()
                        totalH = totalH + cardH + padding
                    end
                end

            else
                -- ── Individual card (promoted from headerless section) ──
                local data  = item.data
                local key   = item.key
                local isCol = collapsed[key] or false

                if totalH > 0 then totalH = totalH + padding end

                local card  = AcquireCard(cardPool, container, maxLines)
                local cardW = container:GetWidth() - 4
                local getH  = SetupCardLines(card, cardW)

                card:SetWidth(cardW)
                card:SetPoint("TOPLEFT", container, "TOPLEFT", 2, -totalH)
                card:SetBackdrop({
                    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    edgeSize = 8,
                    insets   = { left = 2, right = 2, top = 2, bottom = 2 },
                })
                if data._highlight then
                    card:SetBackdropColor(0.05, 0.12, 0.18, math.min(bgAlpha * 2, 1.0))
                    card:SetBackdropBorderColor(0.4, 0.7, 1.0, 0.5)
                else
                    card:SetBackdropColor(0.06, 0.06, 0.08, bgAlpha)
                    card:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.4)
                end

                card._toggleBtn:Show()
                card._toggleBtn:SetScript("OnClick", function()
                    collapsed[key] = not collapsed[key]
                    Refresh()
                end)

                -- Flat reorder — individual cards share the same list as sections
                if flatIdx > 1 then
                    card._upFs:SetText(C_LABEL .. "^" .. C_RESET)
                    card._upBtn:SetScript("OnEnter", function() card._upFs:SetText(C_VALUE .. "^" .. C_RESET) end)
                    card._upBtn:SetScript("OnLeave", function() card._upFs:SetText(C_LABEL .. "^" .. C_RESET) end)
                    card._upBtn:SetScript("OnClick", function()
                        for i, k in ipairs(sectionOrder) do
                            if k == key and i > 1 then
                                sectionOrder[i], sectionOrder[i - 1] = sectionOrder[i - 1], sectionOrder[i]
                                break
                            end
                        end
                        Refresh()
                    end)
                    card._upBtn:Show()
                end
                if flatIdx < #flatItems then
                    card._dnFs:SetText(C_LABEL .. "v" .. C_RESET)
                    card._dnBtn:SetScript("OnEnter", function() card._dnFs:SetText(C_VALUE .. "v" .. C_RESET) end)
                    card._dnBtn:SetScript("OnLeave", function() card._dnFs:SetText(C_LABEL .. "v" .. C_RESET) end)
                    card._dnBtn:SetScript("OnClick", function()
                        for i, k in ipairs(sectionOrder) do
                            if k == key and i < #sectionOrder then
                                sectionOrder[i], sectionOrder[i + 1] = sectionOrder[i + 1], sectionOrder[i]
                                break
                            end
                        end
                        Refresh()
                    end)
                    card._dnBtn:Show()
                end

                currentConfigFns.card(card, data, isCol)

                local cardH = getH()
                card:SetHeight(cardH)
                card:Show()
                totalH = totalH + cardH
            end
        end

        container:SetHeight(math.max(totalH, 1))
        UI:RefreshLayout(parent)
    end

    ---@param sections table[] Array of section defs. Each must have `_key`, optional `_header`, `_entries`, `_collapsible`.
    ---@param configFns table  `{ header = fn(card, data, isSectionCollapsed), card = fn(card, data, isCardCollapsed) }`
    function container:Populate(sections, configFns)
        currentSections  = sections
        currentConfigFns = configFns
        Refresh()
    end

    container:Show()
    return container
end
