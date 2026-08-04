class_name EdictStats
extends Resource

enum EdictType
{
	Green,	# Deals DMG if Unblocked, Shield DMG if blocked, can't Pierce at base. No Speical Effects*
	Red,	# Doesn't Deal Shield DMG or have special effects, but has Pierce at base.
	Blue,	# Special Effects depending on if blocked or not - only Deals Shield DMG unless effects state otherwise
	Purple,	# Special Effects if not blocked, but doesn't deal any form of DMG unless the effect states otherwise
	Yellow,	# Instantly puts a special effect in play on cast without spawning anything on the Track
	Black	# Ultimate Ability - Costs Charge unlike the 
}

# Fundamentals:
@export var id := 0;					# ID of the Edict (its slot on the Spirtesheet reading left to right)
@export var type := EdictType.Green;	# Edict Type (see types above)
@export var appears_on_track := true;	# (everything except yellows & most blacks should be true)

# Costs:
@export var mana_cost := 0.;			
@export var charge_cost := 0.;			# Should ALWAYS be 0 unless this is a Black Edict (Ultimate)
@export var special_cost := 0.;			# Some Characters have bonus Resources that can be Spent to empower Edicts.

# Cost Changers:
@export var cost_reduction_condition := "NA";	# Some Edicts can change cost depending on conditions
@export var cost_increase_condition := "NA";
@export var reset_cost_on_cast := false;		# Most Edicts whose costs change want their Costs to reset back to
												# Default each time it's Cast (this is only false by default since
												# most Edicts don't have changing costs, and don't need to reset) 

# Basic Stats:
@export var size := 1.;
@export var speed := 1.;
@export var damage := 0.;
@export var shield_damage := 0.;
@export var pierce := 0.;						# The % of Damage and Unblocked Effect Strength that will still
												# trigger even if blocked. Does nothing for Blue Edicts.

# Effects:
@export var effect_unblocked := "NA";			# Special effects on hit
@export var effect_blocked := "NA";				# ONLY FOR BLUE EDICTS - secondary effect if blocked
@export var bonus_effect := false;				# If paid Special Cost, indicates whether the effect should be amped
@export var effect_unblocked_strength := 1.;	# Strength of Effect (some effects can't be amped, but some can)
@export var effect_blocked_strength := 1.;
@export var effect_unblocked_duration := 0.;	# Duration of Effect (similarly, doesn't apply to everything)
@export var effect_blocked_duration := 0.;

# Drawing Precision Thresholds
@export var precision_minimum := 0.7;				# Precision Score required for Edict to be recognised & Cast
@export var precise_threshold := 0.925;				# Precision Score required for a Precise Cast

# Buffs from Precisely Cast Edicts:
@export var precise_mana_refund := 0.;				# If all else fails, we can just provide a partial Mana Refund
@export var precise_size_boost := 1.25;				# However if any of these other stats can be relevant to the Edict
@export var precise_speed_boost := 1.;				# In Question, we try to amp them instead...
@export var precise_damage_boost := 1.5;			# Whichever stats are most fitting / fun for the Edict.
@export var precise_shield_damage_boost := 1.5;
@export var precise_pierce_boost := 0.;
@export var precise_bonus_effect := "NA";			# To give an entirely new effect on Precise Casts
@export var precise_effect_strength_boost := 1.5;
@export var precise_effect_duration_boost := 1.5;

# Immunities:
@export var unchanging = false;						# Cannot have its stats changed from base from Casting
@export var unmoving = false;						# Cannot be sped up, slowed down, or moved
@export var hazard_immunity = false;				# Ignores Hazards on the Track
