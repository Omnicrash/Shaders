// TITLE: Spot Light Shader
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  This shader will render a spot light based on the information
//  from the GBuffer.
///////////////////////////////////////////////////////////////////////////


///////   Variables               /////////////////////////////////////////

float4x4 WVP		: WORLDVIEWPROJECTION;
float4x4 LVP;
float4x4 ViewInverse: VIEWINVERSE;
float4x4 ProjInverse;
float4x4 WorldIT	: WORLDIT;

float3	CamPos 		: CAMERAPOS;

// Tweakables
float3	LightPosition;
float	LightRadius;
float	LightLength;
float3	LightColor;
float	Brightness = 1.0f;

float DepthBias = 0.001f;

bool EnableShadowing = true;


///////   Textures & Samplers     /////////////////////////////////////////

texture texMRT1;
sampler sampMRT1 = sampler_state
{
    Texture = (texMRT1);
    MagFilter = Linear;
    MinFilter = Linear;
    Mipfilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

texture texMRT2;
sampler sampMRT2 = sampler_state
{
    Texture = (texMRT2);
    MagFilter = Linear;
    MinFilter = Linear;
    Mipfilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

texture texFilter : TEXTURE0;
sampler sampFilter = sampler_state
{
    Texture = (texFilter);
    MagFilter = Linear;
    MinFilter = Linear;
    Mipfilter = Linear;
    AddressU = Border;
    AddressV = Border;
};

texture texLightDepth;
sampler sampLightDepth = sampler_state
{
	Texture = (texLightDepth);
	MagFilter = Linear;
    MinFilter = Linear;
    Mipfilter = Linear;
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


///////   Functions               /////////////////////////////////////////

// Calculate the light filter
float3 CalcFilter(float3 WorldPos)
{
	// Rotate points
	float4x4 WorldInverse = transpose(WorldIT);
	float3 PRot = mul(WorldPos, WorldInverse);
	float3 POri = mul(LightPosition, WorldInverse);

	// Get distance & exit if its behind the cone
	float PDist = PRot.y - POri.y;
	if (PDist > 0) return 0;
	
	// Calculate radius at point
	float PPos = PDist / LightLength;
	float PRadius = lerp(0, LightRadius, PPos);
	
	// Transform point to -1,1 range
	float2 PNT = (PRot.xz - POri.xz) / PRadius;
	
	// Bring to 0,1 for texture coordinates
	float2 FUV = (PNT + 1) / 2;
	
	return tex2D(sampFilter, FUV);
}

bool IsShadow(float4 WorldPos)
{
	float4 LightingPos = mul(WorldPos, LVP);
	LightingPos /= LightingPos.w;
	
	float2 DepthMapPos;
	DepthMapPos.x = LightingPos.x / 2.0f + 0.5f;
	DepthMapPos.y = 1 - (LightingPos.y / 2.0f + 0.5f);
	
	float4 DepthSample = tex2D(sampLightDepth, DepthMapPos);
	
	float CurDepth = LightingPos.z;
	
	//float ESM_K = 60.0f; // Range [0, 80]
	//float ESM_MIN = -1.0f; // Range [0, -oo]
	//float ESM_DIFFUSE_SCALE = 1.79f; // Range [1, 10]
	//Calculate ESM
	//float shadow = saturate(exp(max(ESM_MIN, ESM_K * (DepthSample - CurDepth))));
	//Return Shadow
	//float3 ReturnColor = 1.0f - (ESM_DIFFUSE_SCALE * (1.0f - shadow));
	
	/*
	float3 ReturnColor;
	if 
	{
		ReturnColor = saturate(CurDepth / 3.0f);
	}
	else
	{
		ReturnColor = 1;
	}
	*/
	return (DepthSample.r <= CurDepth - DepthBias);
}


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
	
	if (EnableShadowing && IsShadow(Position)) return float4(0, 0, 0, 1);
	
	float3 LightVec = LightPosition - Position;
	
	float Attenuation = saturate(1.0f - length(LightVec) / LightLength);
	
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
	
	// Calculate light filter
	float3 FilterColor = CalcFilter(Position);
	
	return float4(Brightness * LightColor * Attenuation * FilterColor * (DiffuseColor + SpecularColor), 1);
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