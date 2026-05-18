# NRRP Consumables System (WIP)

## Overview

The Consumables System is designed to turn cooking and brewing into long-term player professions rather than simple hunger/thirst restoration mechanics.

The system rewards:

- Farming
- Ranching
- Hunting
- Brewing
- Cooking
- Trading
- Medical RP
- Long-term economic participation

Goals:

1. Encourage player-to-player commerce.
2. Create meaningful professions.
3. Support immersive RP through emotes and item descriptions.
4. Tie food and drink into survival and wound systems.
5. Avoid combat-focused "buff meta".

---

# Core Philosophy

Consumables should provide:

Recovery > Comfort > Utility > Combat Power

The intention is to improve quality of life and recovery rather than create PvP advantages.

---

# Ingredient Quality

Ingredients use a quality score rather than fixed categories.

Examples:

Vendor ingredients:
Score = 1

Player produced (poor care):
Score = 2

Player produced (proper care):
Score = 3

Exceptional production:
Score = 4

Examples of factors:

+ Fertilizer
+ Irrigation
+ Animal health
+ Aging
+ Harvest timing
+ Seed quality

---

# Final Product Quality

Final quality is determined by:

Ingredient Quality
+
Preparation Skill
+
Recipe Complexity
+
Random Variation

Example formula:

Final Quality =
(Ingredient Avg × 0.60)
+
(Crafting Skill × 0.30)
+
(Random × 0.10)

---

# Food Quality Tiers

Instead of:

Low / Medium / High

Use immersive tiers:

Poor
Homemade
Fine
Exceptional

Example emotes:

"The stew appears hastily prepared."

"The meal smells fresh and carefully cooked."

"The dish is exceptionally prepared."

---

# Drink Quality Tiers

Rough

Standard

Refined

Reserve

Vintage

---

# Cooking Skill Progression

Players gain Cooking XP by:

Preparing meals

Using difficult recipes

Creating high quality meals

Large failures provide little/no XP

Potential unlocks:

Novice Cook

Cook

Experienced Cook

Chef

Master Chef

---

# Brewing Skill Progression

Players gain Brewing XP by:

Producing alcohol

Producing refined drinks

Successfully aging beverages

Unlocks:

Brewer

Distiller

Master Distiller

---

# Recipe System

Recipes may require:

Ingredients

Tools

Heat source

Station

Skill level

Example:

Venison Stew:

2x Venison

1x Potato

1x Herb

Campfire

Cooking Skill: 10

---

# Rare Recipes

Possible collectible/discoverable recipes:

Hunter's Broth

Blackwater Coffee

Reserve Apple Brandy

Fine Tobacco Tea

Campfire Chili

Medicinal Tea

Moonshine Variants

---

# Aging System (Brewing)

Certain beverages improve over time.

Example:

Fresh:
Rough

3 days:
Refined

7 days:
Reserve

14+ days:
Vintage

Creates:

Distilleries

Storage

Long-term investment

Trade economy

---

# Spoilage System

Food should expire.

Example:

Fresh → Normal

Stale → Reduced effects

Spoiled → Sickness chance

Potential modifiers:

Ice storage

Cellars

Salt curing

Preservation

---

# Buff Philosophy

Avoid major combat buffs.

Preferred bonuses:

Recovery speed

Reduced fatigue

Temperature resistance

Pain tolerance

Work stamina

Minor HP regeneration outside combat

---

# Example Food Effects

Poor Meal:

Restore hunger

Homemade Meal:

Restore hunger

Small recovery bonus

Fine Meal:

Recovery speed increase

Reduced stamina drain

Exceptional Meal:

Long-duration wellness bonus

Small temporary max HP increase

---

# Example Drink Effects

Water:

Restore thirst

Coffee:

Fatigue reduction

Tea:

Recovery bonus

Alcohol:

Pain suppression

Warmth

Courage effect

Minor coordination penalties

---

# Integration with Wound System

Consumables may affect healing.

Examples:

Bone Broth:
Improves severe wound recovery

Protein Meals:
Improves HP recovery

Herbal Tea:
Reduces infection risk

Whiskey:
Temporary pain reduction

---

# Anti-Combat Consumption Rules

Players should not consume food or drink during active combat.

Blocked if:

Recently damaged

Recently fired weapon

Weapon drawn

Being pursued by law

Restrained

Hogtied

Sprinting

Possible emote:

"Attempts to eat but is too occupied by the situation."

---

# Emote Requirements

All preparation actions produce visible emotes.

Examples:

Cooking:

"Carefully stirs a pot over the fire."

Brewing:

"Transfers liquid into aging barrels."

Eating:

"Eats a bowl of stew."

Drinking:

"Takes a long drink from a bottle."

---

# Future Expansion Ideas

Farming system integration

Livestock integration

Ranch products:

Milk

Eggs

Wool

Butter

Cheese

Restaurant ownership

Saloons

Player breweries

Persistent aging barrels

Food vendors

NPC demand economy

Seasonal crops

---

# Planned Commands (Debug)

Testing commands:

/debuggiveingredient

/debugcook

/debugbrew

/debugspoil

/debugage

/debugsetskill

/debugconsumable

---

# Design Principle

The end goal is:

Cooking = Profession

Brewing = Profession

Food = Economy

Drink = Economy

Consumables = RP systems

Not temporary stat boosts.