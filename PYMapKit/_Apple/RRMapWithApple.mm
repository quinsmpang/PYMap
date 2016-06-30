//
//  RRMapWithMA.m
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 MA. All rights reserved.
//
#ifdef _Map_Apple

#import "RRMapWithApple.h"
#import "RRAppleImageAnnotation.h"
#import "Apple+Add.h"
#import "MKMapView+ZoomLevel.h"


/**
 *  @author YangRui, 16-02-26 10:02:46
 *
 *  地图显示标注视图类型
 */
typedef NS_ENUM(NSUInteger, MKAnonotationType) {
    MKAnonotationType_Normal,    //只有图片
    MKAnonotationType_Callout, //带callout的气泡
};;


@interface RRPointAnnotationSave : NSObject

@property(nonatomic,strong) MKPointAnnotation* annotation;
@property(nonatomic,strong) NSString*   uid;
@property(nonatomic,strong) NSString*   imageName;
@property(nonatomic,assign) MKAnonotationType type;

@end


@interface RRMapWithApple () <MKMapViewDelegate>
@end


@implementation RRMapWithApple {
    MKMapView            *_mapView;
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
        _mapView        = [[MKMapView alloc] init];
        _overlayInfo    = [[NSMutableDictionary alloc] init];
        _annotationInfo = [[NSMutableDictionary alloc] init];

        [_mapView setCenterCoordinate:[RRConfig currentLocation]];
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
 *  @brief  向地图窗口添加标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 *
 *  @param annotation 要添加的标注
 */
- (void)addAnnotation:(id <RRAnnotation>)annotation imageName:(NSString *)imgStr uid:(NSString *)uid
{
    [self _addAnnotation:annotation imageName:imgStr uid:uid withType:MKAnonotationType_Normal];

}



- (void)addCalloutAnnotation:(id<RRAnnotation>)annotation
                         imageName:(NSString *)imgStr
                               uid:(NSString *)uid{
   
    [self _addAnnotation:annotation imageName:imgStr uid:uid withType:MKAnonotationType_Callout];
}

- (void)_addAnnotation:(id<RRAnnotation>)annotation
                        imageName:(NSString *)imgStr
                              uid:(NSString *)uid
                         withType:(MKAnonotationType)type{
   
    if (uid == nil) return;
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation._uid_      = uid;
    pointAnnotation.coordinate = [annotation coordinate];
    
    RRPointAnnotationSave* save = [RRPointAnnotationSave new];
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
- (void)removeAnnotation:(NSString*)annotationUID;
{
    RRPointAnnotationSave *pointAnnotation  = [_annotationInfo objectForKey:annotationUID];
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
    MKCoordinateRegion aRegin = MKCoordinateRegionMake(region.center,
                                                     MKCoordinateSpanMake(region.span.latitudeDelta,
                                                                          region.span.longitudeDelta));

    [_mapView setRegion:aRegin animated:animated];
}


- (RRCoordinateRegion)regionThatFits:(RRCoordinateRegion)region
{
    MKCoordinateRegion aRegin = MKCoordinateRegionMake(region.center,
                                                     MKCoordinateSpanMake(region.span.latitudeDelta, region.span.longitudeDelta));
    aRegin = [_mapView regionThatFits:aRegin];

    return RRCoordinateRegionMake(aRegin.center,
                                  RRCoordinateSpanMake(aRegin.span.latitudeDelta, aRegin.span.longitudeDelta));
}


- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated{

    [_mapView setCenterCoordinate:coordinate animated:animated];
}


- (void)addOverLayer:(NSArray *)coordinates strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor lineWidth:(CGFloat)lineWidth uid:(NSString *)uid
{
    if (uid == nil) return;
    
    MKMapPoint *temppoints = new MKMapPoint[[coordinates count]];
    for (int i = 0; i < [coordinates count]; i++) {
        NSString *loc   = [coordinates objectAtIndex:i];
        NSArray  *split = [loc componentsSeparatedByString:@","];
        NSAssert(split.count == 2, @"Coordinate descripe string need 'a,b'");
        NSString               *lon = [split objectAtIndex:0];
        NSString               *lat = [split objectAtIndex:1];
        CLLocationCoordinate2D coor;
        coor.longitude = [lon floatValue];
        coor.latitude  = [lat floatValue];
        MKMapPoint pt = MKMapPointForCoordinate(coor);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }
    
    MKPolygon *overlay = [MKPolygon polygonWithPoints:temppoints count:coordinates.count];
    overlay._uid_ = uid;
    
    NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:strokeColor, @"strokeColor"
                             , fillColor, @"fillColor"
                             , @(lineWidth), @"lineWidth"
                             , @"Polygon", @"shape"
                             , overlay, @"view"
                             , nil];
    
    [_overlayInfo setObject:dicInfo forKey:uid];
    
    [_mapView addOverlay:overlay];
    delete[] temppoints;
}


-(void)addRouteWithCoords:(NSArray*)coordinates
              strokeColor:(UIColor*)strokeColor
                lineWidth:(CGFloat)lineWidth
                      uid:(NSString*)uid
{
    if (uid == nil) return;

    MKMapPoint *temppoints = new MKMapPoint[[coordinates count]];
    for (int i = 0; i < [coordinates count]; i++) {
        CLLocation *loc   = [coordinates objectAtIndex:i];
        NSAssert([loc isKindOfClass:[CLLocation class]], @"Coordinate is CLLocation Object");
        
        MKMapPoint pt = MKMapPointForCoordinate(loc.coordinate);
        temppoints[i].x = pt.x;
        temppoints[i].y = pt.y;
    }

    MKPolyline* line = [MKPolyline polylineWithPoints:temppoints count:coordinates.count];
    line._uid_ = uid;

    NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys
                             :strokeColor, @"strokeColor"
                             , @(lineWidth), @"lineWidth"
                             , @"Polyline", @"shape"
                             , line, @"view"
                             , nil];

    [_overlayInfo setObject:dicInfo forKey:uid];

    [_mapView addOverlay:line];
    delete[] temppoints;
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
    
    [_mapView setCenterCoordinate:_mapView.centerCoordinate
                        zoomLevel:zoomScale
                         animated:animated];
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

- (RRCoordinateRegion)getMapRegion{
    RRCoordinateSpan  span = RRCoordinateSpanMake(_mapView.region.span.latitudeDelta,
                                                  _mapView.region.span.longitudeDelta);
    
    RRCoordinateRegion region = RRCoordinateRegionMake(_mapView.region.center,
                                                       span);
    
    return region;
    

}

/*!
 *  @brief  根据annotation生成对应的view
 *
 *  @param MKpView    地图view
 *  @param annotation 指定的标注
 *
 *  @return 指定标注对应的view
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKShape class]]) {
        MKShape* shape = (MKShape*)overlay;
        NSString* uid = shape._uid_;
        
        NSDictionary *dic = [_overlayInfo objectForKey:uid];
        if (dic && [[dic objectForKey:@"shape"] isEqualToString:@"Polygon"]) {
            MKOverlayPathRenderer *cutomView = [[MKOverlayPathRenderer alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = [dic objectForKey:@"strokeColor"];
            cutomView.fillColor   = [dic objectForKey:@"fillColor"];
            cutomView.lineWidth   = [[dic objectForKey:@"lineWidth"] floatValue];
            
            return cutomView;
        }else if (dic && [[dic objectForKey:@"shape"] isEqualToString:@"Polyline"]){
            MKPolylineRenderer *cutomView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = [dic objectForKey:@"strokeColor"];
            cutomView.lineWidth   = [[dic objectForKey:@"lineWidth"] floatValue];
            
            return cutomView;

        }

        return nil;
    }
    
  
    return nil;
}


// 根据anntation生成对应的View
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        MKPointAnnotation* pointAnnotation = (MKPointAnnotation*)annotation;
        NSString* uid = pointAnnotation._uid_;
        
        RRAppleImageAnnotation *annotationView = (RRAppleImageAnnotation *)[mapView dequeueReusableAnnotationViewWithIdentifier:uid];
        
        if (annotationView == nil) {
            annotationView = [[RRAppleImageAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:uid];
        }
       
        RRPointAnnotationSave *annotationSave = [_annotationInfo objectForKey:uid];
        annotationView.other = uid;
        
        //动画annotation
        if ([self.mapDelegate respondsToSelector:@selector(rrMap:viewForAnnotationId:)]) {
            
            UIView* showView = [self.mapDelegate rrMap:self viewForAnnotationId:uid];
            if (nil == showView) return nil;
            [annotationView setShowView:showView];
        
        }else{
 
            NSString* imageName = annotationSave.imageName;
            if (nil == imageName) return nil;
            
            annotationView.image = [UIImage imageNamed:imageName];
            annotationView.centerOffset = CGPointMake(0,
                                                      -annotationView.image.size.height * 0.5f);
        }
        
        if (annotationSave.type == MKAnonotationType_Callout) {
           
            if (self.annotationCalloutViewWithUid) {
                UIView* calloutView = self.annotationCalloutViewWithUid(uid);
                [annotationView changeCalloutView:calloutView];
            }
        }
        
        return annotationView;
        
    }
    
    return nil;
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{

    if (![view isKindOfClass:[RRAppleImageAnnotation class]]) return;
    
    if (self.annotationSelectAtUid) {
        self.annotationSelectAtUid(((RRAppleImageAnnotation*)view).other);
    }
}



-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{

    if (![view isKindOfClass:[RRAppleImageAnnotation class]]) return;
    
    if (self.annotationDeSelectAtUid) {
        self.annotationDeSelectAtUid(((RRAppleImageAnnotation*)view).other);
    }

}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    RRCoordinateSpan  span = RRCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                  mapView.region.span.longitudeDelta);
    
    RRCoordinateRegion region = RRCoordinateRegionMake(mapView.region.center,
                                                       span);
    
    if ([_mapDelegate respondsToSelector:@selector(rrMap:regionDidChangeTo:withAnimated:)]) {
        [_mapDelegate rrMap:self regionDidChangeTo:region withAnimated:animated];
    }
    
    if ([_mapDelegate respondsToSelector:@selector(rrMap:regionDidChangeTo:)]) {
        [_mapDelegate rrMap:self regionDidChangeTo:region];
    }
}


-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{

    if (![_mapDelegate respondsToSelector:@selector(rrMap:regionWillChangeFrom:withAnimated:)]) return;
    
    
    RRCoordinateSpan  span = RRCoordinateSpanMake(mapView.region.span.latitudeDelta,
                                                  mapView.region.span.longitudeDelta);
    
    RRCoordinateRegion region = RRCoordinateRegionMake(mapView.region.center,
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


- (void)updateCallout{

    for (MKPointAnnotation* aAnnotation in _mapView.annotations) {
        
        if (![aAnnotation isKindOfClass:[MKPointAnnotation class]]) continue;
        
        RRPointAnnotationSave *annotationSave = [_annotationInfo objectForKey:aAnnotation._uid_];
        if (annotationSave.type != MKAnonotationType_Callout) continue;
        
        RRAppleImageAnnotation *annotationView  = (RRAppleImageAnnotation*)[_mapView viewForAnnotation:aAnnotation];
        if (![annotationView isKindOfClass:[RRAppleImageAnnotation class]]) continue;
        
       
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


@implementation RRPointAnnotationSave

@end

#endif
