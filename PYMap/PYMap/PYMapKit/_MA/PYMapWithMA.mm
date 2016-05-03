//
//  PYMapWithMA.m
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 YR. All rights reserved.
//
#ifdef _Map_MA

#import "PYMapWithMA.h"
#import "PYMAImageAnnotation.h"
#import "MA+Add.h"


/**
 *  @author YangRui, 16-02-26 10:02:46
 *
 *  地图显示标注视图类型
 */
typedef NS_ENUM(NSUInteger, MAAnonotationType) {
    MAAnonotationType_Normal,    //只有图片
    MAAnonotationType_Callout,   //带有气泡
};;


@interface PYPointAnnotationSave : NSObject

@property(nonatomic,strong) MAPointAnnotation* annotation;
@property(nonatomic,strong) NSString*   uid;
@property(nonatomic,strong) NSString*   imageName;
@property(nonatomic,assign) MAAnonotationType type;

@end


@interface PYMapWithMA () <MAMapViewDelegate>
@end


@implementation PYMapWithMA {
    MAMapView            *_mapView;
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
        _mapView        = [[MAMapView alloc] init];
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
 *  @brief  向地图窗口添加标注
 *
 *  @param annotation 要添加的标注
 */
- (void)addAnnotation:(id <PYAnnotation>)annotation imageName:(NSString *)imgStr uid:(NSString *)uid
{
    [self _addAnnotation:annotation imageName:imgStr uid:uid withType:MAAnonotationType_Normal];

}



- (void)addCalloutAnnotation:(id<PYAnnotation>)annotation
                         imageName:(NSString *)imgStr
                               uid:(NSString *)uid{
   
    [self _addAnnotation:annotation imageName:imgStr uid:uid withType:MAAnonotationType_Callout];
}

- (void)_addAnnotation:(id<PYAnnotation>)annotation
                        imageName:(NSString *)imgStr
                              uid:(NSString *)uid
                         withType:(MAAnonotationType)type{
   
    if (uid == nil) return;
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
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
    MACoordinateRegion aRegin = MACoordinateRegionMake(region.center,
                                                     MACoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta));

    [_mapView setRegion:aRegin animated:animated];
}


- (PYCoordinateRegion)regionThatFits:(PYCoordinateRegion)region
{
    MACoordinateRegion aRegin = MACoordinateRegionMake(region.center,
                                                     MACoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta));
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

//    [_mapView setCenterCoordinate:coordinate zoomLevel:newZoomLevel animated:animated];
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
        
        NSDictionary *dic = [_overlayInfo objectForKey:uid];
        if (dic && [[dic objectForKey:@"shape"] isEqualToString:@"Polygon"]) {
            MAPolygonView *cutomView = [[MAPolygonView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = [dic objectForKey:@"strokeColor"];
            cutomView.fillColor   = [dic objectForKey:@"fillColor"];
            cutomView.lineWidth   = [[dic objectForKey:@"lineWidth"] floatValue];
            
            return cutomView;
        }else if (dic && [[dic objectForKey:@"shape"] isEqualToString:@"Polyline"]){
            MAPolylineView *cutomView = [[MAPolylineView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = [dic objectForKey:@"strokeColor"];
            cutomView.lineWidth   = [[dic objectForKey:@"lineWidth"] floatValue];
            
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
        
        PYMAImageAnnotation *annotationView = (PYMAImageAnnotation *)[mapView dequeueReusableAnnotationViewWithIdentifier:uid];
        
        if (annotationView == nil) {
            annotationView = [[PYMAImageAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:uid];
        }
       
        PYPointAnnotationSave *annotationSave = [_annotationInfo objectForKey:uid];
        annotationView.other = uid;
        
        //动画annotation
        if ([self.mapDelegate respondsToSelector:@selector(pyMap:viewForAnnotationWithId:)]) {
            
            UIView* showView = [self.mapDelegate pyMap:self viewForAnnotationWithId:uid];
            if (nil == showView) return nil;
            [annotationView setShowView:showView];
        
        }else{
 
            NSString* imageName = annotationSave.imageName;
            if (nil == imageName) return nil;
            
            annotationView.image = [UIImage imageNamed:imageName];
        }
        
        if (annotationSave.type == MAAnonotationType_Callout) {
           
            if (self.annotationCalloutViewWithUid) {
                UIView* calloutView = self.annotationCalloutViewWithUid(uid);
                [annotationView changeCalloutView:calloutView];
            }
        }
        
        return annotationView;
        
    }
    
    return nil;
}


-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{

    if (![view isKindOfClass:[PYMAImageAnnotation class]]) return;
    
    if (self.annotationSelectAtUid) {
        self.annotationSelectAtUid(((PYMAImageAnnotation*)view).other);
    }
}



-(void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view{

    if (![view isKindOfClass:[PYMAImageAnnotation class]]) return;
    
    if (self.annotationDeSelectAtUid) {
        self.annotationDeSelectAtUid(((PYMAImageAnnotation*)view).other);
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


- (void)removeRouteView:(NSString *)uid{

    [self removeOverlayView:uid];
}


- (void)updateCallout{

    for (MAPointAnnotation* aAnnotation in _mapView.annotations) {
        
        if (![aAnnotation isKindOfClass:[MAPointAnnotation class]]) continue;
        
        PYPointAnnotationSave *annotationSave = [_annotationInfo objectForKey:aAnnotation._uid_];
        if (annotationSave.type != MAAnonotationType_Callout) continue;
        
        PYMAImageAnnotation *annotationView  = (PYMAImageAnnotation*)[_mapView viewForAnnotation:aAnnotation];
        if (![annotationView isKindOfClass:[PYMAImageAnnotation class]]) continue;
        
       
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
