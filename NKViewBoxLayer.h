//
//  NKViewBoxLayer.h
//  Narongsak kongpan
//
//  Created by Narongsak kongpan on 1/28/2557 BE.
//  Copyright (c) 2557 Narongsak kongpan., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NKViewBoxSticker.h"

typedef enum{
    kViewBoxLayerTypeSticker,
    kViewBoxLayerTypeImageView
} kViewBoxLayerType;

typedef enum {
    kNKViewBoxSnapSideNone,
    kNKViewBoxSnapSideTopLeft,
    kNKViewBoxSnapSideTopRight,
    kNKViewBoxSnapSideBottomLeft,
    kNKViewBoxSnapSideBottomRight,
    kNKViewBoxSnapSideAuto
} kNKViewBoxSnapSide;

@protocol NKViewBoxLayer_Protocol <NSObject>
@optional;
-(void)onTapViewBoxLayer:(id)sender;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface NKViewBoxLayer : UIView <NKViewBoxSticker_Protocol>
{
    
}

@property (nonatomic) bool disableOutsideView;
@property (nonatomic) CGRect customBoundRect;
@property (nonatomic) kNKViewBoxSnapSide viewBoxSnapSide;
@property (nonatomic) id<NKViewBoxLayer_Protocol> delegate;

-(void)updateViewBox;
-(void)resetToCustomRectFrame;
-(void)setContentItemToStickerLayer:(CGRect)withRect withImage:(UIImage*)image;
-(void)setContentRotate:(CGFloat)radius;
-(void)setContentScale:(CGFloat)scale;

@end
