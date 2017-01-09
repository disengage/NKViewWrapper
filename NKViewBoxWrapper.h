//
//  NKViewBoxWrapper.h
//  Narongsak kongpan
//
//  Created by Narongsak kongpan on 1/28/2557 BE.
//  Copyright (c) 2557 Narongsak kongpan., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NKViewBoxLayer.h"

@interface NKViewBoxWrapper : UIView <NKViewBoxLayer_Protocol>
{
    
}

@property (nonatomic) CGRect customBoundRect;
@property (nonatomic) kNKViewBoxSnapSide viewBoxSnapSide;
@property (nonatomic) NKViewBoxLayer *currentViewBox;
@property (nonatomic) bool enableScale;
@property (nonatomic) bool enableRotate;

-(void)addStickerItemWithRect:(CGRect)rect andImage:(UIImage*)image;
-(void)addStickerItemWithImage:(UIImage*)image;
-(void)setBackgroundWrapperWithImage:(UIImage*)image;
@end
