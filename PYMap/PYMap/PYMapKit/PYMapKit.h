//
//  PYMapKit.h
//  QMapKitSample
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 YR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYMapGeometry.h"
#import "PYAnnotation.h"

@protocol PYMapDelegate;
@protocol PYMapKitProtocal <NSObject>

/*!
 *  @brief  当前地图视图
 */
- (UIView *)mapView;

#pragma mark - Region and ZoomLevel

/*!
 *  @brief  获取缩放级别
 */
- (double)getZoomLevel;

/*!
 *  @brief  获取显示区域
 */
- (PYCoordinateRegion)getMapRegion;

/**
 *  @brief 根据当前地图View的窗口大小调整传入的region，返回适合当前地图窗口显示的region，调整过程会保证中心点不改变
 *  @param region 待调整的经纬度范围
 *  @return 调整后适合当前地图窗口显示的经纬度范围
 */
- (PYCoordinateRegion)regionThatFits:(PYCoordinateRegion)region;

/*!
 *  @brief  设定当前地图的region
 *
 *  @param region   要设定的地图范围，用经纬度的方式表示
 *  @param animated 是否采用动画
 */
- (void)setRegion:(PYCoordinateRegion)region animated:(BOOL)animated;


/*!
 *  @brief  设定地图中心点经纬度
 *
 *  @param coordinate 要设定的地图中心点经纬度
 *  @param animated   是否采用动画
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;


/*!
 *  @brief  同时设置中心点与缩放级别
 *
 *  @param coordinate   要设定的地图中心点经纬度
 *  @param newZoomLevel 目标缩放级别
 *  @param animated     是否采用动画
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate
                  zoomLevel:(double)newZoomLevel
                   animated:(BOOL)animated;


#pragma mark - Annotation

/*!
 *  @brief  向地图窗口添加标注
 *
 *  @param annotation 要添加的标注
 */
- (void)addAnnotation:(id <PYAnnotation>)annotation
            imageName:(NSString *)imgStr
                  uid:(NSString *)uid;
/*!
 *  @brief  向地图窗口添加标注，带有气泡
 *
 *  @param annotation 要添加的标注
 */
- (void)addCalloutAnnotation:(id<PYAnnotation>)annotation
                   imageName:(NSString *)imgStr
                         uid:(NSString *)uid;

/*!
 *  @brief  移除一个标注
 *
 *  @param annotationUID 要移除的标注的唯一标识
 */
- (void)removeAnnotation:(NSString *)uid;
/*!
 *  @brief  移除一组标注
 *
 *  @param annotations 要移除的标注id数组
 */
- (void)removeAnnotations:(NSArray *)uids;
/*!
 *  @brief  移除所有标注
 */
- (void)removeAllAnnotations;

/*!
 *  @brief  刷新气泡
 */
- (void)updateCallout;


#pragma mark - OverLayer

/*!
 *  @brief  添加覆盖视图
 *
 */
- (void)addOverLayer:(NSArray *)coordinates
         strokeColor:(UIColor *)strokeColor
           fillColor:(UIColor *)fillColor
           lineWidth:(CGFloat)lineWidth
                 uid:(NSString *)uid;

/*!
 *  @brief  移除覆盖视图
 */
- (void)removeOverlayView:(NSString *)uid;


/*!
 *  @brief  添加线路图
 *
 *  coordinates CLLocation数组
 */
- (void)addRouteWithCoords:(NSArray *)coordinates
               strokeColor:(UIColor *)strokeColor
                 lineWidth:(CGFloat)lineWidth
                       uid:(NSString *)uid;

/*!
 *  @brief  移除覆盖视图
 */
- (void)removeRouteView:(NSString *)uid;



#pragma mark - ScrollEnable ZoomEnable

/*!
 *  @brief  是否支持平移, 默认为YES
 */
- (void)setScrollEnabled:(BOOL)scrollEnabled;

/*!
 *  @brief  是否支持缩放, 默认为YES
 */
- (void)setZoomEnabled:(BOOL)zoomEnabled;

/*!
 *  @brief  设置当前地图缩放级别
 *
 *  @param zoomScale    目标缩放级别与当前级别的比例
 *  @param animated     是否采用动画
 */
- (void)setZoomScale:(double)zoomScale animated:(BOOL)animated;




#pragma mark - Delegate;
@property (nonatomic, assign) id<PYMapDelegate> mapDelegate;

#pragma mark  - callback
/*!
 *  @brief 回调block,获取标注图片
 */
@property (nonatomic, copy) UIImage *(^annotationImageWithUid)(NSString *);
/*!
 *  @brief 回调block,获取气泡视图调用
 */
@property (nonatomic, copy) UIView *(^annotationCalloutViewWithUid)(NSString *);
/*!
 *  @brief 回调block,点击标注时候调用
 */
@property (nonatomic, copy) void (^annotationSelectAtUid)(NSString *);
/*!
 *  @brief 回调block,取消点击标注时候调用
 */
@property (nonatomic, copy) void (^annotationDeSelectAtUid)(NSString *);

@end


@protocol  PYMapDelegate <NSObject>
@optional
/*!
 *  @brief  地图区域改变完成时会调用此接口
 *
 *  @param mapView  地图view
 *  @param region 完成后的区域
 */
- (void)pyMap:(id<PYMapKitProtocal>)map regionDidChangeTo:(PYCoordinateRegion)region;

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


/**
 *  @brief  自定义视图
 *
 *  @param map 地图view
 *  @param uid 需要显示视图的标识
 */
- (UIView *)pyMap:(id<PYMapKitProtocal>)map viewForAnnotationId:(NSString *)uid;


@end