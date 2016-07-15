//
//  PYMapWithBaidu.m
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 PY. All rights reserved.
//
#ifdef _Map_Baidu

#import "PYMapWithBaidu.h"
#import "PYBaiduImageAnnotation.h"
#import "PYCoordCover.h"
#import "BMK+Add.h"
#import <BaiduMapAPI_Utils/BMKGeometry.h>


@interface PYAnnotationInfo : NSObject

@property(nonatomic, strong) BMKPointAnnotation *annotation;
@property(nonatomic, strong) NSString           *uid;
@property(nonatomic, strong) NSString           *imageName;
@property(nonatomic, strong) NSString           *reuseId;

@end


typedef NS_ENUM (NSUInteger, ShapeType) {
    ShapeType_Polygon,
    ShapeType_Line,
};


@interface PYShapeInfo : NSObject

@property(nonatomic, strong) UIColor   *strokeColor;
@property(nonatomic, strong) UIColor   *fillColor;
@property(nonatomic, assign) CGFloat   lineWidth;
@property(nonatomic, assign) ShapeType shapeType;
@property(nonatomic, strong) BMKShape  *shape;

@end



@interface PYMapWithBaidu () <BMKMapViewDelegate>
@end


@implementation PYMapWithBaidu {
    BMKMapView          *_mapView;
    NSMutableDictionary<NSString*, PYShapeInfo*>* _shapeCache;
    NSMutableDictionary<NSString*, PYAnnotationInfo*>*_annotationCache;
}

@synthesize mapDelegate = _mapDelegate;

- (instancetype)init
{
    if (self = [super init]) {
        _mapView         = [[BMKMapView alloc] init];
        _shapeCache      = [[NSMutableDictionary alloc] init];
        _annotationCache = [[NSMutableDictionary alloc] init];

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
    [_mapView viewWillAppear];
    return _mapView;
}


/*!
 *  @brief  向地图窗口添加标注，需要实现BMKMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 *
 *  @param annotation 要添加的标注
 */
- (void)addAnnotation:(id <PYAnnotation>)annotation
            imageName:(NSString *)imgStr
                  uid:(NSString *)uid
              reuseId:(NSString *)reuseId
{
    if (uid == nil) return;

    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc] init];
    pointAnnotation._uid_      = uid;
    pointAnnotation.title      = @" ";
    pointAnnotation.coordinate = [PYCoordCover convertGCJ02ToBD:
                                  [annotation coordinate]];

    PYAnnotationInfo *save = [PYAnnotationInfo new];
    save.annotation = pointAnnotation;
    save.imageName  = imgStr;
    save.reuseId    = reuseId;

    [_annotationCache setObject:save forKey:uid];

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

        PYAnnotationInfo *pointAnnotation = [_annotationCache objectForKey:annotationUID];
        if (pointAnnotation) {
            [pointAnnotations addObject:pointAnnotation.annotation];
            [_annotationCache removeObjectForKey:annotationUID];
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
    PYAnnotationInfo *pointAnnotation = [_annotationCache objectForKey:annotationUID];
    if (pointAnnotation) {
        [_mapView removeAnnotation:pointAnnotation.annotation];
        [_annotationCache removeObjectForKey:annotationUID];
    }
}


/*!
 *  @brief  移除所有标注
 */
- (void)removeAllAnnotations
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_annotationCache removeAllObjects];
}


/*!
 *  @brief  设定当前地图的region
 *
 *  @param region   要设定的地图范围，用经纬度的方式表示
 *  @param animated 是否采用动画
 */
- (void)setRegion:(PYCoordinateRegion)region animated:(BOOL)animated
{
    CLLocationCoordinate2D center = [PYCoordCover convertGCJ02ToBD:region.center];

    BMKCoordinateRegion qRegin = BMKCoordinateRegionMake(center,
                                                         BMKCoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta));

    [_mapView setRegion:qRegin animated:animated];
}


- (PYCoordinateRegion)regionThatFits:(PYCoordinateRegion)region
{
    CLLocationCoordinate2D center = [PYCoordCover convertGCJ02ToBD:region.center];

    BMKCoordinateRegion qRegin = BMKCoordinateRegionMake(center,
                                                         BMKCoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta));
    qRegin = [_mapView regionThatFits:qRegin];

    return PYCoordinateRegionMake([PYCoordCover convertBDToGCJ02:qRegin.center],
                                  PYCoordinateSpanMake(qRegin.span.latitudeDelta, qRegin.span.longitudeDelta));
}


- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated
{
    CLLocationCoordinate2D center = [PYCoordCover convertGCJ02ToBD:coordinate];

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
        coor           = [PYCoordCover convertGCJ02ToBD:coor];
        BMKMapPoint pt = BMKMapPointForCoordinate(coor);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }

    BMKPolygon *overlay = [BMKPolygon polygonWithPoints:temppoints count:coordinates.count];
    overlay._uid_ = uid;

    
    PYShapeInfo* shapeInfo = [PYShapeInfo new];
    shapeInfo.strokeColor = strokeColor;
    shapeInfo.fillColor = fillColor;
    shapeInfo.lineWidth = lineWidth;
    shapeInfo.shape = overlay;
    shapeInfo.shapeType = ShapeType_Polygon;
    
    [_shapeCache setObject:shapeInfo forKey:uid];
    

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

        CLLocationCoordinate2D coor = [PYCoordCover convertGCJ02ToBD:loc.coordinate];
        BMKMapPoint            pt   = BMKMapPointForCoordinate(coor);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }

    BMKPolyline *line = [BMKPolyline polylineWithPoints:temppoints count:coordinates.count];
    line._uid_ = uid;

    PYShapeInfo* shapeInfo = [PYShapeInfo new];
    shapeInfo.strokeColor = strokeColor;
    shapeInfo.lineWidth = lineWidth;
    shapeInfo.shape = line;
    shapeInfo.shapeType = ShapeType_Line;
    
    [_shapeCache setObject:shapeInfo forKey:uid];

    [_mapView addOverlay:line];
    delete temppoints;
}


/*!
 *  @brief  移除覆线路图
 */
- (void)removeRouteView:(NSString *)uid
{
    [self removeOverlayView:uid];
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
    CLLocationCoordinate2D center = [PYCoordCover convertGCJ02ToBD:coordinate];

    [_mapView setCenterCoordinate:center];
    [_mapView setZoomLevel:newZoomLevel];

//    [_mapView setCenterCoordinate:coordinate zoomLevel:newZoomLevel animated:animated];
}


- (double)getZoomLevel
{
    return _mapView.zoomLevel;
}


- (PYCoordinateRegion)getMapRegion
{
    CLLocationCoordinate2D center = [PYCoordCover convertBDToGCJ02:_mapView.region.center];

    PYCoordinateSpan span = PYCoordinateSpanMake(_mapView.region.span.latitudeDelta,
                                                 _mapView.region.span.longitudeDelta);

    PYCoordinateRegion region = PYCoordinateRegionMake(center,
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

       PYShapeInfo *shapeInfo = [_shapeCache objectForKey:uid];
        
        //添加多边形
        if (shapeInfo && ShapeType_Polygon == shapeInfo.shapeType) {
            
            BMKPolygonView *cutomView = [[BMKPolygonView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = shapeInfo.strokeColor;
            cutomView.fillColor   = shapeInfo.fillColor;
            cutomView.lineWidth   = shapeInfo.lineWidth;
            
            return cutomView;
            
            ///添加线条
        }else if (shapeInfo && ShapeType_Line == shapeInfo.shapeType){
            
            BMKPolylineView *cutomView = [[BMKPolylineView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = shapeInfo.strokeColor;
            cutomView.lineWidth   = shapeInfo.lineWidth;
            
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
        BMKPointAnnotation *pointAnnotation = annotation;
        NSString           *uid             = pointAnnotation._uid_;

        PYAnnotationInfo *annotationSave = [_annotationCache objectForKey:uid];
        NSString         *reuseId        = annotationSave.uid;

        PYBaiduImageAnnotation *annotationView = (PYBaiduImageAnnotation *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];

        if (annotationView == nil) {
            annotationView = [[PYBaiduImageAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        }

        annotationView.other = uid;

        //动画annotation
        if ([self.mapDelegate respondsToSelector:@selector(pyMap:viewForAnnotationWithId:)]) {
            UIView *showView = [self.mapDelegate pyMap:self viewForAnnotationWithId:uid];
            if (nil == showView) return nil;

            [annotationView setShowView:showView];
        } else {
            NSString *imageName = annotationSave.imageName;
            if (nil == imageName) return nil;

            annotationView.image = [UIImage imageNamed:imageName];
        }

        if ([_mapDelegate respondsToSelector:@selector(pyMap:calloutViewForAnnotationWithId:)]) {
            UIView *calloutView = [_mapDelegate pyMap:self calloutViewForAnnotationWithId:uid];
            [annotationView changeCalloutView:calloutView];
        }

        return annotationView;
    }

    return nil;
}


- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if (![view isKindOfClass:[PYBaiduImageAnnotation class]]) return;

    if ([_mapDelegate respondsToSelector:@selector(pyMap:annotationSelectAtUid:)]) {
        [_mapDelegate pyMap:self annotationSelectAtUid:((PYBaiduImageAnnotation *)view).other];
    }
}


- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view
{
    if (![view isKindOfClass:[PYBaiduImageAnnotation class]]) return;

    if ([_mapDelegate respondsToSelector:@selector(pyMap:annotationDeSelectAtUid:)]) {
        [_mapDelegate pyMap:self annotationDeSelectAtUid:((PYBaiduImageAnnotation *)view).other];
    }
}


- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D center = [PYCoordCover convertGCJ02ToBD:_mapView.region.center];

    PYCoordinateSpan span = PYCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                 mapView.region.span.longitudeDelta);

    PYCoordinateRegion region = PYCoordinateRegionMake(center,
                                                       span);

    if ([_mapDelegate respondsToSelector:@selector(pyMap:regionDidChangeTo:withAnimated:)]) {
        [_mapDelegate pyMap:self regionDidChangeTo:region withAnimated:animated];
    }

    if ([_mapDelegate respondsToSelector:@selector(pyMap:regionDidChangeTo:withAnimated:)]) {
        [_mapDelegate pyMap:self regionDidChangeTo:region withAnimated:animated];
    }
}


- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (![_mapDelegate respondsToSelector:@selector(pyMap:regionWillChangeFrom:withAnimated:)]) return;

    CLLocationCoordinate2D center = [PYCoordCover convertGCJ02ToBD:_mapView.region.center];

    PYCoordinateSpan span = PYCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                 mapView.region.span.longitudeDelta);

    PYCoordinateRegion region = PYCoordinateRegionMake(center,
                                                       span);

    [_mapDelegate pyMap:self regionWillChangeFrom:region withAnimated:animated];
}


- (void)removeAnnotations
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_annotationCache removeAllObjects];
}


- (void)removeOverlayView:(NSString *)uid
{
    BMKShape* shape = [_shapeCache objectForKey:uid].shape;
    if ([shape conformsToProtocol:@protocol(BMKOverlay)]) {
        [_mapView removeOverlay:(id <BMKOverlay>)shape];
        [_shapeCache removeObjectForKey:uid];
    }
}


- (void)updateCallout
{
    for (BMKPointAnnotation *aAnnotation in _mapView.annotations) {
        if (![aAnnotation isKindOfClass:[BMKPointAnnotation class]]) continue;

        PYBaiduImageAnnotation *annotationView = (PYBaiduImageAnnotation *)[_mapView viewForAnnotation:aAnnotation];
        if (![annotationView isKindOfClass:[PYBaiduImageAnnotation class]]) continue;

        if ([_mapDelegate respondsToSelector:@selector(pyMap:calloutViewForAnnotationWithId:)]) {
            UIView *calloutView = [_mapDelegate pyMap:self calloutViewForAnnotationWithId:aAnnotation._uid_];
            [annotationView changeCalloutView:calloutView];
        }
    }
}


@end

@implementation PYAnnotationInfo

@end


@implementation PYShapeInfo

@end

#endif