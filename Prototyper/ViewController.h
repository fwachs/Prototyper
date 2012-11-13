//
//  ViewController.h
//  Prototyper
//
//  Created by rafa on 06/11/12.
//  Copyright (c) 2012 2clams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Screen.h"

@interface ViewController : UIViewController <ScreenDelegate>

@property (strong) Screen *screen;
@property (strong) NSString *fileName;

@end
