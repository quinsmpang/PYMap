//
//  PYMapSearchService.h
//  YR
//
//  Created by YR on 15/10/16.
//  Copyright © 2015年 YR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PYMapSearchResult.h"

typedef void(^PYMapSearchErrorCB)(NSError* err);
typedef void(^PYMapSearchKeywordCompleteCB)(NSArray* poies);
typedef void(^PYMapSearchWalkRouteCompleteCB)(PYWalkingRouteSearchResult* result);
typedef void(^PYMapSearchDriveRouteCompleteCB)(PYDrivingRouteSearchResult* result);
typedef void(^PYMapSearchBusRouteCompleteCB)(PYBusingRouteSearchResult* result);
typedef void(^PYMapSearchCoordinateFromCityCompleteCB)(CLLocationCoordinate2D location);
typedef void(^PYMapSearchAddressFromCoordinateCompleteCB)(NSString *province,NSString *city,NSString *district,
                                                          NSString *street_number,NSString *address);


/*搜索服务协议*/
@protocol PYMapSearcherProtocal <NSObject>

/*根据关键字发起检索。城市名称, 特定页数, 每页返回的结果数量*/
-(void)searchKeyword:(NSString*)keyword
                city:(NSString*)city
           pageIndex:(NSUInteger)pageIndex
        pageCapacity:(NSUInteger)pageCapacity;
/*根据地址描述查坐标*/
-(void)searchCoordinateFromCity:(NSString*)city address:(NSString*)address;
/*根据坐标查地址描述*/
-(void)searchAddressFromCoordinate:(CLLocationCoordinate2D)coordinate;
/*搜步行路径*/
-(void)searchWalkingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to;
/*搜驾车路径*/
-(void)searchDrivingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
                                 policyType:(PYDrivingRoutePolicyType)type;
/*搜公交路径*/
-(void)searchBusingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
                                 policyType:(PYBusingRoutePolicyType)type;

/*设置检索关键字成功后的回调函数*/
-(void)setSearchKeywordComplete:(PYMapSearchKeywordCompleteCB)completeCB;
/*设置检索步行成功后的回调函数*/
-(void)setSearchWalkRouteComplete:(PYMapSearchWalkRouteCompleteCB)completeCB;
/*设置检索驾车路线成功后的回调函数*/
-(void)setSearchDriveRouteComplete:(PYMapSearchDriveRouteCompleteCB)completeCB;
/*设置检索公交成功后的回调函数*/
-(void)setSearchBusRouteComplete:(PYMapSearchBusRouteCompleteCB)completeCB;
/*设置从地址检索坐标成功后的回调函数*/
-(void)setSearchCoordinateFromCityComplete:(PYMapSearchCoordinateFromCityCompleteCB)completeCB;
/*设置从坐垫检索地址成功后的回调函数*/
-(void)setSearchAddressFromCoordinateComplete:(PYMapSearchAddressFromCoordinateCompleteCB)completeCB;
/*设置检索失败后的回调函数*/
-(void)setError:(PYMapSearchErrorCB)errCB;
@end


@interface PYMapSearchServiceFactory : NSObject

+(id<PYMapSearcherProtocal>)createSearcher;
+(id)start;


@end

