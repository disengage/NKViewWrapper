//
//  NKViewBoxWrapper.m
//  ViewWrapper
//
//  Created by ebooks.in.th on 1/28/2557 BE.
//  Copyright (c) 2557 PORAR WEB APPLICATION CO., LTD. All rights reserved.
//

#import "NKViewBoxWrapper.h"
#import "NKViewBoxLayer.h"

@implementation NKViewBoxWrapper
{
    NSMutableArray *arrBoxLayer;
    CGFloat currentRotateAngle;
    CGFloat currentScale;
}

@synthesize customBoundRect = _customBoundRect;
@synthesize viewBoxSnapSide = _viewBoxSnapSide;
@synthesize enableRotate = _enableRotate;
@synthesize enableScale = _enableScale;
@synthesize currentViewBox = _currentViewBox;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.layer setBorderWidth:0];
        [self.layer setBorderColor:[UIColor greenColor].CGColor];
        
        arrBoxLayer = [NSMutableArray array];
        [self setViewBoxSnapSide:kNKViewBoxSnapSideNone];
        [self setEnableRotate:YES];
        [self setEnableScale:YES];
    }
    return self;
}

-(CGSize)_tranformSizeToMainScreen:(CGSize)sourceSize{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(screenSize.width, sourceSize.height * (screenSize.width / sourceSize.width));
}

-(void)setBackgroundWrapperWithImage:(UIImage*)image{
    CGSize targetSize = [self _tranformSizeToMainScreen:image.size];
    if (!CGSizeEqualToSize(self.customBoundRect.size,CGSizeZero)) {
        targetSize = [self _tranformSizeToMainScreen:self.customBoundRect.size];
    }
    CGRect rectMake = CGRectMake(0, 0, targetSize.width, targetSize.height);
    [self addStickerItemWithRect:rectMake andImage:image];
}

-(void)addStickerItemWithRect:(CGRect)rect andImage:(UIImage*)image{
    NKViewBoxLayer *boxLayer = [[NKViewBoxLayer alloc] initWithFrame:rect];
    [boxLayer setViewBoxSnapSide:self.viewBoxSnapSide];
    [boxLayer setCustomBoundRect:self.customBoundRect];
    [boxLayer setContentRotate:self.enableRotate];
    [boxLayer setContentScale:self.enableScale];
    [boxLayer setContentItemToStickerLayer:rect withImage:image];
    [boxLayer setDelegate:self];
    [self addSubview:boxLayer];
    [arrBoxLayer addObject:boxLayer];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableArray *allTouches = [[[event allTouches] allObjects] mutableCopy];
    if([allTouches count] == 2){
        CGPoint P1 = [[allTouches objectAtIndex:0] previousLocationInView:nil];
        CGPoint P2 = [[allTouches objectAtIndex:1] previousLocationInView:nil];
        CGPoint M1 = [[allTouches objectAtIndex:0] locationInView:nil];
        CGPoint M2 = [[allTouches objectAtIndex:1] locationInView:nil];
        if (self.enableScale) {
            currentScale = ([self CGPointDistance:M1 p2:M2] / [self CGPointDistance:P1 p2:P2]);
            [self.currentViewBox setContentScale:currentScale];
        }
        if (self.enableRotate) {
            currentRotateAngle = [self CGPointToDegree:M1 p2:M2] - [self CGPointToDegree:P1 p2:P2];
            [self.currentViewBox setContentRotate:[self DegreesToRadians:currentRotateAngle]];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableArray *allTouches = [[[event allTouches] allObjects] mutableCopy];
    if([allTouches count] == 2){
        
    }
}

-(void)onTapViewBoxLayer:(id)sender{
    NKViewBoxLayer *boxLayer = (NKViewBoxLayer*)sender;
    self.currentViewBox = boxLayer;
    [self bringSubviewToFront:boxLayer];
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for (NKViewBoxLayer *each in arrBoxLayer) {
        if (CGRectContainsPoint(each.frame, point)) {
            if (CGRectContainsPoint(self.currentViewBox.frame, point)){
                return self.currentViewBox;
            }else{
                return each;
            }
        }
    }
    return self;
}

-(CGFloat)CGPointDistance:(CGPoint)p1 p2:(CGPoint)p2{
    CGFloat dx = pow(p1.x - p2.x,2);
    CGFloat dy = pow(p1.y - p2.y,2);
    return sqrtf(dx + dy);
}

-(CGFloat)CGPointToDegree:(CGPoint)p1 p2:(CGPoint)p2{
    return atan2(p2.y - p1.y, p2.x - p1.x) * 180 / M_PI;
}

-(CGFloat)DegreesToRadians:(CGFloat)degrees{
    return ((M_PI * degrees) / 180.f);
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
