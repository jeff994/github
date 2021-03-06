//
//  DealTableViewController.h
//  SGExpense
//
//  Created by Hu Jianbo on 10/5/14.
//  Copyright (c) 2014 SD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealTableViewController : UITableViewController <UIGestureRecognizerDelegate>
@property   NSMutableArray *pAllDeals;
@property UITextField * pHeaderField;
-(void) loadDeals;
- (void) initTableHeader;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *m_activityView;
- (IBAction)unwindfromdeal:(UIStoryboardSegue *)segue;
@property  UISwipeGestureRecognizer *swipeRight;
@property  UISwipeGestureRecognizer *swipeLeft;

@end

