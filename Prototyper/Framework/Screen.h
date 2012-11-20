//
//  Screen.h
//  Prototyper
//
//  Created by rafa on 12/11/12.
//  Copyright (c) 2012 2clams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ScreenDelegate <NSObject>

- (void)elementTapped:(NSString *)eventName;

@end

@interface Screen : NSObject <NSXMLParserDelegate> {
    NSMutableArray *elementStack;
    NSMutableDictionary *elements;
    NSMutableArray *events;
    NSDictionary *lastAttributes;
    UIView *view;
}

@property (assign) id <ScreenDelegate> delegate;

- (id)initWithFile:(NSString*)fileName view:(UIView*)viewToLoad;

@end
