//
//  PYMapSearchServiceWithMA.m
//  YR
//
//  Created by YR on 15/10/16.
//  Copyright © 2015年 YR. All rights reserved.
//

#ifdef _Map_MA

#import "PYMapSearcherWithMA.h"
#import <MAMapKit/MAMapKit.h>

@interface PYMapSearcherWithMA () <AMapSearchDelegate>

@end

@implementation PYMapSearcherWithMA {
    AMapSearchAPI *_mapSearcher;
}

@synthesize searchFail                     = _searchFail;
@synthesize searchPOIComplete              = _searchPOIComplete;
@synthesize searchWalkRouteComplete        = _searchWalkRouteComplete;
@synthesize searchDriveRouteComplete       = _searchDriveRouteComplete;
@synthesize searchBusingRouteComplete      = _searchBusingRouteComplete;
@synthesize searchAddressFromCoordComplete = _searchAddressFromCoordComplete;
@synthesize searchCoordFromAddressComplete = _searchCoordFromAddressComplete;

- (instancetype)init
{
    if (self = [super init]) {
        _mapSearcher          = [AMapSearchAPI new];
        _mapSearcher.delegate = self;
    }

    return self;
}


- (void)dealloc
{
    _mapSearcher.delegate = nil;
}


/*根据关键字发起检索。*/
- (void)searchPOIWithKeyword:(NSString *)keyword
                        city:(NSString *)city
{
    AMapPOIKeywordsSearchRequest *poiSearchOption = [AMapPOIKeywordsSearchRequest new];

    [poiSearchOption setKeywords:keyword];
    [poiSearchOption setCityLimit:YES];
    [poiSearchOption setCity:city];

    [_mapSearcher AMapPOIKeywordsSearch:poiSearchOption];
}


/*搜步行路径*/
- (void)searchWalkingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                                toCoordinate:(CLLocationCoordinate2D)to
{
    AMapWalkingRouteSearchRequest *aWRSearchOption = [AMapWalkingRouteSearchRequest new];

    AMapGeoPoint *orig = [AMapGeoPoint locationWithLatitude:from.latitude longitude:from.longitude];
    AMapGeoPoint *dest = [AMapGeoPoint locationWithLatitude:to.latitude longitude:to.longitude];

    aWRSearchOption.origin      = orig;
    aWRSearchOption.destination = dest;

    [_mapSearcher AMapWalkingRouteSearch:aWRSearchOption];
}


/*搜驾车路径*/
- (void)searchDrivingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                                toCoordinate:(CLLocationCoordinate2D)to
                                  policyType:(PYDrivingRoutePolicy)type
{
    AMapDrivingRouteSearchRequest *aDriSearchOption = [AMapDrivingRouteSearchRequest new];

    AMapGeoPoint *orig = [AMapGeoPoint locationWithLatitude:from.latitude longitude:from.longitude];
    AMapGeoPoint *dest = [AMapGeoPoint locationWithLatitude:to.latitude longitude:to.longitude];

    aDriSearchOption.origin      = orig;
    aDriSearchOption.destination = dest;

    MADrivingStrategy strategy;
    switch (type) {
    case PYDrivingRoutePolicy_LeastDistance:
        strategy = MADrivingStrategyShortest;
        break;
    case PYDrivingRoutePolicy_LeastFee:
        strategy = MADrivingStrategyMinFare;
        break;
    case PYDrivingRoutePolicy_LeastTime:
        strategy = MADrivingStrategyFastest;
        break;
    case PYDrivingRoutePolicy_RealTraffic:
        strategy = MADrivingStrategyAvoidFareAndCongestion;
        break;
    default:
        break;
    }

    aDriSearchOption.strategy = strategy;

    [_mapSearcher AMapDrivingRouteSearch:aDriSearchOption];
}


/*搜公交路径*/
- (void)searchBusingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
                                 policyType:(PYBusingRoutePolicy)type
{
    AMapTransitRouteSearchRequest *aBusSearchOption = [AMapTransitRouteSearchRequest new];

    AMapGeoPoint *orig = [AMapGeoPoint locationWithLatitude:from.latitude longitude:from.longitude];
    AMapGeoPoint *dest = [AMapGeoPoint locationWithLatitude:to.latitude longitude:to.longitude];

    aBusSearchOption.origin      = orig;
    aBusSearchOption.destination = dest;

    MATransitStrategy strategy;
    switch (type) {
    case PYBusingRoutePolicy_LeastTime:
        strategy = MATransitStrategyFastest;
        break;
    case PYBusingRoutePolicy_LeastTransfer:
        strategy = MATransitStrategyMinTransfer;
        break;
    case PYBusingRoutePolicy_LeastWalking:
        strategy = MATransitStrategyMinWalk;
        break;
    default:
        break;
    }

    aBusSearchOption.strategy = strategy;
    [_mapSearcher AMapTransitRouteSearch:aBusSearchOption];
}


/*根据地址描述查坐标*/
- (void)searchCoordinateFromCity:(NSString *)city address:(NSString *)address
{
    AMapGeocodeSearchRequest *aGCSearchOption = [AMapGeocodeSearchRequest new];
    if (![address hasPrefix:city]) {
        address = [NSString stringWithFormat:@"%@市%@", city, address];
    }

    aGCSearchOption.address = address;
    aGCSearchOption.city    = city;
    [_mapSearcher AMapGeocodeSearch:aGCSearchOption];
}


/*根据坐标查地址描述*/
- (void)searchAddressFromCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *aGCSearchOption = [AMapReGeocodeSearchRequest new];

    AMapGeoPoint *location = [AMapGeoPoint locationWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];

    [aGCSearchOption setLocation:location];
    aGCSearchOption.requireExtension = false;

    [_mapSearcher AMapReGoecodeSearch:aGCSearchOption];
}


#pragma mark - QMSSearchDelegate


- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error;
{
    if (_searchFail) {
        _searchFail(error);
    }
}


- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response;
{
    if (_searchPOIComplete) {
        NSMutableArray *poies = [NSMutableArray array];

        for (AMapPOI *poiData in response.pois) {
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(poiData.location.latitude,
                                                                     poiData.location.longitude);

            PYMapPoi *poi = [PYMapPoi createWithTitle:poiData.name
                                              address:poiData.address
                                             location:coor];
            [poies addObject:poi];
        }

        _searchPOIComplete(poies);
    }
}


- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if ([request isKindOfClass:[AMapWalkingRouteSearchRequest class]]) {
        [self onWalkingRouteSearchDone:request response:response];
    } else if ([request isKindOfClass:[AMapDrivingRouteSearchRequest class]]) {
        [self onDrivingRouteSearchDone:request response:response];
    } else if ([request isKindOfClass:[AMapTransitRouteSearchRequest class]]) {
        [self onBusingRouteSearchDone:request response:response];
    }
}


- (void)onWalkingRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (_searchWalkRouteComplete) {
        NSMutableArray *routes = [NSMutableArray new];

        for (AMapPath *aPlan in response.route.paths) {
            PYRoutePlan *aRRPlan = [PYRoutePlan new];
            aRRPlan.distance = aPlan.distance;
            aRRPlan.duration = aPlan.duration;
            aRRPlan.polyline = [self _coverToCLLocationsSteps:aPlan.steps];

            [routes addObject:aRRPlan];
        }

        PYWalkingRouteSearchResult *result = [PYWalkingRouteSearchResult new];
        result.routes = routes;

        _searchWalkRouteComplete(result);
    }
}


- (void)onDrivingRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (_searchDriveRouteComplete) {
        NSMutableArray *routes = [NSMutableArray new];

        for (AMapPath *aPlan in response.route.paths) {
            PYRoutePlan *aRRPlan = [PYRoutePlan new];
            aRRPlan.distance = aPlan.distance;
            aRRPlan.duration = aPlan.duration;
            aRRPlan.polyline = [self _coverToCLLocationsSteps:aPlan.steps];

            [routes addObject:aRRPlan];
        }

        PYDrivingRouteSearchResult *result = [PYDrivingRouteSearchResult new];
        result.routes = routes;

        _searchDriveRouteComplete(result);
    }
}


- (void)onBusingRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (_searchBusingRouteComplete) {
        NSMutableArray *routes = [NSMutableArray new];

        for (AMapTransit *aPlan in response.route.transits) {
            PYBusingRoutePlan *aRRPlan = [PYBusingRoutePlan new];
            aRRPlan.distance = aPlan.distance;
            aRRPlan.duration = aPlan.duration;

            NSMutableArray *pySteps = [NSMutableArray new];
            for (AMapSegment *segment in aPlan.segments) {
                if (![segment isKindOfClass:[AMapSegment class]]) continue;

                PYBusingSegmentRoutePlan *pySegment = [PYBusingSegmentRoutePlan new];

                NSArray *busChooses = segment.buslines;

                if (busChooses.count > 0) {
                    AMapBusLine *busLine = segment.buslines[0];
                    pySegment.polyline = [self _coverToCLLocationsPolyline:busLine.polyline];
                    pySegment.mode     = PYBusingRouteStepModeType_Driving;
                } else {
                    AMapWalking *walking = segment.walking;
                    pySegment.polyline = [self _coverToCLLocationsSteps:walking.steps];
                    pySegment.mode     = PYBusingRouteStepModeType_Walking;
                }

                [pySteps addObject:pySegment];
            }

            aRRPlan.steps = pySteps;

            [routes addObject:aRRPlan];
        }

        PYBusingRouteSearchResult *result = [PYBusingRouteSearchResult new];
        result.routes = routes;

        _searchBusingRouteComplete(result);
    }
}


- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response; {
    if (_searchCoordFromAddressComplete) {
        if (response.geocodes.count > 0) {
            AMapGeocode            *geocode = response.geocodes[0];
            CLLocationCoordinate2D coor     = CLLocationCoordinate2DMake(geocode.location.latitude,
                                                                         geocode.location.longitude);

            _searchCoordFromAddressComplete(coor);
        } else {
            if (_searchFail) {
                _searchFail([[NSError alloc] initWithDomain:@"没有查询到信息" code:0 userInfo:nil]);
            }
        }
    }
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response; {
    if (_searchAddressFromCoordComplete) {
        _searchAddressFromCoordComplete(response.regeocode.addressComponent.province,
                                        response.regeocode.addressComponent.city,
                                        response.regeocode.addressComponent.district,
                                        response.regeocode.addressComponent.streetNumber.number,
                                        response.regeocode.formattedAddress);
    }
}


#pragma mark - helper
- (NSArray *)_coverToCLLocationsSteps:(NSArray<AMapStep *> *)steps
{
    NSMutableArray *points = [NSMutableArray new];

    for (AMapStep *aStep in steps) {
        NSString *polyline = aStep.polyline;

        NSArray *coors = [self _coverToCLLocationsPolyline:polyline];

        [points addObjectsFromArray:coors];
    }

    return points;
}


- (NSArray *)_coverToCLLocationsPolyline:(NSString *)polyline
{
    NSMutableArray *points = [NSMutableArray new];

    NSArray *coordsArray = [polyline componentsSeparatedByString:@";"];

    for (NSString *aCoordStr in coordsArray) {
        NSArray *coordArray = [aCoordStr componentsSeparatedByString:@","];

        CLLocationCoordinate2D location;
        location.longitude = ((NSNumber *)coordArray[0]).doubleValue;
        location.latitude  = ((NSNumber *)coordArray[1]).doubleValue;

        CLLocation *loc = [[CLLocation alloc] initWithLatitude:location.latitude
                                                     longitude:location.longitude];
        [points addObject:loc];
    }

    return points;
}


@end


#endif