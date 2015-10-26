//
//  ViewController.m
//  日历
//
//  Created by apple on 15/8/27.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    CGFloat _yOffset;
    CGFloat _xOffset;
    CGFloat _xSpace;
    CGFloat _ySpace;
    CGFloat _dayWidth;
    CGFloat _dayHeight;
    NSDate *_disDate;
    NSMutableArray *_labelsArray;
}
@property (weak, nonatomic) IBOutlet UITextField *text;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConfig];
    [self displayCalenderWithDate:[NSDate date]];

}
-(void)setupConfig
{
    CGSize screenSize=[UIScreen mainScreen].bounds.size;
    _yOffset=80;
    _xOffset=0;
    _xSpace=2;
    _ySpace=2;
    _dayHeight=100;
    _dayWidth=(screenSize.width-_xSpace*8)/7;
    _labelsArray=[NSMutableArray array];
}
//根据任意一天计算当月的起始日的日期以及当月一共有多少天
//通过参数传指针输出结果
-(void)startDate:(NSDate **)startDateOfMonth andDays:(NSInteger*)days ofMonthWithDate:(NSDate *)date
{
    NSDate *startDate;
    NSTimeInterval secondsOfMonth;
    NSCalendar *calender=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //用日历对象计算当月起始日和当月一共拥有多少秒
    [calender rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:&secondsOfMonth forDate:date];
    
    NSInteger daysOfMonth=secondsOfMonth/(3600*24);// 秒数转为天数
     *days=daysOfMonth;
    //下面修正起始日期的时区问题
    NSTimeZone *zone=[NSTimeZone systemTimeZone];
    NSInteger interval=[zone secondsFromGMTForDate:*startDateOfMonth];
    *startDateOfMonth=[startDate dateByAddingTimeInterval:interval];
}
-(void)displayCalenderWithDate:(NSDate *)date
{
    _disDate = date;
    NSDate *startDateOfMonth;
    NSInteger daysOfMonth;
    //下面得到起始日期和当月总天数，结果输出到上面2个变量
    [self startDate:&startDateOfMonth andDays:&daysOfMonth ofMonthWithDate:date];

    NSCalendar *tmpCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [tmpCalendar components:NSCalendarUnitWeekday fromDate:startDateOfMonth];
    NSLog(@"%ld",comp.weekday);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy年MM月";
    NSString *dateStr = [formatter stringFromDate:startDateOfMonth];
    _text.text = dateStr;
    _text.textAlignment = NSTextAlignmentCenter;
    
   //    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
//    dateFormat.dateFormat = @"ccc";
//    NSString *str = [dateFormat stringFromDate:startDateOfMonth];
//    NSLog(@"str:%@",str);
    
    
//    NSLog(@"str:%@,%ld",startDateOfMonth,daysOfMonth);
    for (UILabel *label in _labelsArray) {
        [label removeFromSuperview];
    }
    [_labelsArray removeAllObjects];
    
    for(int week=0,dayOfMonth=0;week<5;week++)
    {
        for(int dayOfWeek=0;(dayOfWeek<7)&&(dayOfMonth<daysOfMonth);dayOfWeek++)
        {
          //根据第几周的第几天来计算格子的显示位置
            if (week == 0 && dayOfWeek<comp.weekday-1) {
                continue;
            }
            
            CGFloat x=dayOfWeek*_dayWidth+(dayOfWeek+1)*_xSpace+_xOffset;
            CGFloat y=week*_dayHeight+(week+1)*_ySpace+_yOffset;
            CGRect frame=CGRectMake(x , y, _dayWidth,_dayHeight);
            //下面获取具体第几天应该显示的文本信息
            NSString *text=[self weakDayStringOfDays:dayOfMonth sinceDate:startDateOfMonth];
            UILabel *label;
            //根据计算出的位置大小以及文本信息来创建格子控键
            label=[self createLabelWithFrame:frame andText:text];
           //  NSString
            //添加到显示界面
            [self.view addSubview:label];
            [_labelsArray addObject:label];
            
            dayOfMonth++;
        }
      
    }
    UILabel *label2 = [UILabel new];
    NSCalendar *new = [NSCalendar currentCalendar];
    NSDateComponents *new1 = [new components:NSCalendarUnitDay fromDate:[NSDate date]];
    label2.text = [NSString stringWithFormat:@"%ld",new1.day];
    if (_labelsArray.count < new1.day)
    {
        label2 = [_labelsArray lastObject];
        label2.backgroundColor = [UIColor blueColor];
    }else
    {
        label2 = _labelsArray[new1.day-1];
        label2.backgroundColor = [UIColor blueColor];
    }
    

}
-(UILabel *)createLabelWithFrame:(CGRect)frame andText:(NSString *)text;
{
    UILabel *label=[UILabel new];
    label.numberOfLines=0;//不限制显示行数
    label.textAlignment=NSTextAlignmentCenter;//文本居中
    label.backgroundColor=[UIColor colorWithRed:0xdd/255.0 green:0x48/255.0 blue:0x14/255.0 alpha:1];
    label.textColor=[UIColor yellowColor];
    label.frame=frame;
    label.text=text;
    return label;
}
    //根据月初日期和某月的第几天（从0开始）来计算星期几
//并把第几天和星期几简写成拼装为字符串，换行符分隔
-(NSString *)weakDayStringOfDays:(NSUInteger)days sinceDate:(NSDate *)startDate
{
    NSDate *date=[NSDate dateWithTimeInterval:3600*24*(days) sinceDate:startDate];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    dateFormatter.dateFormat=@"ccc";//ccc格式代表星期的简写
    NSString *weekday=[dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%zu\n%@",days+1,weekday];
}
- (IBAction)nextClicked:(id)sender {
    NSCalendar *tmpCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [tmpCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:_disDate];
    if (comp.month >= 12) {
        comp.year++;
        comp.month = 1;
    }else{
        comp.month++;
    }
    NSLog(@"%ld,%ld",comp.year,comp.month);
    NSDate *preDate = [tmpCalendar dateFromComponents:comp];
    NSLog(@"preDate:%@",preDate);
    [self displayCalenderWithDate:preDate];
    
}
- (IBAction)preClicked:(id)sender {
    NSCalendar *tmpCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [tmpCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:_disDate];
    if (comp.month <= 1) {
        comp.year--;
        comp.month = 12;
    }else{
        comp.month--;
    }
    NSLog(@"%ld,%ld",comp.year,comp.month);
    NSDate *preDate = [tmpCalendar dateFromComponents:comp];
    NSLog(@"preDate:%@",preDate);
    [self displayCalenderWithDate:preDate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end











