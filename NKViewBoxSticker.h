//
//  NKViewBoxSticker.h
//  ViewWrapper
//
//  Created by ebooks.in.th on 1/28/2557 BE.
//  Copyright (c) 2557 PORAR WEB APPLICATION CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NKViewBoxSticker_Protocol <NSObject>
@optional;
-(void)onImageViewStickerRectChange:(CGRect)frame;
@end

@interface NKViewBoxSticker : UIImageView
{
    
}

@property (nonatomic) id<NKViewBoxSticker_Protocol> delegate;
@property (nonatomic) CGRect innerRect;

-(void)setCGAffineTransformScale:(CGFloat)scale;
-(void)setCGAffineTransformRotate:(CGFloat)radius;

@end
