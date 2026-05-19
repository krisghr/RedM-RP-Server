# NRRP Farming System

### Design Document / README (WIP)

---

# Overview

The Farming System is intended to provide long-term, low-maintenance gameplay that creates RP, player economies, and interdependence between ranchers, farmers, cooks, brewers, traders, and factions.

This is **not** intended to be a survival mechanic.

The goal is:

> Create valuable agricultural goods and emergent roleplay opportunities without forcing players into tedious upkeep.

---

# Core Gameplay Loop

```text
Acquire Seeds > Find suitable land > Plant crops > Maintain crops
(water / fertilizer / disease treatment) > Harvest crops > Produce ingredients or recover seeds > Sell crops OR use for cooking/brewing > Generate profit > Expand farms / purchase land / improve efficiency
```

Secondary loops:

```text
Ranchers > Produce manure > Create high-quality fertilizer > Farmers > Higher quality crops > Cooks/Brewers > Premium products
```

```text
Rotten crops / waste > Compost > Medium fertilizer
```

---

# Planting Restrictions

Players may only plant outside blocked zones.

Blocked zones include:

* Towns
* Roads
* Major settlements
* Rocky terrain
* Extreme climates
* Future manually-defined exclusion zones

Examples:

* Valentine (initial test area)
* Blackwater
* Saint Denis

Implementation:

Coordinate boxes / PolyZones.

---

# Starting Farming

Command:

```text
/farming
```

Opens Farming UI.

Initial menu:

```text
Plant Seeds
Check Nearby Plants
Manage Owned Fields
Permissions
Crop Journal
Farming Skill
Help
```

Future:

```text
Purchase Seeds
Water Nearby Crops
Remove Plants
Field Overview
```

---

# Planting Crops

Selecting:

```text
Plant Seeds
```

Opens categories:

```text
Berry Shrubs
Fruit Trees
Vegetables
Herbs
```

Selecting crop:

Creates ghost/transparent placement object.

Player confirms location.

Server validates:

* Planting zone
* Capacity limit
* Soil compatibility
* Climate compatibility
* Nearby crop density
* Permissions

If valid:

Plant created.

Stored:

```lua
owner
plantType
coords
createdAt
health
water
fertility
growthStage
quality
soilData
permissions
disease
```

---

# Growth Stages

Plants progress gradually:

```text
Seed > Sprout > Young Plant > Growing > Healthy Mature > Overripe > Dead > Rotting > Removed
```

Effects:

Healthy Mature:

* Best yield
* Best quality

Overripe:

* Reduced yield

Dead:

* No yield

Rotting:

* Compostable

Removed:

* Deleted from world

---

# Offline Growth

Plants continue progressing while owners are offline.

System tracks:

```text
Time elapsed
Water level
Disease
Growth
Health
```

Updates occur on server restart/login.

---

# Crop Health

Plants do not instantly die.

Health:

```text
100% Healthy
70% Wilted
40% Dying
0% Dead
```

Poor care reduces health gradually.

---

# Water System

Required items:

```text
Empty Bucket
Full Bucket

Empty Watering Can
Full Watering Can
```

Water sources:

* Rivers
* Lakes
* Wells
* Water barrels
* Future rain catchers

Actions:

```text
R > Water Plant
```

Insufficient water:

Reduces plant health.

---

# Fertilizer System

Fertilizer qualities:

Low Quality
* Purchased from stores

Medium Quality
* Compost produced

High Quality
* Ranch-produced manure fertilizer

Effects:

Low:
* Small growth boost

Medium:
* Growth
* Slight quality increase

High:
* Faster growth
* Higher crop quality
* Reduced disease chance

---

# Composting

Rotten crops may be processed:

```text
Rotten Produce > Compost > Medium Fertilizer
```

Reduces waste.

---

# Disease / Pest System

Very simple implementation.

Possible issues:

### Mold

Cause:
Excess watering

Effect:
Reduced growth

---

### Pests

Cause:
Random chance

Effect:
Reduced quality

---

### Blight

Cause:
Rare disease event

Effect:
Severe health reduction

---

Symptoms visible via:

```text
E > Check Plant
```

Examples:

> Leaves appear unhealthy.

> Small insects are damaging the crop.

Treatment:

Future item:

```text
Plant Treatment
```

---

# Soil Quality System

Every area has hidden values.

Examples:

```text
Fertility
Drainage
Acidity
Moisture Retention
```

Different crops prefer different conditions.

Example:

Blueberries:

Acidic ✓

Neutral ~

Alkaline ✗

---

Good land produces:

* Faster growth
* Higher quality
* Better yields

Poor land produces:

* Lower quality
* Slower growth

Land quality creates valuable farming regions.

---

# Climate Compatibility

Regions affect crops.

Examples:

Fruit Trees:
Poor: Northern mountains
Good: Temperate regions

Hardy Vegetables:
Good: Cold climates

Climate should reduce efficiency rather than prevent planting.

---

# Harvesting

Action:

```text
H > Harvest
```

Results depend on:

* Growth stage
* Soil
* Water
* Fertilizer
* Disease
* Skill
* Climate

Outputs:

Produce

Possible seed return

---

# Seed Recovery

Harvests may return seeds.

Example:

Low quality harvest:

```text
2 Tomatoes
0 Seeds
```

High quality harvest:

```text
5 Tomatoes
2 Seeds
```

Encourages self-sustaining farming.

---

# Permissions System

Default:

```text
Self Only
```

Additional options:

```text
Add Farmhand
Add Co-owner
Allow Faction
Public Access
```

Permissions may allow:

Watering
Fertilizing
Harvesting
Removing plants
Managing fields
Managing permissions

---

# Faction Fields & Taxation

Factions may own larger farms.

Faction field settings:

```text
Owner
Members
Tax %
Plant capacity
Permissions
```

Example:
Smith Ranch
Tax: 10%
Capacity: 100 plants

Members receive access.

Tax automatically deducted from harvest sales.

---

# Capacity Limits

Prevent excessive crop spam.

Examples:
Individual: 10 active plants
Homestead: 25
Small Ranch: 50
Large Ranch: 100+
Faction Farm: Higher configurable limits

---

# Farming Skill (Hidden Progression)

Players gain invisible experience.

Ranks:

```text
Novice Farmer
Field Hand
Grower
Experienced Farmer
Master Cultivator
```

Benefits:
Reduced disease chance
Improved harvests
Increased seed recovery
Higher plant limits
Better crop quality
No visible XP bars.

---

# Crop Journal

Tracks learned information.

Menu:

```text
Crop Journal
```

Entries discovered through farming.

Example:

Wild Mint

Preferred region:
Cumberland Forest

Water:
Medium

Soil:
Acidic

Growth:
Fast

---

Encourages experimentation.

---

# Field Ownership Decay

If crops abandoned:

```text
Healthy > Untended > Wilted > Dead > Rotting > Removed
```

Long timers prevent accidental losses.

---

# Future Expansion Ideas

Not priority:

* Irrigation systems
* Greenhouses
* Rare seeds
* Agricultural contracts
* Crop theft
* Farming events
* Auctions
* Regional markets
* Ranch integration
* NPC produce buyers

---

# Intended Outcomes

This system should create:

Farmers
Ranchers
Brewers
Cooks
Landowners
Faction farms
Trade routes
Property value
Player-driven economy
Emergent RP without requiring constant maintenance.

---

Status:

WIP / Concept Phase