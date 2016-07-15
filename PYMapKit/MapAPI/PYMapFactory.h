//
//  PYMapFactory.h
//  QMapKitSample
//
//  Created by YR on 15/8/21.
//  Copyright (c) 2015年 YR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYMapKit.h"
#import "PYCoordCover.h"

/**
 *  @author YangRui, 15/8/21
 *
 *  地图创建工厂
 */
@interface PYMapFactory : NSObject

/**
 *  创建地图
 */
+(id<PYMapKitProtocal>) createMap;

/**
 *  需在开始使用前调用
 *  建议放在UIApplicationDelegate启动回调里(application:didFinishLaunchingWithOptions:)
 */
+(id)start;

/**
 *  需在停止使用前调用
 *  建议放在UIApplicationDelegate启动回调里(applicationWillTerminate:)
 */
+(void)end:(id)manager;


@end
