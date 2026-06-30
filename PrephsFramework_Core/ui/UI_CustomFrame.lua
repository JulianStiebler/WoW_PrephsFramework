--[[
    <PrephsFramework_Core/UI/UI_CustomFrame.lua>
    Copyright (C) <2026> <JulianStiebler / Prephmage>

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
    Author:  <JulianStiebler / Prephmage>
    Contact: <Discord: stiebulator>
    GitHub: https://github.com/JulianStiebler/PrephsFramework
--]]

---@meta _
local addonName, ns = ...

---@class PrephsFramework
local Core = ns.PF

---@class PrephsFramework.UI
local UI = Core.UI

---@class PrephsFramework.UI.Factory
local Factory = UI.Factory

---@type PrephsFramework.Logger
local logger = Core.Logger

local math = math
local ipairs = ipairs

-- ============================================================================
-- Frame Geometry Persistence
-- ============================================================================

--- Get persisted frame geometry from the module DB
---@param moduleID moduleID
---@param frameName frameName
---@return table|nil geometry {w, h, x, y}
function UI:GetFrameGeometry(moduleID, frameName)
    local moduleDB = Core:GetModuleDB(moduleID)
    if not moduleDB or not moduleDB.frames then return nil end
    return moduleDB.frames[frameName]
end

--- Save frame geometry to the module DB
---@param moduleID moduleID
---@param frameName frameName
---@param frame Frame
---@param saveSize boolean
---@param savePosition boolean
function UI:SaveFrameGeometry(moduleID, frameName, frame, saveSize, savePosition)
    local moduleDB = Core:GetModuleDB(moduleID)
    if not moduleDB then return end

    if not moduleDB.frames then
        moduleDB.frames = {}
    end
    if not moduleDB.frames[frameName] then
        moduleDB.frames[frameName] = {}
    end

    local geo = moduleDB.frames[frameName]

    if saveSize then
        geo.w = frame:GetWidth()
        geo.h = frame:GetHeight()
    end

    if savePosition then
        geo.x = frame:GetLeft()
        geo.y = frame:GetTop() - UIParent:GetTop()
    end
end

-- ============================================================================
-- Custom Frame Creation
-- ============================================================================

---@param moduleID moduleID
---@param frameName frameName
---@param frameConfig ModuleFrameConfig
---@return CustomFrame CustomFrame The created or existing custom frame
function UI:CreateCustomFrame(moduleID, frameName, frameConfig)
    local frameKey = moduleID .. "_" .. frameName

    -- If frame already exists, return it
    if self.CustomFrames[frameKey] then
        return self.CustomFrames[frameKey]
    end

    local sizeConfig = frameConfig.size
    local persistSize = false
    local persistPosition = false

    -- Determine persistence rules based on size config
    if sizeConfig then
        -- Size persisted if w/h specified OR resizable (user can change size)
        persistSize = (sizeConfig.w ~= nil and sizeConfig.h ~= nil) or (sizeConfig.resizable == true)
        -- Position persisted if x/y specified
        persistPosition = (sizeConfig.x ~= nil or sizeConfig.y ~= nil)
    end

    -- Load persisted geometry from DB
    local saved = self:GetFrameGeometry(moduleID, frameName)

    -- Resolve dimensions: persisted > config > defaults
    local frameW = (saved and saved.w) or (sizeConfig and sizeConfig.w) or 700
    local frameH = (saved and saved.h) or (sizeConfig and sizeConfig.h) or 600

    -- Create the main frame
    local f = CreateFrame("Frame", "PrephsFramework_Custom_" .. frameKey, UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(frameW, frameH)

    -- Position: persisted > config > CENTER
    if saved and saved.x and saved.y then
        f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", saved.x, saved.y)
    elseif sizeConfig and (sizeConfig.x ~= nil or sizeConfig.y ~= nil) then
        f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", sizeConfig.x or 0, sizeConfig.y or 0)
    else
        f:SetPoint("CENTER")
    end

    f:Hide()
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")

    -- Frame transparency
    if frameConfig.alpha then
        f:SetAlpha(frameConfig.alpha)
    end

    -- Drag scripts with position persistence
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if persistPosition then
            UI:SaveFrameGeometry(moduleID, frameName, self, persistSize, persistPosition)
        end
    end)

    -- Resizable setup
    if sizeConfig and sizeConfig.resizable then
        f:SetResizable(true)
        local minW = math.max((sizeConfig.w or 200) * 0.5, 200)
        local minH = math.max((sizeConfig.h or 150) * 0.5, 150)

        -- Compat: SetResizeBounds (retail/modern) vs SetMinResize/SetMaxResize (classic)
        if f.SetResizeBounds then
            f:SetResizeBounds(minW, minH, 1920, 1080)
        else
            f:SetMinResize(minW, minH)
            f:SetMaxResize(1920, 1080)
        end

        -- Resize grip
        local resizeGrip = CreateFrame("Button", nil, f)
        resizeGrip:SetSize(16, 16)
        resizeGrip:SetPoint("BOTTOMRIGHT", -2, 2)
        resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

        resizeGrip:SetScript("OnMouseDown", function()
            f:StartSizing("BOTTOMRIGHT")
        end)
        resizeGrip:SetScript("OnMouseUp", function()
            f:StopMovingOrSizing()
            UI:SaveFrameGeometry(moduleID, frameName, f, persistSize, persistPosition)
        end)

        f.resizeGrip = resizeGrip

        -- Adapt scroll child width on resize
        f:HookScript("OnSizeChanged", function(self, w, h)
            if f.contentScrollChild then
                f.contentScrollChild:SetWidth(math.max(w - 43, 100))
            end
        end)
    end

    -- Set title
    local moduleData = Core.DiscoveredModules[moduleID]
    local moduleDisplayName = (moduleData and moduleData.displayName) or moduleID
    f.TitleText:SetText(moduleDisplayName .. " - " .. (frameConfig.title or frameName))

    -- Register for ESC key closure (unless noEsc is set)
    if not frameConfig.noEsc then
        tinsert(UISpecialFrames, f:GetName())
    end

    -- Content area anchored to frame edges for dynamic sizing
    f.content = CreateFrame("Frame", nil, f)
    f.content:SetPoint("TOPLEFT", 8, -30)
    f.content:SetPoint("BOTTOMRIGHT", -8, 8)

    f.contentScrollFrame = CreateFrame("ScrollFrame", nil, f.content, "UIPanelScrollFrameTemplate")
    f.contentScrollFrame:SetPoint("TOPLEFT", 0, -5)
    f.contentScrollFrame:SetPoint("BOTTOMRIGHT", -27, 5)

    f.contentScrollChild = CreateFrame("Frame", nil, f.contentScrollFrame)
    f.contentScrollChild:SetSize(math.max(frameW - 43, 100), 1)
    f.contentScrollFrame:SetScrollChild(f.contentScrollChild)

    -- Store references
    f.moduleID = moduleID
    f.frameName = frameName
    f.frameConfig = frameConfig
    f.ScrollFrame = f.contentScrollFrame
    f.ScrollChild = f.contentScrollChild

    -- Set up show/hide scripts
    f:SetScript("OnShow", function()
        if frameConfig.OnShow then
            local success, err = pcall(frameConfig.OnShow)
            if not success then
                logger:error("Custom frame OnShow failed for %s.%s: %s", moduleID, frameName, tostring(err))
            end
        end
    end)

    f:SetScript("OnHide", function()
        if frameConfig.OnHide then
            local success, err = pcall(frameConfig.OnHide)
            if not success then
                logger:error("Custom frame OnHide failed for %s.%s: %s", moduleID, frameName, tostring(err))
            end
        end
    end)

    -- Call OnInitialize if provided (before uiElements)
    if frameConfig.OnInitialize then
        local success, err = pcall(frameConfig.OnInitialize, f)
        if not success then
            logger:error("Custom frame OnInitialize failed for %s.%s: %s", moduleID, frameName, tostring(err))
        end
    end

    -- Render UI elements
    self:RenderCustomFrameContent(f, frameConfig)

    -- Call AfterInitialize if provided (after uiElements, for custom dynamic content)
    if frameConfig.AfterInitialize then
        local success, err = pcall(frameConfig.AfterInitialize, f)
        if not success then
            logger:error("Custom frame AfterInitialize failed for %s.%s: %s", moduleID, frameName, tostring(err))
        end
    end

    -- Store the frame
    self.CustomFrames[frameKey] = f

    return f
end

---@param frame CustomFrame The custom frame to render into
---@param frameConfig ModuleFrameConfig Frame configuration with uiElements
function UI:RenderCustomFrameContent(frame, frameConfig)
    local content = frame.ScrollChild
    local moduleDB = Core:GetModuleDB(frame.moduleID)

    -- Clear existing managed regions (Labels/FontStrings)
    local regions = {content:GetRegions()}
    for _, region in ipairs(regions) do
        ---@cast region ManagedFontString
        if region.inUse then
            Factory:ReleaseFrame(region)
        end
    end

    -- Clear existing managed children (Frames)
    local children = {content:GetChildren()}
    for _, child in ipairs(children) do
        ---@cast child ManagedFrame
        if child.inUse then
            Factory:ReleaseFrame(child)
        end
    end

    -- Render UI elements using the framework element system
    if frameConfig.uiElements then
        for _, element in ipairs(frameConfig.uiElements) do
            Factory:RenderElement(content, element, moduleDB)
        end
    end

    -- Update layout
    self:RefreshLayout(content)
end

---@param moduleID moduleID
---@param frameName frameName
function UI:ToggleCustomFrame(moduleID, frameName)
    local frameKey = moduleID .. "_" .. frameName
    local frame = self.CustomFrames[frameKey]
    
    if not frame then
        -- Try to create it
        local module = Core.RegisteredModules[moduleID]
        if not module or not module.frames or not module.frames[frameName] then
            logger:error("Custom frame %s.%s not found in module definition", moduleID, frameName)
            return
        end
        
        frame = self:CreateCustomFrame(moduleID, frameName, module.frames[frameName])
    end
    
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

---@param slashCommand string
---@return moduleID|nil moduleID, frameName|nil frameName
function UI:FindCustomFrameBySlashCommand(slashCommand)
    -- Search all registered modules for matching slashListEntry
    for moduleID, module in pairs(Core.RegisteredModules) do
        if module.frames then
            for frameName, frameConfig in pairs(module.frames) do
                if frameConfig.slashListEntry and frameConfig.slashListEntry:lower() == slashCommand:lower() then
                    return moduleID, frameName
                end
            end
        end
    end
    return nil, nil
end

---@return table<string, string> slashCommand -> description
function UI:GetAllSlashListEntries()
    local entries = {}
    for moduleID, module in pairs(Core.RegisteredModules) do
        if module.frames then
            for frameName, frameConfig in pairs(module.frames) do
                if frameConfig.slashListEntry then
                    entries[frameConfig.slashListEntry] = frameConfig.title or frameName
                end
            end
        end
    end
    return entries
end