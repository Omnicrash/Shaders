// TITLE: Threshold
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  This shader applies a threshold.
///////////////////////////////////////////////////////////////////////////

#include "Tonemap.fxh"
#include "FSVApp.fxh"

///////   Variables               /////////////////////////////////////////

float Threshold = 0.85f;


///////   Textures & Samplers     /////////////////////////////////////////

sampler2D samp1 : register(s0);
sampler2D samp2 : register(s1);


///////   Programs                /////////////////////////////////////////

float4 PSApp(in v2p IN) : COLOR0
{
	float3 Sample = tex2D(samp1, IN.TexCoord).rgb;
	
	Sample = ToneMap(Sample, tex2D(samp2, float2(0.5f, 0.5f)).r);
	
	Sample -= Threshold;
	Sample = max(Sample, 0.0f);
	
	return float4(Sample, 1.0f);
}


///////   Techniques              /////////////////////////////////////////

technique CalcThreshold
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSApp();
		
		ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        StencilEnable = false;
	}
}