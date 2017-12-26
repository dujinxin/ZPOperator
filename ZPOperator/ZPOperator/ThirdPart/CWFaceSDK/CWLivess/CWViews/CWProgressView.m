//
//  PICircularProgressView.m
//  PICircularProgressView
//
//  Created by DengWuPing on 15/7/17.
//  Copyright (c) 2015年 dengwuping. All rights reserved.
//

#import "CWProgressView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation CWProgressView

+ (void)initialize{
    if (self == [CWProgressView class]){
        id appearance = [self appearance];
        
        [appearance setShowText:YES];
        
        [appearance setRoundedHead:YES];
        
        [appearance setShowShadow:YES];
        
        [appearance setThicknessRatio:0.15f];
        
        [appearance setOuterBackgroundColor:[UIColor colorWithRed:60.0/255.f green:61.0/255.0 blue:71.0/255.0 alpha:1.0]];
        
        [appearance setTextColor:[UIColor whiteColor]];
        
        [appearance setFont:[UIFont boldSystemFontOfSize:18.f]];
        
        [appearance setProgressFillColor:nil];
        
        [appearance setProgressTopGradientColor:[UIColor colorWithRed:154.0/255.f green:199.0/255.0 blue:155.0/255.0 alpha:1.0]];
        
        [appearance setProgressBottomGradientColor:[UIColor colorWithRed:154.0/255.f green:199.0/255.0 blue:155.0/255.0 alpha:1.0]];
        
        [appearance setBackgroundColor:[UIColor clearColor]];
    }
}

- (id)init{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    return self;
}

#pragma mark - Drawin
- (void)drawRect:(CGRect)rect{
    // Calculate position of the circle
    CGFloat progressAngle = _progress * 360.0 - 90;
    CGPoint center = CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f);
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2.0f;
    
    CGRect square;
    if (rect.size.width > rect.size.height){
        square = CGRectMake((rect.size.width - rect.size.height) / 2.0, 0.0, rect.size.height, rect.size.height);
    }
    else{
        square = CGRectMake(0.0, (rect.size.height - rect.size.width) / 2.0, rect.size.width, rect.size.width);
    }
    
    CGFloat circleWidth = radius * _thicknessRatio;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    if (_innerBackgroundColor){
        // Fill innerCircle with innerBackgroundColor
        UIBezierPath *innerCircle = [UIBezierPath bezierPathWithArcCenter:center radius:radius - circleWidth startAngle:2*M_PI endAngle:0.0 clockwise:YES];
        [_innerBackgroundColor setFill];
        
        [innerCircle fill];
    }
    if (_outerBackgroundColor){
        // Fill outerCircle with outerBackgroundColor
        UIBezierPath *outerCircle = [UIBezierPath bezierPathWithArcCenter:center radius:radius - circleWidth startAngle:0.0 endAngle:2*M_PI                   clockwise:NO];
        
        [outerCircle addArcWithCenter:center  radius:radius - circleWidth startAngle:2*M_PI endAngle:0.0  clockwise:YES];
        [_outerBackgroundColor setFill];
        
        [outerCircle fill];
    }
    if (_showShadow){
        // Draw shadows
        CGFloat locations[5] = { 0.0f, 0.33f, 0.66f, 1.0f };
        
        NSArray *gradientColors = @[(id)[[UIColor colorWithWhite:0.3 alpha:0.5] CGColor],(id)[[UIColor colorWithWhite:0.9 alpha:0.0] CGColor],(id)[[UIColor colorWithWhite:0.9 alpha:0.0] CGColor],(id)[[UIColor colorWithWhite:0.3 alpha:0.5] CGColor],];
        
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)gradientColors, locations);
        CGContextDrawRadialGradient(context, gradient, center, radius - circleWidth, center, radius, 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(rgb);
    }
    
    if (_showText && _textColor){
        
        NSString *progressString = [NSString stringWithFormat:@"%lu", (long )_progressText];
        
        CGFloat fontSize = radius;
        
        UIFont *font = [_font fontWithSize:fontSize];
                
        CGSize expectedSize = CGSizeZero;
#ifdef __IPHONE_7_0
        expectedSize = [progressString sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,[NSNumber numberWithInt:1],NSBaselineOffsetAttributeName, nil]];
#else
        expectedSize = [progressString sizeWithFont:font minFontSize:5.0  actualFontSize:&actualFontSize forWidth:maximumSize.width lineBreakMode:NSLineBreakByWordWrapping];
#endif
        
        CGPoint origin = CGPointMake(center.x - expectedSize.width / 2.0, center.y - expectedSize.height / 2.0);
        
        [_textColor setFill];
        
#ifdef __IPHONE_7_0
        [progressString drawAtPoint:origin withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,[NSNumber numberWithInt:1],NSBaselineOffsetAttributeName,_textColor,NSForegroundColorAttributeName, nil]];
#else
       [progressString drawAtPoint:origin forWidth:expectedSize.width withFont:font lineBreakMode:NSLineBreakByWordWrapping];
#endif

    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:radius  startAngle:DEGREES_TO_RADIANS(-90) endAngle:DEGREES_TO_RADIANS(progressAngle)  clockwise:YES]];
    
    if (_roundedHead){
        CGPoint point;
        point.x = (cos(DEGREES_TO_RADIANS(progressAngle)) * (radius - circleWidth/2)) + center.x;
        point.y = (sin(DEGREES_TO_RADIANS(progressAngle)) * (radius - circleWidth/2)) + center.y;
        
        [path addArcWithCenter:point  radius:circleWidth/2 startAngle:DEGREES_TO_RADIANS(progressAngle) endAngle:DEGREES_TO_RADIANS(270.0 + progressAngle - 90.0)clockwise:YES];
    }
    [path addArcWithCenter:center radius:radius-circleWidth startAngle:DEGREES_TO_RADIANS(progressAngle) endAngle:DEGREES_TO_RADIANS(-90) clockwise:NO];
    
    if (_roundedHead){
        CGPoint point;
        point.x = (cos(DEGREES_TO_RADIANS(-90)) * (radius - circleWidth/2)) + center.x;
        point.y = (sin(DEGREES_TO_RADIANS(-90)) * (radius - circleWidth/2)) + center.y;
        
        [path addArcWithCenter:point  radius:circleWidth/2 startAngle:DEGREES_TO_RADIANS(90) endAngle:DEGREES_TO_RADIANS(-90) clockwise:NO];
    }
    [path closePath];
    if (_progressFillColor){
        [_progressFillColor setFill];
        [path fill];
    }
    else if (_progressTopGradientColor && _progressBottomGradientColor){
        [path addClip];
        
        NSArray *backgroundColors = @[(id)[_progressTopGradientColor CGColor],(id)[_progressBottomGradientColor CGColor],];
        
        CGFloat backgroudColorLocations[2] = { 0.0f, 1.0f };
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGGradientRef backgroundGradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)(backgroundColors), backgroudColorLocations);
        CGContextDrawLinearGradient(context, backgroundGradient, CGPointMake(0.0f, square.origin.y), CGPointMake(0.0f, square.size.height), 0);
        CGGradientRelease(backgroundGradient);
        CGColorSpaceRelease(rgb);
    }
    CGContextRestoreGState(context);
}

-(void)setProgressText:(NSInteger)progressText{
    _progressText = progressText;
    [self setNeedsDisplay];
}

#pragma mark - Setter
- (void)setProgress:(double)progress{
    _progress = MIN(1.0, MAX(0.0, progress));
    [self setNeedsDisplay];
}

#pragma mark - UIAppearance

- (void)setShowText:(NSInteger)showText{
    _showText = showText;
    [self setNeedsDisplay];
}

- (void)setRoundedHead:(NSInteger)roundedHead
{
    _roundedHead = roundedHead;
    [self setNeedsDisplay];
}

- (void)setShowShadow:(NSInteger)showShadow
{
    _showShadow = showShadow;
    [self setNeedsDisplay];
}

- (void)setThicknessRatio:(CGFloat)thickness
{
    _thicknessRatio = MIN(MAX(0.0f, thickness), 1.0f);
    [self setNeedsDisplay];
}

- (void)setInnerBackgroundColor:(UIColor *)innerBackgroundColor
{
    _innerBackgroundColor = innerBackgroundColor;    
    [self setNeedsDisplay];
}

- (void)setOuterBackgroundColor:(UIColor *)outerBackgroundColor
{
    _outerBackgroundColor = outerBackgroundColor;    
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;    
    [self setNeedsDisplay];
}

- (void)setProgressFillColor:(UIColor *)progressFillColor
{
    _progressFillColor = progressFillColor;
    [self setNeedsDisplay];
}

- (void)setProgressTopGradientColor:(UIColor *)progressTopGradientColor
{
    _progressTopGradientColor = progressTopGradientColor;
    [self setNeedsDisplay];
}

- (void)setProgressBottomGradientColor:(UIColor *)progressBottomGradientColor
{
    _progressBottomGradientColor = progressBottomGradientColor;
    [self setNeedsDisplay];
}

@end
