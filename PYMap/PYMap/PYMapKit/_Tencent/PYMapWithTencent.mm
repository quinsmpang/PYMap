//
//  PYMapWithTencent.m
//  QMapKitSample
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 YR. All rights reserved.
//
#ifdef _Map_Tencent

#import "PYMapWithTencent.h"
#import "PYTencentAnnotationView.h"
#import "QMK+Add.h"


@interface PYAnnotationInfo : NSObject

@property(nonatomic,strong) QPointAnnotation* annotation;
@property(nonatomic,strong) NSString*  uid;
@property(nonatomic,strong) NSString*  imageName;
@property(nonatomic,strong) NSString*  reuseId;

@end


typedef NS_ENUM(NSUInteger, ShapeType) {
    ShapeType_Polygon,
    ShapeType_Line,
};


@interface PYShapeInfo : NSObject

@property(nonatomic,strong) UIColor* strokeColor;
@property(nonatomic,strong) UIColor* fillColor;
@property(nonatomic,assign) CGFloat lineWidth;
@property(nonatomic,assign) ShapeType shapeType;
@property(nonatomic,strong) QShape* shape;

@end


@interface PYMapWithTencent () <QMapViewDelegate>{
    QMapView            *_mapView;
    NSMutableDictionary<NSString*, PYShapeInfo*>      *_shapeCache;
    NSMutableDictionary<NSString*, PYAnnotationInfo*> *_annotationCache;
}
@end


@implementation PYMapWithTencent

@synthesize mapDelegate = _mapDelegate;

- (instancetype)init
{
    if (self = [super init]) {
        _mapView        = [[QMapView alloc] init];
        _shapeCache    = [[NSMutableDictionary alloc] init];
        _annotationCache = [[NSMutableDictionary alloc] init];

        _mapView.delegate = self;
    }

    return self;
}


- (void)dealloc
{
    _mapView.delegate = nil;
}


- (UIView *)mapView
{
    return _mapView;
}


/*!
 *  @brief  向地图窗口添加标注，需要实现QMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 *
 *  @param annotation 要添加的标注
 */
- (void)addAnnotation:(id <PYAnnotation>)annotation
            imageName:(NSString *)imgStr
                  uid:(NSString *)uid
              reuseId:(NSString *)reuseId
{
    if (uid == nil) return;
    
    QPointAnnotation *pointAnnotation = [[QPointAnnotation alloc] init];
    pointAnnotation._uid_      = uid;
    pointAnnotation.coordinate = [annotation coordinate];
    
    PYAnnotationInfo* save = [PYAnnotationInfo new];
    save.annotation  = pointAnnotation;
    save.imageName = imgStr;
    save.reuseId   = reuseId;
    
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
    for (NSString* annotationUID in annotationUIDs) {
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
- (void)removeAnnotation:(NSString*)annotationUID;
{
    PYAnnotationInfo *pointAnnotation  = [_annotationCache objectForKey:annotationUID];
    if (pointAnnotation) {
        [_mapView removeAnnotation:pointAnnotation.annotation];
        [_annotationCache removeObjectForKey:annotationUID];
    }
}


/*!
 *  @brief  设定当前地图的region
 *
 *  @param region   要设定的地图范围，用经纬度的方式表示
 *  @param animated 是否采用动画
 */
- (void)setRegion:(PYCoordinateRegion)region animated:(BOOL)animated
{
    QCoordinateRegion qRegin = QCoordinateRegionMake(region.center,
                                                     QCoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta));

    [_mapView setRegion:qRegin animated:animated];
}


- (PYCoordinateRegion)regionThatFits:(PYCoordinateRegion)region
{
    QCoordinateRegion qRegin = QCoordinateRegionMake(region.center,
                                                     QCoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta));
    qRegin = [_mapView regionThatFits:qRegin];

    return PYCoordinateRegionMake(qRegin.center,
                                  PYCoordinateSpanMake(qRegin.span.latitudeDelta, qRegin.span.longitudeDelta));
}


- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated{

    [_mapView setCenterCoordinate:coordinate animated:animated];
}


- (void)addOverLayer:(NSArray *)coordinates strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor lineWidth:(CGFloat)lineWidth uid:(NSString *)uid
{
    if (uid == nil) return;
    
    QMapPoint *temppoints = new QMapPoint[[coordinates count]];
    for (int i = 0; i < [coordinates count]; i++) {
        NSString *loc   = [coordinates objectAtIndex:i];
        NSArray  *split = [loc componentsSeparatedByString:@","];
        NSAssert(split.count == 2, @"Coordinate descripe string need 'a,b'");
        NSString               *lon = [split objectAtIndex:0];
        NSString               *lat = [split objectAtIndex:1];
        CLLocationCoordinate2D coor;
        coor.longitude = [lon floatValue];
        coor.latitude  = [lat floatValue];
        QMapPoint pt = QMapPointForCoordinate(coor);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }
    
    QPolygon *overlay = [QPolygon polygonWithPoints:temppoints count:coordinates.count];
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


-(void)addRouteWithCoords:(NSArray*)coordinates
              strokeColor:(UIColor*)strokeColor
                lineWidth:(CGFloat)lineWidth
                      uid:(NSString*)uid
{
    if (uid == nil) return;

    QMapPoint *temppoints = new QMapPoint[[coordinates count]];
    for (int i = 0; i < [coordinates count]; i++) {
        CLLocation *loc   = [coordinates objectAtIndex:i];
        NSAssert([loc isKindOfClass:[CLLocation class]], @"Coordinate is CLLocation Object");
        
        QMapPoint pt = QMapPointForCoordinate(loc.coordinate);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }

    QPolyline* line = [QPolyline polylineWithPoints:temppoints count:coordinates.count];
    line._uid_ = uid;

    PYShapeInfo* shapeInfo = [PYShapeInfo new];
    shapeInfo.strokeColor = strokeColor;
    shapeInfo.lineWidth = lineWidth;
    shapeInfo.shape = line;
    shapeInfo.shapeType = ShapeType_Polygon;
    
    [_shapeCache setObject:shapeInfo forKey:uid];

    [_mapView addOverlay:line];
    delete temppoints;
}


/*!
 *  @brief  是否支持平移, 默认为YES
 */
-(void)setScrollEnabled:(BOOL)scrollEnabled{

    _mapView.scrollEnabled = scrollEnabled;
}

/*!
 *  @brief  是否支持缩放, 默认为YES
 */
-(void)setZoomEnabled:(BOOL)zoomEnabled{

    _mapView.zoomEnabled = zoomEnabled;
}
/*!
 *  @brief  设置当前地图缩放级别
 *
 *  @param zoomScale    目标缩放级别与当前级别的比例
 *  @param animated     是否采用动画
 */
- (void)setZoomScale:(double)zoomScale animated:(BOOL)animated{

    [_mapView setZoomLevel:zoomScale  animated:animated];
}

/*!
 *  @brief  同时设置中心点与缩放级别
 *
 *  @param coordinate   要设定的地图中心点经纬度
 *  @param newZoomLevel 目标缩放级别
 *  @param animated     是否采用动画
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(double)newZoomLevel animated:(BOOL)animated{

    [_mapView setCenterCoordinate:coordinate zoomLevel:newZoomLevel animated:animated];
}

-(double)getZoomLevel{

    return _mapView.zoomLevel;
}

- (PYCoordinateRegion)getMapRegion{
    PYCoordinateSpan  span = PYCoordinateSpanMake(_mapView.region.span.latitudeDelta,
                                                  _mapView.region.span.longitudeDelta);
    
    PYCoordinateRegion region = PYCoordinateRegionMake(_mapView.region.center,
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
- (QOverlayView *)mapView:(QMapView *)mapView viewForOverlay:(id <QOverlay>)overlay
{
    if ([overlay isKindOfClass:[QShape class]]) {
        QShape* shape = (QShape*)overlay;
        NSString* uid = shape._uid_;
        
        PYShapeInfo *shapeInfo = [_shapeCache objectForKey:uid];
        
        ///添加多边形
        if (shapeInfo && ShapeType_Polygon == shapeInfo.shapeType) {
            
            QPolygonView *cutomView = [[QPolygonView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = shapeInfo.strokeColor;
            cutomView.fillColor   = shapeInfo.fillColor;
            cutomView.lineWidth   = shapeInfo.lineWidth;
            
            return cutomView;
            
            ///添加线条
        }else if (shapeInfo && ShapeType_Line == shapeInfo.shapeType){
            
            QPolylineView *cutomView = [[QPolylineView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = shapeInfo.strokeColor;
            cutomView.lineWidth   = shapeInfo.lineWidth;
            
            return cutomView;
        }

        return nil;
    }
    
  
    return nil;
}


// 根据anntation生成对应的View
- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id <QAnnotation>)annotation
{
    if ([annotation isKindOfClass:[QPointAnnotation class]]) {
        
        QPointAnnotation* pointAnnotation = annotation;
        NSString* uid = pointAnnotation._uid_;
        
        PYAnnotationInfo *annotationSave = [_annotationCache objectForKey:uid];
        NSString* reuseId = annotationSave.uid;
        
        PYTencentAnnotationView *annotationView = (PYTencentAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        
        if (annotationView == nil) {
            annotationView = [[PYTencentAnnotationView alloc] initWithAnnotation:annotation
                                                                 reuseIdentifier:reuseId];
        }
       
        annotationView.annotationId = uid;
        
        //动画annotation
        if ([self.mapDelegate respondsToSelector:@selector(pyMap:viewForAnnotationWithId:)]) {
            
            UIView* showView = [self.mapDelegate pyMap:self viewForAnnotationWithId:uid];
            [annotationView setShowView:showView];
        
        }else{
 
            NSString* imageName = annotationSave.imageName;
            if (nil == imageName) return nil;
            
            annotationView.image = [UIImage imageNamed:imageName];
        }
        

        ///气泡
        if ([_mapDelegate respondsToSelector:@selector(pyMap:calloutViewForAnnotationWithId:)]) {
            UIView* calloutView = [_mapDelegate pyMap:self calloutViewForAnnotationWithId:uid]
            [annotationView changeCalloutView:calloutView];
        }
        
        return annotationView;
        
    }
    
    return nil;
}


-(void)mapView:(QMapView *)mapView didSelectAnnotationView:(QAnnotationView *)view{

    if (![view isKindOfClass:[PYTencentAnnotationView class]]) return;
    
    if ([_mapDelegate respondsToSelector:@selector(pyMap:annotationSelectAtUid:)]) {
        [_mapDelegate pyMap:self annotationSelectAtUid:((PYTecentAnnotationView*)view).annotationId];
    }
}



-(void)mapView:(QMapView *)mapView didDeselectAnnotationView:(QAnnotationView *)view{

    if (![view isKindOfClass:[PYTencentAnnotationView class]]) return;
    
    if ([_mapDelegate respondsToSelector:@selector(pyMap:annotationDeSelectAtUid:)]) {
        [_mapDelegate pyMap:self annotationDeSelectAtUid:((PYTecentAnnotationView*)view).annotationId];
    }

}


-(void)mapView:(QMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    PYCoordinateSpan  span = PYCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                  mapView.region.span.longitudeDelta);
    
    PYCoordinateRegion region = PYCoordinateRegionMake(mapView.region.center,
                                                       span);
    
    if ([_mapDelegate respondsToSelector:@selector(pyMap:regionDidChangeTo:withAnimated:)]) {
        [_mapDelegate pyMap:self regionDidChangeTo:region withAnimated:animated];
    }
    
}


-(void)mapView:(QMapView *)mapView regionWillChangeAnimated:(BOOL)animated{

    if (![_mapDelegate respondsToSelector:@selector(pyMap:regionWillChangeFrom:withAnimated:)]) return;
    
    
    PYCoordinateSpan  span = PYCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                  mapView.region.span.longitudeDelta);
    
    PYCoordinateRegion region = PYCoordinateRegionMake(mapView.region.center,
                                                       span);
    
    [_mapDelegate pyMap:self regionWillChangeFrom:region withAnimated:animated];
    
}


- (void)removeAllAnnotations
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_annotationCache removeAllObjects];
}


- (void)removeOverlayView:(NSString *)uid
{
    [_mapView removeOverlay:[[_shapeCache objectForKey:uid] objectForKey:@"view"]];
    [_shapeCache removeObjectForKey:uid];
}


- (void)updateCallout{

    for (QPointAnnotation* aAnnotation in _mapView.annotations) {
        
        if (![aAnnotation isKindOfClass:[QPointAnnotation class]]) continue;
        
        PYAnnotationInfo *annotationSave = [_annotationCache objectForKey:aAnnotation._uid_];
        if (annotationSave.type != QAnonotationType_Callout) continue;
        
        PYTencentAnnotationView *annotationView  = (PYTencentAnnotationView*)[_mapView viewForAnnotation:aAnnotation];
        if (![annotationView isKindOfClass:[PYTencentAnnotationView class]]) continue;
        
       
        if ([_mapDelegate respondsToSelector:@selector(pyMap:calloutViewForAnnotationWithId:)]) {
            UIView* calloutView = [_mapDelegate pyMap:self calloutViewForAnnotationWithId:aAnnotation._uid_];
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
