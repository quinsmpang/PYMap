//
//  PYMapKit_Delegate.h
//  PYMap
//
//  Created by yr on 16/5/3.
//  Copyright © 2016年 yr. All rights reserved.
//

#import "PYMapSearchResult.h"

@protocol PYMapSearcherProtocal;
@protocol PYMapSSKDelegate;


@protocol PYMapSSK_Delegate

@property (nonatomic, weak) id<PYMapSSKDelegate> searchDelegate;

@end



@protocol PYMapSSKDelegate <NSObject>

/**
 * 检索关键字成功后的回调
 */
- (void)pyMapSearcher:(id<PYMapSearcherProtocal>)mapSearcher searchPOIComplete:(NSArray<PYMapPoi*>*) poies;

/**
 * 检索步行成功后的回调
 */
- (void)pyMapSearcher:(id<PYMapSearcherProtocal>)mapSearcher searchWalkRouteComplete:(PYWalkingRouteSearchResult*) result;

/**
 * 检索驾车路线成功后的回调
 */
- (void)pyMapSearcher:(id<PYMapSearcherProtocal>)mapSearcher searchDriveRouteComplete:(PYDrivingRouteSearchResult*) result;

/**
 * 检索公交成功后的回调
 */
- (void)pyMapSearcher:(id<PYMapSearcherProtocal>)mapSearcher searchBusingRouteComplete:(PYBusingRouteSearchResult*) result;

/**
 * 从地址检索坐标成功后的回调
 */
- (void)pyMapSearcher:(id<PYMapSearcherProtocal>)mapSearcher searchCoordFromAddressComplete:(CLLocationCoordinate2D) location;

/**
 * 从坐垫检索地址成功后的回调
 */
- (void)pyMapSearcher:(id<PYMapSearcherProtocal>)mapSearcher searchAddressFromCoordComplete:(PYMapAddress*) address;

/**
 * 检索失败后的回调
 */
- (void)pyMapSearcher:(id<PYMapSearcherProtocal>)mapSearcher searchFail:(NSError*) err;

@end
