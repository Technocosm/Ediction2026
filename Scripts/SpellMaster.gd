extends Node2D

# Edict Prefabs
var EdictPrefab;		# Prefab Template
var instances : Array;	# An array containing all current Edict instances - even if they are currently inactive

# Resources Containing Edict Data
const EDICT_AMOUNT = 60;
var EdictStats : Array;
const ResourceFilepaths : Array[String] = ["NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "res://Resources/10_LesserForceEdict.tres", "res://Resources/11_StandardForceEdict.tres", "res://Resources/12_LesserBlastEdict.tres", "res://Resources/13_StandardBlastEdict.tres", "res://Resources/14_EtchingEdict.tres", "res://Resources/15_ShieldDrainCurse.tres", "res://Resources/16_MendingMagic.tres", "NA", "NA", "NA", "res://Resources/20_GreaterForceEdict.tres", "res://Resources/21_ShieldMaulerMalediction.tres", "res://Resources/22_EmbrittlingEdict.tres", "res://Resources/23_IntimidationIncantation.tres", "res://Resources/24_ShieldBurstBenediction.tres", "res://Resources/25_ForceConversion.tres", "res://Resources/26_Pressuriser.tres", "res://Resources/27_ProjectionLine.tres", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA", "NA"];

var Duelist;
var DuelistHurtbox;

var t = 0.; 			# Timer

const MAX_EDICTS = 64;	# The Maximum amount of Edicts allowed onscreen at once

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
	
	if(Input.is_action_just_pressed("Cast1")):
		SetupFreeEdict(10, false);
	
	# Update Each Edict in the match each frame
	for i in MAX_EDICTS:
		instances[i].update(delta);
		
		if(t > 0.2):					# Just a failsafe to ensure nothing collides before it's properly set up
			if(instances[i].active):	# Don't Check Collision of inactive Edicts
					if(DuelistHurtbox.overlaps_area(instances[i].getHitbox())):	# If an Edict hits the Duelist
						Duelist.shieldFlash();
	

# Look for an inactive Edict that's free to set up, then give it the ID for the Edict you want it to be.
func SetupFreeEdict(id, precise):
	var num = 0;
	while num < MAX_EDICTS:
		if(!instances[num].active):
			instances[num]._setup(id, EdictStats[id], precise, Duelist.getStrength(), Duelist.getSpeed());
			num = MAX_EDICTS;
		num += 1;
