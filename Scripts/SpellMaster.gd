extends Node2D

# Edict Prefabs
var EdictPrefab;		# Prefab Template
var instances : Array;	# An array containing all current Edict instances - even if they are currently inactive

# Resources Containing Edict Data
const EDICT_AMOUNT = 60;
var EdictStats : Array;
const ResourceFilepaths : Array[String] = ["NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "res://Resources/Spells/10_LesserForceEdict.tres", "res://Resources/Spells/11_StandardForceEdict.tres", "res://Resources/Spells/12_LesserBlastEdict.tres", "res://Resources/Spells/13_StandardBlastEdict.tres", "res://Resources/Spells/14_EtchingEdict.tres", "res://Resources/Spells/15_ShieldDrainCurse.tres", "res://Resources/Spells/16_MendingMagic.tres", "NA", "NA", "NA", "res://Resources/Spells/20_GreaterForceEdict.tres", "res://Resources/Spells/21_ShieldMaulerMalediction.tres", "res://Resources/Spells/22_EmbrittlingEdict.tres", "res://Resources/Spells/23_IntimidationIncantation.tres", "res://Resources/Spells/24_ShieldBurstBenediction.tres", "res://Resources/Spells/25_ForceConversion.tres", "res://Resources/Spells/26_Pressuriser.tres", "res://Resources/Spells/27_ProjectionLine.tres", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA"];

var Duelist;
var DuelistHurtbox;

var t = 0.; 			# Timer

const MAX_EDICTS = 64;	# The Maximum amount of Edicts allowed onscreen at once

const EDICT_TO_SHIELD_SIZE_CONVERSION_CONSTANT = 2;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load Edict Data
	for i in EDICT_AMOUNT:
		if(ResourceFilepaths[i] != "NA"):
			EdictStats.append(load(ResourceFilepaths[i]));
		else:
			# DON'T USE THESE IF THEY'RE NULL - we just need to occupy empty slots for IDs to line up
			EdictStats.append(null);
	
	Duelist = get_node("DuelistNode");
	DuelistHurtbox = get_node("DuelistNode/Hurtbox");
	
	EdictPrefab = preload("res://Prefabs/edict.tscn");
	instances.resize(MAX_EDICTS);
	
	for i in MAX_EDICTS:
		instances[i] = EdictPrefab.instantiate();
		add_child(instances[i]);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	t += delta
	
	# Debug Cast Inputs
	if(Input.is_action_just_pressed("Cast1")):
		SetupFreeEdict(10, false);
	if(Input.is_action_just_pressed("Cast2")):
		SetupFreeEdict(11, false);
	if(Input.is_action_just_pressed("Cast3")):
		SetupFreeEdict(12, false);
	if(Input.is_action_just_pressed("Cast4")):
		SetupFreeEdict(13, false);
	if(Input.is_action_just_pressed("Cast5")):
		SetupFreeEdict(14, false);
	if(Input.is_action_just_pressed("Cast6")):
		SetupFreeEdict(15, false);
	if(Input.is_action_just_pressed("Cast7")):
		SetupFreeEdict(16, false);
	if(Input.is_action_just_pressed("Cast8")):
		SetupFreeEdict(20, false);
	if(Input.is_action_just_pressed("Cast9")):
		SetupFreeEdict(21, false);
	if(Input.is_action_just_pressed("Cast10")):
		SetupFreeEdict(22, false);
	if(Input.is_action_just_pressed("Cast11")):
		SetupFreeEdict(23, false);
	if(Input.is_action_just_pressed("Cast12")):
		SetupFreeEdict(24, false);
	if(Input.is_action_just_pressed("Cast13")):
		SetupFreeEdict(25, false);
	if(Input.is_action_just_pressed("Cast14")):
		SetupFreeEdict(26, false);
	if(Input.is_action_just_pressed("Cast15")):
		SetupFreeEdict(27, false);
	
	# Update Each Edict in the match each frame
	for i in MAX_EDICTS:
		instances[i].update(delta);
		
		if(instances[i].t > 1.5):	# Newly-Spawned Edicts shouldn't have any Collision yet.
			if(instances[i].active):	# Don't Check Collision of inactive Edicts
					if(DuelistHurtbox.overlaps_area(instances[i].getHitbox())):	# If an Edict hits the Duelist
						#Don't Run Collision if we already did it last Frame.
						if(!instances[i].duelistCollissionLastFrame):
							instances[i].duelistCollissionLastFrame = true;
							# Compare Shield & Edict Sizes to see if it should be blocked
							var shieldSize = Duelist.getShieldSize();
							var edictSize = (instances[i].getRealSize().x * EDICT_TO_SHIELD_SIZE_CONVERSION_CONSTANT);
							var sizeDamageBoost = instances[i].getSizeChange()
							var duelistDamage = EdictStats[instances[i].spellID].damage * sizeDamageBoost;
							var shieldDamage = EdictStats[instances[i].spellID].shield_damage * sizeDamageBoost;
							if(shieldSize < edictSize):
								# get hit
								Duelist.dealDamage(duelistDamage);
								Duelist.dealShieldDamage(shieldDamage/2);
							else:
								# block
								Duelist.shieldFlash();
								Duelist.dealShieldDamage(shieldDamage);
								
								var pierce = EdictStats[instances[i].spellID].pierce;
								if(pierce > 0.):
									Duelist.dealDamage(duelistDamage * pierce);
							# Collision Complete, now destory the Edict.
							instances[i].destroy();
					else:
						instances[i].duelistCollissionLastFrame = false;

# Look for an inactive Edict that's free to set up, then give it the ID for the Edict you want it to be.
func SetupFreeEdict(id, precise):
	var num = 0;
	while num < MAX_EDICTS:
		if(!instances[num].active):
			instances[num]._setup(id, EdictStats[id], precise, Duelist.getStrength(), Duelist.getSpeed());
			print_debug("Edict Size: ", instances[num].getRealSize().x);
			num = MAX_EDICTS;
		num += 1;

