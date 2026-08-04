extends Node2D

# Edict Prefabs
var EdictPrefab;		# Prefab Template
var instances : Array;	# An array containing all current Edict instances - even if they are currently inactive

var Duelist;
var DuelistHurtbox;

var t = 0.; 			# Timer

const MAX_EDICTS = 64;	# The Maximum amount of Edicts allowed onscreen at once

# Called when the node enters the scene tree for the first time.
func _ready():
	Duelist = get_node("DuelistNode");
	DuelistHurtbox = get_node("DuelistNode/Hurtbox");
	
	EdictPrefab = preload("res://Prefabs/edict.tscn");
	instances.resize(MAX_EDICTS);
	
	for i in MAX_EDICTS:
		instances[i] = EdictPrefab.instantiate();
		add_child(instances[i]);
		
		# For Debug - Replace Later
		# instances[i]._setup(i);
		
		if(i > 8 && i < 16):
			instances[i]._setup(i);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	t += delta
	
	# Update Each Edict in the match each frame
	for i in MAX_EDICTS:
		instances[i].update(delta);
		
		if(t > 0.2):					# Just a failsafe to ensure nothing collides before it's properly set up
			if(instances[i].active):	# Don't Check Collision of inactive Edicts
					if(DuelistHurtbox.overlaps_area(instances[i].getHitbox())):	# If an Edict hits the Duelist
						Duelist.shieldFlash();
