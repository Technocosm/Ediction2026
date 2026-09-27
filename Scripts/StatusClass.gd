class_name Status
extends Resource

enum StatusEffect
{
	NONE,					# No Status Effect (only use for Placeholder Slots)
	Shield_Staggered,		# Reduced Shield Regen Speed (From Taking Excess Shield Damage during a Shield Break)
	Super_Shield,			# Super Shield Buff (Shield Immune to Pierce & gets heavy DMG Resist)
	Shield_Damage_Amp,		# From Etching Edict
	Shield_Drain,			# From Shield Drain Curse
	Regeneration,			# From Mending Magic - Effect Strength is HP Healed per Second, not in total
	Embrittling,			# From HELIX's Embrittling Edict - Enemy Spells have no Shield Damage or Pierce
	Intimidation,			# From HELIX's Intimidation Incantation - Get Mana from Shield Damage
	Stagger_Boost,			# also from Intimidation Incantion - Shield Staggers last effectStrength times longer
	Force_Conversion,		# From HELIX's Force Conversion - Blocking Enlarges your Spells, up to a limit
	Pressuriser,			# From HELIX's Pressuriser - Speed Boost relative to Spell Size
	Projection_Line,		# From HELIX's Projection Line - Metronome
	Invincibility,			# From Evolent's Disarming Nature
	Recovery,				# From Evolent's Hallowed Hollows - Regenerate a % of the Damage you take as =HP over time
	Pain_Drain,				# From Evolent's Painful Pentacle - Enemy Receives a Flat Heal whenever you take Damage
	Heart_Pricking,			# From Evolent's Heartpricker Hex - Enemy Healing also Damages you
	Discount_Next_Spell,	# From Evolent's Prismatic Mana Well - Reduce the Cost of the next Spell you Cast by a %
	Speed_While_Shielding,	# From Evolent's Windy Warding - Grants Speed to your Spells only while Shielding
	Slow_While_Shielding,	# From Evolent's Windy Warding - Slows Enemy Spells only while Shielding
	Cost_Increase,			# From The Magician's Shackles of Justice - Spells Cost More Mana to Cast
	Mana_Regen_Boost,		# From The Magician's Flame of Creation - Boost your Mana Regen Speed by a %
	FIRE_Red_Shield_Damage,	# From Pherno's Passive - Gain Shield Damage on Reds relative to your Fire %
	FIRE_Mana_In_Shield,	# From Pherno's Passive - Mana Regen still intact while Shielding relative to Fire & Shield %
	Special_Resource_Boost,	# From Pherno's Sadist's Seal - Boost your Special Resource Generation (Fire) by a %
	Damage_Amp,				# From Pherno's Sadist's Seal & On Fire - Amplify Damage received by a %
	Damage_Loses_Mana,		# From Pherno's Sadist's Seal - Taking Damage proportionally makes you lose Mana
	Speed_Boost,			# From Pherno's Inflamation Incantation - Boosts the Speed of all your Spells
	More_Fire_From_DMG,		# From Pherno's Vengeful Vexation - Boosts Fire Generated from being Damaged (Fire Only)
	Lifesteal				# From Pherno's Vengeful Vexation - Heal = to a % of all Damage your Opponent Takes
}

enum EffectType		# Is this Effect intended to be helpful or harmful?
{
	Positive,		# Helpful or at least clearly intended to be helpful in most cases, even if not always
	Neutral,		# Debateable - sometimes good, sometimes bad, sometimes both
	Negative		# Intended to be harmful - once again, may inadvertently help in some cases, but usually harms
}

enum DurationType	# What dictates the duration of this Status Effect?
{
	Timed,			# Status ends when Timer hits 0
	Conditional,	# Status does not end until a condition is met - Timer can still be used as "grace period"
	Infinite		# Status does not end unless PURGED.
}

enum StackType		# How does Stacking effect the Duration of the Status Effect?
{
	Resets_Timer,				# Reset Timer to Default Value if we're below it whenever a Stack is added
	Adds_To_Timer,				# Add Default Value to current Duration Timer to extend duration even beyond max
	Duplicate_With_New_Timer,	# Each Stack has its own separate Timer (handled as a separate duplicate Status)
	No_Effect_On_Timers			# Adding Stacks does not affect the Timer at all
}

enum StackRemoval	# How do Stacks get Removed?
{
	All_At_Once,				# When the Status Effect ends, all Stacks are lost & the Effect is done
	One_Stack_At_A_Time			# The Effect doesn't end until all Stacks are gone, every expiry one Stack is removed
}

# Fundamentals:
@export var id := 0;
@export var name := "NA";
@export var t := 0;								# Timer

# Duration:
@export var durationType := DurationType.Timed;
@export var defaultDuration := 0;				# Default Duration when first Applied
@export var duration := 0;						# Current Remaining Duration
@export var conditionNum := 1;	# Signifies whether the condition for the Status to end has been met when it hits 0

# Effect:
@export var effect1	:= StatusEffect.NONE;		# Each Status must have at least 1 Effect tied to it...
@export var effect2	:= StatusEffect.NONE;		# But it could have multiple Effects combined
@export var effect3	:= StatusEffect.NONE;		# Including conditional bonus Effects!
@export var effectType := EffectType.Positive;	
@export var effectStrength := 1;				# Strength Modifier for Effects that can vary in Power
@export var effectDescriptionShort := "NA";		# Short Description of Effect
@export var effectDecriptionLong := "NA";		# Long & Detailed Description of Effect
@export var affectsGreens := true;				# Affects Green Spells
@export var affectsReds := true;				# Affects Red Spells
@export var affectsBlues := true;				# Affects Blue Spells
@export var affectsPurples := true;				# Affects Purple Spells
@export var affectsYellows := true;				# Affects Yellow Spells
@export var affectsBlacks := true;				# Affects Black Spells (Hyper Hexes - your Ultimates)

# Stacks:
@export var stackType := StackType.Resets_Timer;
@export var stackRemoval := StackRemoval.All_At_Once;
@export var stacks := 0;						# Current Amount of Stacks
@export var maxStacks := 1;						# Maximum Amount of Stacks (just make 1 for non-Stacking Status)
