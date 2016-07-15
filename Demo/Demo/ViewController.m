//
//  ViewController.m
//  PYMap
//
//  Created by YR on 16/4/28.
//  Copyright © 2016年 yr. All rights reserved.
//

#import "ViewController.h"
#import "PYMapFactory.h"

@interface ViewController (){

    id <PYMapKitProtocal> _map;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _map = [PYMapFactory createMap];
    
    [_map setRegion:PYCoordinateRegionMake(CLLocationCoordinate2DMake(30.653605f,104.050807f),
                                           PYCoordinateSpanMake(0.0001, 0.0001))
           animated:YES];
    
    self.view = [_map mapView];
}


@end
