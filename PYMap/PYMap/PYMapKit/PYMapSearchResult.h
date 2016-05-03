//
//  PYMapSearchResult.h
//  YR
//
//  Created by YR on 15/10/16.
//  Copyright © 2015年 YR. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>

@interface PYMapPoi : NSObject

@property (readonly, nonatomic) NSString* title;
@property (readonly, nonatomic) NSString* address;
@property (readonly, nonatomic) CLLocationCoordinate2D location;

+(PYMapPoi*)createWithTitle:(NSString*)title
                    address:(NSString*)address
                   location:(CLLocationCoordinate2D)location;

@end


/*!
 *  @brief  驾车路线规划条件
 */
typedef NS_ENUM(NSUInteger, PYDrivingRoutePolicyType)
{
    PYDrivingRoutePolicyType_LeastTime = 0,     //省时
    PYDrivingRoutePolicyType_LeastFee = 1,      //省钱
    PYDrivingRoutePolicyType_LeastDistance = 2, //距离最短
    PYDrivingRoutePolicyType_RealTraffic = 3,   //综合最优
};


/*!
 *  @brief  公交路线规划条件
 */
typedef NS_ENUM(NSUInteger, PYBusingRoutePolicyType)
{
    PYBusingRoutePolicyTypeLeastTime = 0,          //省时
    PYBusingRoutePolicyTypeLeastTransfer = 1,      //少换乘
    PYBusingRoutePolicyTypeLeastWalking = 2,       //少步行
};


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
