// TITLE: Pointlight Shader
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  This shader will render a point light or a spot light based on
//  the information from the GBuffer.
///////////////////////////////////////////////////////////////////////////


///////   Variables               /////////////////////////////////////////

float4x4 WVP		: WORLDVIEWPROJECTION; 
float4x4 ViewInverse: VIEWINVERSE;
float4x4 ProjInverse;

float3	CamPos 		: CAMERAPOS;

// Tweakables
float3	LightPosition;
float	LightRadius;
float3	LightColor;
float	Brightness = 1.0f;


///////   Textures & Samplers     /////////////////////////////////////////

texture texMRT1;
sampler sampMRT1 = sampler_state
{
    Texture = (texMRT1);
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

texture texMRT2;
sampler sampMRT2 = sampler_state
{
    Texture = (texMRT2);
    MagFilter = LINEAR;
    MinFilter = LINEAR;
    Mipfilter = LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};


///////   Structures              /////////////////////////////////////////

struct a2v
{
	float4 Pos	: POSITION0;
};

struct v2p
{
	float4 Pos	: POSITION0;
	float4 SPos	: TEXCOORD0;
};


///////   Programs                /////////////////////////////////////////

void VSApp(in a2v IN, out v2p OUT)
{
	OUT.Pos = mul(IN.Pos, WVP);
	OUT.SPos = OUT.Pos;
}

float4 PSApp(in v2p IN) : COLOR0
{
	IN.SPos.xy /= IN.SPos.w;
	float2 UV = 0.5f * (float2(IN.SPos.x, -IN.SPos.y) + 1);
	
	// Get world position
	float Depth	= tex2D(sampMRT2, UV).a;
	float4 Position;
	Position.xy = IN.SPos.xy;
	Position.z = Depth;
	Position.w = 1.0f;
	Position = mul(Position, ProjInverse);
	Position = mul(Position, ViewInverse);
	Position /= Position.w;
	
	float3 LightVec = LightPosition - Position;
	
	float Attenuation = saturate(1.0f - length(LightVec) / LightRadius);
	
	LightVec = normalize(LightVec);
	
	float3 Diffuse	= tex2D(sampMRT2, UV).rgb;
	float3 Normal	= tex2D(sampMRT1, UV).rgb;
	float Specular	= tex2D(sampMRT1, UV).a;
	
	float3 DiffuseColor = Diffuse * max(0, dot(Normal, LightVec));
	
	// Calculate specular if enabled
	float SpecularColor = 0;
	if (Specular > 0)
	{	
		Specular = 255 * (1.0f - Specular);
		float3 ReflectVec = normalize(reflect(-LightVec, Normal));
		float3 DirToCam = normalize(CamPos - Position);
		SpecularColor = pow(saturate(dot(ReflectVec, DirToCam)), Specular);
	}
	
	return float4(Brightness * LightColor * Attenuation * (DiffuseColor + SpecularColor), 1);
}


///////   Techniques              /////////////////////////////////////////

technique SolidObject
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSApp();
		AlphaBlendEnable = True;
		SrcBlend         = One;
		DestBlend        = One;
		CullMode         = CW;
		ZEnable          = False;
		ZWriteEnable	 = False;
	}
}