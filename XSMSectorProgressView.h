//
//  XSMSectorProgressView.h
//  XSMSectorProgressView
//
//  Created by 史博 on 17/2/14.
//  Copyright © 2017年 史博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XSMSectorProgressView : UIView

/**
 传进来的数据
 */
@property(nonatomic,assign)CGFloat rata;

/**
 若为yes 则只显示外圆进度条 否则只显示内圆进度条 若不设置则显示系统默认的两个进度条
 */
@property(nonatomic,assign)BOOL showOuterProgress;

/**
 进度条开始的角度
 */
@property(nonatomic,assign)CGFloat startAngle;

/**
 进度条结束的角度
 */
@property(nonatomic,assign)CGFloat endAngle;

/**
 如果调用该方法则根据用户设置的数据配置进度条 否则按默认的条件配置
 @param dashWith 内圆进度条虚线断点的宽度
 @param dashDistanse 内圆进度条虚线断点之间的间隔
 @param outerLineWith 外圆进度条的宽度
 */
-(void)XSMProgressDataWithDashWith:(int)dashWith dashDistanse:(int)dashDistanse outerLineWith:(CGFloat)outerLineWith;


@end
