// TITLE: Combine shader
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  This shader adds two texture's rgb channels together.
///////////////////////////////////////////////////////////////////////////

#include "FSVApp.fxh"

///////   Textures & Samplers     /////////////////////////////////////////

sampler sampOne : register(s0);
sampler sampTwo : register(s1);


///////   Programs                /////////////////////////////////////////

float4 PSApp(in v2p IN) : COLOR0
{
	return float4(tex2D(sampOne, IN.TexCoord).rgb + tex2D(sampTwo, IN.TexCoord).rgb, 1);
}


///////   Techniques              /////////////////////////////////////////

technique SolidObject
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSApp();
	}
}