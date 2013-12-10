//
//  MainViewController.m
//  GLTransformations
//
//  Created by RRC on 9/2/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import "MainViewController.h"
#import "Model.h"
#import "Transformations.h"

@interface MainViewController ()

@property (strong, nonatomic) Model* model;
@property (strong, nonatomic) Transformations* transformations;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up context
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // Set up view
    GLKView* glkView = (GLKView *) self.view;
    glkView.context = context;
    
    // OpenGL ES Settings
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    // Load model
    self.model = [[Model alloc] initWithModel:M_STARSHIP];
    
    // Initialize transformations
    self.transformations = [[Transformations alloc] initWithDepth:5.0f Scale:2.0f Translation:GLKVector2Make(0.0f, 0.0f) Rotation:GLKVector3Make(0.0f, 0.0f, 0.0f)];
}

- (void)calculateMatrices
{
    // Projection Matrix
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 10.0f);
    
    // ModelView Matrix
    GLKMatrix4 modelViewMatrix = [self.transformations getModelViewMatrix];
    
    // Normal Matrix
    // Transform normals from object-space to eye-space
    bool invertible;
    GLKMatrix3 normalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(modelViewMatrix, &invertible));
    if(!invertible)
        NSLog(@"MV matrix is not invertible");
    
    // Set matrices
    [self.model setMatricesProjection:projectionMatrix ModelView:modelViewMatrix Normal:normalMatrix];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Calculate matrices
    [self calculateMatrices];
    
    // Render model
    [self.model renderModel];
}

- (IBAction)selectModel:(UISegmentedControl *)sender
{
    self.paused = YES;
    
    MyModels newModel;
    int m = (int)sender.selectedSegmentIndex;
    switch(m)
    {
        case 0:
            newModel = M_CUBE;
            break;
            
        case 1:
            newModel = M_STARSHIP;
            break;
    }
    
    [self.model loadModel:newModel];
    
    self.paused = NO;
}

// GESTURES

# pragma mark - Gestures

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Begin transformations
    [self.transformations start];
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender
{    
    // Pan (1 Finger)
    if((sender.numberOfTouches == 1) &&
        ((self.transformations.state == S_NEW) || (self.transformations.state == S_TRANSLATION)))
    {
        CGPoint translation = [sender translationInView:sender.view];
        float x = translation.x/sender.view.frame.size.width;
        float y = translation.y/sender.view.frame.size.height;
        [self.transformations translate:GLKVector2Make(x, y) withMultiplier:5.0f];
    }
    
    // Pan (2 Fingers)
    else if((sender.numberOfTouches == 2) &&
        ((self.transformations.state == S_NEW) || (self.transformations.state == S_ROTATION)))
    {
        const float m = GLKMathDegreesToRadians(0.5f);
        CGPoint rotation = [sender translationInView:sender.view];
        [self.transformations rotate:GLKVector3Make(rotation.x, rotation.y, 0.0f) withMultiplier:m];
    }
}

- (IBAction)pinch:(UIPinchGestureRecognizer *)sender
{
    // Pinch
    if((self.transformations.state == S_NEW) || (self.transformations.state == S_SCALE))
    {
        float scale = [sender scale];
        [self.transformations scale:scale];
    }
}

- (IBAction)rotation:(UIRotationGestureRecognizer *)sender
{
    // Rotation
    if((self.transformations.state == S_NEW) || (self.transformations.state == S_ROTATION))
    {
        float rotation = [sender rotation];
        [self.transformations rotate:GLKVector3Make(0.0f, 0.0f, rotation) withMultiplier:1.0f];
    }
}

@end
