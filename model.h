#ifndef MODEL_H
#define MODEL_H

#define MODEL_USE_MATERIAL 1
#define MODEL_DRAW_BBOX    2

/* warning: changing this will break drawModel() */
#define MODEL_FACESIZE 4

@interface Materials
{
  float ambient[4];
  float diffuse[4];
  float specular[4];
  char *name;
}

- (void) setName: (NSString *) o;
- (void) setAmbient: (float *) o;
- (void) setDiffuse: (float *) o;
- (void) setSpecular: (float *) o;
- (NSString *) getName;
- (float *) getAmbient;
- (float *) getDiffuse;
- (float *) getSpecular;
@end

@interface MeshPart
{
  int nFaces;
  NSData *facesizes;
  NSData *vertices;
  NSData *normals;
}

- (void) setNFaces: (int) o;
- (void) setFaceSizes: (NSData *) o;
- (void) setVertices: (NSData *) o;
- (void) setNormals: (NSData *) o;
- (int) getNFaces;
- (NSData *) getFaceSizes;
- (NSData *) getVertices;
- (NSData *) getNormals;
@end

@interface Mesh
{
  int nFaces;
  int nMaterials;
  Material *materials;
  NSArray *meshparts;
  float bbox[3];
}

- (void) setNFaces: (int) o;
- (void) setNMaterials: (int) o;
- (void) setMaterials: (Material *) o;
- (void) setMeshPart: (MeshPart *) o;
- (void) setBBox: (float *) o;
- (int) getNFaces;
- (int) getNMaterials;
- (Material *) getMaterials;
- (MeshPart *) getMeshPart;
- (float *) getBBox;
@end

#endif
