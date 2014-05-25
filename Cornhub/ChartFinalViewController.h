//
//  ChartFinalViewController.h
//  Cornhub
//
//  Created by Blake Tsuzaki on 5/25/14.
//  Copyright (c) 2014 Swag. All rights reserved.
//
#import "XYPieChart.h"
#import <UIKit/UIKit.h>
#import "TweetView.h"

@interface ChartFinalViewController : UIViewController <XYPieChartDataSource, XYPieChartDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet XYPieChart *pieChart;
@property (strong, nonatomic) IBOutlet UINavigationItem *navItem;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingChart;
@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) IBOutlet UILabel *chartLabel;
@property (strong, nonatomic) IBOutlet TweetView *tweetView;

@end
