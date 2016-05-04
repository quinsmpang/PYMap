//
//  PYMapSearchService.h
//  YR
//
//  Created by YR on 15/10/16.
//  Copyright © 2015年 YR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PYMapSSK_Block.h"
#import "PYMapSSK_Delegate.h"


/**
 *  驾车路线规划条件
 */
typedef NS_ENUM(NSUInteger, PYDrivingRoutePolicy)
{
    PYDrivingRoutePolicy_LeastTime = 0,     //省时
    PYDrivingRoutePolicy_LeastFee = 1,      //省钱
    PYDrivingRoutePolicy_LeastDistance = 2, //距离最短
    PYDrivingRoutePolicy_RealTraffic = 3,   //综合最优
};


/**
 *  公交路线规划条件
 */
typedef NS_ENUM(NSUInteger, PYBusingRoutePolicy)
{
    PYBusingRoutePolicy_LeastTime = 0,          //省时
    PYBusingRoutePolicy_LeastTransfer = 1,      //少换乘
    PYBusingRoutePolicy_LeastWalking = 2,       //少步行
};


/**
 *  搜索服务协议
 */
@protocol PYMapSearcherProtocal <NSObject, PYMapSSK_Block, PYMapSSK_Delegate>


/**
 *  根据关键字发起检索。城市名称, 特定页数, 每页返回的结果数量
 */
-(void)searchPOIWithKeyword:(NSString*)keyword city:(NSString*)city;

/**
 *  根据地址描述查坐标
 */

-(void)searchCoordinateFromCity:(NSString*)city address:(NSString*)address;

/**
 *  根据坐标查地址描述
 */
-(void)searchAddressFromCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  搜步行路径
 */
-(void)searchWalkingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to;

/** 
 *  搜驾车路径
 */
-(void)searchDrivingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
                                 policyType:(PYDrivingRoutePolicy)type;

/**
 *  搜公交路径
 */
-(void)searchBusingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
                                 policyType:(PYBusingRoutePolicy)type;


@end


