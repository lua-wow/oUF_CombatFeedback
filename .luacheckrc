std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'614', -- trailing whitespace in comment (which is valid markdown for our docs)
	'631', -- line is too long
}

read_globals = {
	-- WoW API
	'AbbreviateNumbers',
	'COMBATFEEDBACK_FADEINTIME',
	'COMBATFEEDBACK_FADEOUTTIME',
	'COMBATFEEDBACK_HOLDTIME',
	'CombatFeedbackText',
	'CreateColor',
	'CreateFrame',
	'GetTime',
	'issecretvalue',
}
