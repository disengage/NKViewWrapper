//
//  NKViewBoxLayer.m
//  Narongsak kongpan
//
//  Created by Narongsak kongpan on 1/28/2557 BE.
//  Copyright (c) 2557 Narongsak kongpan., LTD. All rights reserved.
//

#import "NKViewBoxLayer.h"
#import "NKViewBoxSticker.h"

@implementation NKViewBoxLayer
{
    CGPoint firstTouchPoint;
    CGPoint lastTouchPoint;
    CGPoint touchCenter;
    
    NKViewBoxSticker *currentSticker;
}

@synthesize customBoundRect = _customBoundRect;
@synthesize viewBoxSnapSide = _viewBoxSnapSide;
@synthesize disableOutsideView = _disableOutsideView;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.layer setBorderWidth:0];
        [self.layer setBorderColor:[UIColor redColor].CGColor];
        
        [self setDisableOutsideView:YES];
    }
    return self;
}

-(void)setContentItemToStickerLayer:(CGRect)withRect withImage:(UIImage*)image{
    currentSticker = [[NKViewBoxSticker alloc] initWithFrame:CGRectMake(0, 0, withRect.size.width, withRect.size.height)];
    [currentSticker setImage:image];
    [currentSticker setDelegate:self];
    [self addSubview:currentSticker];
    if(!CGRectEqualToRect(self.customBoundRect, CGRectZero) ) {
        [self resetToCustomRectFrame];
    }
}

-(void)onImageViewStickerRectChange:(CGRect)frame{
    CGRect transformBound = [self convertRect:frame toView:self];
    transformBound = [self convertRect:frame toView:self.superview];
    
    CGPoint newCenter = CGPointMake((transformBound.size.width / 2) + transformBound.origin.x,
                                    (transformBound.size.height / 2) + transformBound.origin.y);
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, transformBound.size.width, transformBound.size.height)];
    [self setCenter:newCenter];
    [currentSticker setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    [self _recheckDisableOutBound];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableArray *allTouches = [[[event allTouches] allObjects] mutableCopy];
    if([allTouches count] == 1){
        firstTouchPoint = [[touches anyObject] locationInView:self.superview];
        touchCenter = self.center;
        if ([self.delegate respondsToSelector:@selector(onTapViewBoxLayer:)]) {
            [self.delegate onTapViewBoxLayer:self];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(touchesBegan:withEvent:)]) {
            [self.delegate touchesBegan:touches withEvent:event];
        }
    }
}

-(void)setContentScale:(CGFloat)scale{
    [currentSticker setCGAffineTransformScale:scale];
    [self _recheckBoundaryAfterMakeFrame];
}

-(void)setContentRotate:(CGFloat)radius{
    [currentSticker setCGAffineTransformRotate:radius];
    [self _recheckBoundaryAfterMakeFrame];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableArray *allTouches = [[[event allTouches] allObjects] mutableCopy];
    if([allTouches count] == 1){
        lastTouchPoint = [[touches anyObject] locationInView:self.superview];
        CGFloat diffX = (lastTouchPoint.x - firstTouchPoint.x);
        CGFloat diffY = (lastTouchPoint.y - firstTouchPoint.y);
        CGFloat newPointX = touchCenter.x + diffX;
        CGFloat newPointY = touchCenter.y + diffY;
        [self setCenter:CGPointMake(newPointX, newPointY)];
        [self _recheckDisableOutBound];
    }else{
        if ([self.delegate respondsToSelector:@selector(touchesMoved:withEvent:)]) {
            [self.delegate touchesMoved:touches withEvent:event];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSMutableArray *allTouches = [[[event allTouches] allObjects] mutableCopy];
    if([allTouches count] == 1){
        [self _recheckBoundaryAfterMakeFrame];
    }else{
        if ([self.delegate respondsToSelector:@selector(touchesEnded:withEvent:)]) {
            [self.delegate touchesEnded:touches withEvent:event];
        }
    }
}

-(void)updateViewBox{
    [self _recheckBoundaryAfterMakeFrame];
}

-(void)_recheckDisableOutBound{
    if (self.disableOutsideView) {
        CGFloat toWidth = self.superview.frame.size.width;
        CGFloat toHeight = self.superview.frame.size.height;
        if (!CGRectEqualToRect(self.customBoundRect, CGRectZero)){
            toWidth = self.customBoundRect.size.width;
            toHeight = self.customBoundRect.size.height;
        }
        
        CGRect transformRect = [self convertRect:self.frame fromView:self.superview];
        transformRect = [self convertRect:transformRect toView:self.superview];
        
        CGFloat newX = transformRect.origin.x;
        CGFloat newY = transformRect.origin.y;
        
        CGFloat frameMinX = CGRectGetMinX(transformRect);
        CGFloat frameMaxX = CGRectGetMaxX(transformRect);
        CGFloat frameMinY = CGRectGetMinY(transformRect);
        CGFloat frameMaxY = CGRectGetMaxY(transformRect);
        CGFloat frameWidth = transformRect.size.width;
        CGFloat frameHeight = transformRect.size.height;
        
        CGRect refRect = self.superview.frame;
        if (!CGRectEqualToRect(self.customBoundRect, CGRectZero)){
            refRect = self.customBoundRect;
        }
        
        CGFloat refMinX = CGRectGetMinX(refRect);
        CGFloat refMaxX = CGRectGetMaxX(refRect);
        CGFloat refMinY = CGRectGetMinY(refRect);
        CGFloat refMaxY = CGRectGetMaxY(refRect);
        
        if(self.frame.size.width > toWidth){
            if (frameMinX > refMinX) {
                newX = refMinX;
            }
            if (frameMaxX < refMaxX) {
                newX = refMaxX - frameWidth;
            }
            if (self.frame.size.height < toHeight){
                if (frameMinY < refMinY && frameMaxY < refMaxY) {
                    newY = refMinY;
                }
                if (frameMinY > refMinY && frameMaxY > refMaxY) {
                    newY = refMaxY - frameHeight;
                }
            }else{
                if (frameMinY > refMinY){
                    newY = refMinY;
                }
                if (frameMaxY < refMaxY) {
                    newY = refMaxY - frameHeight;
                }
            }
            [self setFrame:CGRectMake(newX, newY, frameWidth, frameHeight)];
        }else{
            if (self.frame.size.height < toHeight){
                if (frameMinY > refMinY && frameMaxY > refMaxY) {
                    newY = refMaxY - frameHeight;
                }
                if (frameMinY < refMinY && frameMaxY < refMaxY) {
                    newY = refMinY;
                }
                if (frameMinX < refMinX) {
                    newX = refMinX;
                }
                if (frameMaxX > refMaxX) {
                    newX = refMaxX - frameWidth;
                }
            }else{
                if (frameMinY > refMinY && frameMaxY > refMaxY) {
                    newY = refMinY;
                }
                if (frameMinY < refMinY && frameMaxY < refMaxY) {
                    newY = refMaxY - frameHeight;
                }
                if (frameMinX < refMinX) {
                    newX = refMinX;
                }
                if (frameMaxX > refMaxX) {
                    newX = refMaxX - frameWidth;
                }
            }
            [self setFrame:CGRectMake(newX, newY, frameWidth, frameHeight)];
        }
    }
}

-(void)_recheckBoundaryAfterMakeFrame{
    NSInteger refBoxSide = 0;
    CGRect newFrame = CGRectZero;
    bool updateNewRect = YES;
    
    CGRect transformRect = [self convertRect:self.frame fromView:self.superview];
    transformRect = [self convertRect:transformRect toView:self.superview];
    
    CGFloat toLeftX = CGRectGetMinX(self.superview.frame);
    CGFloat toMiddleX = CGRectGetMidX(self.superview.frame) - (self.frame.size.width / 2);
    CGFloat toRightX = CGRectGetMaxX(self.superview.frame) - self.frame.size.width;
    CGFloat toTopY = CGRectGetMinY(self.superview.frame);
    CGFloat toMiddleY = CGRectGetMidY(self.superview.frame) - (self.frame.size.height / 2);
    CGFloat toBottomY = CGRectGetMaxY(self.superview.frame) - self.frame.size.height;
    CGFloat toWidth = self.frame.size.width;
    
    NSInteger sideRef = [self _getBoundHitTestRectGridByRefRect:transformRect referenceRect:self.superview.frame];
    if (!CGRectEqualToRect(self.customBoundRect, CGRectZero)){
        sideRef = [self _getBoundHitTestRectGridByRefRect:transformRect referenceRect:self.customBoundRect];
        
        toLeftX = CGRectGetMinX(self.customBoundRect);
        toMiddleX = CGRectGetMidX(self.customBoundRect) - (self.frame.size.width / 2);
        toRightX = CGRectGetMaxX(self.customBoundRect) - self.frame.size.width;
        toTopY = CGRectGetMinY(self.customBoundRect);
        toMiddleY = CGRectGetMidY(self.customBoundRect) - (self.frame.size.height / 2);
        toBottomY = CGRectGetMaxY(self.customBoundRect) - self.frame.size.height;
        toWidth = self.customBoundRect.size.width;
    }
    
    if (self.frame.size.width > toWidth) {
        //None
    }else{
        if (self.viewBoxSnapSide != kNKViewBoxSnapSideNone) {
            //NSLog(@"Enable Frame Snap Mode");
            switch (self.viewBoxSnapSide) {
                case kNKViewBoxSnapSideTopLeft:
                    sideRef = 2;
                    break;
                case kNKViewBoxSnapSideTopRight:
                    sideRef = 1;
                    break;
                case kNKViewBoxSnapSideBottomLeft:
                    sideRef = 4;
                    break;
                case kNKViewBoxSnapSideBottomRight:
                    sideRef = 8;
                    break;
                case kNKViewBoxSnapSideAuto:
                {
                    refBoxSide = [self _getOutsideHitTestRectGridByRefRect:self.frame referenceRect:self.superview.frame];
                    //NSLog(@"View Box Snap Auto : %li", refBoxSide);
                    switch (refBoxSide) {
                        case 0://Bottom Left
                            sideRef = 4;
                            break;
                        case 1://Top Left
                            sideRef = 2;
                            break;
                        case 2://Bottom Right
                            sideRef = 8;
                            break;
                        case 3://Top Right
                            sideRef = 1;
                            break;
                    }
                }
                    break;
                default:
                    //kNKViewBoxSnapSideNone
                    break;
            }
            
            if (sideRef == 0) {//OutSide
                
                NSInteger outSideRef = [self _getOutsideHitTestRectGridByRefRect:transformRect referenceRect:self.customBoundRect];
                //NSLog(@"View Box Out Side : %li", outSideRef);
                switch (outSideRef) {
                    case 0://Top Left
                        sideRef = 2;
                        break;
                    case 1://Bottom Left
                        sideRef = 4;
                        break;
                    case 2://Top Right
                        sideRef = 1;
                        break;
                    case 3://Bottom Right
                        sideRef = 8;
                        break;
                }
            }
            
            //NSLog(@"View Box Snap Side : %li", sideRef);
            switch (sideRef) {
                case 2://TopLeft
                    newFrame = CGRectMake(toLeftX, toTopY, self.frame.size.width, self.frame.size.height);
                    break;
                case 3://TopMiddle
                    newFrame = CGRectMake(toMiddleX, toTopY, self.frame.size.width, self.frame.size.height);
                    break;
                case 1://TopRight
                    newFrame = CGRectMake(toRightX, toTopY, self.frame.size.width, self.frame.size.height);
                    break;
                case 9://Right
                    newFrame = CGRectMake(toRightX, toMiddleY, self.frame.size.width, self.frame.size.height);
                    break;
                case 8://BottomRight
                    newFrame = CGRectMake(toRightX, toBottomY, self.frame.size.width, self.frame.size.height);
                    break;
                case 12://BottomMiddle
                    newFrame = CGRectMake(toMiddleX, toBottomY, self.frame.size.width, self.frame.size.height);
                    break;
                case 4://BottomLeft
                    newFrame = CGRectMake(toLeftX, toBottomY, self.frame.size.width, self.frame.size.height);
                    break;
                case 6://Left
                    newFrame = CGRectMake(toLeftX, toMiddleY, self.frame.size.width, self.frame.size.height);
                    break;
                case 15://Inside
                    updateNewRect = NO;
                    //None
                    break;
            }
        }else{
            //NSLog(@"Disable Frame Snap Mode");
            updateNewRect = NO;
            
            bool updateOutside = NO;
            CGFloat toWidth = self.frame.size.width;
            CGFloat toHeight = self.frame.size.height;
            if (!CGRectEqualToRect(self.customBoundRect, CGRectZero)){
                toWidth = self.customBoundRect.size.width;
                toHeight = self.customBoundRect.size.height;
            }
            
            if(self.frame.size.width < toWidth && self.frame.size.height < toHeight){
                updateOutside = YES;
            }
            
            if (self.disableOutsideView && updateOutside) {
                updateNewRect = YES;
                transformRect = [self convertRect:self.frame fromView:self.superview];
                transformRect = [self convertRect:transformRect toView:self.superview];
                NSInteger sideRef = [self _getBoundHitTestRectGridByRefRect:transformRect referenceRect:self.superview.frame];
                if (!CGRectEqualToRect(self.customBoundRect, CGRectZero)){
                    sideRef = [self _getBoundHitTestRectGridByRefRect:transformRect referenceRect:self.customBoundRect];
                }
                //NSLog(@"Disable Outside Mode : %li",sideRef);
                
                if (sideRef == 0) {
                    
                    CGFloat newX = self.frame.origin.x;
                    newX = (newX < toLeftX) ? toLeftX : newX;
                    newX = (newX > toRightX) ? toRightX : newX;
                    
                    CGFloat newY = self.frame.origin.y;
                    newY = (newY < toTopY) ? toTopY : newY;
                    newY = (newY > toBottomY) ? toBottomY : newY;
                    
                    NSInteger outsideRef = [self _getOutsideHitTestRectGridByRefRect:transformRect referenceRect:self.customBoundRect];
                    //NSLog(@"Outside Mode : %li",outsideRef);
                    switch (outsideRef) {
                        case 1:
                            sideRef = 2;
                            break;
                        case 2: case 3:
                            newFrame = CGRectMake(newX, toTopY, self.frame.size.width, self.frame.size.height);
                            break;
                        case 4:
                            sideRef = 1;
                            break;
                        case 5: case 6:
                            newFrame = CGRectMake(toRightX, newY, self.frame.size.width, self.frame.size.height);
                            break;
                        case 7:
                            sideRef = 8;
                            break;
                        case 8: case 9:
                            newFrame = CGRectMake(newX, toBottomY, self.frame.size.width, self.frame.size.height);
                            break;
                        case 10:
                            sideRef = 4;
                            break;
                        case 11: case 12:
                            newFrame = CGRectMake(toLeftX, newY, self.frame.size.width, self.frame.size.height);
                            break;
                        case 0:
                            updateNewRect = NO;
                            break;
                    }
                }
                
                switch (sideRef) {
                    case 2://TopLeft
                        newFrame = CGRectMake(toLeftX, toTopY, self.frame.size.width, self.frame.size.height);
                        break;
                    case 3://TopMiddle
                        newFrame = CGRectMake(self.frame.origin.x, toTopY, self.frame.size.width, self.frame.size.height);
                        break;
                    case 1://TopRight
                        newFrame = CGRectMake(toRightX, toTopY, self.frame.size.width, self.frame.size.height);
                        break;
                    case 9://Right
                        newFrame = CGRectMake(toRightX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                        break;
                    case 8://BottomRight
                        newFrame = CGRectMake(toRightX, toBottomY, self.frame.size.width, self.frame.size.height);
                        break;
                    case 12://BottomMiddle
                        newFrame = CGRectMake(self.frame.origin.x, toBottomY, self.frame.size.width, self.frame.size.height);
                        break;
                    case 4://BottomLeft
                        newFrame = CGRectMake(toLeftX, toBottomY, self.frame.size.width, self.frame.size.height);
                        break;
                    case 6://Left
                        newFrame = CGRectMake(toLeftX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                        break;
                    case 15:
                        updateNewRect = NO;
                        break;
                }
                
                
            }
        }
        if (updateNewRect) {
            //NSLog(@"Update New Frame");
            self.frame = newFrame;
        }
    }
}

-(void)resetToCustomRectFrame{
    CGFloat newX = self.frame.origin.x;
    CGFloat newY = self.frame.origin.y;
    if (newX < CGRectGetMinX(self.customBoundRect)){
        newX = CGRectGetMinX(self.customBoundRect);
    }
    if (newX > CGRectGetMaxX(self.customBoundRect)){
        newX = CGRectGetMaxX(self.customBoundRect) - self.frame.size.width;
    }
    if (newY < CGRectGetMinY(self.customBoundRect)){
        newY = CGRectGetMinY(self.customBoundRect);
    }
    if (newY > CGRectGetMaxY(self.customBoundRect)){
        newY = CGRectGetMaxY(self.customBoundRect) - self.frame.size.height;
    }
    [self setFrame:CGRectMake(newX, newY, self.frame.size.width, self.frame.size.height)];
}

-(NSInteger)_getBoundHitTestRectGridByRefRect:(CGRect)testRect referenceRect:(CGRect)refRect{
    CGPoint topLeft = CGPointMake(CGRectGetMinX(testRect),CGRectGetMinY(testRect));
    CGPoint topRight = CGPointMake(CGRectGetMaxX(testRect), CGRectGetMinY(testRect));
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(testRect),CGRectGetMaxY(testRect));
    CGPoint bottomLeft = CGPointMake(CGRectGetMinX(testRect),CGRectGetMaxY(testRect));
    int topLeftBit = 0, topRightBit = 0, bottomRightBit = 0, bottomLeftBit = 0;
    if (CGRectContainsPoint(refRect, topLeft)) {topLeftBit = 1;}
    if (CGRectContainsPoint(refRect, topRight)) {topRightBit = 1;}
    if (CGRectContainsPoint(refRect, bottomRight)) {bottomRightBit = 1;}
    if (CGRectContainsPoint(refRect, bottomLeft)) {bottomLeftBit = 1;}
    return [self binaryStringToInt:[NSString stringWithFormat:@"%i%i%i%i",topLeftBit,topRightBit,bottomRightBit,bottomLeftBit]];
}

-(NSInteger)_getOutsideHitTestRectGridByRefRect:(CGRect)testRect referenceRect:(CGRect)refRect{
    CGPoint testCenter = CGPointMake(CGRectGetMidX(testRect), CGRectGetMidY(testRect));
    CGPoint refCenter = CGPointMake(CGRectGetMidX(refRect), CGRectGetMidY(refRect));
    int QuardX = 0, QuardY = 0;
    if (testCenter.x < refCenter.x) {QuardX = 0;}
    if (testCenter.x > refCenter.x) {QuardX = 1;}
    if (testCenter.y < refCenter.y) {QuardY = 1;}
    if (testCenter.y > refCenter.y) {QuardY = 0;}
    NSInteger detectSide = [self binaryStringToInt:[NSString stringWithFormat:@"%i%i", QuardX, QuardY]];
    
    CGPoint topLeft = CGPointMake(CGRectGetMinX(refRect),CGRectGetMinY(refRect));
    CGPoint topRight = CGPointMake(CGRectGetMaxX(refRect), CGRectGetMinY(refRect));
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(refRect),CGRectGetMaxY(refRect));
    CGPoint bottomLeft = CGPointMake(CGRectGetMinX(refRect),CGRectGetMaxY(refRect));
    NSInteger sideRef = 0;
    
    switch (detectSide) {
        case 1:
        {
            sideRef = [self _getOutsideHitTestPointGridByRefPoint:testCenter referenceRect:topLeft];
            switch (sideRef) {
                case 1:return 1; break;
                case 3:return 2; break;
                case 0:return 12; break;
                case 2:break;
            }
        }
            break;
        case 3:
            sideRef = [self _getOutsideHitTestPointGridByRefPoint:testCenter referenceRect:topRight];
            switch (sideRef) {
                case 1:return 3; break;
                case 3:return 4; break;
                case 0:break;
                case 2:return 5; break;
            }
            break;
        case 2:
            sideRef = [self _getOutsideHitTestPointGridByRefPoint:testCenter referenceRect:bottomRight];
            switch (sideRef) {
                case 1:break;
                case 3:return 6; break;
                case 0:return 8; break;
                case 2:return 7; break;
            }
            break;
        case 0:
            sideRef = [self _getOutsideHitTestPointGridByRefPoint:testCenter referenceRect:bottomLeft];
            switch (sideRef) {
                case 1:return 11; break;
                case 3:break;
                case 0:return 10; break;
                case 2:return 9; break;
            }
            break;
    }
    return 0;
}

-(NSInteger)_getOutsideHitTestPointGridByRefPoint:(CGPoint)testPoint referenceRect:(CGPoint)refPoint{
    int QuardX = 0, QuardY = 0;
    if (testPoint.x < refPoint.x) {QuardX = 0;}
    if (testPoint.x > refPoint.x) {QuardX = 1;}
    if (testPoint.y < refPoint.y) {QuardY = 1;}
    if (testPoint.y > refPoint.y) {QuardY = 0;}
    return [self binaryStringToInt:[NSString stringWithFormat:@"%i%i", QuardX, QuardY]];
}

-(int)binaryStringToInt:(NSString*)binaryString{
    unichar aChar;
    int value = 0;
    int index;
    for (index = 0; index<[binaryString length]; index++){
        aChar = [binaryString characterAtIndex: index];
        if (aChar == '1'){value += 1;}
        if (index+1 < [binaryString length]){value = value<<1;}
    }
    return value;
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
