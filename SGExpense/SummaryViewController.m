//
//  SummaryViewController.m
//  SGExpense
//
//  Created by Hu Jianbo on 26/4/14.
//  Copyright (c) 2014 SD. All rights reserved.
//

#import "SummaryViewController.h"
#import "DBManager.h"

@interface SummaryViewController ()

@end

@implementation SummaryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initGlobalData
{
    [self setTitle:@"Summary"];
    self.currency = @"S$";
    self.nSummaryType = 1;
    self.pSelectedDate =[NSDate date];
    self.pCategoryArray = [[NSArray alloc] initWithObjects:@"MONTH", @"YEAR", nil];
    self.pMonthYearSelect.text = @"MONTH";
    self.pMonthYearField.text = [self formatMonthString:self.pSelectedDate];
    self.nSummaryType = 0;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                   target:self action:@selector(doneSelectMothAndYear:)];
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:
                          CGRectMake(0, self.view.frame.size.height-
                                     self.pMonthYearField.frame.size.height-50, 320, 50)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             doneButton, nil];
    [toolBar setItems:toolbarItems];
    self.pMonthYearField.inputView = self.pPickerMonthAndYear;
    self.pMonthYearField.inputAccessoryView = toolBar;
    self.pPickerMonthAndYear.hidden = YES;
    [self prepareSummaryData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pHeaderView.layer.borderWidth = 1;
    self.pHeaderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pHeaderView.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    self.pMonthYearSelect.backgroundColor = [UIColor lightGrayColor];
    self.pHeaderView.layer.cornerRadius = 5;
    self.pViewSummary.layer.cornerRadius = 5;
    self.pViewSummary.layer.masksToBounds = YES;
    self.pViewSummary.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pViewSummary.layer.borderWidth = 1.0f;
    self.pSeperate1View.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pSeperate1View.layer.borderWidth = 1;
    self.pSeperate2View.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pSeperate2View.layer.borderWidth = 1;
    self.pViewSummary.layer.backgroundColor =[UIColor cyanColor].CGColor;
    self.pMonthYearField.backgroundColor = [UIColor cyanColor];
    // Do any additional setup after loading the view.
    [self configMonthYearSelector];
    self.pPickerMonthAndYear.hidden = YES;
    [self initGlobalData];
    [self configYearPicker];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configYearPicker
{
    self.pPickerYear.hidden = YES;
    self.pPickerYear.dataSource = self;
    self.pPickerYear.delegate = self;
    self.pPickerYear.showsSelectionIndicator = YES;
    if(self.toolBarYear == nil)
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                       target:self action:@selector(doneSelectYear:)];
        self.toolBarYear = [[UIToolbar alloc]initWithFrame:
                              CGRectMake(0, self.view.frame.size.height-
                                         self.pMonthYearSelect.frame.size.height-50, 320, 50)];
        [self.toolBarYear setBarStyle:UIBarStyleBlackOpaque];
        NSArray *toolbarItems = [NSArray arrayWithObjects:
                                 doneButton, nil];
        [self.toolBarYear setItems:toolbarItems];
    }
    
    if(self.pYearData == nil)
    {
        self.pYearData = [[NSMutableArray alloc] init];
    }
    NSUInteger loopNumber;
    for(loopNumber = 2000; loopNumber <= 2030; loopNumber++) {
        NSString * pString =[NSString stringWithFormat:@"%d", loopNumber];
        [self.pYearData addObject:pString];
    }
    
    return;
}

- (void) configMonthYearSelector
{
    self.pPickerSelectYearMonth.hidden = YES;
    self.pPickerSelectYearMonth.dataSource = self;
    self.pPickerSelectYearMonth.delegate = self;
    self.pPickerSelectYearMonth.showsSelectionIndicator = YES;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                   target:self action:@selector(doneSelectMothOrYear:)];
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:
                          CGRectMake(0, self.view.frame.size.height-
                                     self.pMonthYearSelect.frame.size.height-50, 320, 50)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             doneButton, nil];
    [toolBar setItems:toolbarItems];
    self.pMonthYearSelect.inputView = self.pPickerSelectYearMonth;
    self.pMonthYearSelect.inputAccessoryView = toolBar;
    return;
}

-(void) doneSelectYear:(id)sender
{
    self.pPickerYear.hidden = YES;
    [self.pMonthYearField resignFirstResponder];
    [self prepareSummaryData];

}

-(void)doneSelectMothAndYear:(id)sender
{
    self.pPickerMonthAndYear.hidden = YES;
    [self.pMonthYearField resignFirstResponder];
    self.pMonthYearField.text = [self formatMonthString:self.pPickerMonthAndYear.date];
    [self prepareSummaryData];
}

- (IBAction)selctDateRange:(id)sender {
    if(self.nSummaryType == 0)
    {
        self.pPickerMonthAndYear.hidden = NO;
        NSDate *pToday =  [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:
                                            (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
                                             NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                       fromDate:pToday ];
        [dateComponents setDay:1];
        [dateComponents setMonth:self.nMonth ];
        [dateComponents setYear:self.nYear];
        self.pPickerMonthAndYear.date = [calendar dateFromComponents:dateComponents];
    }else if(self.nSummaryType == 1)
    {
        NSInteger nIndex = [self.pYearData indexOfObject:self.pMonthYearField.text];
        self.pPickerYear.hidden = NO;
        if(NSNotFound == nIndex) nIndex = 0;
        [self.pPickerYear selectRow:nIndex inComponent:0 animated:YES];
    }

}

-(void)doneSelectMothOrYear:(id)sender
{
    self.pPickerSelectYearMonth.hidden = YES;
    [self.pMonthYearSelect resignFirstResponder];
    NSString * pText = self.pMonthYearSelect.text;
    if([pText isEqual:@"MONTH"])
    {
        self.pMonthYearField.text = [self formatMonthString:self.pSelectedDate];
        self.nSummaryType = 0;
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                       target:self action:@selector(doneSelectMothAndYear:)];
        UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:
                              CGRectMake(0, self.view.frame.size.height-
                                         self.pMonthYearField.frame.size.height-50, 320, 50)];
        [toolBar setBarStyle:UIBarStyleBlackOpaque];
        NSArray *toolbarItems = [NSArray arrayWithObjects:
                                 doneButton, nil];
        [toolBar setItems:toolbarItems];
        self.pMonthYearField.inputView = self.pPickerMonthAndYear;
        self.pMonthYearField.inputAccessoryView = toolBar;
        self.pPickerMonthAndYear.hidden = YES;
    }
    else if ([pText isEqual:@"YEAR"])
    {
        self.pMonthYearField.text = [self formatYearString:self.pSelectedDate];
        self.nSummaryType = 1;
        self.pPickerYear.dataSource = self;
        self.pMonthYearField.inputAccessoryView = self.toolBarYear;
        self.pMonthYearField.inputView = self.pPickerYear;
    }
       // self.categoryName = [self.pCategoryArray objectAtIndex:self.categoryRow];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
    if(pickerView == self.pPickerSelectYearMonth)
        self.pMonthYearSelect.text = [self.pCategoryArray objectAtIndex:row];
    else if(pickerView == self.pPickerYear)
    {
        self.pMonthYearField.text = [self.pYearData objectAtIndex:row];
    }else if(pickerView == self.pPickerMonthAndYear)
    {
        self.pMonthYearField.text = [self formatMonthString:self.pPickerMonthAndYear.date];
    }
}

- (IBAction)beginSelectMonthOrYear:(id)sender {
    self.pPickerSelectYearMonth.hidden = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if(pickerView == self.pPickerSelectYearMonth)
        return [self.pCategoryArray count] ;
    else if (pickerView == self.pPickerYear)
    {
        return [self.pYearData count];
    }
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    if(pickerView == self.pPickerSelectYearMonth)
        
        return [self.pCategoryArray objectAtIndex:row];
    else if (pickerView == self.pPickerYear)
        return [self.pYearData objectAtIndex:row];
    return nil;
}

-(NSString *) formatYearString:(NSDate *) date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    self.nYear = [components year];
    return [NSString stringWithFormat:@"%ld", (long)self.nYear];
}

-(NSString *) formatMonthString:(NSDate *) date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    self.nMonth = [components month];
    self.nYear = [components year];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSArray * monthnames =[df monthSymbols];
    NSString *monthName = [monthnames objectAtIndex:(self.nMonth-1)];
    return [NSString stringWithFormat:@"%@ %ld", monthName, (long)self.nYear];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) prepareSummaryData
{
    if(self.nSummaryType == 0 )
    {
        self.fTotalExepnse = [[DBManager getSharedInstance] getRecursiveSummaryCategory:@"Expense" year:self.nYear month:self.nMonth];
        self.fTotalIncome = [[DBManager getSharedInstance] getRecursiveSummaryCategory:@"Income" year:self.nYear month:self.nMonth];
    }else if(self.nSummaryType == 1)
    {
        self.fTotalExepnse = [[DBManager getSharedInstance] getRecursiveSummaryCategory:@"Expense" year:self.nYear];
        self.fTotalIncome = [[DBManager getSharedInstance] getRecursiveSummaryCategory:@"Income" year:self.nYear];
    }
    double fTotalRemaining = self.fTotalIncome - self.fTotalExepnse;
    
    self.pIncomeTotalField.text = [NSString stringWithFormat:@"%@%.2f", self.currency, self.fTotalIncome];
    self.pExpenseTotalField.text = [NSString stringWithFormat:@"%@%.2f", self.currency, self.fTotalExepnse];
    self.pRemainingField.text = [NSString stringWithFormat:@"%@%.2f", self.currency, fTotalRemaining];

}


@end