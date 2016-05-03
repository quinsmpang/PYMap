//
//  PYMapSearchServiceFactory.h
//  PYMap
//
//  Created by yr on 16/5/3.
//  Copyright © 2016年 yr. All rights reserved.
//

#import "PYMapSearchServiceKit.h"

@interface PYMapSearchServiceFactory : NSObject

/**
 *  创建地图搜索器
 */
+(id<PYMapSearcherProtocal>)createSearcher;

/**
 *  需在开始使用前调用
 *  建议放在UIApplicationDelegate启动回调里(application:didFinishLaunchingWithOptions:)
 */
+(id)start;

@end
