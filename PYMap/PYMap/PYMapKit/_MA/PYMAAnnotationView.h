//
//  PYMAAnnotationView.h
//  YR
//
//  Created by YR on 15-4-28.
//  Copyright (c) 2015年 YR. All rights reserved.
//

#import <MAMapKit/MAAnnotationView.h>

/**
 *  标记视图
 */
@interface PYMAAnnotationView : MAAnnotationView

@property (nonatomic, strong) NSString* annotationId; 

/**
 *  改变泡泡视图
 */
- (void)changeCalloutView:(UIView*)view;

/**
 *  设置显示的视图
 */
- (void)setShowView:(UIView*)view;

@end
