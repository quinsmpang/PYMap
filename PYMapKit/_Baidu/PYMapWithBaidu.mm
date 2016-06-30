//
//   PYMapWithBaidu.m
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 YR. All rights reserved.
//
#ifdef _Map_Baidu

#import "PYMapWithBaidu.h"
#import "PYBaiduImageAnnotation.h"
#import "PYCoordCover.h"
#import "BMK+Add.h"


@interface PYPointAnnotationSave : NSObject

@property(nonatomic, strong) BMKPointAnnotation *annotation;
@property(nonatomic, strong) NSString           *uid;
@property(nonatomic, strong) NSString           *imageName;

@end

@interface PYMapWithBaidu () <BMKMapViewDelegate>

@end

@implementation PYMapWithBaidu {
    BMKMapView          *_mapView;
    NSMutableDictionary *_overlayInfo;
    NSMutableDictionary *_annotationInfo;
}

- (instancetype)init
{
    if (self = [super init]) {
        @try {
            _mapView = [[BMKMapView alloc] init];
        }@catch (NSException *exception) {
            _mapView = [[BMKMapView alloc] init];
            NSLog(@"RECREATE");
        } @finally {
        }

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
 *  @brief  向地图窗口添加标注，需要实现QMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 *
 *  @param annotation 要添加的标注
 */
- (void)addAnnotation:(id <PYAnnotation>)annotation imageName:(NSString *)imgStr uid:(NSString *)uid
{
    if (uid == nil) return;

    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc] init];
    pointAnnotation._uid_ = uid;

    CLLocationCoordinate2D coor = [annotation coordinate];
    coor                       = [PYCoordCover convertGCJ02ToBD:coor.latitude with:coor.longitude];
    pointAnnotation.coordinate = coor;

    PYPointAnnotationSave *save = [PYPointAnnotationSave new];
    save.annotation = pointAnnotation;
    save.imageName  = imgStr;
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
    
    center = [PYCoordCover convertBDToGCJ02:qRegin.center];

    return PYCoordinateRegionMake(center,
                                  PYCoordinateSpanMake(qRegin.span.latitudeDelta, qRegin.span.longitudeDelta));
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
        coor           = [PYCoordCover convertGCJ02ToBD:coor.latitude with:coor.longitude];
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
                             , nil];

    [_overlayInfo setObject:dicInfo forKey:[NSString stringWithFormat:@"%@",uid]];

    [_mapView addOverlay:overlay];
    delete temppoints;
}


/*!
 *  @brief  根据annotation生成对应的view
 *
 *  @param mapView    地图view
 *  @param annotation 指定的标注
 *
 *  @return 指定标注对应的view
 */

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolygon class]]) {
        
        BMKPolygon* polygon = overlay;
        NSString* uid = polygon._uid_;
        
        NSDictionary *dic = [_overlayInfo objectForKey:uid];
        if (dic && [[dic objectForKey:@"shape"] isEqualToString:@"Polygon"]) {
            BMKPolygonView *cutomView = [[BMKPolygonView alloc] initWithOverlay:overlay];
            
            cutomView.strokeColor = [dic objectForKey:@"strokeColor"];
            cutomView.fillColor   = [dic objectForKey:@"fillColor"];
            cutomView.lineWidth   = [[dic objectForKey:@"lineWidth"] floatValue];
            
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [newDic setObject:polygon forKey:@"view"];
            [_overlayInfo setObject:newDic forKey:uid];
            \
            return cutomView;
        }

    }
    
  
    return nil;
}


// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        
        BMKPointAnnotation* pointAnnotation = annotation;
        NSString* uid = pointAnnotation._uid_;
        
        //动画annotation
        PYPointAnnotationSave *annotationSave = [_annotationInfo objectForKey:uid];
        NSString              *imageName      = annotationSave.imageName;
        if (nil == imageName) return nil;
        
        PYBaiduImageAnnotation *annotationView = (PYBaiduImageAnnotation *)[mapView dequeueReusableAnnotationViewWithIdentifier:uid];
        
        if (annotationView == nil) {
            annotationView = [[PYBaiduImageAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:uid];
        }
        
        annotationView.annotationImageView.image = [UIImage imageNamed:imageName];
        return annotationView;

    }
    
    return nil;
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


@end

@implementation PYPointAnnotationSave
@end

#endif
