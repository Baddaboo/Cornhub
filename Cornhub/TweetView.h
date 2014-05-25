//
//  TweetView.h
//  Cornhub
//
//  Created by Blake Tsuzaki on 5/25/14.
//  Copyright (c) 2014 Swag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) NSArray *tweets;
@end
