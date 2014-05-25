//
//  TweetView.m
//  Cornhub
//
//  Created by Blake Tsuzaki on 5/25/14.
//  Copyright (c) 2014 Swag. All rights reserved.
//

#import "TweetView.h"
#import "tweetViewCell.h"

@implementation TweetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTweets:) name:@"ShowTweets" object:nil];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"tweetCell"];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.tweets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    tweetViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:@"tweetCell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
    cell.layer.masksToBounds = NO;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.borderWidth = 7.0f;
    cell.layer.contentsScale = [UIScreen mainScreen].scale;
    cell.layer.shadowOpacity = 0.75f;
    cell.layer.shadowRadius = 5.0f;
    cell.layer.shadowOffset = CGSizeZero;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    cell.layer.shouldRasterize = YES;
    
    
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 290, 30)];
    if ([[self.tweets objectAtIndex:indexPath.row] valueForKey:@"user"])
        [userLabel setText:[NSString stringWithFormat:@"%@ wrote:", [[self.tweets objectAtIndex:indexPath.row] valueForKey:@"user"]]];
    [cell addSubview:userLabel];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 35, 290, 60)];
    [messageLabel setText:[[self.tweets objectAtIndex:indexPath.row] valueForKey:@"tweet"]];
    [cell addSubview:messageLabel];
    return cell;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    NSNumber *moveToBack = [NSNumber numberWithInt:0];
    if (scrollView.contentOffset.y < 100){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ToggleLayer" object:moveToBack];
    }
    else{
        moveToBack = [NSNumber numberWithInt:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ToggleLayer" object:moveToBack];
    }
}

- (void)reloadTweets:(NSNotification *)notification{
    self.tweets = [notification object];
    [self reloadData];
}

@end
