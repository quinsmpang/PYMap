//
//  QMK+Add.m
//  YR
//
//  Created by YR on 15/9/18.
//  Copyright © 2015年 YR. All rights reserved.
//

#ifdef _Map_Tencent

#import "QMK+Add.h"
#import <objc/runtime.h>

@implementation QShape (ADD_UID)


- (void)set_uid_:(NSString *)_uid_
{
    objc_setAssociatedObject(self, @selector(_uid_), _uid_,
                             OBJC_ASSOCIATION_RETAIN);
}


- (NSString *)_uid_
{

    return objc_getAssociatedObject(self, @selector(_uid_));

}


@end

#endif
