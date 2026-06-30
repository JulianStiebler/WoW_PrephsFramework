--- @meta _

--- Template
--- @class RuneSpellButtonTemplate : Button
--- @field icon Texture
--- @field name FontString|GameFontNormal
--- @field typeName FontString|GameFontNormalSmall
--- @field selectedTex Texture
--- @field disabledBG Texture
--- @field tooltipName string # Set at runtime from rune data
--- @field skillLineAbilityID number # Set at runtime from rune data
--- @field showingTooltip boolean # Set at runtime


--- Template
--- @class RuneHeaderButtonTemplate : Button
--- @field middle Texture
--- @field leftEdge Texture
--- @field rightEdge Texture
--- @field expandedIcon Texture
--- @field collapsedIcon Texture
--- @field icon Texture
--- @field name FontString|GameFontNormal
--- @field filter number # Set at runtime from category data


--- child of EngravingFrame
--- @class EngravingFrame_SideInset : Frame, InsetFrameTemplate
--- @field Background Texture


--- child of EngravingFrameSearchBox
--- @class EngravingFrameSearchBox_SearchIcon : Texture


--- @class EngravingFrameSearchBox : EditBox
--- @field searchIcon Texture
EngravingFrameSearchBox = {}


--- child of EngravingFrame scrollFrame
--- @class EngravingFrame_ScrollFrame : ScrollFrame, HybridScrollFrameTemplate
--- @field ScrollBar Slider
--- @field emptyText FontString|GameFontNormal


--- child of EngravingFrame collected
--- @class EngravingFrame_Collected : Frame
--- @field collectedText FontString|GameFontNormal


--- @class EngravingFrame : Frame
--- @field Border Frame|TooltipBackdropTemplate
--- @field sideInset EngravingFrame_SideInset
--- @field FilterDropdown DropdownButton|WowStyle1DropdownTemplate
--- @field scrollFrame EngravingFrame_ScrollFrame
--- @field collected EngravingFrame_Collected
--- @field Header1 Button|RuneHeaderButtonTemplate
--- @field Header2 Button|RuneHeaderButtonTemplate
--- @field Header3 Button|RuneHeaderButtonTemplate
--- @field Header4 Button|RuneHeaderButtonTemplate
--- @field Header5 Button|RuneHeaderButtonTemplate
--- @field Header6 Button|RuneHeaderButtonTemplate
--- @field Header7 Button|RuneHeaderButtonTemplate
--- @field Header8 Button|RuneHeaderButtonTemplate
--- @field Header9 Button|RuneHeaderButtonTemplate
--- @field Header10 Button|RuneHeaderButtonTemplate
--- @field Header11 Button|RuneHeaderButtonTemplate
--- @field Header12 Button|RuneHeaderButtonTemplate
--- @field Header13 Button|RuneHeaderButtonTemplate
--- @field Header14 Button|RuneHeaderButtonTemplate
--- @field Header15 Button|RuneHeaderButtonTemplate
EngravingFrame = {}
