//
//  Screen.m
//  Prototyper
//
//  Created by rafa on 12/11/12.
//  Copyright (c) 2012 2clams. All rights reserved.
//

#import "Screen.h"
#import <QuartzCore/QuartzCore.h>

@implementation Screen

- (id)initWithFile:(NSString*)fileName view:(UIView*)viewToLoad
{
    self = [super init];
    if(self) {
        elementStack = [NSMutableArray array];
        [elementStack addObject:viewToLoad];
        
        elements = [NSMutableDictionary dictionary];
        events = [NSMutableArray array];
        
        [self loadFromFile:fileName];
        
        NSLog(@"%f, %f, %f, %f", viewToLoad.frame.origin.x, viewToLoad.frame.origin.y, viewToLoad.frame.size.width, viewToLoad.frame.size.height);
    }
    return self;
}

- (void)loadFromFileInBundle:(NSString*)fileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res/screen-cfgs/darkside-screen-cfg" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    [xmlParser setDelegate:self];
    
    //Start parsing the XML file.
    BOOL success = [xmlParser parse];
    
    if(success)
        NSLog(@"No Errors");
    else
        NSLog(@"Error Error Error!!!");
}

- (NSData*)loadFileAtPath:(NSString*)pathString
{
    NSData *data = Nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:pathString];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path] == YES){
        data = [NSData dataWithContentsOfFile:path];
    }
    else {
        NSLog(@"File %@ doesn't exist", path);
    }
    
    return data;
}

- (void)loadFromFile:(NSString*)fileName
{
    NSData *data = [self loadFileAtPath:fileName];
    
    if(data){
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
        
        [xmlParser setDelegate:self];
        
        //Start parsing the XML file.
        BOOL success = [xmlParser parse];
        
        if(success)
            NSLog(@"No Errors");
        else
            NSLog(@"Error Error Error!!!");
    }
    else {
        NSLog(@"Error Error Error!!!");
    }    
}

- (CGRect)translateRect:(CGRect)rect
{
    UIView *rootView = [elementStack objectAtIndex:0];
    CGSize screenSize;
    screenSize.height = rootView.frame.size.width;
    screenSize.width = rootView.frame.size.height;
    
    float xScale = screenSize.width / 400.0;
    float yScale = screenSize.height / 640.0;
    
    CGRect tRect = CGRectMake(rect.origin.x * yScale / 2, rect.origin.y * xScale / 2, rect.size.width * yScale, rect.size.height * xScale);
    
    return tRect;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
        qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"screen:element"] == YES) {
        NSString *fileName = [NSString stringWithFormat:@"res/images/%@", [attributeDict valueForKey:@"resource"]];
        
        UIView *parentView = [elementStack lastObject];
        UIImage *image = [UIImage imageWithData:[self loadFileAtPath:fileName]];
        CGSize imageSize = image.size;
        
        UIView *subView = Nil;
        
        NSString *ontap = [attributeDict valueForKey:@"ontap"];
        if(ontap && [ontap isEqualToString:@""] == NO) {
            UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
            [but addTarget:self action:@selector(elementTapped:) forControlEvents:UIControlEventTouchUpInside];
            [but setImage:image forState:UIControlStateNormal];
            
            [events addObject:ontap];
            but.tag = [events count] + 1;
            subView = but;
        }
        else {
            subView = [[UIImageView alloc] initWithImage:image];
        }
        subView.contentMode = UIViewContentModeScaleToFill;

        CGRect frame = subView.frame;
        
        CGPoint pos = CGPointMake([[attributeDict valueForKey:@"left"] floatValue], [[attributeDict valueForKey:@"top"] floatValue]);
        frame.origin = pos;
        
        frame.size = imageSize;
        
        subView.frame = [self translateRect:frame];
        
        NSString *visible = [attributeDict valueForKey:@"visible"];
        if(visible && [[visible lowercaseString] isEqualToString:@"no"]) {
            subView.hidden = YES;
        }
        
        [elements setValue:subView forKey:[attributeDict valueForKey:@"name"]];

        [parentView addSubview:subView];
        [elementStack addObject:subView];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    [elementStack removeLastObject];
}

- (void)elementTapped:(UIButton*)ele
{
    NSString *eventName = [events objectAtIndex:ele.tag - 1];
    [self.delegate elementTapped:eventName];
}

@end
