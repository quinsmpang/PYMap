//
//  PYCoordCover.h
//  QMapKitSample
//
//  Created by YR on 15/8/21.
//  Copyright (c) 2015年 YR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  @author YangRui, 15/8/21
 *
 *  坐标体系转换工具类
 */
@interface PYCoordCover : NSObject

//转GPS坐标与百度坐标互转

/**
 * 百度坐标系 to 火星坐标系 (GCJ-02)
 */
+ (CLLocationCoordinate2D)convertBDToGCJ02:(double)lat with:(double)lon;
+ (CLLocationCoordinate2D)convertBDToGCJ02:(CLLocationCoordinate2D)coor;
/**
 * 火星坐标系 (GCJ-02) to 百度坐标系
 */
+ (CLLocationCoordinate2D)convertGCJ02ToBD:(double)lat with:(double)lon;
+ (CLLocationCoordinate2D)convertGCJ02ToBD:(CLLocationCoordinate2D)coor;



//转GPS坐标与火星坐标互转

/**
 * Gps84 to 火星坐标系 (GCJ-02) //World Geodetic System ==> Mars Geodetic System
 */
+ (CLLocationCoordinate2D)convertWGSToGCJ02:(CLLocationCoordinate2D)wgsLoc;
+ (CLLocationCoordinate2D)convertWGSToGCJ02WithLat:(double)lat lon:(double)lon;
/**
 * 火星坐标系 (GCJ-02) to Gps84 //Mars Geodetic System ==> World Geodetic System 
 */
+ (CLLocationCoordinate2D)convertGCJ02ToWGS:(CLLocationCoordinate2D)gcjLoc;
+ (CLLocationCoordinate2D)convertGCJ02ToWGSWithLat:(double)lat lon:(double)lon;

@end
