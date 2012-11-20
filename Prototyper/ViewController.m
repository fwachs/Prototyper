//
//  ViewController.m
//  Prototyper
//
//  Created by rafa on 06/11/12.
//  Copyright (c) 2012 2clams. All rights reserved.
//

#import "ViewController.h"
#import "Screen.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];

    CGRect frame = self.view.frame;
    frame.size.height = screenBounds.size.width;
    frame.size.width = screenBounds.size.height;
    self.view.frame = frame;
    
    self.screen = [[Screen alloc] initWithFile:self.fileName view:self.view];
    self.screen.delegate = self;
    
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBack:)];
    [self.view addGestureRecognizer:gesture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)elementTapped:(NSString *)eventName
{
    NSLog(@"element tapped: %@", eventName);
    NSArray *comps = [eventName componentsSeparatedByString:@":"];
    
    if([comps count] < 2) return;
    
    if([[comps objectAtIndex:1] isEqualToString:@"back"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
        vc.fileName = [NSString stringWithFormat:@"res/screen-cfgs/%@", [comps objectAtIndex:1]];

        [self.navigationController pushViewController:vc animated:YES];
    }
    
    /*
    if([[comps objectAtIndex:0] isEqualToString:@"modal"]) {
        
    }
    else {
        
    }
     */
}

- (void)swipeBack:(UISwipeGestureRecognizer*)gesture
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
