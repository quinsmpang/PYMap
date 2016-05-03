//
//  PYMapWithTencent.m
//  QMapKitSample
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 YR. All rights reserved.
//
#ifdef _Map_Tencent

#import "PYMapWithTencent.h"
#import "PYTencentImageAnnotation.h"
#import "QMK+Add.h"


/**
 *  @author YangRui, 16-02-26 10:02:46
 *
 *  地图显示标注视图类型
 */
typedef NS_ENUM(NSUInteger, QAnonotationType) {
    QAnonotationType_Normal,    //只有图片
    QAnonotationType_Callout, //带callout的气泡
};;


@interface PYPointAnnotationSave : NSObject

@property(nonatomic,strong) QPointAnnotation* annotation;
@property(nonatomic,strong) NSString*   uid;
@property(nonatomic,strong) NSString*   imageName;
@property(nonatomic,assign) QAnonotationType type;

@end


@interface PYMapWithTencent () <QMapViewDelegate>
@end


@implementation PYMapWithTencent {
    QMapView            *_mapView;
    NSMutableDictionary *_overlayInfo;
    NSMutableDictionary *_annotationInfo;
}

@synthesize annotationSelectAtUid = _annotationSelectAtUid;
@synthesize annotationDeSelectAtUid = _annotationDeSelectAtUid;
@synthesize annotationCalloutViewWithUid = _annotationCalloutViewWithUid;
@synthesize annotationImageWithUid = _annotationImageWithUid;
@synthesize mapDelegate = _mapDelegate;

- (instancetype)init
{
    if (self = [super init]) {
        _mapView        = [[QMapView alloc] init];
        _overlayInfo    = [[NSMutableDictionary alloc] init];
        _annotationInfo = [[NSMutableDictionary alloc] init];

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
- (void)addAnnotation:(id <PYAnnotation>)annotation imageName:(NSString *)imgStr uid:(NSString *)uid
{
    [self _addAnnotation:annotation imageName:imgStr uid:uid withType:QAnonotationType_Normal];

}



- (void)addCalloutAnnotation:(id<PYAnnotation>)annotation
                         imageName:(NSString *)imgStr
                               uid:(NSString *)uid{
   
    [self _addAnnotation:annotation imageName:imgStr uid:uid withType:QAnonotationType_Callout];
}

- (void)_addAnnotation:(id<PYAnnotation>)annotation
                        imageName:(NSString *)imgStr
                              uid:(NSString *)uid
                         withType:(QAnonotationType)type{
   
    if (uid == nil) return;
    
    QPointAnnotation *pointAnnotation = [[QPointAnnotation alloc] init];
    pointAnnotation._uid_      = uid;
    pointAnnotation.coordinate = [annotation coordinate];
    
    PYPointAnnotationSave* save = [PYPointAnnotationSave new];
    save.annotation  = pointAnnotation;
    save.imageName = imgStr;
    save.type = type;
    
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
    for (NSString* annotationUID in annotationUIDs) {
        if (![annotationUID isKindOfClass:[NSString class]]) return;

        PYPointAnnotationSave *pointAnnotation = [_annotationInfo objectForKey:annotationUID];
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
- (void)removeAnnotation:(NSString*)annotationUID;
{
    PYPointAnnotationSave *pointAnnotation  = [_annotationInfo objectForKey:annotationUID];
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
        
        NSDictionary *dic = [_overlayInfo objectForKey:uid];
        if (dic && [[dic objectForKey:@"shape"] isEqualToString:@"Polygon"]) {
            QPolygonView *cutomView = [[QPolygonView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = [dic objectForKey:@"strokeColor"];
            cutomView.fillColor   = [dic objectForKey:@"fillColor"];
            cutomView.lineWidth   = [[dic objectForKey:@"lineWidth"] floatValue];
            
            return cutomView;
        }else if (dic && [[dic objectForKey:@"shape"] isEqualToString:@"Polyline"]){
            QPolylineView *cutomView = [[QPolylineView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = [dic objectForKey:@"strokeColor"];
            cutomView.lineWidth   = [[dic objectForKey:@"lineWidth"] floatValue];
            
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
        
        PYTencentImageAnnotation *annotationView = (PYTencentImageAnnotation *)[mapView dequeueReusableAnnotationViewWithIdentifier:uid];
        
        if (annotationView == nil) {
            annotationView = [[PYTencentImageAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:uid];
        }
       
        PYPointAnnotationSave *annotationSave = [_annotationInfo objectForKey:uid];
        annotationView.other = uid;
        
        //动画annotation
        if ([self.mapDelegate respondsToSelector:@selector(pyMap:viewForAnnotationId:)]) {
            
            UIView* showView = [self.mapDelegate pyMap:self viewForAnnotationId:uid];
            if (nil == showView) return nil;
            [annotationView setShowView:showView];
        
        }else{
 
            NSString* imageName = annotationSave.imageName;
            if (nil == imageName) return nil;
            
            annotationView.image = [UIImage imageNamed:imageName];
        }
        
        if (annotationSave.type == QAnonotationType_Callout) {
           
            if (self.annotationCalloutViewWithUid) {
                UIView* calloutView = self.annotationCalloutViewWithUid(uid);
                [annotationView changeCalloutView:calloutView];
            }
        }
        
        return annotationView;
        
    }
    
    return nil;
}


-(void)mapView:(QMapView *)mapView didSelectAnnotationView:(QAnnotationView *)view{

    if (![view isKindOfClass:[PYTencentImageAnnotation class]]) return;
    
    if (self.annotationSelectAtUid) {
        self.annotationSelectAtUid(((PYTencentImageAnnotation*)view).other);
    }
}



-(void)mapView:(QMapView *)mapView didDeselectAnnotationView:(QAnnotationView *)view{

    if (![view isKindOfClass:[PYTencentImageAnnotation class]]) return;
    
    if (self.annotationDeSelectAtUid) {
        self.annotationDeSelectAtUid(((PYTencentImageAnnotation*)view).other);
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
    
    if ([_mapDelegate respondsToSelector:@selector(pyMap:regionDidChangeTo:)]) {
        [_mapDelegate pyMap:self regionDidChangeTo:region];
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
    [_annotationInfo removeAllObjects];
}


- (void)removeOverlayView:(NSString *)uid
{
    [_mapView removeOverlay:[[_overlayInfo objectForKey:uid] objectForKey:@"view"]];
    [_overlayInfo removeObjectForKey:uid];
}


- (void)updateCallout{

    for (QPointAnnotation* aAnnotation in _mapView.annotations) {
        
        if (![aAnnotation isKindOfClass:[QPointAnnotation class]]) continue;
        
        PYPointAnnotationSave *annotationSave = [_annotationInfo objectForKey:aAnnotation._uid_];
        if (annotationSave.type != QAnonotationType_Callout) continue;
        
        PYTencentImageAnnotation *annotationView  = (PYTencentImageAnnotation*)[_mapView viewForAnnotation:aAnnotation];
        if (![annotationView isKindOfClass:[PYTencentImageAnnotation class]]) continue;
        
       
        if (self.annotationCalloutViewWithUid) {
            UIView* calloutView = self.annotationCalloutViewWithUid(aAnnotation._uid_);
            [annotationView changeCalloutView:calloutView];
        }
        
        if (self.annotationImageWithUid) {
            UIImage* image = self.annotationImageWithUid(aAnnotation._uid_);
            if (image) {
                annotationView.image = image;
            }
        }
    }
}

@end


@implementation PYPointAnnotationSave

@end

#endif
