// TITLE: Radial Blur
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  Full screen radial blur post process.
///////////////////////////////////////////////////////////////////////////

#include "FSVApp.fxh"

///////   Variables               /////////////////////////////////////////

float2 Center   = {0.5f, 0.5f};
float BlurStart = 1.0f;
float BlurWidth = -0.14f;


///////   Textures & Samplers     /////////////////////////////////////////

sampler2D sampScreen : register(s0);


///////   Programs                /////////////////////////////////////////

float4 PSApp(in v2p IN) : COLOR0
{
	float Samples = 16;
	
	float4 Color = 0;
	
	for (int i = 0; i < Samples; i++)
	{
		float Scale = BlurStart + BlurWidth * (i / (Samples - 1));
		Color += tex2D(sampScreen, (IN.TexCoord - 0.5f) * Scale + Center);
	}
	Color /= Samples;
	
	return Color;
}


///////   Techniques              /////////////////////////////////////////

technique RadialBlur
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSApp();
	}
}