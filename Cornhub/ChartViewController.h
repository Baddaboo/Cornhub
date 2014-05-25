//
//  ChartViewController.h
//  Cornhub
//
//  Created by Blake Tsuzaki on 5/24/14.
//  Copyright (c) 2014 Swag. All rights reserved.
//
#import "XYPieChart.h"
#import <UIKit/UIKit.h>

@interface ChartViewController : UIViewController <XYPieChartDataSource, XYPieChartDelegate>
@property (strong, nonatomic) IBOutlet XYPieChart *pieChart;
@property (strong, nonatomic) IBOutlet UIButton *upButton;
- (IBAction)upButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *neutralButton;
- (IBAction)neutralButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *downButton;
- (IBAction)downButtonPressed:(id)sender;

@end
