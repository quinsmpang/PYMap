//
//  RRBaiduImageAnnotation.m
//  YR
//
//  Created by YR on 15-4-28.
//  Copyright (c) 2015年 YR. All rights reserved.
//
#ifdef _Map_Baidu

#import "RRBaiduImageAnnotation.h"

@implementation RRBaiduImageAnnotation{
    UIView* _curCallOutView;
    UIView* _showView;
}

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
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
    
    [_curCallOutView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.top);
        make.size.equalTo(_curCallOutView.bounds.size);
        
    }];
    
}

- (void)setShowView:(UIView*)view{
    
    [_showView removeFromSuperview];
    if (view == nil) return;
    
    _showView = view;
    
    [self setBounds:view.bounds];
    [self addSubview:view];
    
    [_showView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

@end

#endif
