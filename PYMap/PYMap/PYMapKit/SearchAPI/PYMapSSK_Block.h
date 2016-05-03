//
//  PYMapKit_Delegate.h
//  PYMap
//
//  Created by yr on 16/5/3.
//  Copyright © 2016年 yr. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  地图搜索block回调协议
 */
@protocol PYMapSSK_Block

/**
 * 检索关键字成功后的回调
 */
@property (nonatomic, copy) void(^searchPOIComplete)(NSArray<PYMapPoi*>* poies);

/**
 * 检索步行成功后的回调
 */
@property (nonatomic, copy) void(^searchWalkRouteComplete)(PYWalkingRouteSearchResult* result);

/**
 * 检索驾车路线成功后的回调
 */
@property (nonatomic, copy) void(^searchDriveRouteComplete)(PYDrivingRouteSearchResult* result);

/**
 * 检索公交成功后的回调
 */
@property (nonatomic, copy) void(^searchBusingRouteComplete)(PYBusingRouteSearchResult* result);

/**
 * 从地址检索坐标成功后的回调
 */
@property (nonatomic, copy) void(^searchCoordFromAddressComplete)(CLLocationCoordinate2D location);

/**
 * 从坐垫检索地址成功后的回调
 */
@property (nonatomic, copy) void(^searchAddressFromCoordComplete)(NSString *province,NSString *city,
                                                                  NSString *district,NSString *street_number,
                                                                  NSString *address);
/**
 * 检索失败后的回调
 */
@property (nonatomic, copy) void(^searchFail)(NSError* err);

@end
