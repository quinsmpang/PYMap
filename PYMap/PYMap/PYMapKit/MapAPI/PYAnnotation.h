//
//  PYAnnotation.h
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 YR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  标注协议
 */
@protocol  PYAnnotation < NSObject>

/*!
 *  @brief  标注view中心坐标
 */
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) BOOL showCallout;

@end




/**
 *  点标注
 */
@interface PYPointAnnotation : NSObject <PYAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) BOOL showCallout;

@end
