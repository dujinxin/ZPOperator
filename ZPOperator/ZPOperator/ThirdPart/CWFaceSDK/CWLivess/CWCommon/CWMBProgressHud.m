//
//  CWCWMBProgressHud.m
//  CloudwalkFaceSDKDemo
//
//  Created by DengWuPing on 16/7/14.
//  Copyright © 2016年 DengWuPing. All rights reserved.
//

#import "CWMBProgressHud.h"

#import <tgmath.h>

#if __has_feature(objc_arc)
#define CWMB_AUTORELEASE(exp) exp
#define CWMB_RELEASE(exp) exp
#define CWMB_RETAIN(exp) exp
#else
#define CWMB_AUTORELEASE(exp) [exp autorelease]
#define CWMB_RELEASE(exp) [exp release]
#define CWMB_RETAIN(exp) [exp retain]
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
#define CWMBLabelAlignmentCenter NSTextAlignmentCenter
#else
#define CWMBLabelAlignmentCenter UITextAlignmentCenter
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define CWMB_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
#define CWMB_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define CWMB_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
#define CWMB_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
#endif

static const CGFloat kPadding = 4.f;
static const CGFloat kLabelFontSize = 16.f;
static const CGFloat Kmargin = 20.f;

@interface CWProgressHud() {
    BOOL useAnimation;
    SEL methodForExecution;
    id targetForExecution;
    id objectForExecution;
    UILabel *label;
    BOOL isFinished;
    CGAffineTransform rotationTransform;
}
@property (atomic, CWMB_STRONG) UIView *indicator;
@end

@interface CWMBRoundProgressView : UIView

@property (nonatomic, assign) float progress;


@property (nonatomic, CWMB_STRONG) UIColor *progressTintColor;

@property (nonatomic, CWMB_STRONG) UIColor *backgroundTintColor;

@property (nonatomic, assign, getter = isAnnular) BOOL annular;

@end

@interface CWMBBarProgressView : UIView

@property (nonatomic, assign) float progress;

@property (nonatomic, CWMB_STRONG) UIColor *lineColor;

@property (nonatomic, CWMB_STRONG) UIColor *progressRemainingColor;

@property (nonatomic, CWMB_STRONG) UIColor *progressColor;

@end

@implementation CWProgressHud

#pragma mark - Properties

@synthesize animationType;
@synthesize opacity;
@synthesize color;
@synthesize labelFont;
@synthesize labelColor;
@synthesize indicator;
@synthesize square;
@synthesize taskInProgress;
@synthesize customView;
@synthesize mode;
@synthesize labelText;
@synthesize size;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Set default values for properties
        self.animationType = CWMBProgressHudAnimationFade;
        self.mode = CWMBProgressHudModeIndeterminate;
        self.labelText = nil;
        self.opacity = 0.8f;
        self.color = nil;
        self.labelFont = [UIFont boldSystemFontOfSize:kLabelFontSize];
        self.labelColor = [UIColor whiteColor];
        
        self.cornerRadius = 10.0f;
        self.square = NO;
        self.contentMode = UIViewContentModeCenter;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
								| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        // Transparent background
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        // Make it invisible for now
        self.alpha = 0.0f;
        
        taskInProgress = NO;
        rotationTransform = CGAffineTransformIdentity;
        
        [self setupLabels];
        [self updateIndicators];
        [self registerForKVO];
        [self registerForNotifications];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}

- (id)initWithWindow:(UIWindow *)window {
    return [self initWithView:window];
}

- (void)dealloc {
    [self unregisterFromNotifications];
    [self unregisterFromKVO];
#if !__has_feature(objc_arc)
    [color release];
    [indicator release];
    [label release];
    [labelText release];
    [customView release];
    [labelFont release];
    [labelColor release];
#if NS_BLOCKS_AVAILABLE
    [completionBlock release];
#endif
    [super dealloc];
#endif
}

#pragma mark - Show & hide

- (void)show:(BOOL)animated {
    NSAssert([NSThread isMainThread], @"CWMBProgressHud needs to be accessed on the main thread.");
    useAnimation = animated;
    
    [self showUsingAnimation:useAnimation];
    
}

- (void)hide:(BOOL)animated {
    NSAssert([NSThread isMainThread], @"CWMBProgressHud needs to be accessed on the main thread.");
    useAnimation = animated;
    
    [self hideUsingAnimation:useAnimation];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(hideDelayed:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

- (void)hideDelayed:(NSNumber *)animated {
    [self hide:[animated boolValue]];
}

#pragma mark - View Hierrarchy

- (void)didMoveToSuperview {
    [self updateForCurrentOrientationAnimated:NO];
}

#pragma mark - Internal show & hide operations

- (void)showUsingAnimation:(BOOL)animated {
    // Cancel any scheduled hideDelayed: calls
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setNeedsDisplay];
    
    if (animated && animationType == CWMBProgressHudAnimationZoomIn) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
    } else if (animated && animationType == CWMBProgressHudAnimationZoomOut) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
    }
    // Fade in
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        self.alpha = 1.0f;
        if (animationType == CWMBProgressHudAnimationZoomIn || animationType == CWMBProgressHudAnimationZoomOut) {
            self.transform = rotationTransform;
        }
        [UIView commitAnimations];
    }
    else {
        self.alpha = 1.0f;
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    // Fade out
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        // in the done method
        if (animationType == CWMBProgressHudAnimationZoomIn) {
            self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
        } else if (animationType == CWMBProgressHudAnimationZoomOut) {
            self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
        }
        
        self.alpha = 0.02f;
        [UIView commitAnimations];
    }
    else {
        self.alpha = 0.0f;
        [self done];
    }
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    [self done];
}

- (void)done {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    isFinished = YES;
    self.alpha = 0.0f;
}

#pragma mark - Threading

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated {
    methodForExecution = method;
    targetForExecution = CWMB_RETAIN(target);
    objectForExecution = CWMB_RETAIN(object);
    // Launch execution in new thread
    self.taskInProgress = YES;
    [NSThread detachNewThreadSelector:@selector(launchExecution) toTarget:self withObject:nil];
    // Show HUD view
    [self show:animated];
}

- (void)launchExecution {
    @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // Start executing the requested task
        [targetForExecution performSelector:methodForExecution withObject:objectForExecution];
#pragma clang diagnostic pop
        [self performSelectorOnMainThread:@selector(cleanUp) withObject:nil waitUntilDone:NO];
    }
}

- (void)cleanUp {
    taskInProgress = NO;
#if !__has_feature(objc_arc)
    [targetForExecution release];
    [objectForExecution release];
#else
    targetForExecution = nil;
    objectForExecution = nil;
#endif
    [self hide:useAnimation];
}

#pragma mark - UI

- (void)setupLabels {
    label = [[UILabel alloc] initWithFrame:self.bounds];
    label.adjustsFontSizeToFitWidth = NO;
    label.textAlignment = CWMBLabelAlignmentCenter;
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.labelColor;
    label.font = self.labelFont;
    label.text = self.labelText;
    [self addSubview:label];
}

- (void)updateIndicators {
    
    BOOL isActivityIndicator = [indicator isKindOfClass:[UIActivityIndicatorView class]];
    BOOL isRoundIndicator = [indicator isKindOfClass:[CWMBRoundProgressView class]];
    
    if (mode == CWMBProgressHudModeIndeterminate) {
        if (!isActivityIndicator) {
            // Update to indeterminate indicator
            [indicator removeFromSuperview];
            self.indicator = CWMB_AUTORELEASE([[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]);
            [(UIActivityIndicatorView *)indicator startAnimating];
            [self addSubview:indicator];
        }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
        [(UIActivityIndicatorView *)indicator setColor:[UIColor whiteColor]];
#endif
    }
    else if (mode == CWMBProgressHudModeDeterminateHorizontalBar) {
        // Update to bar determinate indicator
        [indicator removeFromSuperview];
        self.indicator = CWMB_AUTORELEASE([[CWMBBarProgressView alloc] init]);
        [self addSubview:indicator];
    }
    else if (mode == CWMBProgressHudModeDeterminate || mode == CWMBProgressHudModeAnnularDeterminate) {
        if (!isRoundIndicator) {
            // Update to determinante indicator
            [indicator removeFromSuperview];
            self.indicator = CWMB_AUTORELEASE([[CWMBRoundProgressView alloc] init]);
            [self addSubview:indicator];
        }
        if (mode == CWMBProgressHudModeAnnularDeterminate) {
            [(CWMBRoundProgressView *)indicator setAnnular:YES];
        }
        [(CWMBRoundProgressView *)indicator setProgressTintColor:[UIColor whiteColor]];
        [(CWMBRoundProgressView *)indicator setBackgroundTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.1f]];
    }
    else if (mode == CWMBProgressHudModeCustomView && customView != indicator) {
        // Update custom view indicator
        [indicator removeFromSuperview];
        self.indicator = customView;
        [self addSubview:indicator];
    } else if (mode == CWMBProgressHudModeText) {
        [indicator removeFromSuperview];
        self.indicator = nil;
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Entirely cover the parent view
    UIView *parent = self.superview;
    if (parent) {
        self.frame = parent.bounds;
    }
    CGRect bounds = self.bounds;
    
    // Determine the total widt and height needed
    CGFloat maxWidth = bounds.size.width - 4 * Kmargin;
    CGSize totalSize = CGSizeZero;
    
    CGRect indicatorF = indicator.bounds;
    indicatorF.size.width = MIN(indicatorF.size.width, maxWidth);
    totalSize.width = MAX(totalSize.width, indicatorF.size.width);
    totalSize.height += indicatorF.size.height;
    
    CGSize labelSize = CWMB_TEXTSIZE(label.text, label.font);
    labelSize.width = MIN(labelSize.width, maxWidth);
    totalSize.width = MAX(totalSize.width, labelSize.width);
    totalSize.height += labelSize.height;
    if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
        totalSize.height += kPadding;
    }
    
    totalSize.width = totalSize.width +kPadding;
    
    totalSize.width += 2 * Kmargin;
    totalSize.height += 2 * Kmargin;
    
    // Position elements
    CGFloat yPos = round(((bounds.size.height - totalSize.height) / 2)) + Kmargin ;
    
    indicatorF.origin.y = yPos;
    indicatorF.origin.x = round((bounds.size.width - indicatorF.size.width) / 2) ;
    indicator.frame = indicatorF;
    yPos += indicatorF.size.height;
    
    if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
        yPos += kPadding;
    }
    CGRect labelF;
    labelF.origin.y = yPos;
    labelF.origin.x = round((bounds.size.width - labelSize.width) / 2) ;
    labelF.size = labelSize;
    label.frame = labelF;
    // Enforce minsize and quare rules
    if (square) {
        CGFloat max = MAX(totalSize.width, totalSize.height);
        if (max <= bounds.size.width - 2 * Kmargin) {
            totalSize.width = max;
        }
        if (max <= bounds.size.height - 2 * Kmargin) {
            totalSize.height = max;
        }
    }
    if (totalSize.width <0) {
        totalSize.width =0;
    }
    if (totalSize.height < 0) {
        totalSize.height = 0;
    }
    
    size = totalSize;
}

#pragma mark BG Drawing

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    if (self.color) {
        CGContextSetFillColorWithColor(context, self.color.CGColor);
    } else {
        CGContextSetGrayFillColor(context, 0.0f, self.opacity);
    }
    CGRect allRect = self.bounds;
    // Draw rounded HUD backgroud rect
    CGRect boxRect = CGRectMake(round((allRect.size.width - size.width) / 2), round((allRect.size.height - size.height) / 2) , size.width, size.height);
    float radius = self.cornerRadius;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIGraphicsPopContext();
}

#pragma mark - KVO

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"mode", @"customView", @"labelText", @"labelFont", @"labelColor",
            nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    } else {
        [self updateUIForKeypath:keyPath];
    }
}

- (void)updateUIForKeypath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"mode"] || [keyPath isEqualToString:@"customView"] ) {
        [self updateIndicators];
    } else if ([keyPath isEqualToString:@"labelText"]) {
        label.text = self.labelText;
    } else if ([keyPath isEqualToString:@"labelFont"]) {
        label.font = self.labelFont;
    } else if ([keyPath isEqualToString:@"labelColor"]) {
        label.textColor = self.labelColor;
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)registerForNotifications {
#if !TARGET_OS_TV
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(statusBarOrientationDidChange:)
               name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
#endif
}

- (void)unregisterFromNotifications {
#if !TARGET_OS_TV
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
#endif
}

#if !TARGET_OS_TV
- (void)statusBarOrientationDidChange:(NSNotification *)notification {
    UIView *superview = self.superview;
    if (!superview) {
        return;
    } else {
        [self updateForCurrentOrientationAnimated:YES];
    }
}
#endif

- (void)updateForCurrentOrientationAnimated:(BOOL)animated {
    // Stay in sync with the superview in any case
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    // Only needed pre iOS 7 when added to a window
    BOOL iOS8OrLater = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0;
    if (iOS8OrLater || ![self.superview isKindOfClass:[UIWindow class]]) return;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat radians = 0;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
        else { radians = (CGFloat)M_PI_2; }
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
        else { radians = 0; }
    }
    rotationTransform = CGAffineTransformMakeRotation(radians);
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
    }
    [self setTransform:rotationTransform];
    if (animated) {
        [UIView commitAnimations];
    }
#endif
}

@end


@implementation CWMBRoundProgressView

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _progress = 0.f;
        _annular = NO;
        _progressTintColor = [[UIColor alloc] initWithWhite:1.f alpha:1.f];
        _backgroundTintColor = [[UIColor alloc] initWithWhite:1.f alpha:.1f];
    }
    return self;
}

- (void)dealloc {
#if !__has_feature(objc_arc)
    [_progressTintColor release];
    [_backgroundTintColor release];
    [super dealloc];
#endif
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_annular) {
        // Draw background
        BOOL isPreiOS7 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
        CGFloat lineWidth = isPreiOS7 ? 5.f : 2.f;
        UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
        processBackgroundPath.lineWidth = lineWidth;
        processBackgroundPath.lineCapStyle = kCGLineCapButt;
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        CGFloat radius = (self.bounds.size.width - lineWidth)/2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (2 * (float)M_PI) + startAngle;
        [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_backgroundTintColor set];
        [processBackgroundPath stroke];
        // Draw progress
        UIBezierPath *processPath = [UIBezierPath bezierPath];
        processPath.lineCapStyle = isPreiOS7 ? kCGLineCapRound : kCGLineCapSquare;
        processPath.lineWidth = lineWidth;
        endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressTintColor set];
        [processPath stroke];
    } else {
        // Draw background
        [_progressTintColor setStroke];
        [_backgroundTintColor setFill];
        CGContextSetLineWidth(context, 2.0f);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        // Draw progress
        CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
        CGFloat radius = (allRect.size.width - 4) / 2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [_progressTintColor setFill];
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}

@end


@implementation CWMBBarProgressView

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(.0f, .0f, 120.0f, 20.0f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _progress = 0.f;
        _lineColor = [UIColor whiteColor];
        _progressColor = [UIColor whiteColor];
        _progressRemainingColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (void)dealloc {
#if !__has_feature(objc_arc)
    [_lineColor release];
    [_progressColor release];
    [_progressRemainingColor release];
    [super dealloc];
#endif
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context,[_lineColor CGColor]);
    CGContextSetFillColorWithColor(context, [_progressRemainingColor CGColor]);
    
    // Draw background
    float radius = (rect.size.height / 2) - 2;
    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
    CGContextFillPath(context);
    
    // Draw border
    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [_progressColor CGColor]);
    radius = radius - 2;
    float amount = self.progress * rect.size.width;
    
    // Progress in the middle area
    if (amount >= radius + 4 && amount <= (rect.size.width - radius - 4)) {
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, amount, 4);
        CGContextAddLineToPoint(context, amount, radius + 4);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, amount, rect.size.height - 4);
        CGContextAddLineToPoint(context, amount, radius + 4);
        
        CGContextFillPath(context);
    }
    
    // Progress in the right arc
    else if (amount > radius + 4) {
        float x = amount - (rect.size.width - radius - 4);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - 4, 4);
        float angle = -acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width - radius - 4, rect.size.height/2, radius, M_PI, angle, 0);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - 4, rect.size.height - 4);
        angle = acos(x/radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(context, rect.size.width - radius - 4, rect.size.height/2, radius, -M_PI, angle, 1);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextFillPath(context);
    }
    
    // Progress is in the left arc
    else if (amount < radius + 4 && amount > 0) {
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
        
        CGContextFillPath(context);
    }
}

@end


@implementation CWMBProgressHud

+ (instancetype)sharedClient{
    static CWMBProgressHud *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CWMBProgressHud alloc]initSingle];
        
    });
    return _sharedClient;
}

-(id)initSingle{
    
    self = [super init];
    
    if(self){
        
    }
    return self;
}

-(id)init{
    return [self initSingle];
}

#pragma mark
#pragma mark showHudModel //显示提示信息
-(void)showHudModel:(BOOL)isSuccess message:(NSString *)message  hudMode:(CWMBProgressHudMode)hudeMode{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showHudWithView:[[UIApplication sharedApplication] keyWindow] message:message hudMode:hudeMode isSuccess:isSuccess];
        
        [hud show:YES];
        
    });
}

#pragma mark
#pragma mark showHudModel //显示提示信息
-(void)showHudWithView:(UIView *)view isSuccess:(BOOL)isSuccess message:(NSString *)message  hudMode:(CWMBProgressHudMode)hudeMode isRotate:(float)rotateDegree{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showHudWithView:view message:message hudMode:hudeMode isSuccess:isSuccess];
        
        hud.transform = CGAffineTransformMakeRotation(rotateDegree);
        
        [hud show:YES];
        
    });
}

-(void)showHudWithView:(UIView *)view message:(NSString *)message  hudMode:(CWMBProgressHudMode)hudeMode isSuccess:(BOOL)isSuccess{
    
    if (hud == nil) {
        
        hud = [[CWProgressHud alloc]initWithView:view];
        
        [view addSubview:hud];
    }
    
    if (hudeMode == CWMBProgressHudModeCustomView) {
        if (isSuccess) {
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CWResource.bundle/CheckmarkOk"]];
        }else{
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CWResource.bundle/Crossmark"]];
        }
    }
    
    hud.mode = hudeMode;
    
    hud.labelText = message;
    
    if (hudeMode == CWMBProgressHudModeCustomView || hudeMode ==CWMBProgressHudModeText) {
        [self performSelector:@selector(hideHud) withObject:nil afterDelay:2.f];
    }
    
}

-(void)hideHud{
    
    if (hud != nil) {
        [hud hide:YES];
        [hud removeFromSuperview];
        hud= nil;
    }
}

@end

