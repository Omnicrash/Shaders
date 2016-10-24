// TITLE: Volumetric Light Scattering
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  This shader renders light shafts based on the emissive map.
///////////////////////////////////////////////////////////////////////////

#include "FSVApp.fxh"

///////   Variables               /////////////////////////////////////////

float4x4 ViewProjection : VIEWPROJECTION;

float Density = 0.286f;
float Weight = 0.832f;
float Decay = 1.0261f;
float Exposure = 0.0104f;

float3 LightPosition;

int NumSamples = 16;


///////   Textures & Samplers     /////////////////////////////////////////

sampler2D sampScene	: register(s0);
sampler2D sampBase	: register(s1);

/*texture texBase;
sampler sampBase = sampler_state
{
	Texture	= <texBase>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};*/

/*texture texScene;
sampler sampScene = sampler_state
{
	Texture	= <texScene>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};*/


///////   Programs                /////////////////////////////////////////

float4 PSApp(in v2p IN) : COLOR0
{
	// Get light position in screen space
	float4 WVPLightPos = mul(LightPosition, ViewProjection);
	float2 SSLightPos = WVPLightPos.xy / WVPLightPos.w * float2(0.5,-0.5) + 0.5;
	
	// Light vector from pixel to light source in screen space
	float2 DeltaTexCoord = (IN.TexCoord - SSLightPos);
    
	float2 TexCoord = IN.TexCoord;
    DeltaTexCoord *= 1.0f / NumSamples * Density;
    
	float3 Color = tex2D(sampBase, IN.TexCoord);

    float IlluminationDecay = 1.0f;
    
	for (int i=0; i < NumSamples; i++)
	{
		// Offset sample location
		TexCoord -= DeltaTexCoord;
		
		float3 Sample = tex2D(sampBase, TexCoord);
		Sample *= IlluminationDecay * Weight;
		Color += Sample;
			
		IlluminationDecay *= Decay;
	}
	
	float4 SceneSample = tex2D(sampScene, IN.TexCoord);
	
	return float4(Color * Exposure + SceneSample, 1);
}


///////   Techniques              /////////////////////////////////////////

technique LightScatter
{
    pass Pass0
    {
		VertexShader	= compile vs_3_0 VSApp();
		PixelShader		= compile ps_3_0 PSApp();
    }
}