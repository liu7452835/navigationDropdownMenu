//
//  LTYNavigationDropdownMenu.m
//  LTYNavigationDropdownMenu
//
//  Created by 刘天宇 on 2018/10/16.
//  Copyright © 2018年 lty. All rights reserved.
//

#import "LTYNavigationDropdownMenu.h"

@interface LTYNavigationDropdownMenu()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak) UINavigationController *navigationController;//导航栏下拉菜单对应的导航控制器，设置为weak,因为若导航栏控制器不存在了，该指针应指向nil
@property(nonatomic,strong) UIView *menuForegroundView;//菜单栏前景视图(用于下拉时盖住背景)
@property(nonatomic,strong) UIView *menuBackgroundView;//菜单栏背景视图
@property(nonatomic,strong) UITableView *menuTableView;//菜单栏表视图

@end


@implementation LTYNavigationDropdownMenu

#pragma mark - InitMethod

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController{
    self = [LTYNavigationDropdownMenu buttonWithType:UIButtonTypeCustom];
    if (self) {
        self.frame = navigationController.navigationBar.frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        自动调整下拉菜单的宽度，保证左边距、右边距、上边距和下边距不变
        self.navigationController = navigationController;
    }
    return self;
}


#pragma mark - layout method

//覆写方法，布局按钮中图片和文字
- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.titleLabel setFont:self.titleFont];//标题字体
    [self setTitleColor:self.titleColor forState:UIControlStateNormal];//标题颜色
//    没有设置按钮文字，需确认数据源后再设置.由于标题数据源必须设置，所以可以不用单独添加获得标题的方法
    [self setImage:[self arrowImage] forState:UIControlStateNormal];//箭头图片，由于不强制设置图片，需要单独添加获得图片的方法arrowImage
    //箭头图片和文字的相对位置
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -CGRectGetWidth(self.imageView.frame), 0, CGRectGetWidth(self.imageView.frame) + [self spacingBetweenTitleAndArrow])];//CGRectGetWidth(self.imageView.frame)先移动到图片左边，[self spacingBetweenTitleAndArrow]为补充的间距
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(self.titleLabel.frame) + [self spacingBetweenTitleAndArrow], 0, -CGRectGetWidth(self.titleLabel.frame))];
    
    //菜单栏背景视图
    CGRect menuBackgroundViewFrame = [UIScreen mainScreen].bounds;
    menuBackgroundViewFrame.origin.y += CGRectGetMaxY(self.navigationController.navigationBar.frame);
    menuBackgroundViewFrame.size.height -= CGRectGetMaxY(self.navigationController.navigationBar.frame);
    self.menuBackgroundView.frame = menuBackgroundViewFrame;
    
    //菜单栏前景视图，为了填充间隙（可以注释后，看效果）
    CGRect menuForegroundViewFrame = CGRectZero;
    menuForegroundViewFrame.size.width = self.navigationController.navigationBar.frame.size.width;
    menuForegroundViewFrame.size.height = [self cellHeight];
    self.menuForegroundView.frame = menuForegroundViewFrame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect menuForegroundViewFrame = self.menuForegroundView.frame;
    if (scrollView.contentOffset.y < 0) {
        menuForegroundViewFrame.size.height = - scrollView.contentOffset.y;
    } else {
        menuForegroundViewFrame.size.height = 0.0;
    }
    self.menuForegroundView.frame = menuForegroundViewFrame;
}

/**
 view自带方法 请求视图计算并返回最适合指定大小的大小。sizeThatFits:(占用的尺寸)
 使用:可以实现那种contentSize和高度一致的效果，不产生滚动条。调用sizeThatFits:并不改变View的size，它只是根据已有的content和给定的size计算出最合适的view的size。

 @param size 视图应计算其最佳拟合大小的大小。
 */
- (CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([super sizeThatFits:size].width + [self spacingBetweenTitleAndArrow],[super sizeThatFits:size].height);
}

//intrinsicContentSize(固有的尺寸)
- (CGSize)intrinsicContentSize{
    return  CGSizeMake([super intrinsicContentSize].width + [self spacingBetweenTitleAndArrow], [super intrinsicContentSize].height);
}

#pragma mark - Property Methods
- (UIView *)menuForegroundView{
    if (!_menuForegroundView) {
        _menuForegroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _menuForegroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _menuForegroundView.backgroundColor = [self cellBackgroundColor];
        [self.menuBackgroundView addSubview:_menuForegroundView];
    }
    return _menuForegroundView;
}

- (UIView *)menuBackgroundView{
    if(!_menuBackgroundView){
        _menuBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _menuBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _menuBackgroundView.clipsToBounds = YES;
        _menuBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    }
    return _menuBackgroundView;
}

- (UITableView *)menuTableView{
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc] initWithFrame:self.menuBackgroundView.bounds style:UITableViewStylePlain];
        _menuTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _menuTableView.dataSource = self;
        _menuTableView.delegate = self;
        _menuTableView.backgroundColor = [UIColor clearColor];
        _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        [_menuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.menuBackgroundView addSubview:_menuTableView];
    }
    return _menuTableView;
}

- (void)setDelegate:(id<LTYNavigationDropdownMenuDelegate>)delegate{
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(navigationDropdownMenu:didSelectTitleAtIndex:)]) {
        [self addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setDataSource:(id<LTYNavigationDropdownMenuDataSource>)dataSource{
    _dataSource = dataSource;
    [self setTitle:[self titleArray].firstObject forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.userInteractionEnabled = NO;//在设置时间内，按钮不能交互
    [UIView animateWithDuration:[self animationDuration] animations:^{
        if (selected) {
            self.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        } else {
            self.imageView.transform = CGAffineTransformMakeRotation(0.0);
        }
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;//恢复按钮能交互
    }];
}


#pragma mark - methods
-(void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self.menuBackgroundView];
    __block CGRect menuTableViewFrame = self.menuTableView.frame;
    menuTableViewFrame.origin.y = -(MIN([self titleArray].count * [self cellHeight], CGRectGetHeight(self.menuBackgroundView.frame)));//先放在屏幕外部
    self.menuTableView.frame = menuTableViewFrame;
    
    [UIView animateWithDuration:[self animationDuration] *1.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionLayoutSubviews animations:^{
        //CGRect menuTableViewFrame = self.menuTableView.frame;
        menuTableViewFrame.origin.y = 0;
        self.menuTableView.frame = menuTableViewFrame;
        // self.menuBackgroundView.alpha = 1.0;
    } completion:nil];
    self.selected = YES;
}

- (void)hide{
    self.selected = NO;
    [UIView animateWithDuration:[self animationDuration] animations:^{
        CGRect menuTableViewFrame = self.menuTableView.frame;
        menuTableViewFrame.origin.y = -(MIN(self.titleArray.count * self.cellHeight, CGRectGetHeight(self.menuBackgroundView.frame)));
        self.menuTableView.frame = menuTableViewFrame;
        // self.menuBackgroundView.alpha = 0.0;动画开始瞬间，立马隐藏背景视图
    } completion:^(BOOL finished) {
        [self.menuBackgroundView removeFromSuperview];
    }];
}


#pragma mark - Event Response
- (void)menuAction:(LTYNavigationDropdownMenu *)sender{
    self.isSelected ? [self hide] : [self show];//第一次按下时 isSelected值为NO
}

#pragma mark - MenuTalbeViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self titleArray] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.font = [self cellTextFont];
    cell.textLabel.textColor = [self cellTextColor];
    cell.textLabel.textAlignment = [self cellTextAlignment];
    cell.backgroundColor = [self cellBackgroundColor];
    cell.textLabel.text = [self.dataSource titleArrayForNavigationDropdownMenu:self][indexPath.row];
    
    if ([self cellBackgroundColor]) {
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = [self cellBackgroundColor];
    }
    return cell;
}

#pragma mark - MenuTableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellHeight];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:[self cellSeparatorInsets]];//设置表格分割线
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self keepCellSelection] ? : [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(navigationDropdownMenu:didSelectTitleAtIndex:)]) {
        [self.delegate navigationDropdownMenu:self didSelectTitleAtIndex:indexPath.row];
        [self setTitle:[self.dataSource titleArrayForNavigationDropdownMenu:self][indexPath.row] forState:UIControlStateNormal];
    }
    [self hide];
}


#pragma mark - ReadOnly Property
//下拉菜单数据源
- (NSArray<NSString*> *)titleArray{
    if ([self.dataSource respondsToSelector:@selector(titleArrayForNavigationDropdownMenu:)]) {
        return [self.dataSource titleArrayForNavigationDropdownMenu:self];
    } else {
        return nil;
    }
}
//标题字体
- (UIFont *)titleFont{
    if ([self.dataSource respondsToSelector:@selector(titleFontForNavigationDropdownMenu:)]) {
        return [self.dataSource titleFontForNavigationDropdownMenu:self];
    } else {
        return [UIFont systemFontOfSize:17];
    }
}
//标题颜色
- (UIColor *)titleColor{
    if ([self.dataSource respondsToSelector:@selector(titleColorForNavigationDropdownMenu:)]) {
        return [self.dataSource titleColorForNavigationDropdownMenu:self];
    } else {
        return [UIColor blackColor];
    }
}
//箭头图片
- (UIImage *)arrowImage{
    if ([self.dataSource respondsToSelector:@selector(arrowImageForNavigationDropdownMenu:)]) {
        return [self.dataSource arrowImageForNavigationDropdownMenu:self];
    } else {
        return nil;
    }
}
//箭头和文字间的间距
- (CGFloat)spacingBetweenTitleAndArrow{
    if ([self.dataSource respondsToSelector:@selector(spacingBetweenTitleAndArrowForNavigationDropdownMenu:)]) {
        return [self.dataSource spacingBetweenTitleAndArrowForNavigationDropdownMenu:self];
    } else {
        return 0.0;
    }
}
//标题下拉时动画时间间隔
- (NSTimeInterval)animationDuration{
    if ([self.dataSource respondsToSelector:@selector(animationDurationForNavigationDropdownMenu:)]) {
        return [self.dataSource animationDurationForNavigationDropdownMenu:self];
    } else {
        return 0.25;
    }
}
//是否保持下拉菜单栏单元格选中
- (BOOL)keepCellSelection {
    if ([self.dataSource respondsToSelector:@selector(keepCellSelectionForNavigationDropdownMenu:)]) {
        return [self.dataSource keepCellSelectionForNavigationDropdownMenu:self];
    } else {
        return YES;
    }
}
//下拉菜单栏单元格高度
- (CGFloat)cellHeight {
    if ([self.dataSource respondsToSelector:@selector(cellHeightForNavigationDropdownMenu:)]) {
        return [self.dataSource cellHeightForNavigationDropdownMenu:self];
    } else {
        return 45.0;
    }
}
//下拉菜单栏单元格间距
- (UIEdgeInsets)cellSeparatorInsets {
    if ([self.dataSource respondsToSelector:@selector(cellSeparatorInsetsForNavigationDropdownMenu:)]) {
        return [self.dataSource cellSeparatorInsetsForNavigationDropdownMenu:self];
    } else {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }
}
//下拉菜单栏单元格文本对齐方式
- (NSTextAlignment)cellTextAlignment {
    if ([self.dataSource respondsToSelector:@selector(cellTextAlignmentForNavigationDropdownMenu:)]) {
        return [self.dataSource cellTextAlignmentForNavigationDropdownMenu:self];
    } else {
        return NSTextAlignmentCenter;
    }
}
//下拉菜单栏单元格文本字体
- (UIFont *)cellTextFont {
    if ([self.dataSource respondsToSelector:@selector(cellTextFontForNavigationDropdownMenu:)]) {
        return [self.dataSource cellTextFontForNavigationDropdownMenu:self];
    } else {
        return [UIFont systemFontOfSize:16.0];
    }
}
//下拉菜单栏单元格文本颜色
- (UIColor *)cellTextColor {
    if ([self.dataSource respondsToSelector:@selector(cellTextColorForNavigationDropdownMenu:)]) {
        return [self.dataSource cellTextColorForNavigationDropdownMenu:self];
    } else {
        return [UIColor blackColor];
    }
}
//下拉菜单栏单元格背景颜色
- (UIColor *)cellBackgroundColor {
    if ([self.dataSource respondsToSelector:@selector(cellBackgroundColorForNavigationDropdownMenu:)]) {
        return [self.dataSource cellBackgroundColorForNavigationDropdownMenu:self];
    } else {
        return [UIColor whiteColor];
    }
}
//下拉菜单栏单元格选中后颜色
- (UIColor *)cellSelectedColor {
    if ([self.dataSource respondsToSelector:@selector(cellSelectedColorForNavigationDropdownMenu:)]) {
        return [self.dataSource cellSelectedColorForNavigationDropdownMenu:self];
    } else {
        return nil;
    }
}


@end
