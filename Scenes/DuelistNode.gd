extends Node2D

# Other Nodes we need
var Screen;
var DuelistSprite;
var Shield;
var ShieldInside;
var Hurtbox;
var Tapbox;

# Necessities
var active = false;
var t = 0.; 								# Timer

# Input
var mousePos;
var lmbHeld = false;		# Is Left Mouse Button Held?
var mouseOnShield = false;	# Is our Mouse currently over the Shield button?

const MAX_HP = 100.;
const MAX_SHIELD = 1.;

const MIN_SHIELD_REGEN = 0.4;				# Minimum & Maximum Possible Default Shield Regen Speeds while Shielding
const MAX_SHIELD_REGEN = 0.6;				# Dictated by your Duelist's Defense stat
const SHIELD_REGEN_RANGE = MAX_SHIELD_REGEN - MIN_SHIELD_REGEN;	# Range between the max and min
const SHIELD_DEGEN = -0.3;					# Rate at which your Shield Shrinks while not Blocking
const SHIELD_DROP_FADE_TIME = 0.8;			# Time taken in Seconds to fade from Shield Regen to Degen speed

const SHIELD_MAX_SCALE = 0.25;				# Scale Shield should be at while Max Size
const SHIELD_FADE_IN_THRESHOLD = 0.3;		# Threshold at which the shield becomes fully visible from fade in
const SHIELD_INSIDE_NO_FLASH_MAX = 0.7;	# Transparency for the inner Shield Texture with no Flash & Full Shield
const SHIELD_INSIDE_NO_FLASH_MIN = 0.4;		# Transparency for the inner Shield Texture with no Flash & no Shield
const SHIELD_INSIDE_ALPHA_RANGE = SHIELD_INSIDE_NO_FLASH_MAX - SHIELD_INSIDE_NO_FLASH_MIN;
const SHIELD_FLASH_TRANSPARENCY = 0.99;		# Transparency the inner Shield Texture rises to after flashing
const SHIELD_FLASH_FADE_TIME = 1.6;			# Seconds for flash to dissipate back to default alpha

var hp = MAX_HP;
var shieldCharge = 0.;						# The Current Shield Charge %
var shieldRegenSpeed;						# The Max Speed of your Character's Shield Regen
var shieldRegen = SHIELD_DEGEN;				# The current Regeneration of your shield expressed as % charge/second
var shielding = false;

var timeOfLastShieldDrop = -SHIELD_DROP_FADE_TIME;
var timeSinceLastShield = -SHIELD_DROP_FADE_TIME;

var innerShieldAlpha = 0.;
var outerShieldAlpha = 0.;
var timeOfLastShieldFlash = -SHIELD_FLASH_FADE_TIME;		# When did the last Shield Flash happen?
var timeElapsedSinceLastFlash = SHIELD_FLASH_FADE_TIME;		# How long ago was that in Seconds?
# These initial values are set up this way just to be extra careful we don't get any unwanted flashes on spawn
# They should be overwritten by the time they would do anything anyway.

var charId = 0;

var strength : Array = [60, 20, 40, 100];
var speed : Array = [50, 80, 50, 50];
var defense : Array = [70, 20, 10, 0];
var trickiness : Array = [20, 80, 100, 50];

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Get Viewport (game screen manager) for Mouse Stuff later
	Screen = get_viewport();
	
	# Get Child Nodes
	DuelistSprite = get_node("DuelistSprite");
	Shield = get_node("Shield");
	ShieldInside = get_node("Shield/ShieldInside");
	Hurtbox = get_node("Hurtbox");
	Tapbox = get_node("TapBox");
	
	# Don't become Visible until we are told which Duelist we are
	visible = false;
	
	# REPLACE LATER
	setup(0);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(active):
		# Count Time
		t += delta;
		timeElapsedSinceLastFlash += delta;
		
		# DEBUG - REMOVE LATER
		# if(Input.is_key_pressed(KEY_SPACE)):
			# shieldFlash();
		
		# Are we shielding?
		lmbHeld = Input.is_mouse_button_pressed(1);
		if(mouseOnShield):
			if(lmbHeld):
				shielding = true;
			else:
				shielding = false;
		else:
			shielding = false;
		
		# If we are, Regen Shield.
		if(shielding):
			shieldRegen = shieldRegenSpeed;
			timeOfLastShieldDrop = t;
			# ^ This counter will stop updating when we drop shield, indicating when it was dropped.
		# If we're not shielding...
		else:
			# Check how long it's been since we dropped Shield -
			timeSinceLastShield = t - timeOfLastShieldDrop;
			
			# If it hasn't been long enough for the fade out to be done yet, calculate the Shield's fading Regen
			if(timeSinceLastShield < SHIELD_DROP_FADE_TIME):
				# Find the % progress we should be to a full shield drop at this point in time
				var shieldDropPercent = timeSinceLastShield / SHIELD_DROP_FADE_TIME;
				# Apply that % to the difference between full shield and full degen
				shieldRegen = SHIELD_DEGEN + ((shieldRegenSpeed + SHIELD_DEGEN) * shieldDropPercent);
			# Otherwise, we just Degen Shield as usual
			else:
				shieldRegen = SHIELD_DEGEN;
			
		# End of Shielding If Statement - now we apply what we've calculated
		
		# Change Shield Charge by whatever we found our Shield Regen to be at this point
		shieldCharge += shieldRegen * delta;
		
		# Don't allow shieldCharge to exceed 1 or go below 0
		if(shieldCharge < 0.):
			shieldCharge = 0.;
		if(shieldCharge > 1.):
			shieldCharge = 1.;
		
		# Set Shield Sprite Scaling to Match Charge
		Shield.scale = Vector2(shieldCharge * SHIELD_MAX_SCALE, shieldCharge * SHIELD_MAX_SCALE);
		
		# Set the Transparency of the entire Shield - it should be fully opaque if above the fade in threshold
		if(shieldCharge > SHIELD_FADE_IN_THRESHOLD):
			outerShieldAlpha = 1.;
		else:
			# If below the threshold, fade in from 0 to 100% visibility depending on how close to the threshold it is
			outerShieldAlpha = shieldCharge / SHIELD_FADE_IN_THRESHOLD;
		Shield.modulate.a = outerShieldAlpha;
		
		# Now work on the Inner Shield's Alpha
		innerShieldAlpha = SHIELD_INSIDE_NO_FLASH_MIN + (shieldCharge * SHIELD_INSIDE_ALPHA_RANGE);
		# Cover the case of a Shield Flash
		if(timeElapsedSinceLastFlash < SHIELD_FLASH_FADE_TIME):
			var difference = SHIELD_FLASH_TRANSPARENCY - innerShieldAlpha;
			var percent = 1 - (timeElapsedSinceLastFlash / SHIELD_FLASH_FADE_TIME);
			percent *= percent; # Adds some downward tension to the curve that looks better
			percent *= percent;
			innerShieldAlpha = innerShieldAlpha + (difference * percent);
		ShieldInside.modulate.a = innerShieldAlpha;
	

func setup(id = 0):
	
	# Set ID and Sprite
	charId = id;
	DuelistSprite.frame = id;
	
	# Set Shield Regen Speed based off of Defense Stat.
	shieldRegenSpeed = (MIN_SHIELD_REGEN + ((defense[id] / 100.) * SHIELD_REGEN_RANGE));
	
	# Activate and make Visible
	active = true;
	visible = true;

func shieldFlash():
	timeOfLastShieldFlash = t;
	timeElapsedSinceLastFlash = 0.;

func _on_tap_box_mouse_entered():
	mouseOnShield = true;


func _on_tap_box_mouse_exited():
	mouseOnShield = false;
