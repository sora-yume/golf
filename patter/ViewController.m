//
//  ViewController.m
//  patter
//
//  Created by 平原　和人 on 14/01/09.
//  Copyright (c) 2014年 University of kitakyu. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

typedef enum{
    BallStop,
    BallTouch,
    BallRelease,
} BallStatus;

@interface ViewController (){
    BallStatus status;
    CGPoint startPoint;
    CGPoint releasePoint;
    float speed;
    CADisplayLink *timer;
}

@end

@implementation ViewController
@synthesize ball, anchorArray;
@synthesize shibaA, shibaB, banker, cup;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //self.view.backgroundColor = [UIColor greenColor];
    anchorArray = [[NSMutableArray alloc] init];
    
    //ground
    [self createGround];
    
    //ball
    [self setUpBall];
    
    //start
    [self start];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    ball = nil;
    anchorArray = nil;
}


- (void)createGround
{
    
    //createGround
    shibaA = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];//define ichi,size(xpiont,ypoint,width,height)
    shibaA.center = CGPointMake(160,340);//
    shibaA.layer.cornerRadius = 15.0;//coner
    //[self.view addSubview:shibaA];
    
    shibaB = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,50)];
    shibaB.center = CGPointMake(120,120);
    shibaB.layer.cornerRadius = 15.0;
    //[self.view addSubview:shibaB];
    
    banker = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,50)];
    banker.center = CGPointMake(220,200);
    banker.layer.cornerRadius = 25.0;
    //[self.view addSubview:banker];
    
    cup = [[UIView alloc] initWithFrame:CGRectMake(0,0,40,40)];
    cup.center = CGPointMake(280,50);
    cup.layer.transform = CATransform3DMakeRotation(M_PI * 0.2, 1.0, 0, 0);
    cup.layer.cornerRadius = 100;
    //[self .view addSubview:cup];
     
}


 
- (void)setUpBall
{
    //setUpBall
    ball = [[UIView alloc] initWithFrame:CGRectMake(0,0,20,20)];
    ball.center = CGPointMake(160,350);
    ball.layer.cornerRadius = 10.0;
    ball.layer.zPosition = 200;
    //[self.view addSubview:ball];
}


- (void)start
{
    timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisp:)];
    [timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateDisp:(CADisplayLink*)sender
{
    if (status == BallRelease){
        float dx = (startPoint.x - releasePoint.x) * speed * 0.001;
        float dy = (startPoint.y - releasePoint.y) * speed * 0.001;
        ball.center = CGPointMake(ball.center.x + dx, ball.center.y + dy);
        
        float groundCondition = [self checkGroundCondition:ball.frame];
        
        //checkCupIn
        if (groundCondition < 0) {
            status = BallStop;
            [UIView animateWithDuration:1.0 animations:^{
                ball.center = cup.center;
                ball.transform = CGAffineTransformMakeScale(0.5,0.5);
            } completion:^(BOOL finished) {
                //clearEffect
                UILabel *clearLabel = [[UILabel alloc] init];
                clearLabel.font = [UIFont boldSystemFontOfSize:50];
                clearLabel.text = @"Clear!";
                [clearLabel sizeToFit];
                clearLabel.center = CGPointMake(160,-200);
                clearLabel.backgroundColor = [UIColor clearColor];
                //[self.view addSubview:clearLabel];
                
                [UIView animateWithDuration:0.5 animations:^{
                    clearLabel.center = self.view.center;
                }];
                
            }];
        }
        
        speed = speed - groundCondition;
        if(speed < 0){
            status = BallStop;
            startPoint = ball.center;
        }
    }
}

- (float)checkGroundCondition:(CGRect)rect
{
    //speedChangeForGround
    if (CGRectIntersectsRect(rect, shibaA.frame)){
        return 2.0;
    }
    else if (CGRectIntersectsRect(rect, shibaB.frame)){
        return 3.0;
    }
    else if (CGRectIntersectsRect(rect, banker.frame)){
        return 10.0;
    }
    else if (CGRectIntersectsRect(rect, cup.frame)){
        return -1.0;
    }
    return 1.0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self.view];
    if (CGRectContainsPoint(ball.frame, p)){
        startPoint = ball.center;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //引っ張るとアンカーがのびる
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self.view];
    
    for (UIView *v in self.anchorArray){
        [v removeFromSuperview];
    }
    
    float dx = startPoint.x - p.x;
    float dy = startPoint.y - p.y;
    int len = hypotf(dx,dy);
    for(int i=10; i<len; i+=10){
        UIView *anchorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        anchorView.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.6].CGColor;
        anchorView.layer.borderWidth = 2.0;
        anchorView.layer.cornerRadius = 5.0;
        anchorView.center = CGPointMake(startPoint.x - i * (dx / len), startPoint.y - i * (dy / len));
        //[self.view addSubview:anchorView];
        [self.anchorArray addObject:anchorView];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //話すとボールを飛ばす
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self.view];
    
    releasePoint = p;
    speed = hypotf(startPoint.x - p.x, startPoint.y - p.y);
    status = BallRelease;
    
    for (UIView *v in self.anchorArray){
        [v removeFromSuperview];
    }
 
}

 
@end
