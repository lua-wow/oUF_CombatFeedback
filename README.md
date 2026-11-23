# oUF_CombatFeedback

Combat feedback (damage, heals, misses) support for oUF layouts.

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

```lua
local CombatFeedback = self.Health:CreateFontString(nil, "OVERLAY")
CombatFeedback:SetFontObject(GameFontNormal)
CombatFeedback:SetPoint("CENTER", self.Health, "CENTER", 0, 0)

-- Register with oUF
self.CombatFeedback = CombatFeedback
```

## License

Please, read file [LICENSE](LICENSE)
