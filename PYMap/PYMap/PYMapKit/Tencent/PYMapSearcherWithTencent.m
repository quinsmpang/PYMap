//
//  PYMapSearchServiceWithYR.m
//  YR
//
//  Created by YR on 15/10/16.
//  Copyright © 2015年 YR. All rights reserved.
//

#ifdef _Map_Tencent

#import "PYMapSearcherWithTencent.h"

@interface PYMapSearcherWithTencent () <QMSSearchDelegate>

@end

@implementation PYMapSearcherWithTencent {
    QMSSearcher        *_mapSearcher;

    PYMapSearchErrorCB    _errorCB;
    PYMapSearchKeywordCompleteCB _kwcompleteCB;
    PYMapSearchWalkRouteCompleteCB _wrCompleteCB;
    PYMapSearchDriveRouteCompleteCB _driCompleteCB;
    PYMapSearchBusRouteCompleteCB _busCompleteCB;
    PYMapSearchCoordinateFromCityCompleteCB _cfcCompleteCB;
    PYMapSearchAddressFromCoordinateCompleteCB _afcCompleteCB;
}

- (instancetype)init
{
    if (self = [super init]) {
        _mapSearcher = [[QMSSearcher alloc] initWithDelegate:self];
    }

    return self;
}

-(void)dealloc{
    _mapSearcher.delegate = nil;
}


/*根据关键字发起检索。*/
- (void)searchKeyword:(NSString *)keyword
                 city:(NSString *)city
            pageIndex:(NSUInteger)pageIndex
         pageCapacity:(NSUInteger)pageCapacity
{
    QMSPoiSearchOption *poiSearchOption = [QMSPoiSearchOption new];
    
    [poiSearchOption setKeyword:keyword];
    [poiSearchOption setPage_index:pageIndex];
    [poiSearchOption setPage_size:pageCapacity];
    [poiSearchOption setBoundaryByRegionWithCityName:city autoExtend:NO];
    
    //        [_poiSearchOption setFilterByCategories:@"房产小区",nil];
    [_mapSearcher searchWithPoiSearchOption:poiSearchOption];
}

/*搜步行路径*/
-(void)searchWalkingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
{
    QMSWalkingRouteSearchOption* aWRSearchOption = [QMSWalkingRouteSearchOption new];
    [aWRSearchOption setFromCoordinate:from];
    [aWRSearchOption setToCoordinate:to];
    [_mapSearcher searchWithWalkingRouteSearchOption:aWRSearchOption];
}


/*搜驾车路径*/
-(void)searchDrivingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                               toCoordinate:(CLLocationCoordinate2D)to
                                 policyType:(PYDrivingRoutePolicyType)type
{
    QMSDrivingRouteSearchOption* aDriSearchOption = [QMSDrivingRouteSearchOption new];
    [aDriSearchOption setFromCoordinate:from];
    [aDriSearchOption setToCoordinate:to];
    QMSDrivingRoutePolicyType qType;
    switch (type) {
        case PYDrivingRoutePolicyType_LeastDistance:
            qType = QMSDrivingRoutePolicyTypeLeastDistance;
            break;
        case PYDrivingRoutePolicyType_LeastFee:
            qType = QMSDrivingRoutePolicyTypeLeastFee;
            break;
        case PYDrivingRoutePolicyType_LeastTime:
            qType = QMSDrivingRoutePolicyTypeLeastTime;
            break;
        case PYDrivingRoutePolicyType_RealTraffic:
            qType = QMSDrivingRoutePolicyTypeRealTraffic;
            break;
        default:
            break;
    }
    
    [aDriSearchOption setPolicyWithType:qType];
    [_mapSearcher searchWithDrivingRouteSearchOption:aDriSearchOption];
}
/*搜公交路径*/
-(void)searchBusingRouteWithFromCoordinate:(CLLocationCoordinate2D)from
                              toCoordinate:(CLLocationCoordinate2D)to
                                policyType:(PYBusingRoutePolicyType)type
{
    QMSBusingRouteSearchOption* aBusSearchOption = [QMSBusingRouteSearchOption new];
    [aBusSearchOption setFromCoordinate:from];
    [aBusSearchOption setToCoordinate:to];
    QMSBusingRoutePolicyType qType;
    switch (type) {
        case PYBusingRoutePolicyTypeLeastTime:
            qType = QMSBusingRoutePolicyTypeLeastTime;
            break;
        case PYBusingRoutePolicyTypeLeastTransfer:
            qType = QMSBusingRoutePolicyTypeLeastTransfer;
            break;
        case PYBusingRoutePolicyTypeLeastWalking:
            qType = QMSBusingRoutePolicyTypeLeastWalking;
            break;
        default:
            break;
    }
    
    [aBusSearchOption setPolicyWithType:qType];
    [_mapSearcher searchWithBusingRouteSearchOption:aBusSearchOption];
}

/*根据地址描述查坐标*/
-(void)searchCoordinateFromCity:(NSString*)city address:(NSString*)address{

    QMSGeoCodeSearchOption* aGCSearchOption = [QMSGeoCodeSearchOption new];
    if (![address hasPrefix:city]) {
        address = [NSString stringWithFormat:@"%@市%@",city,address];
    }
    aGCSearchOption.address = address;
    aGCSearchOption.region = city;
    [_mapSearcher searchWithGeoCodeSearchOption:aGCSearchOption];
}

/*根据坐标查地址描述*/
-(void)searchAddressFromCoordinate:(CLLocationCoordinate2D)coordinate{
    
    QMSReverseGeoCodeSearchOption* aGCSearchOption = [QMSReverseGeoCodeSearchOption new];
    
    [aGCSearchOption setLocationWithCenterCoordinate:coordinate];
    aGCSearchOption.get_poi = false;
    aGCSearchOption.coord_type = QMSReverseGeoCodeCoordinateTencentGoogleGaodeType;

    [_mapSearcher searchWithReverseGeoCodeSearchOption:aGCSearchOption];
}

/*设置检索成功后的回调函数*/
-(void)setSearchKeywordComplete:(PYMapSearchKeywordCompleteCB)completeCB;
{
    _kwcompleteCB = [completeCB copy];
}
/*设置检索成功后的回调函数*/
-(void)setSearchWalkRouteComplete:(PYMapSearchWalkRouteCompleteCB)completeCB
{
    _wrCompleteCB = [completeCB copy];
}
/*设置检索驾车路线成功后的回调函数*/
-(void)setSearchDriveRouteComplete:(PYMapSearchDriveRouteCompleteCB)completeCB
{
    _driCompleteCB = [completeCB copy];
}
/*设置检索公交成功后的回调函数*/
-(void)setSearchBusRouteComplete:(PYMapSearchBusRouteCompleteCB)completeCB
{
    _busCompleteCB = [completeCB copy];
}
/*设置检索成功后的回调函数*/
-(void)setSearchCoordinateFromCityComplete:(PYMapSearchCoordinateFromCityCompleteCB)completeCB
{
    _cfcCompleteCB = [completeCB copy];
}

-(void)setSearchAddressFromCoordinateComplete:(PYMapSearchAddressFromCoordinateCompleteCB)completeCB{
    _afcCompleteCB = [completeCB copy];
}

///*设置检索失败后的回调函数*/
- (void)setError:(PYMapSearchErrorCB)errCB
{
    _errorCB = [errCB copy];
}


#pragma mark - QMSSearchDelegate

- (void)searchWithSuggestionSearchOption:(QMSSuggestionSearchOption *)suggestionSearchOption didReceiveResult:(QMSSuggestionResult *)suggestionSearchResult {
    if (_kwcompleteCB) {
        NSMutableArray *poies = [NSMutableArray array];
        
        for (QMSSuggestionPoiData *poiData in suggestionSearchResult.dataArray) {
            PYMapPoi *poi = [PYMapPoi createWithTitle:poiData.title
                                              address:poiData.address
                                             location:poiData.location];
            [poies addObject:poi];
        }
        
        _kwcompleteCB(poies);
    }
}
- (void)searchWithSearchOption:(QMSSearchOption *)searchOption didFailWithError:(NSError *)error
{
    if (_errorCB != nil) {
        _errorCB(error);
    }
}


- (void)searchWithPoiSearchOption:(QMSPoiSearchOption *)poiSearchOption didReceiveResult:(QMSPoiSearchResult *)poiSearchResult
{
    if (_kwcompleteCB) {
        NSMutableArray *poies = [NSMutableArray array];

        for (QMSSuggestionPoiData *poiData in poiSearchResult.dataArray) {
            PYMapPoi *poi = [PYMapPoi createWithTitle:poiData.title
                                              address:poiData.address
                                             location:poiData.location];
            [poies addObject:poi];
        }

        _kwcompleteCB(poies);
    }
}

- (void)searchWithWalkingRouteSearchOption:(QMSWalkingRouteSearchOption *)walkingRouteSearchOption
                          didRecevieResult:(QMSWalkingRouteSearchResult *)walkingRouteSearchResult
{
    if (_wrCompleteCB) {
        NSMutableArray *routes = [NSMutableArray new];

        for (QMSRoutePlan *aQPlan in walkingRouteSearchResult.routes) {
            PYRoutePlan *aRRPlan = [PYRoutePlan new];
            aRRPlan.distance  = aQPlan.distance;
            aRRPlan.duration  = aQPlan.duration;
            aRRPlan.direction = aQPlan.direction;
            aRRPlan.polyline = [self _coverToCLLocationsQPolyline:aQPlan.polyline];

            [routes addObject:aRRPlan];
        }

        PYWalkingRouteSearchResult *result = [PYWalkingRouteSearchResult new];
        result.routes = routes;

        _wrCompleteCB(result);
    }
}


- (void)searchWithDrivingRouteSearchOption:(QMSDrivingRouteSearchOption *)drivingRouteSearchOption
                          didRecevieResult:(QMSDrivingRouteSearchResult *)drivingRouteSearchResult
{
    if (_driCompleteCB) {
        NSMutableArray *routes = [NSMutableArray new];
        
        for (QMSRoutePlan *aQPlan in drivingRouteSearchResult.routes) {
            PYRoutePlan *aRRPlan = [PYRoutePlan new];
            aRRPlan.distance  = aQPlan.distance;
            aRRPlan.duration  = aQPlan.duration;
            aRRPlan.direction = aQPlan.direction;
            aRRPlan.polyline = [self _coverToCLLocationsQPolyline:aQPlan.polyline];
            
            [routes addObject:aRRPlan];
        }
        
        PYDrivingRouteSearchResult *result = [PYDrivingRouteSearchResult new];
        result.routes = routes;
        
        _driCompleteCB(result);
    }

}


- (void)searchWithBusingRouteSearchOption:(QMSBusingRouteSearchOption *)busingRouteSearchOption
                         didRecevieResult:(QMSBusingRouteSearchResult *)busingRouteSearchResult
{
    if (_busCompleteCB) {
        NSMutableArray *routes = [NSMutableArray new];
        
        for (QMSBusingRoutePlan *aQPlan in busingRouteSearchResult.routes) {
            PYBusingRoutePlan *aRRPlan = [PYBusingRoutePlan new];
            aRRPlan.distance  = aQPlan.distance;
            aRRPlan.duration  = aQPlan.duration;
            
            NSMutableArray* PYSteps = [NSMutableArray new];
            for (QMSBusingSegmentRoutePlan* segment in aQPlan.steps) {
                if (![segment isKindOfClass:[QMSBusingRoutePlan class]]) continue;
              
                PYBusingSegmentRoutePlan* PYSegment = [PYBusingSegmentRoutePlan new];
                PYSegment.direction = segment.direction;
                PYSegment.distance  = segment.distance;
                PYSegment.duration  = segment.duration;
                PYSegment.polyline  = [self _coverToCLLocationsQPolyline:segment.polyline];
               
                if ([segment.mode isEqualToString:@"DRIVING"]) {
                    PYSegment.mode = PYBusingRouteStepModeType_Driving;
                }else{
                    PYSegment.mode = PYBusingRouteStepModeType_Walking;
                }
                
                [PYSteps addObject:PYSegment];
            }
            
            aRRPlan.steps = PYSteps;
            
            [routes addObject:aRRPlan];
        }
        
        PYBusingRouteSearchResult *result = [PYBusingRouteSearchResult new];
        result.routes = routes;
        
        _busCompleteCB(result);
    }


}

-(void)searchWithGeoCodeSearchOption:(QMSGeoCodeSearchOption *)geoCodeSearchOption
                    didReceiveResult:(QMSGeoCodeSearchResult *)geoCodeSearchResult{
    
    if (_cfcCompleteCB) {
        _cfcCompleteCB(geoCodeSearchResult.location);
    }



}

- (void)searchWithReverseGeoCodeSearchOption:(QMSReverseGeoCodeSearchOption *)reverseGeoCodeSearchOption didReceiveResult:(QMSReverseGeoCodeSearchResult *)reverseGeoCodeSearchResult{

    if (_afcCompleteCB) {
        _afcCompleteCB(reverseGeoCodeSearchResult.address_component.province,
                       reverseGeoCodeSearchResult.address_component.city,
                       reverseGeoCodeSearchResult.address_component.district,
                       reverseGeoCodeSearchResult.address_component.street_number,
                       reverseGeoCodeSearchResult.formatted_addresses.recommend);
    }
}


#pragma mark - helper
- (NSArray*)_coverToCLLocationsQPolyline:(NSArray*)polyline{

    NSMutableArray* points = [NSMutableArray new];
    
    for (id obj in polyline) {
        if (strcmp(@encode(CLLocationCoordinate2D), [obj objCType]) == 0) {
            CLLocationCoordinate2D coord;
            [obj getValue:&coord];
            
            CLLocation* loc = [[CLLocation alloc] initWithLatitude:coord.latitude
                                                         longitude:coord.longitude];
            [points addObject:loc];
        }
    }
    
    return points;
}

@end

#endif