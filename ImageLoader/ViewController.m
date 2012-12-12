//
//  ViewController.m
//  ImageLoader
//
//  Created by Joe Andolina on 9/25/12.
//  Copyright (c) 2012 Joe Andolina. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>

@interface ViewController ()

@end

@implementation ViewController
{
    int count;
    int finished;
    NSArray *paths;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:@"img"];
	
    self.importButton.enabled = [paths count] > 0;
    self.instructionText.alpha = [paths count] > 0 ? 0 : 1;
    self.progressView.progress = 0.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleImageImport:(id)sender
{
    count = 0;
    finished = 0;
    [self importImages];
    self.importButton.enabled = false;
}

- (void)importImages
{
    NSLog(@"importImages");
    
    for (NSString *path in paths)
    {
        NSURL * tmpPath = [NSURL URLWithString:path relativeToURL:nil];
        CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)tmpPath, NULL);

        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        NSMutableData* data = [self getImageWithMetaData:image];
        //CGImageSourceRef* ref = [CGImageSourceCreateWithURL (
        //                                             CFURLRef  path,
        //                                             CFDictionaryRef nil
        //                                             ) ];
        
        if (image)
        {
            count++;
            SEL sel = @selector(image:handleImageLoaded:contextInfo:);
            UIImageWriteToSavedPhotosAlbum(image, self, sel, NULL);
        }
    }
    
    NSLog(@"Found %d", count);
}


//FOR CAMERA IMAGE
//NSData *originalImgData = [self getImageWithMetaData:imgOriginal];

//FOR PHOTO LIBRARY IMAGE
//[self getImagedataPhotoLibrary:[[myasset defaultRepresentation] metadata] andImage:imgOriginal];

-(NSMutableData *)getImageWithMetaData:(UIImage *)pImage
{
    //NSData* pngData =  UIImagePNGRepresentation(pImage);
    NSData* pngData =  UIImageJPEGRepresentation(pImage, 1.0);

    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)pngData, NULL);
    NSDictionary *metadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    
    //For EXIF Dictionary
    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    if(!EXIFDictionary)
        EXIFDictionary = [NSMutableDictionary dictionary];
    
    [EXIFDictionary setObject:[NSDate date] forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
    [EXIFDictionary setObject:[NSDate date] forKey:(NSString*)kCGImagePropertyExifDateTimeDigitized];
    
    NSLog(@"%@", [EXIFDictionary valueForKey:(NSString*)kCGImagePropertyExifDateTimeOriginal]);
    
    //add our modified EXIF data back into the image’s metadata
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    
    CFStringRef UTI = CGImageSourceGetType(source);
    
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    
    if(!destination)
        dest_data = [pngData mutableCopy];
    else
    {
        CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef) metadataAsMutable);
        BOOL success = CGImageDestinationFinalize(destination);
        if(!success)
            dest_data = [pngData mutableCopy];
    }
    
    if(destination)
        CFRelease(destination);
    
    CFRelease(source);
    
    return dest_data;
}

//FOR PHOTO LIBRARY IMAGE
-(NSMutableData *)getImagedataPhotoLibrary:(NSDictionary *)pImgDictionary andImage:(UIImage *)pImage
{
    NSData* data = UIImagePNGRepresentation(pImage);
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    NSMutableDictionary *metadataAsMutable = [pImgDictionary mutableCopy];
    
    CFStringRef UTI = CGImageSourceGetType(source);
    
    NSMutableData *dest_data = [NSMutableData data];
    
    //For Mutabledata
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    
    if(!destination)
        dest_data = [data mutableCopy];
    else
    {
        CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef) metadataAsMutable);
        BOOL success = CGImageDestinationFinalize(destination);
        if(!success)
            dest_data = [data mutableCopy];
    }
    if(destination)
        CFRelease(destination);
    
    CFRelease(source);
    
    return dest_data;
}

- (void)image:(UIImage *)image handleImageLoaded:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        count--;
        NSLog(@"Loading Error: %@", error);
    }
    else
    {
        NSLog(@"Loaded %d of %d", finished, count);
        self.progressText.text = [NSString stringWithFormat:@"Progress: %d of %d", finished, count];
        self.progressView.progress = finished/(count+0.0);
        finished++;
    }
    
    if( count == finished )
    {
        self.progressText.text = @"Progress: Complete";
        NSLog(@"Complete");
    }
}


@end
