shader_type canvas_item;

uniform float manaPercentage : hint_range(0.0, 1.0, 0.01);

uniform sampler2D screenTexture : hint_screen_texture;
uniform sampler2D noise : repeat_enable;

uniform float manaColourR : hint_range(0.0, 1.0, 0.01);
uniform float manaColourG : hint_range(0.0, 1.0, 0.01);
uniform float manaColourB : hint_range(0.0, 1.0, 0.01);
uniform float manaColourA : hint_range(0.0, 1.0, 0.01);
uniform float manaBrightness : hint_range(0.0, 1.0, 0.01);
uniform float sloshBrightness : hint_range(0.0, 1.0, 0.01);
uniform float manaLineSize : hint_range(0.0, 1.0, 0.01);

uniform float waveFrequency = 10.f;
uniform float waveSpeed = 4.f;
uniform float waveStrength = 0.01;

void fragment()
{
	//For some reason 0.5 seems to be a little to the top-left & this is the centre?
	vec2 centre = vec2(0.515, 0.515);
	float distanceFromCentre = length(UV - centre);
	
	float distanceFromManaLine = UV.y - (1.f - manaPercentage);
	
	//Make any part of the Sprite this isn't within the circle invisible
	COLOR.a = 0.f;
	
	//For the inside of the circle, execute the code
	if (distanceFromCentre < 0.5)
	{
		//We also don't want to draw below the mana line
		if(distanceFromManaLine > 0.f)
		{
			//Prepare varaibles for RGBA
			float r = manaColourR;
			float g = manaColourG;
			float b = manaColourB;
			float a = manaColourA;
			float t = TIME;
		
			//Warbly water effect
			float waveX = (sin((UV.x * waveFrequency) + (t * waveSpeed)) * waveStrength);
			float waveY = (sin((UV.y * waveFrequency) + (t * waveSpeed)) * waveStrength);
			//We can get the 2D image of the screen as a texture, and manipulate where to render each pixel
			//Based on the sloshing to give the effect of warbly reflections.
			vec2 waveUV = SCREEN_UV + vec2(waveX, waveY);
			vec4 screenColour = texture(screenTexture, waveUV);
	
			float transparency = 1.f;
			a *= transparency;
	
			//Set Mana Colour based off of inputs
			vec4 manaColour = vec4(r*a, g*a, b*a, 1.f);
			//Also factor in the Colour of anything below this material's layer for translucency
			vec4 combinedColour = screenColour * manaColour;
			
			//Brighten by Mana Brightness
			combinedColour.x = combinedColour.x + ((1.f - combinedColour.x) * manaBrightness);
			combinedColour.y = combinedColour.y + ((1.f - combinedColour.y) * manaBrightness);
			combinedColour.z = combinedColour.z + ((1.f - combinedColour.z) * manaBrightness);
			
			//Find size of Mana Line in UV Values
			float maxMLS = 0.1125f;
			float mLS = manaLineSize * maxMLS;
			//Don't bother running the code to brighten when close to the Mana Line if not close
			if(distanceFromManaLine < mLS)
			{
				//Scale Brightness based on proximity
				float manaLineBrightnessBoost = (mLS - distanceFromManaLine) / mLS;
				
				combinedColour.x = combinedColour.x + ((1.f - combinedColour.x) * manaLineBrightnessBoost);
				combinedColour.y = combinedColour.y + ((1.f - combinedColour.y) * manaLineBrightnessBoost);
				combinedColour.z = combinedColour.z + ((1.f - combinedColour.z) * manaLineBrightnessBoost);
			}
			
			//Not sure why, but the values are all off if we don't mess with the numbers a little here.
			float sloshSpeed = waveSpeed / 18.f;
			float sloshSize = 0.75f;
			//Use a noise texture to add Slosh Brightness
			vec2 samplePoint = vec2(sin((UV.x / sloshSize) + (t * sloshSpeed)), cos((UV.y / sloshSize) + ((t / 2.5) * sloshSpeed)));
			float brightLevelModifier = texture(noise, samplePoint).z;
			
			//Apply Brightening
			combinedColour.x = combinedColour.x + ((1.f - combinedColour.x) * (sloshBrightness * brightLevelModifier));
			combinedColour.y = combinedColour.y + ((1.f - combinedColour.y) * (sloshBrightness * brightLevelModifier));
			combinedColour.z = combinedColour.z + ((1.f - combinedColour.z) * (sloshBrightness * brightLevelModifier));
			
			//Set final colour
			COLOR = combinedColour;
		}
	}
}
