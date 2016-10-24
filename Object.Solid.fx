// TITLE: Solid object rendering
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  This shader will render a solid object to a multi render surface (mrt),
//  with info for diffuse, normals, depth, specular, emissive & velocities.
///////////////////////////////////////////////////////////////////////////


///////   Variables               /////////////////////////////////////////

float4x4 World		: WORLD;
float4x4 WVP		: WORLDVIEWPROJECTION;
float4x4 WVPold;
float3	 ViewPos	: VIEWPOS;

float Parallax = 0.3f;


///////   Textures & Samplers     /////////////////////////////////////////

texture texDiffuse : TEXTURE0;
sampler sampDiffuse = sampler_state
{
    Texture = (texDiffuse);
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

texture texNormal : TEXTURE1;
sampler sampNormal = sampler_state
{
    Texture = (texNormal);
    MagFilter = LINEAR;
    MinFilter = LINEAR;
    Mipfilter = LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

texture texEmissive : TEXTURE2;
sampler sampEmissive = sampler_state
{
    Texture = (texEmissive);
    MagFilter = LINEAR;
    MinFilter = LINEAR;
    Mipfilter = LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};


///////   Structures              /////////////////////////////////////////

struct a2v
{
	float4 Pos		: POSITION0;
	float2 UV		: TEXCOORD0;
	float3 Normal	: NORMAL0;
	float3 Binormal	: BINORMAL0;
	float3 Tangent	: TANGENT0;
};

struct v2p
{
	float4 Pos		: POSITION0;
	float2 UV		: TEXCOORD0;
	float2 Depth	: TEXCOORD1;
	float2 Velocity	: TEXCOORD2;
	float3 ViewVec	: TEXCOORD3;
	float3x3 TanToW	: TEXCOORD4;
};

struct mrt
{
	float4 MRT0 	: COLOR0;
	float4 MRT1 	: COLOR1;
	float4 MRT2 	: COLOR2;
	float4 MRT3		: COLOR3;
};


///////   Functions               /////////////////////////////////////////

float2 ParallaxTexCoord(float2 UV, float Height, float3 eye_vect, float parallax_amount)
{
	parallax_amount = parallax_amount * 0.1f;
	return (Height * parallax_amount - parallax_amount * 0.5)
			* eye_vect + UV;
}


///////   Programs                /////////////////////////////////////////

void VSApp(in a2v IN, out v2p OUT)
{
	OUT.Pos = mul(IN.Pos, WVP);
	OUT.UV = IN.UV;
	
	OUT.Depth.x = OUT.Pos.z;
	OUT.Depth.y = OUT.Pos.w;
	
	float4 VPos = OUT.Pos;
	float4 VPosold = mul(IN.Pos, WVPold);
	VPos /= VPos.w;
	VPosold /= VPosold.w;
	OUT.Velocity = (VPos - VPosold) / 2.0f;
	
	OUT.TanToW[0] = mul(IN.Tangent, World);
	OUT.TanToW[1] = mul(IN.Binormal, World);
	OUT.TanToW[2] = mul(IN.Normal, World);
	
	OUT.ViewVec = mul(OUT.TanToW, ViewPos - mul(IN.Pos, World));
	
	// Store this WVP for the next frame
	//WVPold = WVP; 	// Produces error X3025: global variables are implicitly constant, enable compatibility mode to allow modification
}

void PSApp(in v2p IN, out mrt OUT)
{
	// Calculate parallax offset
	float2 PUV = IN.UV;
	if (Parallax > 0)
	{
		float Height = tex2D(sampNormal, IN.UV).a;
		if (Height > 0) PUV = ParallaxTexCoord(IN.UV, Height, normalize(IN.ViewVec), Parallax);
	}
	
	// Emissive map
	OUT.MRT0.rgb = tex2D(sampEmissive, PUV).rgb;
	
	// Unused
	OUT.MRT0.a = 1.0f;
	
	// Normal map
	float3 Normal = tex2D(sampNormal, PUV).rgb;
	Normal = 2.0f * Normal - 1.0f;		// To [-1,1]
	Normal = mul(Normal, IN.TanToW);	// To tangent space
	Normal = normalize(Normal);			// Normalize
	OUT.MRT1.rgb = Normal;
	
	// Specular map
	OUT.MRT1.a = tex2D(sampEmissive, PUV).a;
	
	// Diffuse map
	OUT.MRT2.rgb = tex2D(sampDiffuse, PUV);
	
	// Depth map
	OUT.MRT2.a = IN.Depth.x / IN.Depth.y;
	
	// Velocity map
	OUT.MRT3.rg = IN.Velocity.xy;
	
	// Unused
	OUT.MRT3.ba = 0.0f;
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