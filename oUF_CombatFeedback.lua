--[[
# Element: Combat Feedback

Shows damage, heals and avoided hits taken by the unit as a short text that fades in and out.

## Widget

CombatFeedback - A `FontString` used to display the feedback.

## Notes

Driven by `UNIT_COMBAT`. Energize events are ignored.

`amount` is secret on Retail (not on Classic or Forever), so it is never compared: it is only formatted with `AbbreviateNumbers`.
While it is secret, a `WOUND` flagged `ABSORB`, `BLOCK` or `RESIST` shows the flag instead of the number.

Fade timings come from Blizzard's `COMBATFEEDBACK_FADEINTIME`, `COMBATFEEDBACK_HOLDTIME` and
`COMBATFEEDBACK_FADEOUTTIME`.

## Options

.colors     - Table with `DAMAGE`, `HEAL` and `STANDARD` keys, each a `ColorMixin`. Missing keys use the defaults.
.ignoreHeal - Ignore heals (boolean)
.ignoreMiss - Ignore avoided and mitigated hits: miss, dodge, parry, immune, absorb, ... (boolean)

## Examples

    local CombatFeedback = self.Health:CreateFontString(nil, "OVERLAY")
    CombatFeedback:SetFontObject(GameFontNormal)
    CombatFeedback:SetPoint("CENTER", self.Health, "CENTER", 0, 0)

    -- Register with oUF
    self.CombatFeedback = CombatFeedback
--]]

local _, ns = ...
local oUF = ns.oUF

-- Blizzard
local AbbreviateNumbers = _G.AbbreviateNumbers
local CombatFeedbackText = _G.CombatFeedbackText
local GetTime = _G.GetTime
local issecretvalue = _G.issecretvalue

-- Mine
local FADE_IN = _G.COMBATFEEDBACK_FADEINTIME or 0.2
local HOLD = _G.COMBATFEEDBACK_HOLDTIME or 0.7
local FADE_OUT = _G.COMBATFEEDBACK_FADEOUTTIME or 0.3

local COLORS = {
	DAMAGE = CreateColor(0.80, 0.30, 0.30),
	HEAL = CreateColor(0.30, 0.80, 0.30),
	STANDARD = CreateColor(1.00, 1.00, 1.00),
}

local FORMATS = {
	DAMAGE = "-%s",
	HEAL = "+%s",
}

-- WOUND flags shown as text when the amount can't be checked for zero
local MITIGATED = {
	ABSORB = true,
	BLOCK = true,
	RESIST = true,
}

-- elements currently fading, element -> start time
local active = {}
local driver = CreateFrame("Frame")
driver:Hide()

driver:SetScript("OnUpdate", function(self)
	local now = GetTime()
	for element, start in next, active do
		local elapsed = now - start
		if elapsed < FADE_IN then
			element:SetAlpha(elapsed / FADE_IN)
		elseif elapsed < FADE_IN + HOLD then
			element:SetAlpha(1)
		elseif elapsed < FADE_IN + HOLD + FADE_OUT then
			element:SetAlpha(1 - (elapsed - FADE_IN - HOLD) / FADE_OUT)
		else
			element:Hide()
			active[element] = nil
		end
	end

	if next(active) == nil then
		self:Hide()
	end
end)

-- returns the WOUND as "DAMAGE", or the mitigation flag to show as text
local function GetWound(flags, amount)
	if issecretvalue(amount) then
		return MITIGATED[flags] and flags or "DAMAGE"
	end
	if amount ~= 0 then
		return "DAMAGE"
	end
	return MITIGATED[flags] and flags or "MISS"
end

local function Update(self, event, unit, eventType, flags, amount)
	local element = self.CombatFeedback

	local kind = eventType
	if eventType == "WOUND" then
		kind = GetWound(flags, amount)
	end

	if kind == "DAMAGE" or kind == "HEAL" then
		if kind == "HEAL" and element.ignoreHeal then return end
		element:SetFormattedText(FORMATS[kind], AbbreviateNumbers(amount))
	else
		local text = CombatFeedbackText[kind]
		if not text or element.ignoreMiss then return end
		element:SetText(text)
		kind = "STANDARD"
	end

	local color = element.colors and element.colors[kind] or COLORS[kind]
	element:SetTextColor(color:GetRGB())
	element:SetAlpha(0)
	element:Show()

	active[element] = GetTime()
	driver:Show()

	--[[ Callback: CombatFeedback:PostUpdate(eventType, flags)
	Called after the element has been updated.

	* self      - the CombatFeedback element
	* eventType - the UNIT_COMBAT event type, e.g. WOUND, HEAL, DODGE (string)
	* flags     - the UNIT_COMBAT flag text, e.g. CRITICAL, ABSORB (string)
	--]]
	if element.PostUpdate then
		element:PostUpdate(eventType, flags)
	end
end

local function Path(self, ...)
	--[[ Override: CombatFeedback.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	(self.CombatFeedback.Override or Update)(self, ...)
end

local function Clear(element)
	active[element] = nil
	element:Hide()
end

-- feedback only exists while events arrive: a full update (e.g. target changed) just clears it
local function ClearPath(self)
	Clear(self.CombatFeedback)
end

local function Enable(self)
	local element = self.CombatFeedback
	if element then
		element.__owner = self
		element.ForceUpdate = Clear

		self:RegisterEvent("UNIT_COMBAT", Path)

		Clear(element)

		return true
	end
end

local function Disable(self)
	local element = self.CombatFeedback
	if element then
		Clear(element)

		self:UnregisterEvent("UNIT_COMBAT", Path)
	end
end

oUF:AddElement("CombatFeedback", ClearPath, Enable, Disable)
