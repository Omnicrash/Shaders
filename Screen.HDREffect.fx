// TITLE: HDR
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  This shader contains various functions used in HDR post-processing.
///////////////////////////////////////////////////////////////////////////

#include "Tonemap.fxh"
#include "FSVApp.fxh"

///////   Variables               /////////////////////////////////////////

float deltaTime;

float BloomMultiplier = 1.0f;


///////   Textures & Samplers     /////////////////////////////////////////

sampler2D samp1 : register(s0);
sampler2D samp2 : register(s1);

texture texBloom;
sampler2D samp3 = sampler_state
{
	Texture	= <texBloom>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Clamp;
	AddressV = Clamp;
};


///////   Programs                /////////////////////////////////////////

float4 LuminancePSApp(in v2p IN) : COLOR0
{
	float3 sColor = tex2D(samp1, IN.TexCoord).rgb;
	
	float Lum = log(1e-5 + dot(sColor, LUMINANCE));
	
	return float4(Lum, 1.0f, 1.0f, 1.0f);
}

float4 CalcAdaptedLumPSApp(in v2p IN) : COLOR0
{
	float CurLum = tex2D(samp1, float2(0.5f, 0.5f)).r;
	float LastLum = tex2D(samp2, float2(0.5f, 0.5f)).r;
	
	float AdaptedLum = LastLum + (CurLum - LastLum) * (1 - exp(-deltaTime * 0.5f));
	
	return float4(AdaptedLum, 1.0f, 1.0f, 1.0f);
}

float4 ToneMapPSApp(in v2p IN) : COLOR0
{
	float3 sColor = tex2D(samp1, IN.TexCoord).rgb;
	
	sColor = ToneMap(sColor, tex2D(samp2, float2(0.5f, 0.5f)).r);
	
	sColor = sColor + tex2D(samp3, IN.TexCoord).rgb * BloomMultiplier;
	
	return float4(sColor, 1.0f);
}


///////   Techniques              /////////////////////////////////////////

technique Luminance
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 LuminancePSApp();
		
		ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        StencilEnable = false;
	}
}

technique CalcAdaptedLum
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 CalcAdaptedLumPSApp();
		
		ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        StencilEnable = false;
	}
}

technique Tonemap
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 ToneMapPSApp();
		
		ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        StencilEnable = false;
	}
}