// TITLE: Full screen vertex shader
// AUTHOR: Yve Verstrepen
// DESCRIPTION:
//  Vertex shader for fullscreen effects
///////////////////////////////////////////////////////////////////////////


///////   Variables               /////////////////////////////////////////

float2 DestDimensions;


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
	OUT.Position = IN.Position;
	float2 Offset = 0.5f / DestDimensions;
	OUT.TexCoord = IN.TexCoord + Offset;
}