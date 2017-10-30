//
//  JotUI.h
//  JotUI
//
//  Created by Adam Wulf on 12/8/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#ifndef JotUI_h
#define JotUI_h


#define CheckMainThread                              \
    if (![NSThread isMainThread]) {                  \
        NSAssert(NO, @"needs to be on main thread"); \
    }

#define kJotEnableCacheStats NO

#define kJotBufferBucketSize 200.0

// vm page size: http://developer.apple.com/library/mac/#documentation/Performance/Conceptual/ManagingMemory/Articles/MemoryAlloc.html
#define kJotMemoryPageSize 4096

#define kAbstractMethodException [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]


#import <Foundation/Foundation.h>

#import "JotView.h"
#import "JotViewDelegate.h"
#import "MoveToPathElement.h"
#import "CurveToPathElement.h"
#import "JotStrokeManager.h"
#import "JotGLTextureBackedFrameBuffer.h"
#import "JotViewImmutableState.h"
#import "JotGLContext.h"
#import "JotViewStateProxy.h"
#import "JotViewStateProxyDelegate.h"
#import "NSArray+JotMapReduce.h"
#import "JotTrashManager.h"
#import "UIImage+Resize.h"
#import "JotDiskAssetManager.h"
#import "UIScreen+PortraitBounds.h"
#import "MMWeakTimer.h"
#import "MMMainOperationQueue.h"
#import "JotGLProgram.h"
#import "JotBrushTexture.h"
#import "JotDefaultBrushTexture.h"
#import "JotHighlighterBrushTexture.h"

typedef struct {
    GLfloat x;
    GLfloat y;
} Vertex3D;

typedef Vertex3D Vector3D;


#endif
