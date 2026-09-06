extends Node2D

# OTHER NODES WE NEED
var EdictPos;
var EdictSprite;
var EdictHitbox;
# RESOURCE OF EDICT WE'VE BEEN TOLD TO BE
var EdictDataResource;

# GAMEPLAY VARIABLES
var active = false;
var t = 0.;			# t = time (basically a clock)

var speed = 0;
var size = 0;
var baseSpeed = 0;
var baseSize = 0;

# ANIMATION CONSTS - Counts the amount of frames on the Spritesheet
const EDICT_SPRITESHEET_HFRAMES = 10;
const EDICT_SPRITESHEET_VFRAMES = 6;
const EDICT_SPRITESHEET_FRAMES = EDICT_SPRITESHEET_HFRAMES * EDICT_SPRITESHEET_VFRAMES;

# SIZE & SPEED STATS & HOW CHARACTER STATS CAN AFFECT THEM
const SPEED_MULT = 22.5;	# 1 speed = 22.5 degrees traversed per second - 8s to 180
const SIZE_MIN = 0.01;
const SIZE_MAX = 0.05;
const SIZE_RANGE = SIZE_MAX - SIZE_MIN;
const CHR_STR_BOOST_MIN = 0.8;	# Max reduction in Size from low Strength Stat is 20%
const CHR_STR_BOOST_MAX = 1.2;	# Max Size increase from high Strength is 20%
const CHR_STR_RANGE = CHR_STR_BOOST_MAX - CHR_STR_BOOST_MIN;	#Calculate the Range between min and max.
const CHR_SPD_BOOST_MIN = 0.8;	# Same for speed
const CHR_SPD_BOOST_MAX = 1.2;
const CHR_SPD_RANGE = CHR_SPD_BOOST_MAX - CHR_SPD_BOOST_MIN;

# Horizontally shifts Edicts as they move to creat a slightly more Ovular shape to the path.
# This makes the Edicts overlap less with other UI elements.
const HORIZONTAL_SHIFT = 40;
const QUARTER_ROT = 90;
const CURVE_EXPONENT = 3;		# Exponent used for _curveUp() function to make HShift motion more "round"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get Nodes
	EdictPos = get_node("EdictPos");
	EdictSprite = get_node("EdictPos/EdictSprite");
	EdictHitbox = get_node("EdictPos/EdictHitbox");
	
	# Set Size to 0 to begin with
	EdictPos.scale = Vector2(0, 0);	# We don't want an Edict that isn't prepared to be visible or have collision.
	active = false;					# For the same reason, mark it as inactive until it has been set up.

func _setup(id, resource, precise, charStr = 0.5, charSpd = 0.5, spellStr = 1, spellSpd = 1):
	# id - Spell ID
	# resource - resource containing Edict Data
	# charStr - Character's Strength Stat (0-1)
	# charSpd - Character's Speed Stat (0-1)
	# spellStr - Any Strength Mutlipliers to be applied to the Spell from Buffs
	# spellSpd - Any Speed Multipliers to be applied to the Spell from Buffs
	
	# Set Sprite from Spirtesheet using ID
	EdictSprite.frame = id % EDICT_SPRITESHEET_FRAMES;
	
	# Store Edict Resource for later reference:
	EdictDataResource = resource;
	
	size = resource.size;
	speed = resource.speed;
	
	# Record this Base Size and Speed before any modifiers, because we're about to change them.
	baseSize = size;
	baseSpeed = speed;
	
	# Increase or Decrease both stats by the proper amounts based on our Character Stats.
	var st = (CHR_STR_BOOST_MIN + (CHR_STR_RANGE * (charStr / 100.0))) * spellStr;
	var sp = (CHR_SPD_BOOST_MIN + (CHR_SPD_RANGE * (charSpd / 100.0))) * spellSpd;
	size *= st;
	speed *= sp;
	
	# Run the below function to apply the calculated size to the actual Scale of the Sprite
	_setSize();
	active = true;	# Now the Edict is fully prepared, we set it to be active.
	
	pass
	
func _setSize():		# Sets the Scale of the Edict to match the size indiciated by the variables in this Script
	var realSize = SIZE_MIN + (size * SIZE_RANGE);
	EdictPos.scale = Vector2(realSize, realSize);
	pass
	
func _sizeMult(amnt):	# Multiply the Current Size of this Edict by the given amount, and apply that to its Scale.
	size *= amnt;
	_setSize();
	pass
	
func _sizeAdd(amnt):	# Adds Scale rather than multiplying.
	size += amnt;
	_setSize();
	pass
	
func _curveDown(amnt, cPow = 2):	# amnt should be between 1 and 0. This applies an "exponential curve" downwards.
	for i in (cPow - 1):			# 0 will still = 0 and 1 will still equal 1, but if you were at the halfway point
		amnt *= amnt;				# of the curve if you imagine it as a graph, we multiply amnt by itself as many
	return amnt;					# times as was entered in cPow - turning 0.5 into 0.25 if cPow = 2
	
func _curveUp(amnt, cPow = 2):				# CurveUp works the same as down, only we Calculate the result of Down
	amnt = 1 - _curveDown(1 - amnt, cPow);	# first, since it's easier to figure out. Then we simply invert it, by
	return amnt;							# starting from 1 and taking the result away from it - 0.5 turns into 0.75



# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	
	if(active):
		t += delta;								# Add elapsed Time to Clock.
		
		# Rotation
		var rot = speed * SPEED_MULT * delta;	# Caclulate Rotation amount
		rotation_degrees -= rot;				# Apply rotation to the Sprite
		EdictPos.rotation_degrees += rot;		# Counter-Rotation to keep sprite upright - only position rotates.
		
		# Horizontal Shift
		var shift = 0;
		var angle = rotation_degrees;
		
		# Get current angle (mod 360 degrees)
		if(angle > 0):
			while(angle > 360):
				angle -= 360;
		else:
			while(angle < 0):
				angle += 360;
		
		# Shift horizontally based off rotation position broken down into 90 degree quarters
		if(angle < QUARTER_ROT):
			# We turn our angle into a float between 0 and 1 representing how far through the "quarter" of rotation
			# we are, then use _curveUp to apply an upwards exponential curve to that value. This makes the motion
			# of our horizontal shift more "circular" as we want it, rather than it looking jagged & pointy.
			
			# For this first quarter, to get the motion we want, we invert our shift direction, but not our angle
			# percentage value.
			shift = -HORIZONTAL_SHIFT * _curveUp((angle / QUARTER_ROT), CURVE_EXPONENT);
			
		elif (angle < QUARTER_ROT * 2):
			# Before we re-use our previous calculations, they only work if angle is between 0 and 90.
			# For this case to ever run, the angle would need to be between 90 and 180 instead.
			# For this reason, we take 90 from our angle temporarily to get an accurate value for the
			# Percentage of progress the angle has made it through this quarter rotation.
			angle -= QUARTER_ROT;
			
			# For this quarter, we still want the inverted shift direction...
			# But we also want to invert the % progress to get a smooth pulling back motion
			shift = -HORIZONTAL_SHIFT * _curveUp((1 - (angle / QUARTER_ROT)), CURVE_EXPONENT);
			
		elif (angle < QUARTER_ROT * 3):
			# Once again, remove 2 Quarter Rotations of degrees to get us back to a 0-90 value...
			angle -= QUARTER_ROT * 2;
			
			# And run the formula again, this time with no inversions.
			shift = HORIZONTAL_SHIFT * _curveUp((angle / QUARTER_ROT), CURVE_EXPONENT);
			
		else:
			# Remove 3 quarter rotations to get a 0-90
			angle -= QUARTER_ROT * 3;
			
			# Formula again, this time only invert the progress, and not the shift direction.
			shift = HORIZONTAL_SHIFT * _curveUp((1 - (angle / QUARTER_ROT)), CURVE_EXPONENT);
		
		# Apply the calculated shift.
		position = Vector2(shift, 0);
	pass

func getHitbox():
	return EdictHitbox;
