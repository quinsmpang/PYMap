//
//  RRMapSearcherWithBaidu.m
//  YR
//
//  Created by YR on 15/10/16.
//  Copyright © 2015年 YR. All rights reserved.
//

#import "RRMapSearcherWithBaidu.h"
#import <BaiduMapAPI_Utils/BMKGeometry.h>

@interface RRMapSearcherWithBaidu () <BMKGeoCodeSearchDelegate,BMKPoiSearchDelegate,BMKRouteSearchDelegate>
@end

@implementation RRMapSearcherWithBaidu {
    
    BMKGeoCodeSearch* _geoCodeSearch;
    BMKPoiSearch*     _poiSearch;
    BMKRouteSearch*   _routeSearch;
    
    RRMapSearchErrorCB    _errorCB;
    RRMapSearchKeywordCompleteCB _kwcompleteCB;
    RRMapSearchWalkRouteCompleteCB _wrCompleteCB;
    RRMapSearchDriveRouteCompleteCB _driCompleteCB;
    RRMapSearchBusRouteCompleteCB _busCompleteCB;
    RRMapSearchCoordinateFromCityCompleteCB _cfcCompleteCB;
    RRMapSearchAddressFromCoordinateCompleteCB _afcCompleteCB;
}

- (instancetype)init
{
    if (self = [super init]) {
        _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
        _poiSearch = [[BMKPoiSearch alloc] init];
        _routeSearch = [[BMKRouteSearch alloc] init];
        
        _geoCodeSearch.delegate = self;
        _poiSearch.delegate = self;
        _routeSearch.delegate = self;
    }
    
    return self;
}

-(void)dealloc{
    _geoCodeSearch.delegate = nil;
    _poiSearch.delegate = nil;
    _routeSearch.delegate = nil;
}


/*根据关键字发起检索。*/
- (void)searchKeyword:(NSString *)keyword
                 city:(NSString *)city
            pageIndex:(NSUInteger)pageIndex
         pageCapacity:(NSUInteger)pageCapacity
{
    BMKCitySearchOption *poiSearchOption = [BMKCitySearchOption new];
    
    [poiSearchOption setKeyword:keyword];
    [poiSearchOption setPageIndex:pageIndex];
    [poiSearchOption setPageCapacity:pageCapacity];
    [poiSearchOption setCity:city];
    
    [_poiSearch  poiSearchInCity:poiSearchOption];
}

/*搜步行路径*/
-(void)searchWalkingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
{
    BMKWalkingRoutePlanOption* aWRSearchOption = [BMKWalkingRoutePlanOption new];
    BMKPlanNode* fromNode = [BMKPlanNode new];
    BMKPlanNode* toNode = [BMKPlanNode new];

    fromNode.pt = [RRCoordCover convertGCJ02ToBD:from];
    toNode.pt = [RRCoordCover convertGCJ02ToBD:to];
    
    [aWRSearchOption setFrom:fromNode];
    [aWRSearchOption setTo:toNode];
    [_routeSearch walkingSearch:aWRSearchOption];
}


/*搜驾车路径*/
-(void)searchDrivingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
                                 policyType:(RRDrivingRoutePolicyType)type
{
    BMKDrivingRoutePlanOption* aDriSearchOption = [BMKDrivingRoutePlanOption new];
    BMKPlanNode* fromNode = [BMKPlanNode new];
    BMKPlanNode* toNode = [BMKPlanNode new];
    
    fromNode.pt = [RRCoordCover convertGCJ02ToBD:from];
    toNode.pt = [RRCoordCover convertGCJ02ToBD:to];

    BMKDrivingPolicy qType;
    switch (type) {
        case RRDrivingRoutePolicyType_LeastDistance:
            qType = BMK_DRIVING_DIS_FIRST;
            break;
        case RRDrivingRoutePolicyType_LeastFee:
            qType = BMK_DRIVING_FEE_FIRST;
            break;
        case RRDrivingRoutePolicyType_LeastTime:
            qType = BMK_DRIVING_TIME_FIRST;
            break;
        case RRDrivingRoutePolicyType_RealTraffic:
            qType = BMK_DRIVING_BLK_FIRST;
            break;
        default:
            break;
    }
    
    [aDriSearchOption setDrivingPolicy:qType];
    [_routeSearch drivingSearch:aDriSearchOption];
}
/*搜公交路径*/
-(void)searchBusingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                              toCoordinate:(CLLocationCoordinate2D)to
                                policyType:(RRBusingRoutePolicyType)type
{
    BMKTransitRoutePlanOption* aBusSearchOption = [BMKTransitRoutePlanOption new];
    BMKPlanNode* fromNode = [BMKPlanNode new];
    BMKPlanNode* toNode = [BMKPlanNode new];
    
    fromNode.pt = [RRCoordCover convertGCJ02ToBD:from];
    toNode.pt = [RRCoordCover convertGCJ02ToBD:to];

    BMKTransitPolicy qType;
    switch (type) {
        case RRBusingRoutePolicyTypeLeastTime:
            qType = BMK_TRANSIT_TIME_FIRST;
            break;
        case RRBusingRoutePolicyTypeLeastTransfer:
            qType = BMK_TRANSIT_TRANSFER_FIRST;
            break;
        case RRBusingRoutePolicyTypeLeastWalking:
            qType = BMK_TRANSIT_WALK_FIRST;
            break;
        default:
            break;
    }
    
    [aBusSearchOption setTransitPolicy:qType];
    [_routeSearch transitSearch:aBusSearchOption];
}

/*根据地址描述查坐标*/
-(void)searchCoordinateFromCity:(NSString*)city address:(NSString*)address{
    
    BMKGeoCodeSearchOption* aGCSearchOption = [BMKGeoCodeSearchOption new];
    if (![address hasPrefix:city]) {
        address = [NSString stringWithFormat:@"%@市%@",city,address];
    }
    aGCSearchOption.address = address;
    aGCSearchOption.city = city;
    [_geoCodeSearch geoCode:aGCSearchOption];
}

/*根据坐标查地址描述*/
-(void)searchAddressFromCoordinate:(CLLocationCoordinate2D)coordinate{
    
    BMKReverseGeoCodeOption* aGCSearchOption = [BMKReverseGeoCodeOption new];
    coordinate = [RRCoordCover convertGCJ02ToBD:coordinate];
    [aGCSearchOption setReverseGeoPoint:coordinate];
    [_geoCodeSearch reverseGeoCode:aGCSearchOption];
}

/*设置检索成功后的回调函数*/
-(void)setSearchKeywordComplete:(RRMapSearchKeywordCompleteCB)completeCB;
{
    _kwcompleteCB = [completeCB copy];
}
/*设置检索成功后的回调函数*/
-(void)setSearchWalkRouteComplete:(RRMapSearchWalkRouteCompleteCB)completeCB
{
    _wrCompleteCB = [completeCB copy];
}
/*设置检索驾车路线成功后的回调函数*/
-(void)setSearchDriveRouteComplete:(RRMapSearchDriveRouteCompleteCB)completeCB
{
    _driCompleteCB = [completeCB copy];
}
/*设置检索公交成功后的回调函数*/
-(void)setSearchBusRouteComplete:(RRMapSearchBusRouteCompleteCB)completeCB
{
    _busCompleteCB = [completeCB copy];
}
/*设置检索成功后的回调函数*/
-(void)setSearchCoordinateFromCityComplete:(RRMapSearchCoordinateFromCityCompleteCB)completeCB
{
    _cfcCompleteCB = [completeCB copy];
}

-(void)setSearchAddressFromCoordinateComplete:(RRMapSearchAddressFromCoordinateCompleteCB)completeCB{
    _afcCompleteCB = [completeCB copy];
}

///*设置检索失败后的回调函数*/
- (void)setError:(RRMapSearchErrorCB)errCB
{
    _errorCB = [errCB copy];
}


#pragma mark - QMSSearchDelegate


- (void)onGetPoiResult:(BMKPoiSearch*)searcher
                result:(BMKPoiResult*)poiResult
             errorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode != BMK_SEARCH_NO_ERROR) {
        if (_errorCB != nil) {
            _errorCB(nil);
        }
        return;
    }
    
    if (_kwcompleteCB) {
        NSMutableArray *poies = [NSMutableArray array];
        
        for (BMKPoiInfo *poiData in poiResult.poiInfoList) {
            RRMapPoi *poi = [RRMapPoi createWithTitle:poiData.name
                                              address:poiData.address
                                             location:poiData.pt];
            [poies addObject:poi];
        }
        
        _kwcompleteCB(poies);
    }
}

- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher
                         result:(BMKWalkingRouteResult*)result
                      errorCode:(BMKSearchErrorCode)error
{
    if (error != BMK_SEARCH_NO_ERROR) {
        if (_errorCB != nil) {
            _errorCB(nil);
        }
        return;
    }
    
    if (_wrCompleteCB) {
        NSMutableArray *routes = [NSMutableArray new];
        
        for (BMKWalkingRouteLine *aQPlan in result.routes) {
            
            RRRoutePlan *aRRPlan = [RRRoutePlan new];
            aRRPlan.distance  = aQPlan.distance;
            aRRPlan.duration  = aQPlan.duration.dates*24*60*60
                                + aQPlan.duration.hours*60*60
                                + aQPlan.duration.minutes*60
                                + aQPlan.duration.seconds;
            
            aRRPlan.direction = nil;
            
            aRRPlan.polyline = [self _coverToCLLocationsQPolyline:aQPlan.steps];
            
            [routes addObject:aRRPlan];
        }
        
        RRWalkingRouteSearchResult *result = [RRWalkingRouteSearchResult new];
        result.routes = routes;
        
        _wrCompleteCB(result);
        
    }
}


- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher
                         result:(BMKDrivingRouteResult*)result
                      errorCode:(BMKSearchErrorCode)error;
{
    if (error != BMK_SEARCH_NO_ERROR) {
        if (_errorCB != nil) {
            _errorCB(nil);
        }
        return;
    }
    
    if (_driCompleteCB) {
        NSMutableArray *routes = [NSMutableArray new];
        
        for (BMKDrivingRouteLine *aQPlan in result.routes) {
            RRRoutePlan *aRRPlan = [RRRoutePlan new];
            aRRPlan.distance  = aQPlan.distance;
            aRRPlan.duration  = aQPlan.duration.dates*24*60*60
                                + aQPlan.duration.hours*60*60
                                + aQPlan.duration.minutes*60
                                + aQPlan.duration.seconds;
            aRRPlan.direction = nil;
            aRRPlan.polyline = [self _coverToCLLocationsQPolyline:aQPlan.steps];
            
            [routes addObject:aRRPlan];
        }
        
        RRDrivingRouteSearchResult *result = [RRDrivingRouteSearchResult new];
        result.routes = routes;
        
        _driCompleteCB(result);
    }
    
}


- (void)onGetTransitRouteResult:(BMKRouteSearch*)searcher
                         result:(BMKTransitRouteResult*)result
                      errorCode:(BMKSearchErrorCode)error
{
    if (error != BMK_SEARCH_NO_ERROR) {
        if (_errorCB != nil) {
            _errorCB(nil);
        }
        return;
    }
    
    if (_busCompleteCB) {
        NSMutableArray *routes = [NSMutableArray new];
        
        for (BMKTransitRouteLine *aQPlan in result.routes) {
            RRBusingRoutePlan *aRRPlan = [RRBusingRoutePlan new];
            aRRPlan.distance  = aQPlan.distance;
            aRRPlan.duration  = aQPlan.duration.dates*24*60*60
            + aQPlan.duration.hours*60*60
            + aQPlan.duration.minutes*60
            + aQPlan.duration.seconds;
            
            NSMutableArray* rrSteps = [NSMutableArray new];
            for (BMKTransitStep* segment in aQPlan.steps) {
                if (![segment isKindOfClass:[BMKTransitStep class]]) continue;
                
                RRBusingSegmentRoutePlan* rrSegment = [RRBusingSegmentRoutePlan new];
                rrSegment.direction = nil;
                rrSegment.distance  = segment.distance;
                rrSegment.duration  = segment.duration;
                rrSegment.polyline  = [self _coverToCLLocationsStep:segment];
                
                if (segment.stepType == BMK_BUSLINE) {
                    rrSegment.mode = RRBusingRouteStepModeType_Driving;
                }else{
                    rrSegment.mode = RRBusingRouteStepModeType_Walking;
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

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher
                    result:(BMKGeoCodeResult *)result
                 errorCode:(BMKSearchErrorCode)error{
    
    if (error != BMK_SEARCH_NO_ERROR) {
        if (_errorCB != nil) {
            _errorCB(nil);
        }
        return;
    }
    
    
    if (_cfcCompleteCB) {
        _cfcCompleteCB([RRCoordCover convertGCJ02ToBD:result.location]);
    }
    
    
    
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher
                           result:(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    
    if (error != BMK_SEARCH_NO_ERROR) {
        if (_errorCB != nil) {
            _errorCB(nil);
        }
        return;
    }
    
    if (_afcCompleteCB) {
        _afcCompleteCB(result.addressDetail.province,
                       result.addressDetail.city,
                       result.addressDetail.district,
                       result.addressDetail.streetNumber,
                       result.address);
    }
}


#pragma mark - helper
- (NSArray*)_coverToCLLocationsQPolyline:(NSArray<BMKRouteStep*>*)polyline{
    
    NSMutableArray* points = [NSMutableArray new];
    
    for (BMKRouteStep* obj in polyline) {
       
        
        NSArray* addPoints = [self _coverToCLLocationsStep:obj];
    
        [points addObjectsFromArray:addPoints];
    }
    
    return points;
}


- (NSArray*)_coverToCLLocationsStep:(BMKRouteStep*)step{
    
    NSMutableArray* points = [NSMutableArray new];
    
    for (int i = 0; i < step.pointsCount; i++) {
     
        BMKMapPoint point;
        point.x = step.points[i].x;
        point.y = step.points[i].y;
        
        CLLocationCoordinate2D coor = BMKCoordinateForMapPoint(point);
        
        coor = [RRCoordCover convertBDToGCJ02:coor];
        
        CLLocation* loc =  [[CLLocation alloc] initWithLatitude:coor.latitude
                                                      longitude:coor.longitude];
        [points addObject:loc];

    }
    
    return points;
}

@end
