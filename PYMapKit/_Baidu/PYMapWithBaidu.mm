//
//  RRMapWithBaidu.m
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//
#ifdef _Map_Baidu

#import "RRMapWithBaidu.h"
#import "RRBaiduImageAnnotation.h"
#import "RRCoordCover.h"
#import "BMK+Add.h"
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPolygon.h>
#import <BaiduMapAPI_Map/BMKPolyline.h>
#import <BaiduMapAPI_Map/BMKPolygonView.h>
#import <BaiduMapAPI_Map/BMKPolylineView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>


typedef NS_ENUM (NSUInteger, BMKAnonotationType) {
    BMKAnonotationType_Normal,    //只有图片
    BMKAnonotationType_Callout, //带callout的气泡
};


@interface RRPointAnnotationSave : NSObject

@property(nonatomic, strong) BMKPointAnnotation *annotation;
@property(nonatomic, strong) NSString           *uid;
@property(nonatomic, strong) NSString           *imageName;
@property(nonatomic, assign) BMKAnonotationType type;

@end


@interface RRMapWithBaidu () <BMKMapViewDelegate>
@end


@implementation RRMapWithBaidu {
    BMKMapView          *_mapView;
    NSMutableDictionary *_overlayInfo;
    NSMutableDictionary *_annotationInfo;
}

@synthesize annotationSelectAtUid        = _annotationSelectAtUid;
@synthesize annotationDeSelectAtUid      = _annotationDeSelectAtUid;
@synthesize annotationCalloutViewWithUid = _annotationCalloutViewWithUid;
@synthesize annotationImageWithUid       = _annotationImageWithUid;
@synthesize mapDelegate                  = _mapDelegate;

- (instancetype)init
{
    if (self = [super init]) {
        _mapView        = [[BMKMapView alloc] init];
        _overlayInfo    = [[NSMutableDictionary alloc] init];
        _annotationInfo = [[NSMutableDictionary alloc] init];

        _mapView.delegate = self;
    }

    return self;
}


- (void)dealloc
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
}


- (UIView *)mapView
{
    return _mapView;
}


/*!
 *  @brief  向地图窗口添加标注，需要实现BMKMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 *
 *  @param annotation 要添加的标注
 */
- (void)addAnnotation:(id <RRAnnotation>)annotation imageName:(NSString *)imgStr uid:(NSString *)uid
{
    [self _addAnnotation:annotation imageName:imgStr uid:uid withType:BMKAnonotationType_Normal];
}


- (void)addCalloutAnnotation:(id<RRAnnotation>)annotation
                   imageName:(NSString *)imgStr
                         uid:(NSString *)uid
{
    [self _addAnnotation:annotation imageName:imgStr uid:uid withType:BMKAnonotationType_Callout];
}


- (void)_addAnnotation:(id<RRAnnotation>)annotation
             imageName:(NSString *)imgStr
                   uid:(NSString *)uid
              withType:(BMKAnonotationType)type
{
    if (uid == nil) return;

    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc] init];
    pointAnnotation._uid_      = uid;
    pointAnnotation.coordinate = [RRCoordCover convertGCJ02ToBD:
                                  [annotation coordinate]];;

    RRPointAnnotationSave *save = [RRPointAnnotationSave new];
    save.annotation = pointAnnotation;
    save.imageName  = imgStr;
    save.type       = type;

    [_annotationInfo setObject:save forKey:uid];

    [_mapView addAnnotation:pointAnnotation];
}


/*!
 *  @brief  移除一组标注
 *
 *  @param annotations 要移除的标注数组
 */
- (void)removeAnnotations:(NSArray *)annotationUIDs
{
    NSMutableArray *pointAnnotations = [NSMutableArray array];
    for (NSString *annotationUID in annotationUIDs) {
        if (![annotationUID isKindOfClass:[NSString class]]) return;

        RRPointAnnotationSave *pointAnnotation = [_annotationInfo objectForKey:annotationUID];
        if (pointAnnotation) {
            [pointAnnotations addObject:pointAnnotation.annotation];
            [_annotationInfo removeObjectForKey:annotationUID];
        }
    }

    [_mapView removeAnnotations:pointAnnotations];
}


/*!
 *  @brief  移除标注
 *
 *  @param annotationUID 要移除的标注的唯一标识
 */
- (void)removeAnnotation:(NSString *)annotationUID;
{
    RRPointAnnotationSave *pointAnnotation = [_annotationInfo objectForKey:annotationUID];
    if (pointAnnotation) {
        [_mapView removeAnnotation:pointAnnotation.annotation];
        [_annotationInfo removeObjectForKey:annotationUID];
    }
}


/*!
 *  @brief  设定当前地图的region
 *
 *  @param region   要设定的地图范围，用经纬度的方式表示
 *  @param animated 是否采用动画
 */
- (void)setRegion:(RRCoordinateRegion)region animated:(BOOL)animated
{
    CLLocationCoordinate2D center = [RRCoordCover convertGCJ02ToBD:region.center];

    BMKCoordinateRegion qRegin = BMKCoordinateRegionMake(center,
                                                         BMKCoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta));

    [_mapView setRegion:qRegin animated:animated];
}


- (RRCoordinateRegion)regionThatFits:(RRCoordinateRegion)region
{
    CLLocationCoordinate2D center = [RRCoordCover convertGCJ02ToBD:region.center];

    BMKCoordinateRegion qRegin = BMKCoordinateRegionMake(center,
                                                         BMKCoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta));
    qRegin = [_mapView regionThatFits:qRegin];

    return RRCoordinateRegionMake([RRCoordCover convertBDToGCJ02:qRegin.center],
                                  RRCoordinateSpanMake(qRegin.span.latitudeDelta, qRegin.span.longitudeDelta));
}


- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated
{
    CLLocationCoordinate2D center = [RRCoordCover convertGCJ02ToBD:coordinate];

    [_mapView setCenterCoordinate:center animated:animated];
}


- (void)addOverLayer:(NSArray *)coordinates strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor lineWidth:(CGFloat)lineWidth uid:(NSString *)uid
{
    if (uid == nil) return;

    BMKMapPoint *temppoints = new BMKMapPoint[[coordinates count]];
    for (int i = 0; i < [coordinates count]; i++) {
        NSString *loc   = [coordinates objectAtIndex:i];
        NSArray  *split = [loc componentsSeparatedByString:@","];
        NSAssert(split.count == 2, @"Coordinate descripe string need 'a,b'");
        NSString               *lon = [split objectAtIndex:0];
        NSString               *lat = [split objectAtIndex:1];
        CLLocationCoordinate2D coor;
        coor.longitude = [lon floatValue];
        coor.latitude  = [lat floatValue];
        coor           = [RRCoordCover convertGCJ02ToBD:coor];
        BMKMapPoint pt = BMKMapPointForCoordinate(coor);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }

    BMKPolygon *overlay = [BMKPolygon polygonWithPoints:temppoints count:coordinates.count];
    overlay._uid_ = uid;

    NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:strokeColor, @"strokeColor"
                             , fillColor, @"fillColor"
                             , @(lineWidth), @"lineWidth"
                             , @"Polygon", @"shape"
                             , overlay, @"view"
                             , nil];

    [_overlayInfo setObject:dicInfo forKey:uid];

    [_mapView addOverlay:overlay];
    delete temppoints;
}


- (void)addRouteWithCoords:(NSArray *)coordinates
               strokeColor:(UIColor *)strokeColor
                 lineWidth:(CGFloat)lineWidth
                       uid:(NSString *)uid
{
    if (uid == nil) return;

    BMKMapPoint *temppoints = new BMKMapPoint[[coordinates count]];
    for (int i = 0; i < [coordinates count]; i++) {
        CLLocation *loc = [coordinates objectAtIndex:i];
        NSAssert([loc isKindOfClass:[CLLocation class]], @"Coordinate is CLLocation Object");

        CLLocationCoordinate2D coor  = [RRCoordCover convertGCJ02ToBD:loc.coordinate];
        BMKMapPoint pt = BMKMapPointForCoordinate(coor);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }

    BMKPolyline *line = [BMKPolyline polylineWithPoints:temppoints count:coordinates.count];
    line._uid_ = uid;

    NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys
                             :strokeColor, @"strokeColor"
                             , @(lineWidth), @"lineWidth"
                             , @"Polyline", @"shape"
                             , line, @"view"
                             , nil];

    [_overlayInfo setObject:dicInfo forKey:uid];

    [_mapView addOverlay:line];
    delete temppoints;
}


/*!
 *  @brief  是否支持平移, 默认为YES
 */
- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _mapView.scrollEnabled = scrollEnabled;
}


/*!
 *  @brief  是否支持缩放, 默认为YES
 */
- (void)setZoomEnabled:(BOOL)zoomEnabled
{
    _mapView.zoomEnabled = zoomEnabled;
}


/*!
 *  @brief  设置当前地图缩放级别
 *
 *  @param zoomScale    目标缩放级别与当前级别的比例
 *  @param animated     是否采用动画
 */
- (void)setZoomScale:(double)zoomScale animated:(BOOL)animated
{
//    [_mapView setZoomLevel:zoomScale  animated:animated];

    [_mapView setZoomLevel:zoomScale];
}


/*!
 *  @brief  同时设置中心点与缩放级别
 *
 *  @param coordinate   要设定的地图中心点经纬度
 *  @param newZoomLevel 目标缩放级别
 *  @param animated     是否采用动画
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(double)newZoomLevel animated:(BOOL)animated
{
    CLLocationCoordinate2D center = [RRCoordCover convertGCJ02ToBD:coordinate];

    [_mapView setCenterCoordinate:center];
    [_mapView setZoomLevel:newZoomLevel];

//    [_mapView setCenterCoordinate:coordinate zoomLevel:newZoomLevel animated:animated];
}


- (double)getZoomLevel
{
    return _mapView.zoomLevel;
}


- (RRCoordinateRegion)getMapRegion
{
    CLLocationCoordinate2D center = [RRCoordCover convertBDToGCJ02:_mapView.region.center];

    RRCoordinateSpan span = RRCoordinateSpanMake(_mapView.region.span.latitudeDelta,
                                                 _mapView.region.span.longitudeDelta);

    RRCoordinateRegion region = RRCoordinateRegionMake(center,
                                                       span);

    return region;
}


/*!
 *  @brief  根据annotation生成对应的view
 *
 *  @param mapView    地图view
 *  @param annotation 指定的标注
 *
 *  @return 指定标注对应的view
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKShape class]]) {
        BMKShape *shape = (BMKShape *)overlay;
        NSString *uid   = shape._uid_;

        NSDictionary *dic = [_overlayInfo objectForKey:uid];
        if (dic && [[dic objectForKey:@"shape"] isEqualToString:@"Polygon"]) {
            BMKPolygonView *cutomView = [[BMKPolygonView alloc] initWithOverlay:overlay];

            cutomView.strokeColor = [dic objectForKey:@"strokeColor"];
            cutomView.fillColor   = [dic objectForKey:@"fillColor"];
            cutomView.lineWidth   = [[dic objectForKey:@"lineWidth"] floatValue];

            return cutomView;
        } else if (dic && [[dic objectForKey:@"shape"] isEqualToString:@"Polyline"]) {
            BMKPolylineView *cutomView = [[BMKPolylineView alloc] initWithOverlay:overlay];

            cutomView.strokeColor = [dic objectForKey:@"strokeColor"];
            cutomView.lineWidth   = [[dic objectForKey:@"lineWidth"] floatValue];

            return cutomView;
        }

        return nil;
    }

    return nil;
}


// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPointAnnotation *pointAnnotation = (BMKPointAnnotation *)annotation;
        NSString           *uid             = pointAnnotation._uid_;

        RRBaiduImageAnnotation *annotationView = (RRBaiduImageAnnotation *)[mapView dequeueReusableAnnotationViewWithIdentifier:uid];

        if (annotationView == nil) {
            annotationView = [[RRBaiduImageAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:uid];
        }

        RRPointAnnotationSave *annotationSave = [_annotationInfo objectForKey:uid];
        annotationView.other = uid;

        //动画annotation
        if ([self.mapDelegate respondsToSelector:@selector(rrMap:viewForAnnotationId:)]) {
            UIView *showView = [self.mapDelegate rrMap:self viewForAnnotationId:uid];
            if (nil == showView) return nil;

            [annotationView setShowView:showView];
        } else {
            NSString *imageName = annotationSave.imageName;
            if (nil == imageName) return nil;

            annotationView.image = [UIImage imageNamed:imageName];
        }

        if (annotationSave.type == BMKAnonotationType_Callout) {
            if (self.annotationCalloutViewWithUid) {
                UIView *calloutView = self.annotationCalloutViewWithUid(uid);
                [annotationView changeCalloutView:calloutView];
            }
        }

        return annotationView;
    }

    return nil;
}


- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if (![view isKindOfClass:[RRBaiduImageAnnotation class]]) return;

    if (self.annotationSelectAtUid) {
        self.annotationSelectAtUid(((RRBaiduImageAnnotation *)view).other);
    }
}


- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view
{
    if (![view isKindOfClass:[RRBaiduImageAnnotation class]]) return;

    if (self.annotationDeSelectAtUid) {
        self.annotationDeSelectAtUid(((RRBaiduImageAnnotation *)view).other);
    }
}


- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D center = [RRCoordCover convertGCJ02ToBD:_mapView.region.center];

    RRCoordinateSpan span = RRCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                 mapView.region.span.longitudeDelta);

    RRCoordinateRegion region = RRCoordinateRegionMake(center,
                                                       span);

    if ([_mapDelegate respondsToSelector:@selector(rrMap:regionDidChangeTo:withAnimated:)]) {
        [_mapDelegate rrMap:self regionDidChangeTo:region withAnimated:animated];
    }

    if ([_mapDelegate respondsToSelector:@selector(rrMap:regionDidChangeTo:)]) {
        [_mapDelegate rrMap:self regionDidChangeTo:region];
    }
}


- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (![_mapDelegate respondsToSelector:@selector(rrMap:regionWillChangeFrom:withAnimated:)]) return;

    CLLocationCoordinate2D center = [RRCoordCover convertGCJ02ToBD:_mapView.region.center];

    RRCoordinateSpan span = RRCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                 mapView.region.span.longitudeDelta);

    RRCoordinateRegion region = RRCoordinateRegionMake(center,
                                                       span);

    [_mapDelegate rrMap:self regionWillChangeFrom:region withAnimated:animated];
}


- (void)removeAnnotations
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_annotationInfo removeAllObjects];
}


- (void)removeOverlayView:(NSString *)uid
{
    [_mapView removeOverlay:[[_overlayInfo objectForKey:uid] objectForKey:@"view"]];
    [_overlayInfo removeObjectForKey:uid];
}


- (void)updateCallout
{
    for (BMKPointAnnotation *aAnnotation in _mapView.annotations) {
        if (![aAnnotation isKindOfClass:[BMKPointAnnotation class]]) continue;

        RRPointAnnotationSave *annotationSave = [_annotationInfo objectForKey:aAnnotation._uid_];
        if (annotationSave.type != BMKAnonotationType_Callout) continue;

        RRBaiduImageAnnotation *annotationView = (RRBaiduImageAnnotation *)[_mapView viewForAnnotation:aAnnotation];
        if (![annotationView isKindOfClass:[RRBaiduImageAnnotation class]]) continue;

        if (self.annotationCalloutViewWithUid) {
            UIView *calloutView = self.annotationCalloutViewWithUid(aAnnotation._uid_);
            [annotationView changeCalloutView:calloutView];
        }

        if (self.annotationImageWithUid) {
            UIImage *image = self.annotationImageWithUid(aAnnotation._uid_);
            if (image) {
                annotationView.image = image;
            }
        }
    }
}


@end


@implementation RRPointAnnotationSave

@end

#endif