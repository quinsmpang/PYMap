//
//  PYBaiduImageAnnotation.m
//  YR
//
//  Created by YR on 15-4-28.
//  Copyright (c) 2015年 YR. All rights reserved.
//
#ifdef _Map_Baidu

#import "PYBaiduImageAnnotation.h"

@implementation PYBaiduImageAnnotation
@synthesize annotationImageView = _annotationImageView;
- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        //        [self setBounds:CGRectMake(0.f, 0.f, 30.f, 30.f)];
        [self setBounds:CGRectMake(0.f, 0.f, 32.f, 32.f)];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _annotationImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _annotationImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_annotationImageView];
    }
    return self;
}

@end

#endif
