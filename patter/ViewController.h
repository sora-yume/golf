//
//  ViewController.h
//  patter
//
//  Created by 平原　和人 on 14/01/09.
//  Copyright (c) 2014年 University of kitakyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *shibaA;
@property (strong, nonatomic) IBOutlet UIView *shibaB;
@property (strong, nonatomic) IBOutlet UIView *banker;
@property (strong, nonatomic) IBOutlet UIView *cup;
@property (strong, nonatomic) IBOutlet UIView *ball;
@property (nonatomic, strong) NSMutableArray *anchorArray;

@end
