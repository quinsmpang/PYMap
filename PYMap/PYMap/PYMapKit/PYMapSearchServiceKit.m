//
//  PYMapSearchService.m
//  YR
//
//  Created by YR on 15/10/16.
//  Copyright © 2015年 YR. All rights reserved.
//

#import "PYMapSearchServiceKit.h"
#import "PYMapApiKey.h"

#ifdef _Map_Tencent
#import "PYMapSearcherWithTencent.h"
#endif


#ifdef _Map_MA
#import "PYMapSearcherWithMA.h"
#endif

@implementation PYMapSearchServiceFactory

+ (id<PYMapSearcherProtocal>)createSearcher
{
#ifdef _Map_Tencent
    return [[PYMapSearcherWithTencent alloc] init];
#endif
    
#ifdef _Map_MA
    return [[PYMapSearcherWithMA alloc] init];
#endif
    return nil;
}


+ (id)start
{
#ifdef _Map_Tencent
    [[QMSSearchServices sharedServices] setApiKey:PYMapApiKey];
#endif
    
    
#ifdef _Map_MA
    [[AMapSearchServices sharedServices] setApiKey:PYMapApiKey];
#endif

    return nil;
}


@end
