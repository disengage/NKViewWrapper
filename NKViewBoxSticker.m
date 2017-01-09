//
//  NKViewBoxSticker.m
//  Narongsak kongpan
//
//  Created by Narongsak kongpan on 1/28/2557 BE.
//  Copyright (c) 2557 Narongsak kongpan., LTD. All rights reserved.
//

#import "NKViewBoxSticker.h"

@implementation NKViewBoxSticker

@synthesize delegate = _delegate;
@synthesize innerRect = _innerRect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.layer setBorderWidth:0];
        [self.layer setBorderColor:[UIColor blueColor].CGColor];
        
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

-(void)setCGAffineTransformScale:(CGFloat)scale{
    self.transform = CGAffineTransformScale(self.transform, scale, scale);
    [self _updateResponse];
}

-(void)setCGAffineTransformRotate:(CGFloat)radius{
    self.transform = CGAffineTransformRotate(self.transform, radius);
    [self _updateResponse];
}

-(void)_updateResponse{
    if ([self.delegate respondsToSelector:@selector(onImageViewStickerRectChange:)]) {
        [self.delegate onImageViewStickerRectChange:self.frame];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
