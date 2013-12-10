//
//  Model.m
//  GLTransformations
//
//  Created by RRC on 9/2/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import "Model.h"
#import "PhongShader.h"
#import "cube.h"
#import "starship.h"

@interface Model ()

@property (readwrite) MyModels model;

@end

@implementation Model

- (id)initWithModel:(MyModels)m
{
    if(self = [super init])
    {
        // Load shader
        self.shader = [[PhongShader alloc] init];
        glUseProgram(self.shader.program);
        
        // Load model
        [self loadModel:m];
    }
    
    return self;
}

- (void)loadModel:(MyModels)m
{
    self.model = m;
    [self loadTexture];
}

- (void)loadTexture
{
    NSDictionary* options = @{GLKTextureLoaderOriginBottomLeft: @YES};
    NSError* error;
    
    NSString* path;
    switch(self.model)
    {
        case M_CUBE:
            path = [[NSBundle mainBundle] pathForResource:@"cube_decal.png" ofType:nil];
            break;
            
        case M_STARSHIP:
            path = [[NSBundle mainBundle] pathForResource:@"starship_decal.png" ofType:nil];
            break;
    }
    
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    
    if(texture == nil)
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    
    glBindTexture(GL_TEXTURE_2D, texture.name);
    glUniform1i(self.shader.uTexture, 0);
}

- (void)renderModel
{
    // Enable
    glEnableVertexAttribArray(self.shader.aPosition);
    glEnableVertexAttribArray(self.shader.aTexel);
    glEnableVertexAttribArray(self.shader.aNormal);
    
    // Render model
    switch(_model)
    {
        case M_CUBE:
            [self renderCube];
            break;
            
        case M_STARSHIP:
            [self renderStarship];
            break;
    }
    
    // Disable
    glDisableVertexAttribArray(self.shader.aPosition);
    glDisableVertexAttribArray(self.shader.aTexel);
    glDisableVertexAttribArray(self.shader.aNormal);
}

- (void)renderCube
{
    // Geometry
    glVertexAttribPointer(self.shader.aPosition, 3, GL_FLOAT, GL_FALSE, 0, cubePositions);
    glVertexAttribPointer(self.shader.aTexel, 2, GL_FLOAT, GL_FALSE, 0, cubeTexels);
    glVertexAttribPointer(self.shader.aNormal, 3, GL_FLOAT, GL_FALSE, 0, cubeNormals);
    
    for(int i=0; i<cubeMaterials; i++)
    {
        // Materials
        glUniform3f(self.shader.uDiffuse, cubeDiffuses[i][0], cubeDiffuses[i][1], cubeDiffuses[i][2]);
        glUniform3f(self.shader.uSpecular, cubeSpeculars[i][0], cubeSpeculars[i][1], cubeSpeculars[i][2]);
        
        // Vertices
        glDrawArrays(GL_TRIANGLES, cubeFirsts[i], cubeCounts[i]);
    }
}

- (void)renderStarship
{
    // Geometry
    glVertexAttribPointer(self.shader.aPosition, 3, GL_FLOAT, GL_FALSE, 0, starshipPositions);
    glVertexAttribPointer(self.shader.aTexel, 2, GL_FLOAT, GL_FALSE, 0, starshipTexels);
    glVertexAttribPointer(self.shader.aNormal, 3, GL_FLOAT, GL_FALSE, 0, starshipNormals);
    
    for(int i=0; i<starshipMaterials; i++)
    {
        // Materials
        glUniform3f(self.shader.uDiffuse, starshipDiffuses[i][0], starshipDiffuses[i][1], starshipDiffuses[i][2]);
        glUniform3f(self.shader.uSpecular, starshipSpeculars[i][0], starshipSpeculars[i][1], starshipSpeculars[i][2]);
        
        // Vertices
        glDrawArrays(GL_TRIANGLES, starshipFirsts[i], starshipCounts[i]);
    }
}

- (void)setMatricesProjection:(GLKMatrix4)p ModelView:(GLKMatrix4)mv Normal:(GLKMatrix3)n
{
    glUniformMatrix4fv(self.shader.uProjectionMatrix, 1, 0, p.m);
    glUniformMatrix4fv(self.shader.uModelViewMatrix, 1, 0, mv.m);
    glUniformMatrix3fv(self.shader.uNormalMatrix, 1, 0, n.m);
}

@end
