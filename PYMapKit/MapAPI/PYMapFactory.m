//
//  PYMapFactory.m
//  QMapKitSample
//
//  Created by YR on 15/8/21.
//  Copyright (c) 2015年 YR. All rights reserved.
//

#import "PYMapFactory.h"
#import "PYMapApiKey.h"

#ifdef _Map_Baidu
#import "PYMapWithBaidu.h"
#endif

#ifdef _Map_Tencent
#import "PYMapWithTencent.h"
#endif


#ifdef _Map_MA
#import "PYMapWithMA.h"
#endif


@implementation PYMapFactory

/**
 *  创建地图
 */
+(id<PYMapKitProtocal>) createMap{
    
#ifdef _Map_Baidu
    return [[PYMapWithBaidu alloc] init];
#endif
    
#ifdef _Map_Tencent
    return [[PYMapWithTencent  alloc] init];
#endif
    
#ifdef _Map_MA
    return [[PYMapWithMA alloc] init];
#endif
    
    return nil;
}


/**
 *  设置apikey 和 地图服务代理
 */
+(id) setApiKey:(NSString*)key delegate:(id)delegate{

#ifdef _Map_Baidu
    BMKMapManager* manager = [[BMKMapManager alloc] init];
    [manager start:key generalDelegate:delegate];
    return manager;
#endif
    
#ifdef _Map_Tencent
     [QMapServices sharedServices].apiKey = key;
#endif
    
#ifdef _Map_MA
    [MAMapServices sharedServices].apiKey = key;
#endif
    
    return nil;
}

/**
 *  需在开始使用前调用
 */
+(id)start{

    NSString* key = PYMapApiKey;

    return  [PYMapFactory setApiKey:key delegate:self];
}


/**
 *  需在停止使用前调用
 */
+(void)end:(id)manager{
#ifdef _Map_Baidu
    if ([manager isKindOfClass:[BMKMapManager class]]) {
        [((BMKMapManager*)manager) stop];
    }
#endif
}


/**
 *  应用丢失活跃状态时调用
 */
+(void)appWillResignActive{
    
#ifdef _Map_Baidu
//    [BMKMapView willBackGround];
#endif
}

/**
 *  应用变为活跃状态时候调用
 */
+(void)appDidBecomeActive{
    
#ifdef _Map_Baidu
//    [BMKMapView didForeGround];
#endif
}

@end
