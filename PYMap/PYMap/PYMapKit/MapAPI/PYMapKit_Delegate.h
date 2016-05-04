//
//  PYMapKit_Delegate.h
//  PYMap
//
//  Created by yr on 16/5/3.
//  Copyright © 2016年 yr. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PYMapDelegate;
@protocol PYMapKitProtocal;


@protocol PYMapKit_Delegate

@property (nonatomic, weak) id<PYMapDelegate> mapDelegate;

@end


@protocol  PYMapDelegate <NSObject>

@optional

/*!
 *  @brief  地图区域改变完成时会调用此接口
 *
 *  @param mapView  地图view
 *  @param region 完成后的区域
 */
- (void)pyMap:(id<PYMapKitProtocal>)map regionDidChangeTo:(PYCoordinateRegion)region withAnimated:(BOOL)animated;

/*!
 *  @brief  地图区域即将改变时会调用此接口
 *
 *  @param mapView  地图view
 *  @param region 开始时候的区域
 */
- (void)pyMap:(id<PYMapKitProtocal>)map regionWillChangeFrom:(PYCoordinateRegion)region withAnimated:(BOOL)animated;

/*!
 *  @brief  自定义视图
 *
 *  @param map 地图view
 *  @param uid 需要显示视图的标识
 */
- (UIView *)pyMap:(id<PYMapKitProtocal>)map viewForAnnotationWithId:(NSString *)uid;

/*!
 *  @brief 获取气泡视图调用
 */
- (UIView *)pyMap:(id<PYMapKitProtocal>)map calloutViewForAnnotationWithId:(NSString *)uid;

/*!
 *  @brief 点击标注时候调用
 */
- (UIView *)pyMap:(id<PYMapKitProtocal>)map annotationSelectAtUid:(NSString *)uid;

/*!
 *  @brief 取消点击标注时候调用
 */
- (UIView *)pyMap:(id<PYMapKitProtocal>)map annotationDeSelectAtUid:(NSString *)uid;


@end
