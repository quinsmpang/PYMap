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

    PYMapSearcherrorCB                         _errorCB;
    PYMapSearchKeywordCompleteCB               _kwcompleteCB;
    PYMapSearchWalkRouteCompleteCB             _wrCompleteCB;
    PYMapSearchDriveRouteCompleteCB            _driCompleteCB;
    PYMapSearchBusRouteCompleteCB              _busCompleteCB;
    PYMapSearchCoordinateFromCityCompleteCB    _cfcCompleteCB;
    PYMapSearchAddressFromCoordinateCompleteCB _afcCompleteCB;
}

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
- (void)searchKeyword:(NSString *)keyword
                 city:(NSString *)city
            pageIndex:(NSUInteger)pageIndex
         pageCapacity:(NSUInteger)pageCapacity
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
                                  policyType:(RRDrivingRoutePolicyType)type
{
    AMapDrivingRouteSearchRequest *aDriSearchOption = [AMapDrivingRouteSearchRequest new];

    AMapGeoPoint *orig = [AMapGeoPoint locationWithLatitude:from.latitude longitude:from.longitude];
    AMapGeoPoint *dest = [AMapGeoPoint locationWithLatitude:to.latitude longitude:to.longitude];

    aDriSearchOption.origin      = orig;
    aDriSearchOption.destination = dest;

    MADrivingStrategy strategy;
    switch (type) {
    case RRDrivingRoutePolicyType_LeastDistance:
        strategy = MADrivingStrategyShortest;
        break;
    case RRDrivingRoutePolicyType_LeastFee:
        strategy = MADrivingStrategyMinFare;
        break;
    case RRDrivingRoutePolicyType_LeastTime:
        strategy = MADrivingStrategyFastest;
        break;
    case RRDrivingRoutePolicyType_RealTraffic:
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
                                 policyType:(RRBusingRoutePolicyType)type
{
    AMapTransitRouteSearchRequest *aBusSearchOption = [AMapTransitRouteSearchRequest new];

    AMapGeoPoint *orig = [AMapGeoPoint locationWithLatitude:from.latitude longitude:from.longitude];
    AMapGeoPoint *dest = [AMapGeoPoint locationWithLatitude:to.latitude longitude:to.longitude];

    aBusSearchOption.origin      = orig;
    aBusSearchOption.destination = dest;

    MATransitStrategy strategy;
    switch (type) {
    case RRBusingRoutePolicyTypeLeastTime:
        strategy = MATransitStrategyFastest;
        break;
    case RRBusingRoutePolicyTypeLeastTransfer:
        strategy = MATransitStrategyMinTransfer;
        break;
    case RRBusingRoutePolicyTypeLeastWalking:
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


/*设置检索成功后的回调函数*/
- (void)setSearchKeywordComplete:(PYMapSearchKeywordCompleteCB)completeCB;
{
    _kwcompleteCB = [completeCB copy];
}
/*设置检索成功后的回调函数*/
- (void)setSearchWalkRouteComplete:(PYMapSearchWalkRouteCompleteCB)completeCB
{
    _wrCompleteCB = [completeCB copy];
}


/*设置检索驾车路线成功后的回调函数*/
- (void)setSearchDriveRouteComplete:(PYMapSearchDriveRouteCompleteCB)completeCB
{
    _driCompleteCB = [completeCB copy];
}


/*设置检索公交成功后的回调函数*/
- (void)setSearchBusRouteComplete:(PYMapSearchBusRouteCompleteCB)completeCB
{
    _busCompleteCB = [completeCB copy];
}


/*设置检索成功后的回调函数*/
- (void)setSearchCoordinateFromCityComplete:(PYMapSearchCoordinateFromCityCompleteCB)completeCB
{
    _cfcCompleteCB = [completeCB copy];
}


- (void)setSearchAddressFromCoordinateComplete:(PYMapSearchAddressFromCoordinateCompleteCB)completeCB
{
    _afcCompleteCB = [completeCB copy];
}


///*设置检索失败后的回调函数*/
- (void)setError:(PYMapSearcherrorCB)errCB
{
    _errorCB = [errCB copy];
}


#pragma mark - QMSSearchDelegate


- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error;
{
    if (_errorCB != nil) {
        _errorCB(error);
    }
}


- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response;
{
    if (_kwcompleteCB) {
        NSMutableArray *poies = [NSMutableArray array];

        for (AMapPOI *poiData in response.pois) {
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(poiData.location.latitude,
                                                                     poiData.location.longitude);

            RRMapPoi *poi = [RRMapPoi createWithTitle:poiData.name
                                              address:poiData.address
                                             location:coor];
            [poies addObject:poi];
        }

        _kwcompleteCB(poies);
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
    if (_wrCompleteCB) {
        NSMutableArray *routes = [NSMutableArray new];

        for (AMapPath *aPlan in response.route.paths) {
            RRRoutePlan *aRRPlan = [RRRoutePlan new];
            aRRPlan.distance = aPlan.distance;
            aRRPlan.duration = aPlan.duration;
            aRRPlan.polyline = [self _coverToCLLocationsSteps:aPlan.steps];

            [routes addObject:aRRPlan];
        }

        RRWalkingRouteSearchResult *result = [RRWalkingRouteSearchResult new];
        result.routes = routes;

        _wrCompleteCB(result);
    }
}


- (void)onDrivingRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (_driCompleteCB) {
        NSMutableArray *routes = [NSMutableArray new];

        for (AMapPath *aPlan in response.route.paths) {
            RRRoutePlan *aRRPlan = [RRRoutePlan new];
            aRRPlan.distance = aPlan.distance;
            aRRPlan.duration = aPlan.duration;
            aRRPlan.polyline = [self _coverToCLLocationsSteps:aPlan.steps];

            [routes addObject:aRRPlan];
        }

        RRDrivingRouteSearchResult *result = [RRDrivingRouteSearchResult new];
        result.routes = routes;

        _driCompleteCB(result);
    }
}


- (void)onBusingRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (_busCompleteCB) {
        NSMutableArray *routes = [NSMutableArray new];

        for (AMapTransit *aPlan in response.route.transits) {
            RRBusingRoutePlan *aRRPlan = [RRBusingRoutePlan new];
            aRRPlan.distance = aPlan.distance;
            aRRPlan.duration = aPlan.duration;

            NSMutableArray *rrSteps = [NSMutableArray new];
            for (AMapSegment *segment in aPlan.segments) {
                if (![segment isKindOfClass:[AMapSegment class]]) continue;

                RRBusingSegmentRoutePlan *rrSegment = [RRBusingSegmentRoutePlan new];

                NSArray *busChooses = segment.buslines;

                if (busChooses.count > 0) {
                    rrSegment.mode = RRBusingRouteStepModeType_Driving;
                    AMapBusLine *busLine = segment.buslines[0];

                    rrSegment.polyline = [self _coverToCLLocationsPolyline:busLine.polyline];
                } else {
                    rrSegment.mode = RRBusingRouteStepModeType_Walking;

                    AMapWalking *walking = segment.walking;
                    rrSegment.polyline = [self _coverToCLLocationsSteps:walking.steps];
                }
                
                [rrSteps addObject:rrSegment];
            }

            aRRPlan.steps = rrSteps;

            [routes addObject:aRRPlan];
        }

        RRBusingRouteSearchResult *result = [RRBusingRouteSearchResult new];
        result.routes = routes;

        _busCompleteCB(result);
    }
}


- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response; {
    if (_cfcCompleteCB) {
        if (response.geocodes.count > 0) {
            AMapGeocode            *geocode = response.geocodes[0];
            CLLocationCoordinate2D coor     = CLLocationCoordinate2DMake(geocode.location.latitude,
                                                                         geocode.location.longitude);

            _cfcCompleteCB(coor);
        } else {
            if (_errorCB != nil) {
                _errorCB([[NSError alloc] initWithDomain:@"没有查询到信息" code:0 userInfo:nil]);
            }
        }
    }
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response; {
    if (_afcCompleteCB) {
        _afcCompleteCB(response.regeocode.addressComponent.province,
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
        NSString* polyline = aStep.polyline;
       
        NSArray* coors = [self _coverToCLLocationsPolyline:polyline];
        
        [points addObjectsFromArray:coors];
       
    }

    return points;
}


- (NSArray *)_coverToCLLocationsPolyline:(NSString *)polyline
{
    NSMutableArray *points = [NSMutableArray new];
   
    NSArray *coordsArray = [polyline componentsSeparatedByString:@";"];
    
    
    for (NSString* aCoordStr in coordsArray) {
       
        NSArray *coordArray = [aCoordStr componentsSeparatedByString: @","];
        
         CLLocationCoordinate2D location;
        location.longitude = ((NSNumber *)coordArray[0]).doubleValue;
        location.latitude = ((NSNumber *)coordArray[1]).doubleValue;
        
        CLLocation* loc = [[CLLocation alloc] initWithLatitude:location.latitude
                                                     longitude:location.longitude];
        [points addObject:loc];
    }

    

//        if (strcmp(@encode(CLLocationCoordinate2D), [obj objCType]) == 0) {
//            CLLocationCoordinate2D coord;
//            [obj getValue:&coord];
//
//            CLLocation* loc = [[CLLocation alloc] initWithLatitude:coord.latitude
//                                                         longitude:coord.longitude];
//            [points addObject:loc];
//        }

    return points;
}


@end


#endif