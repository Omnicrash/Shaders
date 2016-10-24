// TITLE: Terrain shader
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  Terrain splatting shader.
///////////////////////////////////////////////////////////////////////////


///////   Variables               /////////////////////////////////////////

float4x4 WVP		: WORLDVIEWPROJECTION;


///////   Textures & Samplers     /////////////////////////////////////////

texture texAlphaMap;
sampler sampAlphaMap = sampler_state
{
	Texture	= <texAlphaMap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Clamp;
	AddressV = Clamp;
};

texture tex1;
sampler samp1 = sampler_state
{
	Texture	= <tex1>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};

texture tex2;
sampler samp2 = sampler_state
{
	Texture	= <tex2>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};

texture tex3;
sampler samp3 = sampler_state
{
	Texture	= <tex3>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};

texture tex4;
sampler samp4 = sampler_state
{
	Texture	= <tex4>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
	AddressV = Wrap;
};


///////   Structures              /////////////////////////////////////////

struct a2v
{
	float4 Position	: POSITION0;
	float2 TexCoord	: TEXCOORD0;
};

struct v2p
{
	float4 Position	: POSITION0;
	float2 TexCoord	: TEXCOORD0;
};


///////   Programs                /////////////////////////////////////////

void VSApp(in a2v IN, out v2p OUT)
{
	OUT.Position = mul(IN.Position, WVP);
	OUT.TexCoord = IN.TexCoord;
}

float4 PSApp(in v2p IN) : COLOR0
{
	float3 oColor = 0;
	
	float4 AlphaMap = tex2D(sampAlphaMap, IN.TexCoord);
	
	oColor += AlphaMap.r * tex2D(samp1, IN.TexCoord);
	oColor += AlphaMap.g * tex2D(samp2, IN.TexCoord);
	oColor += AlphaMap.b * tex2D(samp3, IN.TexCoord);
	oColor += AlphaMap.a * tex2D(samp4, IN.TexCoord);
	
	return float4(oColor, 1.0f);
}


///////   Techniques              /////////////////////////////////////////

technique Terrain
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSApp();
	}
}