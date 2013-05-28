//
//  JotStrokeDelegate.h
//  JotUI
//
//  Created by Adam Wulf on 5/28/13.
//  Copyright (c) 2013 Adonit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JotStroke;

@protocol JotStrokeDelegate <NSObject>

-(void) jotStrokeWasCancelled:(JotStroke*)stroke;

@end