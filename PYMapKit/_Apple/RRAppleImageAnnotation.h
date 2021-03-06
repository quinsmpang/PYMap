//
//  RRMAImageAnnotation.h
//  YR
//
//  Created by YR on 15-4-28.
//  Copyright (c) 2015年 YR. All rights reserved.
//

#import <MapKit/MKAnnotationView.h>

/**
 *  @author YangRui, 16-02-26 09:02:14
 *
 *  只有一个图标
 */
@interface RRAppleImageAnnotation : MKAnnotationView
@property (nonatomic, strong) NSString* other; //相当于tag
/**
 *  改变泡泡视图
 */
- (void)changeCalloutView:(UIView*)view;

/**
 *  设置显示的视图
 */
- (void)setShowView:(UIView*)view;

@end
