//
//  ViewController.m
//  Menu
//
//  Created by lv on 2018/1/4.
//  Copyright © 2018年 lv. All rights reserved.
//

#import "ViewController.h"
#import "LDropDownMenu.h"

@interface ViewController ()<LDropDownMenuDelegate, LDropDownMenuDataSource>
{
    LDropDownMenu *lDropMenu;
    NSMutableArray *datas;
    DropIndexPath *selectIndex;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor: [UIColor whiteColor]];
    
    UIButton *menuBtn = [UIButton buttonWithType: UIButtonTypeSystem];
    [menuBtn setTitle: @"menuBtn" forState: UIControlStateNormal];
    [menuBtn setFrame: CGRectMake( 100, 100, 100, 30)];
    [menuBtn addTarget: self
                action: @selector(handleMenuBtnTapEvent)
      forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: menuBtn];
    
    
    UIButton *menuBtn2 = [UIButton buttonWithType: UIButtonTypeSystem];
    [menuBtn2 setTitle: @"menuBtn" forState: UIControlStateNormal];
    [menuBtn2 setFrame: CGRectMake( 100, 200, 100, 30)];
    [menuBtn2 addTarget: self
                action: @selector(handleMenuBtn2TapEvent)
      forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: menuBtn2];
    
    lDropMenu = [[LDropDownMenu alloc] initWithFrame: CGRectMake( 0, 100,
                                                                 [UIScreen mainScreen].bounds.size.width,
                                                                 [UIScreen mainScreen].bounds.size.height)];
    lDropMenu.backgroundColor = [UIColor colorWithWhite: 0.f alpha: 0.3f];
    lDropMenu.delegate = self;
    lDropMenu.dataSource = self;
    lDropMenu.autoChangeHeight = YES;
//    lDropMenu.hidderTopArrow = YES;
    lDropMenu.leftBgColor = [UIColor whiteColor];
    lDropMenu.showFrame = CGRectMake(30.f, 100.f, [UIScreen mainScreen].bounds.size.width - 60.f, 300.f);
    lDropMenu.cornerRadius = 5.f;
    lDropMenu.masksToBounds = YES;
    lDropMenu.shadowColor = [UIColor redColor];
    lDropMenu.shadowOffset = CGSizeMake(0, 3.f);
    lDropMenu.shadowOpacity = 7.f;
    lDropMenu.shadowRadius = 3.f;
    
    [self.view addSubview: lDropMenu];
    
    selectIndex = [DropIndexPath indexPathWithRow: 0 item: 0];
    
    
    datas = nil;
    [lDropMenu reloadData];
    [lDropMenu selectIndexPath: selectIndex];
}

- (void) handleMenuBtn2TapEvent
{
    datas = [NSMutableArray arrayWithObjects:
             @{@"area": @"下城区", @"data": @[@"壹"]},
             @{@"area": @"江干区", @"data": @[@"好人", @"坏人", @"好人", @"坏人", @"好人", @"坏人", @"好人", @"坏人"]},
             nil];
    
//    datas = [NSMutableArray arrayWithObjects:
//             @{@"area": @"江干区", @"data": @[@"好人", @"坏人", @"好人", @"坏人", @"好人", @"坏人", @"好人", @"坏人"]},
//             @{@"area": @"下城区", @"data": @[@"壹"]},
//             @{@"area": @"余杭区", @"data": @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"]},
//             @{@"area": @"西湖区", @"data": @[@"昨天",@"今天", @"明天"]},
//             @{@"area": @"拱墅区", @"data": @[@"语文", @"数学", @"物理", @"化学"]},
//             @{@"area": @"萧山区", @"data": @[@"12312", @"12"]}
//            , nil];
    
//    datas = [NSMutableArray arrayWithObjects:
//             @{@"area": @"江干区"},
//             @{@"area": @"西湖区"},
//             @{@"area": @"拱墅区"},
//             @{@"area": @"萧山区"},
//             @{@"area": @"余杭区"}
//             , nil];
    [lDropMenu reloadData];
    [lDropMenu selectIndexPath: selectIndex];
}

- (void) handleMenuBtnTapEvent
{
    [lDropMenu selectIndexPath: selectIndex];
    [lDropMenu showMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfRowsInMenu:(LDropDownMenu *)menu
{
    return [datas count];
}

- (NSString *)menu:(LDropDownMenu *)menu titleForRowAtIndexPath:(DropIndexPath *)indexPath
{
    if (indexPath.row < [datas count])
    {
        NSDictionary *dic = datas[indexPath.row];
        return dic[@"area"];
    }
    
    return @"";
}

- (NSInteger) menu:(LDropDownMenu *)menu numberOfItemsInRow:(NSInteger)row
{
    if (row < [datas count])
    {
        NSDictionary *dic = datas[row];
        NSArray *arr = dic[@"data"];
        return [arr count];
    }
    
    return 0;
}

- (NSString *) menu:(LDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DropIndexPath *)indexPath
{
    if (indexPath.row < [datas count])
    {
        NSDictionary *dic = datas[indexPath.row];
        NSArray *arr = dic[@"data"];
        NSString *titStr = @"";
        if (indexPath.item < [arr count])
        {
            titStr = arr[indexPath.item];
        }
        return titStr;
    }
    
    return  @"";
}

- (void) menu:(LDropDownMenu *)menu didSelectRowAtIndexPath:(DropIndexPath *)indexPath
{
    NSLog(@"indexPath = %ld, %ld", (long)indexPath.row, (long)indexPath.item);
    selectIndex = indexPath;

}

- (void) menu: (LDropDownMenu *)menu didBlankDismiss: (NSString *)dismiss
{
    [lDropMenu dismissMenu];
}

@end
