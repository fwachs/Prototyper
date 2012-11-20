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
        view = viewToLoad;
        
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
    
    float xScale = screenSize.width / 800.0;
    float yScale = screenSize.height / 1280.0;
    
    CGRect tRect = CGRectMake(rect.origin.x * yScale, rect.origin.y * xScale, rect.size.width * yScale, rect.size.height * xScale);
    
    return tRect;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
        qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"Begin element %@", attributeDict);
    
    if([elementName isEqualToString:@"screen:element"] == YES) {
        NSString *resource = [attributeDict valueForKey:@"resource"];
        NSString *fileName = [NSString stringWithFormat:@"res/images/%@", resource];
        
        UIView *parentView = [elementStack lastObject];
        
        
        UIImage *image = Nil;
        CGSize imageSize;
        
        if([resource length] > 0) {
            image = [UIImage imageWithData:[self loadFileAtPath:fileName]];
            imageSize = image.size;
        }
        else {
            NSString *swidth = [attributeDict valueForKey:@"width"];
            if(swidth) {
                imageSize.width = [swidth floatValue];
            }
            else {
                imageSize.width = parentView.frame.size.width;
            }

            NSString *sheight = [attributeDict valueForKey:@"height"];
            if(sheight) {
                imageSize.height = [sheight floatValue];
            }
            else {
                imageSize.height = parentView.frame.size.height;
            }
        }
        
        CGRect frame;        
        CGPoint pos = CGPointMake([[attributeDict valueForKey:@"left"] floatValue], [[attributeDict valueForKey:@"top"] floatValue]);
        frame.origin = pos;
        frame.size = imageSize;
        
        UIView *newView = [[UIView alloc] initWithFrame:frame];
        newView.backgroundColor = [UIColor clearColor];
        newView.frame = [self translateRect:frame];

        [parentView addSubview:newView];
        [elementStack addObject:newView];

        NSString *visible = [attributeDict valueForKey:@"visible"];
        if(visible && [[visible lowercaseString] isEqualToString:@"no"]) {
            newView.hidden = YES;
        }
        
        [elements setValue:newView forKey:[attributeDict valueForKey:@"name"]];
        lastAttributes = attributeDict;
        
        
        if(image) {
            UIView *subView = Nil;

            NSString *ontap = [attributeDict valueForKey:@"ontap"];
            if(ontap && [ontap isEqualToString:@""] == NO) {
                UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
                [but addTarget:self action:@selector(elementTapped:) forControlEvents:UIControlEventTouchUpInside];
                [but setImage:image forState:UIControlStateNormal];
                
                [events addObject:ontap];
                but.tag = [events count];
                subView = but;
            }
            else {
                subView = [[UIImageView alloc] initWithImage:image];
            }
            
            subView.frame = newView.bounds;
            subView.contentMode = UIViewContentModeScaleToFill;
            
            [newView addSubview:subView];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"Text %@", string);
    
    NSString *text = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    if([text length] == 0) return;
    
    UIView *parentView = [elementStack lastObject];

    UILabel *label = [[UILabel alloc] initWithFrame:parentView.bounds];
    
    NSString *fontName = @"ArialMT";
    NSString *fontStyle = [lastAttributes valueForKey:@"font-style"];
    if([fontStyle isEqualToString:@"bold"]) {
        fontName = @"Arial-BoldMT";
    }
    else if([fontStyle isEqualToString:@"italic"]) {
        fontName = @"Arial-ItalicMT";
    }
    
    float fontSize = 14.0f;
    NSString *size = [lastAttributes valueForKey:@"font-size"];
    if(size) {
        fontSize = [size floatValue];
    }
    
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont fontWithName:fontName size:fontSize]];
    [label setText:text];
    
    NSString *align = [lastAttributes valueForKey:@"text-align"];
    if(align) {
        if([align isEqualToString:@"right"]) {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        else if([align isEqualToString:@"center"]) {
            [label setTextAlignment:NSTextAlignmentCenter];
        }
        else {
            [label setTextAlignment:NSTextAlignmentLeft];
        }
    }
    
    [parentView addSubview:label];
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"End element");
    
    [elementStack removeLastObject];
}

- (void)elementTapped:(UIButton*)ele
{
    NSString *eventName = [events objectAtIndex:ele.tag - 1];
    [self.delegate elementTapped:eventName];
}

@end
