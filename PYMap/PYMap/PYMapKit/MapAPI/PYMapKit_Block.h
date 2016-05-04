//
//  PYMapKit_Delegate.h
//  PYMap
//
//  Created by yr on 16/5/3.
//  Copyright © 2016年 yr. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  地图回调
 */
@protocol PYMapKit_Block

/*!
 *  @brief 回调block,获取标注图片
 */
@property (nonatomic, copy) UIView *(^viewForAnnotation)(NSString *uid);

/*!
 *  @brief 回调block,获取气泡视图调用
 */
@property (nonatomic, copy) UIView *(^calloutViewForAnnotation)(NSString *uid);

/*!
 *  @brief 回调block,点击标注时候调用
 */
@property (nonatomic, copy) void (^annotationSelect)(NSString *uid);

/*!
 *  @brief 回调block,取消点击标注时候调用
 */
@property (nonatomic, copy) void (^annotationDeSelect)(NSString *uid);

/*!
 *  @brief 回调block,取消点击标注时候调用
 */
@property (nonatomic, copy) void (^mapDidChangeRegion)(PYCoordinateRegion didToRegion, BOOL animated);

/*!
 *  @brief 回调block,取消点击标注时候调用
 */
@property (nonatomic, copy) void (^mapWillChangeRegion)(PYCoordinateRegion willToRegion, BOOL animated);

@end
