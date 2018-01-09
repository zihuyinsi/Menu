//
//  LDropDownMenu.m
//  Menu
//
//  Created by lv on 2018/1/4.
//  Copyright © 2018年 lv. All rights reserved.
//

#import "LDropDownMenu.h"

#pragma mark - DropIndexPath
@implementation DropIndexPath

- (instancetype) initWithRow:(NSInteger)row
{
    self = [super init];
    if (self)
    {
        _row = row;
        _item = 1;
    }
    return self;
}

- (instancetype) initWithRow:(NSInteger)row item: (NSInteger)item
{
    self = [self initWithRow: row];
    if (self)
    {
        _item = item;
    }
    
    return self;
}

+ (instancetype) indexPathWithRow:(NSInteger)row
{
    return [[self alloc] initWithRow: row];
}

+ (instancetype) indexPathWithRow:(NSInteger)row item:(NSInteger)item
{
    return [[self alloc] initWithRow: row item: item];
}

@end

#pragma mark - LDropDownMenu
#define iPhoneWidth             [UIScreen mainScreen].bounds.size.width
#define iPhoneHeight            [UIScreen mainScreen].bounds.size.height
#define kTableViewCellHeight    (45.f * (iPhoneWidth / 375.f))
#define kLeft_Scale             0.36
#define kRight_Scale            (1 - kLeft_Scale)

@interface LDropDownMenu()<UIGestureRecognizerDelegate>
{
    struct {
        unsigned int numberOfRowsInMenu :1;
        unsigned int numberOfItemsInRow :1;
        unsigned int titleForRowAtIndexPath :1;
        unsigned int titleForItemsInRowAtIndexPath :1;
        unsigned int imageNameForRowAtIndexPath :1;
        unsigned int imageNameForItemsInRowAtIndexPath :1;
    } _dataSourceFlags;
}

/** 颜色背景 */
@property (nonatomic, strong) UIView *colorBgView;
/** 颜色背景frame */
@property (nonatomic, assign) CGRect colorBgFrame;
/** 头部箭头 */
@property (nonatomic, strong) UIImageView *imgView;
/** 展示区背景view */
@property (nonatomic, strong) UIView *bgView;
/** 阴影效果 */
@property (nonatomic, strong) UIView *shadowBgView;
/** 一级列表 */
@property (nonatomic, strong) UITableView *leftTableView;
/** 二级列表 */
@property (nonatomic, strong) UITableView *rightTableView;

/** 选中的标题 */
@property (nonatomic, copy) NSString *selectedTitle;


@end

@implementation LDropDownMenu

#pragma mark - init method
- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: [UIScreen mainScreen].bounds];
    if (self)
    {
        self.hidden = YES;
        _colorBgFrame = frame;
        [self loadDefaultData];
        [self initializationLDropDownMenu];
    }
    
    return self;
}

- (void) loadDefaultData
{
    _backgroundColor = [UIColor clearColor];
    _currentSelectedMenuIndex = 0;
    _fontSize = 14;
    _textColor = [UIColor colorWithRed: 51/255.f green: 51/255.f blue: 51/255.f alpha: 1.f];
    _textSelectedColor = [UIColor colorWithRed: 246/255.f green: 27/255.f blue: 16/255.f alpha: 1.f];
    _leftBgColor = [UIColor colorWithRed: 243/255.f green: 243/255.f blue: 243/255.f alpha: 1.f];
    _leftSelectBgColor = [UIColor whiteColor];
    _leftTextAlignment = NSTextAlignmentCenter;
    _rightBgColor = [UIColor whiteColor];
    _rightSelectBgColor = [UIColor whiteColor];
    _showFrame = CGRectMake(0, 0, self.frame.size.width, 300.f);
}

- (void) initializationLDropDownMenu
{
    /** 点击手势 */
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapGestureEvent)];
    tapGesture.delegate = self;
    [self addGestureRecognizer: tapGesture];
    
    /** 带颜色背景 */
    _colorBgView = [[UIView alloc] initWithFrame: _colorBgFrame];
    [self addSubview: _colorBgView];
    
    /** 图标 */
    _imgView = [[UIImageView alloc] initWithFrame: CGRectMake((_showFrame.size.width - 17)/2,
                                                              -6,
                                                              17,
                                                              16)];
    [_imgView setImage: [UIImage imageNamed: @"up"]];
    [_colorBgView addSubview: _imgView];
    
    /** 阴影背景 */
    _shadowBgView = [[UIView alloc] initWithFrame: CGRectMake(0, 10, _showFrame.size.width, 0)];
    [_colorBgView addSubview: _shadowBgView];

    /** 背景视图 */
    _bgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, _showFrame.size.width, 0)];
    [_shadowBgView addSubview: _bgView];

    /** 一级菜单列表 */
    _leftTableView = [[UITableView alloc] initWithFrame: CGRectMake(0,
                                                                    0,
                                                                    _showFrame.size.width * kLeft_Scale,
                                                                    0.f)
                                                  style: UITableViewStylePlain];
    _leftTableView.rowHeight = kTableViewCellHeight;
    _leftTableView.delegate = self;
    _leftTableView.dataSource = self;
    _leftTableView.separatorColor = [UIColor colorWithRed: 243/255.f green: 243/255.f blue: 243/255.f alpha: 1.f];
    [_leftTableView setBackgroundColor: [UIColor colorWithRed: 243/255.f green: 243/255.f blue: 243/255.f alpha: 1.f]];

    /** 二级菜单列表 */
    _rightTableView = [[UITableView alloc] initWithFrame: CGRectMake(_showFrame.size.width * kLeft_Scale,
                                                                     0,
                                                                     _showFrame.size.width * kRight_Scale,
                                                                     0.f)
                                                   style: UITableViewStylePlain];
    _rightTableView.rowHeight = kTableViewCellHeight;
    _rightTableView.delegate = self;
    _rightTableView.dataSource = self;
    _rightTableView.separatorColor = [UIColor colorWithRed: 243/255.f green: 243/255.f blue: 243/255.f alpha: 1.f];
}

- (void)reloadData
{
    id VC = self.dataSource;
    self.dataSource = nil;
    self.dataSource = VC;

    if (_dataSource)
    {
        [_leftTableView reloadData];
        if (_dataSourceFlags.numberOfItemsInRow)
        {
            [_rightTableView reloadData];
        }
    }
}

#pragma mark -
- (void) selectDefaultIndexPath
{
    [self selectIndexPath: [DropIndexPath indexPathWithRow: 0 item: 0]];
}

- (void) selectIndexPath: (DropIndexPath *)indexPath
{
    if (!_dataSource ||
        !_delegate ||
        ![_delegate respondsToSelector: @selector(menu:didSelectRowAtIndexPath:)])
    {
        return;
    }
    
    if ([_dataSource numberOfRowsInMenu: self] <= indexPath.row)
    {
        return;
    }

    _currentSelectedMenuIndex = indexPath.row;

    if (indexPath.item < 0)
    {
        [self loadTableView: _leftTableView
                  indexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                inSection: 0]];
        
        if ([_dataSource menu:self numberOfItemsInRow: indexPath.row] > 0)
        {
            [_delegate menu: self
    didSelectRowAtIndexPath: [DropIndexPath indexPathWithRow: indexPath.row item: 0]];
        }
        else
        {
            [_delegate menu: self didSelectRowAtIndexPath: indexPath];
        }
    }
    else
    {
        [self loadTableView: _leftTableView
                  indexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                inSection: 0]];
        [self loadTableView: _rightTableView
                  indexPath: [NSIndexPath indexPathForRow: indexPath.item
                                                inSection: 0]];
        
        [_delegate menu: self didSelectRowAtIndexPath: indexPath];
    }
}

- (void) loadTableView: (UITableView *)tableView
             indexPath: (NSIndexPath *)indexPath
{
    [tableView selectRowAtIndexPath: indexPath
                           animated: YES
                     scrollPosition: UITableViewScrollPositionMiddle];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    if (tableView == _leftTableView)
    {
        [cell setBackgroundColor: _leftSelectBgColor];
    }
    else
    {
        [cell setBackgroundColor: _rightSelectBgColor];
    }
    [cell.textLabel setTextColor: _textSelectedColor];
}

- (void) showMenu
{
    if (_dataSource == nil)
    {
        return;
    }
    
    [self animationTableViewShow: YES
                        complete:^{
                        }];
}

- (void) dismissMenu
{
    [self animationTableViewShow: NO
                        complete:^{
                        }];
}

- (void) animationTableViewShow: (BOOL)show complete:(void(^)(void))complete
{
    BOOL haveItems = [self isHaveItems];
    if (show)
    {

        //根据是否展示顶部箭头，处理箭头状态
        CGFloat imgHeight = 0.f;
        if (self.hidderTopArrow)
        {
            imgHeight = 0.f;
            _imgView.hidden = YES;
        }
        else
        {
            imgHeight = 10.f;
            _imgView.hidden = NO;
        }
        [_imgView setFrame: CGRectMake(_showFrame.origin.x + (_showFrame.size.width - 17)/2, _showFrame.origin.y-6, 17, 16)];
        [_shadowBgView setFrame: CGRectMake( _showFrame.origin.x, _showFrame.origin.y + imgHeight, _showFrame.size.width, 0)];
        [_bgView setFrame: CGRectMake(0, 0, _showFrame.size.width, 0)];

        //背景View高度
        CGFloat height = 0.f;
        if (_autoChangeHeight)
        {
            NSInteger num = [_leftTableView numberOfRowsInSection: 0] > [_rightTableView numberOfRowsInSection: 0] ? [_leftTableView numberOfRowsInSection: 0] : [_rightTableView numberOfRowsInSection: 0];
            height = num * kTableViewCellHeight > _showFrame.size.height ? _showFrame.size.height : num *kTableViewCellHeight;
        }
        else
        {
            height = _showFrame.size.height;
        }
        
        //判断是否存在item (右侧列表)
        if (haveItems)
        {
            [_leftTableView setFrame: CGRectMake(0,
                                                 0,
                                                 _showFrame.size.width * kLeft_Scale,
                                                 0)];
            [_rightTableView setFrame: CGRectMake(_showFrame.size.width * kLeft_Scale,
                                                  0,
                                                  _showFrame.size.width * kRight_Scale,
                                                  0)];
            [_bgView addSubview: _leftTableView];
            [_bgView addSubview: _rightTableView];
            [UIView animateWithDuration: 0.1f
                             animations:^{
                                 self.hidden = NO;
                                 [self.superview bringSubviewToFront: self];
                                 [_shadowBgView setFrame: CGRectMake( _showFrame.origin.x, _showFrame.origin.y + imgHeight, _showFrame.size.width, height)];
                                 [_bgView setFrame: CGRectMake(0, 0, _showFrame.size.width, height)];
                                 [_leftTableView setFrame: CGRectMake(0,
                                                                      0,
                                                                      _showFrame.size.width * kLeft_Scale,
                                                                      height)];
                                 [_rightTableView setFrame: CGRectMake(_showFrame.size.width * kLeft_Scale,
                                                                       0,
                                                                       _showFrame.size.width * kRight_Scale,
                                                                       height)];
                             }];
        }
        else
        {
            [_leftTableView setFrame: CGRectMake(0,
                                                 0,
                                                 _showFrame.size.width,
                                                 0)];
            [_bgView addSubview: _leftTableView];
            [UIView animateWithDuration: 0.1f
                             animations:^{
                                 self.hidden = NO;
                                 [self.superview bringSubviewToFront: self];
                                 [_shadowBgView setFrame: CGRectMake( _showFrame.origin.x, _showFrame.origin.y + imgHeight, _showFrame.size.width, height)];
                                 [_bgView setFrame: CGRectMake(0, 0, _showFrame.size.width, height)];
                                 [_leftTableView setFrame: CGRectMake(0,
                                                                      0,
                                                                      _showFrame.size.width,
                                                                      height)];
                                 [_rightTableView setFrame: CGRectMake(_showFrame.size.width * kLeft_Scale,
                                                                       0,
                                                                       _showFrame.size.width * kRight_Scale,
                                                                       height)];
                             }];
        }
    }
    else
    {
        CGFloat imgHeight = 0.f;
        if (self.hidderTopArrow)
        {
            imgHeight = 0.f;
            _imgView.hidden = YES;
        }
        else
        {
            imgHeight = 10.f;
            _imgView.hidden = NO;
        }
        
        [UIView animateWithDuration: 0.1f
                         animations:^{
                             [_shadowBgView setFrame: CGRectMake( _showFrame.origin.x, _showFrame.origin.y + imgHeight, _showFrame.size.width, 0)];
                             [_bgView setFrame: CGRectMake(0, 0, _showFrame.size.width, 0)];
                             if (haveItems)
                             {
                                 [_leftTableView setFrame: CGRectMake(0,
                                                                      0,
                                                                      _showFrame.size.width * kLeft_Scale,
                                                                      0)];
                                 [_rightTableView setFrame: CGRectMake(_showFrame.size.width * kLeft_Scale,
                                                                       0,
                                                                       _showFrame.size.width * kRight_Scale,
                                                                       0)];
                             }
                             else
                             {
                                 [_leftTableView setFrame: CGRectMake(0,
                                                                      0,
                                                                      _showFrame.size.width,
                                                                      0)];
                                 
                             }
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 self.hidden = YES;
                                 if (_rightTableView.superview)
                                 {
                                     [_rightTableView removeFromSuperview];
                                 }
                                 [_leftTableView removeFromSuperview];
                             }
                         }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_leftTableView == tableView)
    {
        if (_dataSourceFlags.numberOfRowsInMenu)
        {
            return [_dataSource numberOfRowsInMenu: self];
        }
        else
        {
            return 0;
        }
    }
    else
    {
        if (_dataSourceFlags.numberOfItemsInRow)
        {
            return [_dataSource menu:self numberOfItemsInRow: _currentSelectedMenuIndex];
        }
        else
        {
            return 0;
        }
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierStr = @"LDropDownMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifierStr];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: identifierStr];
        [cell.textLabel setHighlightedTextColor: _textSelectedColor];
        [cell.textLabel setFont: [UIFont systemFontOfSize: _fontSize]];
    }
    [cell.textLabel setTextColor: _textColor];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    if (_leftTableView == tableView)
    {
        if (_dataSourceFlags.titleForRowAtIndexPath)
        {
            [cell setBackgroundColor: _leftBgColor];
            cell.textLabel.text = [_dataSource menu: self
                             titleForRowAtIndexPath: [DropIndexPath indexPathWithRow: indexPath.row]];
            [cell.textLabel setTextAlignment: _leftTextAlignment];
            if (_dataSourceFlags.imageNameForRowAtIndexPath)
            {
                NSString *imgName = [_dataSource menu: self
                           imageNameFroRowAtIndexPath: [DropIndexPath indexPathWithRow: indexPath.row]];
                if (imgName && [imgName length] > 0)
                {
                    cell.imageView.image = [UIImage imageNamed: imgName];
                }
                else
                {
                    cell.imageView.image = nil;
                }
            }
        }
        if (indexPath.row == _currentSelectedMenuIndex)
        {
            [tableView selectRowAtIndexPath: indexPath
                                   animated: YES
                             scrollPosition: UITableViewScrollPositionMiddle];
        }
    }
    else
    {
        if (_dataSourceFlags.titleForItemsInRowAtIndexPath)
        {
            [cell setBackgroundColor: _rightBgColor];
            cell.textLabel.text = [_dataSource menu: self
                      titleForItemsInRowAtIndexPath: [DropIndexPath indexPathWithRow: _currentSelectedMenuIndex
                                                                                item: indexPath.row]];
            if (_dataSourceFlags.imageNameForItemsInRowAtIndexPath)
            {
                NSString *imgName = [_dataSource menu: self
                    imageNameForItemsInRowAtIndexPath: [DropIndexPath indexPathWithRow: _currentSelectedMenuIndex
                                                                                  item: indexPath.row]];
                if (imgName && [imgName length] > 0)
                {
                    cell.imageView.image = [UIImage imageNamed: imgName];
                }
                else
                {
                    cell.imageView.image = nil;
                }
            }
        }
        if ([cell.textLabel.text isEqualToString: _selectedTitle])
        {
            [_leftTableView selectRowAtIndexPath: [NSIndexPath indexPathForRow: _currentSelectedMenuIndex
                                                                     inSection: 0]
                                        animated: YES
                                  scrollPosition: UITableViewScrollPositionMiddle];
            [_rightTableView selectRowAtIndexPath: indexPath
                                         animated: YES
                                   scrollPosition: UITableViewScrollPositionMiddle];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_leftTableView == tableView)
    {
        _currentSelectedMenuIndex = indexPath.row;
        [_leftTableView reloadData];

        if ([self isHaveItems])
        {
            BOOL haveItem = [self configMenuWithSelectRow: indexPath.row];
            if (haveItem &&
                _delegate &&
                [_delegate respondsToSelector: @selector(menu:didSelectRowAtIndexPath:)])
            {
                [self.delegate menu: self
            didSelectRowAtIndexPath: [DropIndexPath indexPathWithRow: indexPath.row]];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
            [cell setBackgroundColor: _leftSelectBgColor];
            [cell.textLabel setTextColor: _textSelectedColor];
        }
        else
        {
            if (_delegate &&
                [_delegate respondsToSelector: @selector(menu:didSelectRowAtIndexPath:)])
            {
                [self.delegate menu: self
            didSelectRowAtIndexPath: [DropIndexPath indexPathWithRow:indexPath.row item: -1]];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
            [cell setBackgroundColor: _leftSelectBgColor];
            [cell.textLabel setTextColor: _textSelectedColor];
            [self dismissMenu];
        }
    }
    else
    {
        [_rightTableView reloadData];
        _selectedTitle = [_dataSource menu: self
             titleForItemsInRowAtIndexPath: [DropIndexPath indexPathWithRow: _currentSelectedMenuIndex
                                                                       item: indexPath.row]];
        if (self.delegate &&
            [_delegate respondsToSelector: @selector(menu:didSelectRowAtIndexPath:)])
        {
            [self.delegate menu: self
        didSelectRowAtIndexPath: [DropIndexPath indexPathWithRow: _currentSelectedMenuIndex
                                                            item: indexPath.row]];
        }

        UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
        [cell setBackgroundColor: _rightSelectBgColor];
        [cell.textLabel setTextColor: _textSelectedColor];
        
        [self dismissMenu];
    }
}

- (BOOL) configMenuWithSelectRow: (NSInteger)row
{

    if (_dataSourceFlags.numberOfItemsInRow &&
        [_dataSource menu: self numberOfItemsInRow: row])
    {
        [_leftTableView reloadData];
        [_rightTableView reloadData];
        
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL) isHaveItems
{
    BOOL haveItems = NO;
    
    if (_dataSource) {
        NSInteger num = [_leftTableView numberOfRowsInSection:0];
        
        for (int i = 0; i < num; i ++)
        {
            if (_dataSourceFlags.numberOfItemsInRow &&
                [_dataSource menu: self numberOfItemsInRow: i])
            {
                haveItems = YES;
                break;
            }
        }
    }
    
    return haveItems;
}

#pragma mark-手势代理，解决和tableview点击发生的冲突
- (BOOL) gestureRecognizer: (UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch: (UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
    {
        //判断如果点击的是tableView的cell，就把手势给关闭了
        return NO;//关闭手势
    }
    //否则手势存在
    return YES;
}

#pragma mark - 手势点击事件
- (void) handleTapGestureEvent
{
    if (self.delegate &&
        [_delegate respondsToSelector: @selector(menu:didBlankDismiss:)])
    {
        [self.delegate menu: self didBlankDismiss: @"取消"];
    }
}

#pragma mark - setter
- (void) setDataSource:(id<LDropDownMenuDataSource>)dataSource
{
    if (_dataSource == dataSource)
    {
        return;
    }
    
    _dataSource = dataSource;
    
    _dataSourceFlags.numberOfRowsInMenu =
    [_dataSource respondsToSelector:@selector(numberOfRowsInMenu:)];
    _dataSourceFlags.numberOfItemsInRow =
    [_dataSource respondsToSelector:@selector(menu:numberOfItemsInRow:)];
    _dataSourceFlags.titleForRowAtIndexPath =
    [_dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)];
    _dataSourceFlags.titleForItemsInRowAtIndexPath =
    [_dataSource respondsToSelector:@selector(menu:titleForItemsInRowAtIndexPath:)];
    _dataSourceFlags.imageNameForRowAtIndexPath =
    [_dataSource respondsToSelector:@selector(menu:imageNameFroRowAtIndexPath:)];
    _dataSourceFlags.imageNameForItemsInRowAtIndexPath =
    [_dataSource respondsToSelector:@selector(menu:imageNameForItemsInRowAtIndexPath:)];
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [_colorBgView setBackgroundColor: _backgroundColor];
}

- (void) setMasksToBounds:(BOOL)masksToBounds
{
    _masksToBounds = masksToBounds;
    _bgView.layer.masksToBounds = masksToBounds;
}

- (void) setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    _bgView.layer.cornerRadius = cornerRadius;
}

- (void) setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    _bgView.layer.borderColor = borderColor.CGColor;
}

- (void) setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    _bgView.layer.borderWidth = borderWidth;
}

- (void) setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    _shadowBgView.layer.shadowColor = shadowColor.CGColor;
}

- (void) setShadowRadius:(CGFloat)shadowRadius
{
    _shadowRadius = shadowRadius;
    _shadowBgView.layer.shadowRadius = shadowRadius;
}

- (void) setShadowOpacity:(CGFloat)shadowOpacity
{
    _shadowOpacity = shadowOpacity;
    _shadowBgView.layer.shadowOpacity = shadowOpacity;
}

- (void) setShadowOffset:(CGSize)shadowOffset
{
    _shadowOffset = shadowOffset;
    _shadowBgView.layer.shadowOffset = shadowOffset;
}


@end
