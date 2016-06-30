//
//  PYMapSearchServiceFactory.m
//  PYMap
//
//  Created by yr on 16/5/3.
//  Copyright © 2016年 yr. All rights reserved.
//

#import "PYMapSearchServiceFactory.h"
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
