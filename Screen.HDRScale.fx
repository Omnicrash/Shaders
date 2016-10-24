// TITLE: Scaling
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  This shader will perform various scaling operations.
///////////////////////////////////////////////////////////////////////////

#include "FSVApp.fxh"

///////   Textures & Samplers     /////////////////////////////////////////

sampler2D sampIN : register(s0);


///////   Programs                /////////////////////////////////////////

float4 PSApp(in v2p IN, uniform bool bLuminance) : COLOR0
{
	float4 oColor = tex2D(sampIN, IN.TexCoord);
	if (bLuminance) oColor = float4(exp(oColor.r), 1.0f, 1.0f, 1.0f);
	return oColor;
}


///////   Techniques              /////////////////////////////////////////

technique Scale
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSApp(false);
		
        ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        StencilEnable = false;
	}
}

technique ScaleLum
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSApp(true);
		
        ZEnable = false;
        ZWriteEnable = false;
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        StencilEnable = false;
	}
}