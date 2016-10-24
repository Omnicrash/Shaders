// TITLE: Depth mapping shader
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  Simple depth mapping shader.
///////////////////////////////////////////////////////////////////////////


///////   Variables               /////////////////////////////////////////

float4x4 WVP		: WORLDVIEWPROJECTION;


///////   Structures              /////////////////////////////////////////

struct a2v
{
	float4 Position	: POSITION0;
};

struct v2p
{
	float4 Position	: POSITION0;
	float3 Depth	: TEXCOORD0;
};


///////   Programs                /////////////////////////////////////////

void VSApp(in a2v IN, out v2p OUT)
{
	OUT.Position = mul(IN.Position, WVP);
	OUT.Depth.x = OUT.Position.z;
	OUT.Depth.y = OUT.Position.w;
}

float4 PSApp(in v2p IN) : COLOR0
{
	return float4(IN.Depth.x / IN.Depth.y, 0, 0, 1);
}


///////   Techniques              /////////////////////////////////////////

technique DepthMap
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSApp();
	}
}