//
//  LDropDownMenu.h
//  Menu
//
//  Created by lv on 2018/1/4.
//  Copyright © 2018年 lv. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - DropIndexPath
@interface DropIndexPath: NSObject

/** 行 */
@property (nonatomic, assign) NSInteger row;
/** 每行item数量 */
@property (nonatomic, assign) NSInteger item;

- (instancetype) initWithRow: (NSInteger)row;
+ (instancetype) indexPathWithRow: (NSInteger)row;
+ (instancetype) indexPathWithRow: (NSInteger)row item: (NSInteger)item;

@end

#pragma mark - data source protocol
@class LDropDownMenu;

@protocol LDropDownMenuDataSource <NSObject>

//必须实现
@required

/**
 *  返回menu有多少行
 */
- (NSInteger) numberOfRowsInMenu: (LDropDownMenu *)menu;

/**
 *  返回menu每行title
 */
- (NSString *) menu: (LDropDownMenu *)menu titleForRowAtIndexPath: (DropIndexPath *)indexPath;

//可选实现
@optional
/**
 *  返回menu每行image
 */
- (NSString *) menu: (LDropDownMenu *)menu imageNameFroRowAtIndexPath: (DropIndexPath *)indexPath;

/**
 *  返回有多少item, 如果>0说明有二级列表 =0说明没有二级列表
 */
- (NSInteger) menu: (LDropDownMenu *)menu numberOfItemsInRow: (NSInteger)row;

/**
 *  返回每个item title
 */
- (NSString *) menu: (LDropDownMenu *)menu titleForItemsInRowAtIndexPath: (DropIndexPath *)indexPath;

/**
 *  返回每个item image
 */
- (NSString *) menu: (LDropDownMenu *)menu imageNameForItemsInRowAtIndexPath: (DropIndexPath *)indexPath;

@end

#pragma mark - delegate protocol
@protocol LDropDownMenuDelegate <NSObject>

@optional
/**
 *  点击代理
 */
- (void) menu: (LDropDownMenu *)menu didSelectRowAtIndexPath: (DropIndexPath *)indexPath;

/**
 *  点击空白地方消失
 */
- (void) menu: (LDropDownMenu *)menu didBlankDismiss: (NSString *)dismiss;

@end

#pragma mark - LDropDownMenu
@interface LDropDownMenu : UIView<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <LDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id <LDropDownMenuDelegate> delegate;

/** 颜色背景 */
@property (nonatomic, strong) UIColor *backgroundColor;
/** 当前选中行 */
@property (nonatomic, assign) NSInteger currentSelectedMenuIndex;
/** 字体大小 */
@property (nonatomic, assign) CGFloat fontSize;
/** 文字颜色 */
@property (nonatomic, strong) UIColor *textColor;
/** 选中文字颜色 */
@property (nonatomic, strong) UIColor *textSelectedColor;
/** 是否自动改变高度 */
@property (nonatomic, assign) BOOL autoChangeHeight;
/** 是否隐藏头部箭头 */
@property (nonatomic, assign) BOOL hidderTopArrow;
/** 左侧背景色 */
@property (nonatomic, strong) UIColor *leftBgColor;
/** 左侧选中背景色 */
@property (nonatomic, strong) UIColor *leftSelectBgColor;
/** 左侧文本位置 */
@property (nonatomic, assign) NSTextAlignment leftTextAlignment;
/** 右侧背景色 */
@property (nonatomic, strong) UIColor *rightBgColor;
/** 右侧选中背景色 */
@property (nonatomic, strong) UIColor *rightSelectBgColor;
/** 是否圆角 */
@property (nonatomic, assign) BOOL masksToBounds;
/** 圆角半径 */
@property (nonatomic, assign) CGFloat cornerRadius;
/** 边框颜色 */
@property (nonatomic, strong) UIColor *borderColor;
/** 边框宽度 */
@property (nonatomic, assign) CGFloat borderWidth;
/** 阴影 */
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat shadowOpacity;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGSize shadowOffset;
/** TableView距离边框 */
@property (nonatomic, assign) CGFloat sub_Tablemargin;


/** 展示位置 */
@property (nonatomic, assign) CGRect showFrame;

- (void) reloadData;
- (void) selectDefaultIndexPath;
- (void) selectIndexPath: (DropIndexPath *)indexPath;

- (void) showMenu;
- (void) dismissMenu;

@end
