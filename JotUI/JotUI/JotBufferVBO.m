//
//  JotBufferVBO.m
//  JotUI
//
//  Created by Adam Wulf on 7/20/13.
//  Copyright (c) 2013 Adonit. All rights reserved.
//

#import "JotBufferVBO.h"
#import "AbstractBezierPathElement.h"
#import "JotBufferManager.h"
#import "JotUI.h"

/**
 * a JotBufferVBO represents a single VBO
 * on the GPU. This may or may not be backed
 * literally be it's own block of memory. it may
 * share a backing VBO with other JotBufferVBOs
 * (likely).
 */
@implementation JotBufferVBO{
    // this cacheNumber saves which bucket of VBOs this particular VBO may share with
    int cacheNumber;
    // this is the backing VBO which may or may not be shared with other JotBufferVBOs
    OpenGLVBO* vbo;
    // this is the stepNumber inside the OpenGL vbo where our memory is stored
    NSInteger stepNumber;
}

-(id) initWithData:(NSData*)vertexData andOpenGLVBO:(OpenGLVBO*)_vbo andStepNumber:(NSInteger)_stepNumber{
    if(self = [super init]){
        
        vbo = _vbo;
        stepNumber = _stepNumber;
        cacheNumber = [JotBufferManager cacheNumberForData:vertexData];

        // update our backing store with our initial data
        [vbo updateStep:stepNumber withBufferWithData:vertexData];
    }
    return self;
}

+(int) cacheNumberForBytes:(int)bytes{
    return ceilf(bytes / kJotBufferBucketSize);
}

-(int) cacheNumber{
    return cacheNumber;
}

-(void) updateBufferWithData:(NSData*)vertexData{
    [vbo updateStep:stepNumber withBufferWithData:vertexData];
}

/**
 * this bind method presumes that color information is included in
 * the vertex data of the VBO
 */
-(void) bind{
    [vbo bindForStep:stepNumber];
}

/**
 * this bind method presumes that color information is NOT included in
 * the vertex data of the VBO, and will set glColor4f
 */
-(void) bindForColor:(UIColor*)color{
    [vbo bindForColor:color andStep:stepNumber];
}

-(void) unbind{
    [vbo unbind];
}



@end