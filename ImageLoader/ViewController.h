//
//  ViewController.h
//  ImageLoader
//
//  Created by Joe Andolina on 9/25/12.
//  Copyright (c) 2012 Joe Andolina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITextView *instructionText;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (weak, nonatomic) IBOutlet UILabel *progressText;

@end
