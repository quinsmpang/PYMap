//
//  PYMapWithMA.m
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 YR. All rights reserved.
//
#ifdef _Map_MA

#import "PYMapWithMA.h"
#import "PYMAAnnotationView.h"
#import "MA+Add.h"


@interface PYAnnotationInfo : NSObject

@property(nonatomic,strong) MAPointAnnotation* annotation;
@property(nonatomic,strong) NSString*   uid;
@property(nonatomic,strong) NSString*   reuseId;
@property(nonatomic,strong) NSString*   imageName;

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
@property(nonatomic,strong) id<MAOverlay> shape;

@end



@interface PYMapWithMA () <MAMapViewDelegate>{
    MAMapView           *_mapView;
    NSMutableDictionary<NSString*, PYShapeInfo*>* _shapeCache;
    NSMutableDictionary<NSString*, PYAnnotationInfo*>*_annotationCache;
}

@end


@implementation PYMapWithMA

@synthesize mapDelegate = _mapDelegate;


- (instancetype)init
{
    if (self = [super init]) {
        _mapView        = [[MAMapView alloc] init];
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
 *  @brief  向地图窗口添加标注
 *
 *  @param annotation 要添加的标注
 */
- (void)addAnnotation:(id <PYAnnotation>)annotation
            imageName:(NSString *)imgStr
                  uid:(NSString *)uid
              reuseId:(NSString *)reuseId
{
    if (uid == nil) return;
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
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
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSString* annotationUID in annotationUIDs) {
        if (![annotationUID isKindOfClass:[NSString class]]) return;

        PYAnnotationInfo *annotationInfo = [_annotationCache objectForKey:annotationUID];
        if (annotationInfo) {
            [annotations addObject:annotationInfo.annotation];
            [_annotationCache removeObjectForKey:annotationUID];
        }
    }

    [_mapView removeAnnotations:annotations];
}


/*!
*  @brief  移除标注
*
*  @param annotationUID 要移除的标注的唯一标识
*/
- (void)removeAnnotation:(NSString*)annotationUID;
{
    PYAnnotationInfo *annotationInfo  = [_annotationCache objectForKey:annotationUID];
    if (annotationInfo) {
        [_mapView removeAnnotation:annotationInfo.annotation];
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
    MACoordinateSpan  span = MACoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta);
    MACoordinateRegion aRegin = MACoordinateRegionMake(region.center, span);

    [_mapView setRegion:aRegin animated:animated];
}


- (PYCoordinateRegion)regionThatFits:(PYCoordinateRegion)region
{
    
    MACoordinateSpan  span = MACoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta);
    MACoordinateRegion aRegin = MACoordinateRegionMake(region.center, span);
                                                     
    aRegin = [_mapView regionThatFits:aRegin];

    return PYCoordinateRegionMake(aRegin.center,
                                  PYCoordinateSpanMake(aRegin.span.latitudeDelta, aRegin.span.longitudeDelta));
}


- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated{

    [_mapView setCenterCoordinate:coordinate animated:animated];
}


- (void)addOverLayer:(NSArray *)coordinates strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor lineWidth:(CGFloat)lineWidth uid:(NSString *)uid
{
    if (uid == nil) return;
    
    MAMapPoint *temppoints = new MAMapPoint[[coordinates count]];
    for (int i = 0; i < [coordinates count]; i++) {
        NSString *loc   = [coordinates objectAtIndex:i];
        NSArray  *split = [loc componentsSeparatedByString:@","];
        NSAssert(split.count == 2, @"Coordinate descripe string need 'a,b'");
        NSString               *lon = [split objectAtIndex:0];
        NSString               *lat = [split objectAtIndex:1];
        CLLocationCoordinate2D coor;
        coor.longitude = [lon floatValue];
        coor.latitude  = [lat floatValue];
        MAMapPoint pt = MAMapPointForCoordinate(coor);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }
    
    MAPolygon *overlay = [MAPolygon polygonWithPoints:temppoints count:coordinates.count];
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

    MAMapPoint *temppoints = new MAMapPoint[[coordinates count]];
    for (int i = 0; i < [coordinates count]; i++) {
        CLLocation *loc   = [coordinates objectAtIndex:i];
        NSAssert([loc isKindOfClass:[CLLocation class]], @"Coordinate is CLLocation Object");
        
        MAMapPoint pt = MAMapPointForCoordinate(loc.coordinate);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }

    MAPolyline* line = [MAPolyline polylineWithPoints:temppoints count:coordinates.count];
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

    [_mapView setCenterCoordinate:coordinate];
    [_mapView setZoomLevel:newZoomLevel  animated:animated];
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
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAShape class]]) {
        
        MAShape* shape = (MAShape*)overlay;
        NSString* uid = shape._uid_;
        
        PYShapeInfo *shapeInfo = [_shapeCache objectForKey:uid];
        
        ///添加多边形
        if (shapeInfo && ShapeType_Polygon == shapeInfo.shapeType) {
            
            MAPolygonView *cutomView = [[MAPolygonView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = shapeInfo.strokeColor;
            cutomView.fillColor   = shapeInfo.fillColor;
            cutomView.lineWidth   = shapeInfo.lineWidth;
            
            return cutomView;
         
        ///添加线条
        }else if (shapeInfo && ShapeType_Line == shapeInfo.shapeType){
            
            MAPolylineView *cutomView = [[MAPolylineView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = shapeInfo.strokeColor;
            cutomView.lineWidth   = shapeInfo.lineWidth;
            
            return cutomView;
        }

        return nil;
    }
    
  
    return nil;
}


// 根据anntation生成对应的View
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        MAPointAnnotation* pointAnnotation = (MAPointAnnotation*)annotation;
        NSString* uid = pointAnnotation._uid_;
        
        PYAnnotationInfo *annotationSave = [_annotationCache objectForKey:uid];
        NSString* reuseId = annotationSave.reuseId;
        
        PYMAAnnotationView *annotationView = (PYMAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
        
        if (annotationView == nil) {
            annotationView = [[PYMAAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:reuseId];
        }
       
        
        annotationView.annotationId = uid;
        
        //viewForAnnotationWithId 优先级高于添加时候的设定
        if ([_mapDelegate respondsToSelector:@selector(pyMap:viewForAnnotationWithId:)]) {
            
            UIView* showView = [_mapDelegate pyMap:self viewForAnnotationWithId:uid];
            [annotationView setShowView:showView];
        
        }else{
 
            NSString* imageName = annotationSave.imageName;
            annotationView.image = [UIImage imageNamed:imageName];
            annotationView.centerOffset = CGPointMake(0,
                                                      -annotationView.image.size.height * 0.5f);
        }
        
        ///气泡
        if ([_mapDelegate respondsToSelector:@selector(pyMap:calloutViewForAnnotationWithId:)]) {
            UIView* calloutView = [_mapDelegate pyMap:self calloutViewForAnnotationWithId:uid];
            [annotationView changeCalloutView:calloutView];
        }
        
        return annotationView;
        
    }
    
    return nil;
}


-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{

    if (![view isKindOfClass:[PYMAAnnotationView class]]) return;
    
    if ([_mapDelegate respondsToSelector:@selector(pyMap:annotationSelectAtUid:)]) {
        [_mapDelegate pyMap:self annotationSelectAtUid:((PYMAAnnotationView*)view).annotationId];
    }
}



-(void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view{

    if (![view isKindOfClass:[PYMAAnnotationView class]]) return;
   
    if ([_mapDelegate respondsToSelector:@selector(pyMap:annotationDeSelectAtUid:)]) {
        [_mapDelegate pyMap:self annotationDeSelectAtUid:((PYMAAnnotationView*)view).annotationId];
    }
}


-(void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    PYCoordinateSpan  span = PYCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                  mapView.region.span.longitudeDelta);
    
    PYCoordinateRegion region = PYCoordinateRegionMake(mapView.region.center,
                                                       span);
    
    if ([_mapDelegate respondsToSelector:@selector(pyMap:regionDidChangeTo:withAnimated:)]) {
        [_mapDelegate pyMap:self regionDidChangeTo:region withAnimated:animated];
    }
}


-(void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{

    
    PYCoordinateSpan  span = PYCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                  mapView.region.span.longitudeDelta);
    
    PYCoordinateRegion region = PYCoordinateRegionMake(mapView.region.center,
                                                       span);
    
    if (![_mapDelegate respondsToSelector:@selector(pyMap:regionWillChangeFrom:withAnimated:)]) {
        [_mapDelegate pyMap:self regionWillChangeFrom:region withAnimated:animated];
    }
    
}


- (void)removeAllAnnotations
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_annotationCache removeAllObjects];
}


- (void)removeOverlayView:(NSString *)uid
{
    [_mapView removeOverlay:[_shapeCache objectForKey:uid].shape];
    [_shapeCache removeObjectForKey:uid];
}


- (void)removeRouteView:(NSString *)uid{

    [self removeOverlayView:uid];
}


- (void)updateCallout{

    for (MAPointAnnotation* aAnnotation in _mapView.annotations) {
        
        if (![aAnnotation isKindOfClass:[MAPointAnnotation class]]) continue;
        
        PYMAAnnotationView *annotationView  = (PYMAAnnotationView*)[_mapView viewForAnnotation:aAnnotation];
        if (![annotationView isKindOfClass:[PYMAAnnotationView class]]) continue;
        
       
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
