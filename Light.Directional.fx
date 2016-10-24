// TITLE: Directional Lighting
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  This shader will render a directionally lit scene based on information
//  from a GBuffer.
///////////////////////////////////////////////////////////////////////////

#include "FSVApp.fxh"

///////   Variables               /////////////////////////////////////////

float4x4 ViewInverse: VIEWINVERSE;
float4x4 ProjInverse;

float3	CamPos 		: CAMERAPOS;


// Tweakables
float3	LightDirection;
float3	LightAmbient;
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


///////   Programs                /////////////////////////////////////////

float4 PSApp(in v2p IN) : COLOR0
{
	// Sampling
	float4	MRT1Color	= tex2D(sampMRT1, IN.TexCoord);
	float3	Normal		= MRT1Color.rgb;
	float	Specular 	= MRT1Color.a;
	float4	MRT2Color	= tex2D(sampMRT2, IN.TexCoord);
	float3	Diffuse		= MRT2Color.rgb;
	float	Depth		= MRT2Color.a;
	
	// Get world position
	float4 Position;
    Position.x = IN.TexCoord * 2.0f - 1.0f;
    Position.y = -(IN.TexCoord * 2.0f - 1.0f);
    Position.z = Depth;
    Position.w = 1.0f;
	Position = mul(Position, ProjInverse);
	Position = mul(Position, ViewInverse);
    Position /= Position.w;
	
	// Surface-to-light vector
	float3 LightVec = -normalize(LightDirection);
	
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
	
	return float4(Brightness * LightColor * (DiffuseColor + SpecularColor), 1);
}


///////   Techniques              /////////////////////////////////////////

technique DirectionalLighting
{
	pass Pass0
	{
		VertexShader 	= compile vs_3_0 VSApp();
		PixelShader 	= compile ps_3_0 PSApp();
	}
}