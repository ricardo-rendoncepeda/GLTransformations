//
//  Shader.h
//  GLTransformations
//
//  Created by RRC on 9/2/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface Shader : NSObject

- (GLuint)BuildProgram:(const char*)vertexShaderSource with:(const char*)fragmentShaderSource;

@end
