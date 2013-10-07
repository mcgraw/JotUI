//
//  OpenGLVBO.m
//  JotUI
//
//  Created by Adam Wulf on 8/6/13.
//  Copyright (c) 2013 Adonit. All rights reserved.
//

#import "OpenGLVBO.h"
#import "JotUI.h"
#import "UIColor+JotHelper.h"
#import "AbstractBezierPathElement-Protected.h"

/**
 * an OpenGLVBO serves as a backing store for (potentially) multiple
 * JotBufferVBOs
 *
 * this buffer will allocate a larger chunk of memory, which it'll split
 * into multiple smaller buffers of equal size. This way, one allocation
 * can be used to back multiple VBOs
 *
 * all VBOs assume the use of ColorfulVertex or ColorlessVertex
 */
@implementation OpenGLVBO{
    // this is the vbo id in OpenGL
    GLuint vbo;
    // this is the number that will determine our malloc size, both total and step
    NSInteger cacheNumber;
    // this will track the entire size of our malloc'd memory
    GLsizeiptr mallocSize;
    // this is the size of a single step of memory
    NSInteger stepMallocSize;
    // this tracks the number of steps that we hold. stepMallocSize * numberOfSteps == mallocSize
    NSInteger numberOfSteps;
}

static int zeroedCacheNumber = -1;
static void * zeroedDataCache = nil;


@synthesize numberOfSteps;

-(id) initForCacheNumber:(NSInteger)_cacheNumber{
    if(self = [super init]){
        // calculate all of our memory bucket sizes
        cacheNumber = _cacheNumber;
        stepMallocSize = cacheNumber * kJotBufferBucketSize;
        mallocSize = ceilf(stepMallocSize / ((float)kJotMemoryPageSize)) * kJotMemoryPageSize;
        numberOfSteps = floorf(mallocSize / stepMallocSize);

        // generate the VBO in OpenGL
        glGenBuffers(1,&vbo);
        glBindBuffer(GL_ARRAY_BUFFER,vbo);
        // create buffer of size mallocSize (init w/ NULL to create)
        
        // zeroedDataCache is a pointer to zero'd memory that we
        // use to initialze our VBO. This prevents "VBO uses uninitialized data"
        // warning in Instruments, and will only waste a few Kb of memory
        if(_cacheNumber > zeroedCacheNumber){
            @synchronized([OpenGLVBO class]){
                if(zeroedDataCache){
                    free(zeroedDataCache);
                }
                zeroedDataCache = calloc(cacheNumber, kJotBufferBucketSize);
            }
        }
        @synchronized([OpenGLVBO class]){
            // initialize the buffer to zero'd data
            glBufferData(GL_ARRAY_BUFFER, mallocSize, zeroedDataCache, GL_DYNAMIC_DRAW);
        }
    }
    return self;
}

/**
 * this will update a single step of data inside the VBO.
 * no other steps are affected
 */
-(void) updateStep:(NSInteger)stepNumber withBufferWithData:(NSData*)vertexData{
    [self bindForStep:stepNumber];
    GLintptr offset = stepNumber*stepMallocSize;
    GLsizeiptr len = vertexData.length;
    glBufferSubData(GL_ARRAY_BUFFER, offset, len, vertexData.bytes);
}


/**
 * this will bind the VBO with pointers to the input step number,
 * and will prep the client state and pointers appropriately
 *
 * this assumes the VBO is filled with ColorfulVertex vertex data
 */
-(void) bindForStep:(NSInteger)stepNumber{
    glBindBuffer(GL_ARRAY_BUFFER,vbo);
    glVertexPointer(2, GL_FLOAT, sizeof(struct ColorfulVertex), stepNumber*stepMallocSize + offsetof(struct ColorfulVertex, Position));
    glColorPointer(4, GL_FLOAT, sizeof(struct ColorfulVertex), stepNumber*stepMallocSize + offsetof(struct ColorfulVertex, Color));
    glPointSizePointerOES(GL_FLOAT, sizeof(struct ColorfulVertex), stepNumber*stepMallocSize + offsetof(struct ColorfulVertex, Size));
    
    JotGLContext* context = (JotGLContext*) [JotGLContext currentContext];
    [context glEnableClientState:GL_VERTEX_ARRAY];
    [context glEnableClientState:GL_COLOR_ARRAY];
    [context glEnableClientState:GL_POINT_SIZE_ARRAY_OES];
    [context glDisableClientState:GL_TEXTURE_COORD_ARRAY];
}

/**
 * this will bind the VBO with pointers for the input step number,
 * and will prep the client state and pointers appropriately
 *
 * this will also set glColor4f for the input color, and assumes
 * that the VBO is filled with ColorlessVertex vertex data
 */
-(void) bindForColor:(UIColor*)color andStep:(NSInteger)stepNumber{
    
    JotGLContext* context = (JotGLContext*)[JotGLContext currentContext];
    
    glBindBuffer(GL_ARRAY_BUFFER,vbo);
    glVertexPointer(2, GL_FLOAT, sizeof(struct ColorlessVertex), stepNumber*stepMallocSize + offsetof(struct ColorlessVertex, Position));
    glPointSizePointerOES(GL_FLOAT, sizeof(struct ColorlessVertex), stepNumber*stepMallocSize + offsetof(struct ColorlessVertex, Size));

    [context glEnableClientState:GL_VERTEX_ARRAY];
    [context glDisableClientState:GL_COLOR_ARRAY];
    [context glEnableClientState:GL_POINT_SIZE_ARRAY_OES];
    [context glDisableClientState:GL_TEXTURE_COORD_ARRAY];

    if(!color){
        [context glColor4f:0 and:0 and:0 and:1];
    }else{
        GLfloat colorSteps[4];
        [color getRGBAComponents:colorSteps];
        if(colorSteps[0] * colorSteps[3] > 1 ||
           colorSteps[1] * colorSteps[3] > 1 ||
           colorSteps[2] * colorSteps[3] > 1 ||
           colorSteps[3] > 1){
            NSLog(@"what2");
        }
        [context glColor4f:(colorSteps[0] * colorSteps[3]) and:(colorSteps[1] * colorSteps[3]) and:(colorSteps[2] * colorSteps[3]) and:(colorSteps[3])];
    }
}

-(void) unbind{
    glBindBuffer(GL_ARRAY_BUFFER,0);
}

-(void) dealloc{
    if(vbo){
        glDeleteBuffers(1,&vbo);
    }
}


@end