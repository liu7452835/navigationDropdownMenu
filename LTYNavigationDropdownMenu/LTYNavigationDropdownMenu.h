//
//  LTYNavigationDropdownMenu.h
//  LTYNavigationDropdownMenu
//
//  Created by 刘天宇 on 2018/10/16.
//  Copyright © 2018年 lty. All rights reserved.
//


/**
 *该类提供了一个导航栏下拉菜单，实际为一个在导航栏上按钮，按钮按下，在下方弹出一列菜单栏，可以选中某一菜单，
 *选择菜单后，实现相应的变化，且菜单栏收叠（即菜单栏隐藏）。
 *必须提供数据源，必须实现选中相应菜单后执行的动作
 */

#import <UIKit/UIKit.h>

@class LTYNavigationDropdownMenu;

/**
 导航栏下拉菜单数据源
 */
@protocol LTYNavigationDropdownMenuDataSource<NSObject>

@required
/**
 返回一个字符串数组作为导航栏下拉菜单的数据

 @param navigationDropdownMenu 需要设置相应数据的导航栏下拉菜单
 @return 字符串数组
 */
- (NSArray<NSString *> *)titleArrayForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;

@optional
//标题字体（下拉菜单导航栏中）
- (UIFont *)titleFontForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//标题颜色（下拉菜单导航栏中）
- (UIColor *)titleColorForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//箭头图片（下拉菜单导航栏中）
- (UIImage *)arrowImageForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//箭头和文字间的间距（下拉菜单导航栏中）
- (CGFloat)spacingBetweenTitleAndArrowForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//标题下拉时动画时间间隔
- (NSTimeInterval)animationDurationForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;

//是否保持下拉菜单栏单元格选中
- (BOOL)keepCellSelectionForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//下拉菜单栏单元格高度
- (CGFloat)cellHeightForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//下拉菜单栏单元格间距
- (UIEdgeInsets)cellSeparatorInsetsForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//下拉菜单栏单元格文本对齐方式
- (NSTextAlignment)cellTextAlignmentForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//下拉菜单栏单元格文本字体
- (UIFont *)cellTextFontForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//下拉菜单栏单元格文本颜色
- (UIColor *)cellTextColorForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//下拉菜单栏单元格背景颜色
- (UIColor *)cellBackgroundColorForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
//下拉菜单栏单元格选中后颜色
- (UIColor *)cellSelectedColorForNavigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu;
@end


@protocol LTYNavigationDropdownMenuDelegate<NSObject>

@required
//在下拉菜单选定相应单元格后，应执行的方法
- (void)navigationDropdownMenu:(LTYNavigationDropdownMenu *)navigationDropdownMenu didSelectTitleAtIndex:(NSUInteger)index;

@end


@interface LTYNavigationDropdownMenu : UIButton

@property(nonatomic,weak) id<LTYNavigationDropdownMenuDataSource> dataSource;
@property(nonatomic,weak) id<LTYNavigationDropdownMenuDelegate> delegate;

/**
 根据导航控制器初始化一个导航栏下拉菜单

 @param navigationController 需要添加导航栏下拉菜单的导航控制器
 @return 初始化后的导航栏下拉菜单
 */
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

/**
 显示下拉菜单（默认显示下拉菜单）
 */
- (void)show;

/**
 隐藏下拉菜单
 */
- (void)hide;

@end
