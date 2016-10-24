// TITLE: Tonemapping function
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  Tonemapping function used in HDR.
///////////////////////////////////////////////////////////////////////////


///////   Variables               /////////////////////////////////////////

float ToneMapKey 	= 0.8f;
float MaxLuminance 	= 512.0f;

static const float3 LUMINANCE = float3(0.299f, 0.587f, 0.114f);


///////   Functions               /////////////////////////////////////////

float3 ToneMap(float3 Color, float AvgLum)
{
	float CurLum = dot(Color, LUMINANCE);
	
	float ScaledLum = (CurLum * ToneMapKey) / AvgLum;
	float CompressedLum = (ScaledLum * (1 + (ScaledLum / (MaxLuminance * MaxLuminance)))) / (1 + ScaledLum);
	
	return Color * CompressedLum;
}