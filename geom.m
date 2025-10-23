/* some geometric routines always needed */

#include "gltron.h"
#include <math.h>

@implementation GLtron (Geometry)
- (float) lengthWithVertice: (float[3]) v
{
	return sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
}

- (void) normalizeWithVertice: (float[3]) v
{
	float d = [self lengthWithVertice: v];
	if (d == 0) return;
	v[0] /= d;
	v[1] /= d;
	v[2] /= d;
}

- (void) crossProdWithVertice: (float[3]) v1
         vertice: (float[3]) v2
         out: (float[3]) vout
{
	vout[0] = v1[1] * v2[2] - v1[2] * v2[1];
	vout[1] = v1[2] * v2[0] - v1[0] * v2[2];
	vout[2] = v1[0] * v2[1] - v1[1] * v2[0];
}

- (void) normalizeCrossProdWithVertice: (float[3]) v1
         vertice: (float[3]) v2
         out: (float[3]) vout
{
	[self crossProdWithVertice: v1
              vertice: v2
              out: vout];
	[self normalizeWithVertice: vout];
}

- (float) scalarProdWithVertice: (float[3]) v1 vertice: (float[3]) v2
{
	return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
}

- (void) verticeSubWithVertice: (float[3]) v1
         vertice: (float[3]) v2
         out: (float[3]) vout
{
	vout[0] = v1[0] - v2[0];
	vout[1] = v1[1] - v2[1];
	vout[2] = v1[2] - v2[2];
}

- (void) verticeAddWithVertice: (float[3]) v1
         vertice: (float[3]) v2
         out: (float[3]) vout
{
	vout[0] = v1[0] + v2[0];
	vout[1] = v1[1] + v2[1];
	vout[2] = v1[2] + v2[2];
}
@end
