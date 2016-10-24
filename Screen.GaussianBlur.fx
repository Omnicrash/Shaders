// TITLE: Guassian blur
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  Simple gaussian blur as a post-processing effect.
///////////////////////////////////////////////////////////////////////////

#include "FSVApp.fxh"

///////   Variables               /////////////////////////////////////////

float2 SourceDimensions;

float Sigma = 2.5f;


///////   Textures & Samplers     /////////////////////////////////////////

sampler2D sampIN : register(s0);


///////   Functions               /////////////////////////////////////////

float CalcWeight(int SamplePoint)
{
	float g = 1.0f / sqrt(2.0f * 3.14159 * Sigma * Sigma);
	return (g * exp(-(SamplePoint * SamplePoint) / (2 * Sigma * Sigma)));
}


///////   Programs                /////////////////////////////////////////

float4 PSAppH(in v2p IN) : COLOR0
{
	int Radius = 6;
	
	float4 Color = 0;
	float2 UV = IN.TexCoord;
	
	for (int i = -Radius; i < Radius; i++)
	{
		float Weight = CalcWeight(i);
		
		UV.x = IN.TexCoord.x + (i / SourceDimensions.x);
		float4 Sample = tex2D(sampIN, UV);
		
		Color += Sample * Weight;
	}
	
	return Color;
}

float4 PSAppV(in v2p IN) : COLOR0
{
	int Radius = 6;
	
	float4 Color = 0;
	float2 UV = IN.TexCoord;
	
	for (int i = -Radius; i < Radius; i++)
	{
		float Weight = CalcWeight(i);
		
		UV.y = IN.TexCoord.y + (i / SourceDimensions.y);
		float4 Sample = tex2D(sampIN, UV);
		
		Color += Sample * Weight;
	}
	
	return Color;
}


///////   Techniques              /////////////////////////////////////////

technique BlurH
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSAppH();
		
		ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        StencilEnable = false;
	}
}

technique BlurV
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSAppV();
		
		ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        StencilEnable = false;
	}
}