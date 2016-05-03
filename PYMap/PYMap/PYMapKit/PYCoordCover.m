//
//  PYCoordCover.m
//  QMapKitSample
//
//  Created by YR on 15/8/21.
//  Copyright (c) 2015年 YR. All rights reserved.
//

#import "PYCoordCover.h"
#import "PYMapGeometry.h"

@implementation PYCoordCover

/**
 * 百度坐标系 to 火星坐标系 (GCJ-02)
 */
+ (CLLocationCoordinate2D)convertBDToGCJ02:(double)lat with:(double)lon
{
    double                 x_pi       = M_PI*3000.0/180.0;
    double                 x          = lon - 0.0065;
    double                 y          = lat - 0.006;
    double                 z          = sqrt(x*x+y*y)-0.00002*sin(y*x_pi);
    double                 theta      = atan2(y, x)-0.000003*cos(x*x_pi);
    double                 google_lon = z*cos(theta);
    double                 google_lat = z*sin(theta);
    CLLocationCoordinate2D location   = CLLocationCoordinate2DMake(google_lat, google_lon);
    return location;
}


+ (CLLocationCoordinate2D)convertBDToGCJ02:(CLLocationCoordinate2D)coor
{
    return [self convertBDToGCJ02:coor.latitude with:coor.longitude];
}


/**
 * 火星坐标系 (GCJ-02) to 百度坐标系
 */
+ (CLLocationCoordinate2D)convertGCJ02ToBD:(double)lat with:(double)lon
{
    double x_pi = M_PI*3000.0/180.0;
    double x    = lon, y = lat;

    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);

    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);

    double bd_lon = z * cos(theta) + 0.0065;
    double bd_lat = z * sin(theta) + 0.006;

    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(bd_lat, bd_lon);
    return location;
}


+ (CLLocationCoordinate2D)convertGCJ02ToBD:(CLLocationCoordinate2D)coor
{
    return [self convertGCJ02ToBD:coor.latitude with:coor.longitude];
}


///////////////////////

/**
 * Gps84 to 火星坐标系 (GCJ-02) //World Geodetic System ==> Mars Geodetic System
 */
+ (CLLocationCoordinate2D)convertWGSToGCJ02WithLat:(double)lat lon:(double)lon
{
    PYCoordinateSpan span = [self delta:lat with:lon];

    double mgLat = lat + span.latitudeDelta;
    double mgLon = lon + span.longitudeDelta;
    return CLLocationCoordinate2DMake(mgLat, mgLon);
}


+ (CLLocationCoordinate2D)convertWGSToGCJ02:(CLLocationCoordinate2D)wgsLoc
{
    return [self convertWGSToGCJ02WithLat:wgsLoc.latitude lon:wgsLoc.longitude];
}


/**
 * 火星坐标系 (GCJ-02) to Gps84 //Mars Geodetic System ==> World Geodetic System
 */
+ (CLLocationCoordinate2D)convertGCJ02ToWGSWithLat:(double)lat lon:(double)lon
{
    PYCoordinateSpan span = [self delta:lat with:lon];

    double mgLat = lat + span.latitudeDelta;
    double mgLon = lon + span.longitudeDelta;

    double latitude  = lat * 2 - mgLat;
    double lontitude = lon * 2 - mgLon;
    return CLLocationCoordinate2DMake(latitude, lontitude);
}


+ (CLLocationCoordinate2D)convertGCJ02ToWGS:(CLLocationCoordinate2D)gcjLoc
{
    return [self convertGCJ02ToWGSWithLat:gcjLoc.latitude lon:gcjLoc.longitude];
}


#pragma mark -  Helper Methods

const double a  = 6378245.0;
const double ee = 0.00669342162296594323;
const double pi = M_PI;

+ (PYCoordinateSpan)delta:(double)lat with:(double)lon
{
    double dLat   = [self transformLat:lon - 105.0 y:lat - 35.0];
    double dLon   = [self transformLon:lon - 105.0 y:lat - 35.0];
    double radLat = lat / 180.0 * pi;
    double magic  = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);

    return PYCoordinateSpanMake(dLat, dLon);
}


+ (double)transformLat:(double)x y:(double)y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y
                 + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}


+ (double)transformLon:(double)x y:(double)y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1
                 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0
                                                     * pi)) * 2.0 / 3.0;
    return ret;
}


@end
