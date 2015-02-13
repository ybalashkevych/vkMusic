//
//  DetailViewController.h
//  exampleCoreData
//
//  Created by George on 13.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

