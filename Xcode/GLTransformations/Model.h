//
//  Model.h
//  GLTransformations
//
//  Created by RRC on 9/2/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import "PhongShader.h"

@interface Model : NSObject

typedef enum MyModels
{
    M_CUBE,
    M_STARSHIP,
}
MyModels;

@property (strong, nonatomic) PhongShader* shader;

- (id)initWithModel:(MyModels)m;
- (void)loadModel:(MyModels)m;
- (void)renderModel;
- (void)setMatricesProjection:(GLKMatrix4)p ModelView:(GLKMatrix4)mv Normal:(GLKMatrix3)n;

@end
