//
//  PYMapSearchResult.h
//  YR
//
//  Created by YR on 15/10/16.
//  Copyright © 2015年 YR. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  poi 信息
 */
@interface PYMapPoi : NSObject

@property (readonly, nonatomic) NSString* title;
@property (readonly, nonatomic) NSString* address;
@property (readonly, nonatomic) CLLocationCoordinate2D location;

+(PYMapPoi*)createWithTitle:(NSString*)title
                    address:(NSString*)address
                   location:(CLLocationCoordinate2D)location;

@end

/**
 *  地址信息
 */
@interface PYMapAddress : NSObject

@property (readonly, nonatomic) NSString* province;
@property (readonly, nonatomic) NSString* city;
@property (readonly, nonatomic) NSString* district;
@property (readonly, nonatomic) NSString* street_number;
@property (readonly, nonatomic) NSString* summaryAddress; /*简明地址*/

@end



/**
 *  路径规划
 */
@interface PYRoutePlan : NSObject

/*!
 *  @brief  距离 单位:米
 */
@property (nonatomic) CGFloat distance;

/*!
 *  @brief  时间 单位:分钟 四舍五入
 */
@property (nonatomic) CGFloat duration;

/*!
 *  @brief  方向描述
 */
@property (nonatomic) NSString *direction;

/*!
 *  @brief  路线坐标点串, 导航方案经过的点, 每个step中会根据索引取得自己所对应的路段, 类型为CLLocation
 */
@property (nonatomic, copy) NSArray *polyline;

@end

#pragma mark - Walking

@interface PYWalkingRouteSearchResult : NSObject

/*!
 *  @brief  路径规划方案数组, 元素类型为RRRoutePlan
 */
@property (nonatomic, copy) NSArray *routes;

@end


#pragma mark - Driving

@interface PYDrivingRouteSearchResult : NSObject

/*!
 *  @brief  路径规划方案数组, 元素类型为RRRoutePlan
 */
@property (nonatomic, copy) NSArray *routes;

@end



#pragma mark - Busing

@interface PYBusingRouteSearchResult : NSObject

/*!
 *  @brief  路径规划方案数组, 元素类型为RRBusingRoutePlan
 */
@property (nonatomic, copy) NSArray *routes;

@end

/*!
 *  @brief  公交出行方案
 */
@interface PYBusingRoutePlan : NSObject

/*!
 *  @brief  距离 单位:米
 */
@property (nonatomic) CGFloat distance;

/*!
 *  @brief  时间 单位:分钟 四舍五入
 */
@property (nonatomic) CGFloat duration;

/*!
 *  @brief  路线bounds，用于显示地图时使用
 */
@property (nonatomic, copy) NSString *bounds;

/*!
 *  @brief  分段描述 类型为:PYBusingSegmentRoutePlan
 */
@property (nonatomic, copy) NSArray *steps;

@end


/*!
 *  @brief  公交分段方案
 */
@interface PYBusingSegmentRoutePlan : NSObject


/*!
 *  @brief  标记路径规划类型
 */
typedef NS_ENUM(NSUInteger, PYBusingRouteStepModeType)
{
    PYBusingRouteStepModeType_Driving = 0,          //坐车
    PYBusingRouteStepModeType_Walking = 1,      //不幸
};

/*!
 *  @brief  标记路径规划类型
 */
@property (nonatomic ,assign) PYBusingRouteStepModeType mode;

/*!
 *  @brief  距离 单位:米
 */
@property (nonatomic) CGFloat distance;

/*!
 *  @brief  时间 单位:分钟 四舍五入
 */
@property (nonatomic) CGFloat duration;

/*!
 *  @brief  方向描述
 */
@property (nonatomic) NSString *direction;

/*!
 *  @brief  路线坐标点串, 导航方案经过的点, 每个step中会根据索引取得自己所对应的路段, 类型为CLLocation
 */
@property (nonatomic, copy) NSArray *polyline;

@end
