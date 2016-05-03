//
//  PYAnnotation.h
//
//  Created by YR on 15/8/19.
//  Copyright (c) 2015年 YR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  @author YangRui, 15/8/19
 *
 *  点标注协议
 */
@protocol  PYAnnotation < NSObject>

/*!
 *  @brief  标注view中心坐标
 */
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

/*!
 *  @brief  获取annotation标题
 *
 *  @return 返回annotation的标题信息
 */
- (NSString *)title;

/*!
 *  @brief  获取annotation副标题
 *
 *  @return 返回annotation的副标题信息
 */
- (NSString *)subtitle;




@end

@interface PYPointAnnotation : NSObject <PYAnnotation>

@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSString* subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
