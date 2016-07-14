//
//  PYMapSearcherWithBaidu.m
//  YR
//
//  Created by YR on 15/10/16.
//  Copyright © 2015年 YR. All rights reserved.
//
#ifdef _Map_Baidu

#import "PYMapSearcherWithBaidu.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import "PYCoordCover.h"

@interface PYMapSearcherWithBaidu () <BMKGeoCodeSearchDelegate, BMKPoiSearchDelegate, BMKRouteSearchDelegate>
@end

@implementation PYMapSearcherWithBaidu {
    BMKGeoCodeSearch *_geoCodeSearch;
    BMKPoiSearch     *_poiSearch;
    BMKRouteSearch   *_routeSearch;
}

@synthesize searchDelegate = _searchDelegate;

- (instancetype)init
{
    if (self = [super init]) {
        _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
        _poiSearch     = [[BMKPoiSearch alloc] init];
        _routeSearch   = [[BMKRouteSearch alloc] init];

        _geoCodeSearch.delegate = self;
        _poiSearch.delegate     = self;
        _routeSearch.delegate   = self;
    }

    return self;
}


- (void)dealloc
{
    _geoCodeSearch.delegate = nil;
    _poiSearch.delegate     = nil;
    _routeSearch.delegate   = nil;
}


/*根据关键字发起检索。*/
- (void)searchPOIWithKeyword:(NSString *)keyword
                        city:(NSString *)city
{
    BMKCitySearchOption *poiSearchOption = [BMKCitySearchOption new];

    [poiSearchOption setKeyword:keyword];
    [poiSearchOption setCity:city];

    [_poiSearch poiSearchInCity:poiSearchOption];
}


/*搜步行路径*/
- (void)searchWalkingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                                toCoordinate:(CLLocationCoordinate2D)to
{
    BMKWalkingRoutePlanOption *aWRSearchOption = [BMKWalkingRoutePlanOption new];
    BMKPlanNode               *fromNode        = [BMKPlanNode new];
    BMKPlanNode               *toNode          = [BMKPlanNode new];

    fromNode.pt = [PYCoordCover convertGCJ02ToBD:from];
    toNode.pt   = [PYCoordCover convertGCJ02ToBD:to];

    [aWRSearchOption setFrom:fromNode];
    [aWRSearchOption setTo:toNode];
    [_routeSearch walkingSearch:aWRSearchOption];
}


/*搜驾车路径*/
- (void)searchDrivingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                                toCoordinate:(CLLocationCoordinate2D)to
                                  policyType:(PYDrivingRoutePolicy)type
{
    BMKDrivingRoutePlanOption *aDriSearchOption = [BMKDrivingRoutePlanOption new];
    BMKPlanNode               *fromNode         = [BMKPlanNode new];
    BMKPlanNode               *toNode           = [BMKPlanNode new];

    fromNode.pt = [PYCoordCover convertGCJ02ToBD:from];
    toNode.pt   = [PYCoordCover convertGCJ02ToBD:to];

    BMKDrivingPolicy qType;
    switch (type) {
    case PYDrivingRoutePolicy_LeastDistance:
        qType = BMK_DRIVING_DIS_FIRST;
        break;
    case PYDrivingRoutePolicy_LeastFee:
        qType = BMK_DRIVING_FEE_FIRST;
        break;
    case PYDrivingRoutePolicy_LeastTime:
        qType = BMK_DRIVING_TIME_FIRST;
        break;
    case PYDrivingRoutePolicy_RealTraffic:
        qType = BMK_DRIVING_BLK_FIRST;
        break;
    default:
        break;
    }

    [aDriSearchOption setDrivingPolicy:qType];
    [_routeSearch drivingSearch:aDriSearchOption];
}


/*搜公交路径*/
- (void)searchBusingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
                                 policyType:(PYBusingRoutePolicy)type
{
    BMKTransitRoutePlanOption *aBusSearchOption = [BMKTransitRoutePlanOption new];
    BMKPlanNode               *fromNode         = [BMKPlanNode new];
    BMKPlanNode               *toNode           = [BMKPlanNode new];

    fromNode.pt = [PYCoordCover convertGCJ02ToBD:from];
    toNode.pt   = [PYCoordCover convertGCJ02ToBD:to];

    BMKTransitPolicy qType;
    switch (type) {
    case PYBusingRoutePolicy_LeastTime:
        qType = BMK_TRANSIT_TIME_FIRST;
        break;
    case PYBusingRoutePolicy_LeastTransfer:
        qType = BMK_TRANSIT_TRANSFER_FIRST;
        break;
    case PYBusingRoutePolicy_LeastWalking:
        qType = BMK_TRANSIT_WALK_FIRST;
        break;
    default:
        break;
    }

    [aBusSearchOption setTransitPolicy:qType];
    [_routeSearch transitSearch:aBusSearchOption];
}


/*根据地址描述查坐标*/
- (void)searchCoordinateFromCity:(NSString *)city address:(NSString *)address
{
    BMKGeoCodeSearchOption *aGCSearchOption = [BMKGeoCodeSearchOption new];
    if (![address hasPrefix:city]) {
        address = [NSString stringWithFormat:@"%@市%@", city, address];
    }

    aGCSearchOption.address = address;
    aGCSearchOption.city    = city;
    [_geoCodeSearch geoCode:aGCSearchOption];
}


/*根据坐标查地址描述*/
- (void)searchAddressFromCoordinate:(CLLocationCoordinate2D)coordinate
{
    BMKReverseGeoCodeOption *aGCSearchOption = [BMKReverseGeoCodeOption new];
    coordinate = [PYCoordCover convertGCJ02ToBD:coordinate];
    [aGCSearchOption setReverseGeoPoint:coordinate];
    [_geoCodeSearch reverseGeoCode:aGCSearchOption];
}


#pragma mark - QMSSearchDelegate

- (BOOL)isFailOfSearchWithErrorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode != BMK_SEARCH_NO_ERROR) {
        if ([_searchDelegate respondsToSelector:@selector(pyMapSearcher:searchFail:)]) {
            [_searchDelegate pyMapSearcher:self searchFail:nil];
        }

        return true;
    }

    return false;
}


- (void)onGetPoiResult:(BMKPoiSearch *)searcher
                result:(BMKPoiResult *)poiResult
             errorCode:(BMKSearchErrorCode)errorCode
{
    if ([self isFailOfSearchWithErrorCode:errorCode]) return;

    if ([_searchDelegate respondsToSelector:@selector(pyMapSearcher:searchPOIComplete:)]) {
        NSMutableArray *poies = [NSMutableArray array];

        for (BMKPoiInfo *poiData in poiResult.poiInfoList) {
            PYMapPoi *poi = [PYMapPoi createWithTitle:poiData.name
                                              address:poiData.address
                                             location:poiData.pt];
            [poies addObject:poi];
        }

        [_searchDelegate pyMapSearcher:self searchPOIComplete:poies];
    }
}


- (void)onGetWalkingRouteResult:(BMKRouteSearch *)searcher
                         result:(BMKWalkingRouteResult *)result
                      errorCode:(BMKSearchErrorCode)error
{
    if ([self isFailOfSearchWithErrorCode:error]) return;

    if ([_searchDelegate respondsToSelector:@selector(pyMapSearcher:searchWalkRouteComplete:)]) {
        NSMutableArray *routes = [NSMutableArray new];

        for (BMKWalkingRouteLine *aQPlan in result.routes) {
            PYRoutePlan *aPYPlan = [PYRoutePlan new];
            aPYPlan.distance = aQPlan.distance;
            aPYPlan.duration = aQPlan.duration.dates*24*60*60
                               + aQPlan.duration.hours*60*60
                               + aQPlan.duration.minutes*60
                               + aQPlan.duration.seconds;

            aPYPlan.direction = nil;

            aPYPlan.polyline = [self _coverToCLLocationsPolyline:aQPlan.steps];

            [routes addObject:aPYPlan];
        }

        PYWalkingRouteSearchResult *result = [PYWalkingRouteSearchResult new];
        result.routes = routes;

        [_searchDelegate pyMapSearcher:self searchWalkRouteComplete:result];
    }
}


- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher
                         result:(BMKDrivingRouteResult *)result
                      errorCode:(BMKSearchErrorCode)error;
{
    if ([self isFailOfSearchWithErrorCode:error]) return;

    if ([_searchDelegate respondsToSelector:@selector(pyMapSearcher:searchDriveRouteComplete:)]) {
        NSMutableArray *routes = [NSMutableArray new];

        for (BMKDrivingRouteLine *aQPlan in result.routes) {
            PYRoutePlan *aPYPlan = [PYRoutePlan new];
            aPYPlan.distance = aQPlan.distance;
            aPYPlan.duration = aQPlan.duration.dates*24*60*60
                               + aQPlan.duration.hours*60*60
                               + aQPlan.duration.minutes*60
                               + aQPlan.duration.seconds;
            aPYPlan.direction = nil;
            aPYPlan.polyline  = [self _coverToCLLocationsPolyline:aQPlan.steps];

            [routes addObject:aPYPlan];
        }

        PYDrivingRouteSearchResult *result = [PYDrivingRouteSearchResult new];
        result.routes = routes;

        [_searchDelegate pyMapSearcher:self searchDriveRouteComplete:result];
    }
}


- (void)onGetTransitRouteResult:(BMKRouteSearch *)searcher
                         result:(BMKTransitRouteResult *)result
                      errorCode:(BMKSearchErrorCode)error
{
    if ([self isFailOfSearchWithErrorCode:error]) return;

    if ([_searchDelegate respondsToSelector:@selector(pyMapSearcher:searchBusingRouteComplete:)]) {
        NSMutableArray *routes = [NSMutableArray new];

        for (BMKTransitRouteLine *aQPlan in result.routes) {
            PYBusingRoutePlan *aPYPlan = [PYBusingRoutePlan new];
            aPYPlan.distance = aQPlan.distance;
            aPYPlan.duration = aQPlan.duration.dates*24*60*60
                               + aQPlan.duration.hours*60*60
                               + aQPlan.duration.minutes*60
                               + aQPlan.duration.seconds;

            NSMutableArray *rrSteps = [NSMutableArray new];
            for (BMKTransitStep *segment in aQPlan.steps) {
                if (![segment isKindOfClass:[BMKTransitStep class]]) continue;

                PYBusingSegmentRoutePlan *rrSegment = [PYBusingSegmentRoutePlan new];
                rrSegment.direction = nil;
                rrSegment.distance  = segment.distance;
                rrSegment.duration  = segment.duration;
                rrSegment.polyline  = [self _coverToCLLocationsStep:segment];

                if (segment.stepType == BMK_BUSLINE) {
                    rrSegment.mode = PYBusingRouteStepModeType_Driving;
                } else {
                    rrSegment.mode = PYBusingRouteStepModeType_Walking;
                }

                [rrSteps addObject:rrSegment];
            }

            aPYPlan.steps = rrSteps;

            [routes addObject:aPYPlan];
        }

        PYBusingRouteSearchResult *result = [PYBusingRouteSearchResult new];
        result.routes = routes;

        [_searchDelegate pyMapSearcher:self searchBusingRouteComplete:result];
    }
}


- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher
                    result:(BMKGeoCodeResult *)result
                 errorCode:(BMKSearchErrorCode)error
{
    if ([self isFailOfSearchWithErrorCode:error]) return;

    if ([_searchDelegate respondsToSelector:@selector(pyMapSearcher:searchCoordFromAddressComplete:)]) {
        [_searchDelegate pyMapSearcher:self
         searchCoordFromAddressComplete:[PYCoordCover convertGCJ02ToBD:result.location]];
    }
}


- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher
                           result:(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error
{
    if ([self isFailOfSearchWithErrorCode:error]) return;

    if ([_searchDelegate respondsToSelector:@selector(pyMapSearcher:searchAddressFromCoordComplete:)]) {
        PYMapAddress *address = [PYMapAddress new];

        address.province       = result.addressDetail.province;
        address.city           = result.addressDetail.city;
        address.district       = result.addressDetail.district;
        address.street_number  = result.addressDetail.streetNumber;
        address.summaryAddress = result.address;

        [_searchDelegate pyMapSearcher:self
         searchAddressFromCoordComplete:address];
    }
}


#pragma mark - helper

- (NSArray *)_coverToCLLocationsPolyline:(NSArray<BMKRouteStep *> *)polyline
{
    NSMutableArray *points = [NSMutableArray new];

    for (BMKRouteStep *obj in polyline) {
        NSArray *addPoints = [self _coverToCLLocationsStep:obj];

        [points addObjectsFromArray:addPoints];
    }

    return points;
}


- (NSArray *)_coverToCLLocationsStep:(BMKRouteStep *)step
{
    NSMutableArray *points = [NSMutableArray new];

    for (int i = 0; i < step.pointsCount; i++) {
        BMKMapPoint point;
        point.x = step.points[i].x;
        point.y = step.points[i].y;

        CLLocationCoordinate2D coor = BMKCoordinateForMapPoint(point);

        coor = [PYCoordCover convertBDToGCJ02:coor];

        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coor.latitude
                                                     longitude:coor.longitude];
        [points addObject:loc];
    }

    return points;
}


@end

#endif
