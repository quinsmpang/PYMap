//
//  PYMAAnnotationView.m
//  YR
//
//  Created by YR on 15-4-28.
//  Copyright (c) 2015年 YR. All rights reserved.
//
#ifdef _Map_MA

#import "PYMAAnnotationView.h"

@implementation PYMAAnnotationView{
    UIView* _curCallOutView;
    UIView* _showView;
}

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBounds:CGRectMake(0.f, 0.f, 32.f, 32.f)];
        [self setBackgroundColor:[UIColor clearColor]];
    }

    return self;
}

-(void)changeCalloutView:(UIView *)view{

    if (_curCallOutView) {
        [_curCallOutView removeFromSuperview];
    }
    
    if (view == nil) return;
    
    _curCallOutView = view;
    
    [self addSubview:view];
    
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_curCallOutView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_curCallOutView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_curCallOutView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:CGRectGetHeight( _curCallOutView.bounds)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_curCallOutView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:CGRectGetWidth( _curCallOutView.bounds)]];
    
}

- (void)setShowView:(UIView*)view{

    [_showView removeFromSuperview];
    if (view == nil) return;
    
    _showView = view;
    
    [self setBounds:view.bounds];
    [self addSubview:view];
    
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray* edges = @[@(NSLayoutAttributeTopMargin), @(NSLayoutAttributeLeadingMargin),
                      @(NSLayoutAttributeBottomMargin), @(NSLayoutAttributeTrailingMargin)];
    
    for (NSNumber* aEdge in edges) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_showView
                                                         attribute:[aEdge integerValue]
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:[aEdge integerValue]
                                                        multiplier:1
                                                          constant:0]];
    }
    
}

@end


#endif