//
//  XSMSectorProgressView.m
//  XSMSectorProgressView
//
//  Created by 史博 on 17/2/14.
//  Copyright © 2017年 史博. All rights reserved.
//

#import "XSMSectorProgressView.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

#define AngleToRadian(X) (M_PI * (X)/180.0)//角度转化为弧度
#define CENTER CGPointMake(WIDTH/2 ,HEIGHT/2)

@interface XSMSectorProgressView ()

@property(nonatomic,assign)CGFloat  innerRadius;//内扇形半径
@property(nonatomic,assign)CGFloat  outerRadius;//外扇形半径
@property(nonatomic,assign)CGFloat  innerLineWith;//内扇形宽
@property(nonatomic,assign)CGFloat  outerLineWith;//外扇形宽
@property(nonatomic,strong)NSMutableArray * colors; //颜色数组
@property(nonatomic,strong)UIBezierPath * innerPath; //内圆路径
@property(nonatomic,strong)CAShapeLayer * innerbottomShapeLayer; //内圆底部layer
@property(nonatomic,strong)CAShapeLayer * innerShapeLayer; //内圆进度条
@property(nonatomic,strong)CAGradientLayer * innergradientLayer; //内圆颜色渐进layer
@property(nonatomic,strong)UIBezierPath * outerPath; //外圆路径
@property(nonatomic,strong)CAShapeLayer * outerBottomShapeLayer; //外圆底部layer
@property(nonatomic,strong)CAShapeLayer * outerProgressShapeLayer;//外圆进度条
@property(nonatomic,strong)CAGradientLayer * outergradientLayer;//外圆颜色渐进
@property(nonatomic,strong)UILabel * progressLab; //显示进度的lab
@property(nonatomic,assign)int dashWith; //内圆虚线断点宽度
@property(nonatomic,assign)int dashDistanse;//内圆虚线断点之间的间距
@property(nonatomic,assign)NSInteger isProgress;//内圆虚线断点之间的间距




@end

@implementation XSMSectorProgressView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self drawLayers];
    }
    return self;
}
//处理传进来的数据
-(void)setRata:(CGFloat)rata{
    _rata = rata;
    _innerShapeLayer.strokeEnd = [NSString stringWithFormat:@"%.2f",rata/100].floatValue;
    _outerProgressShapeLayer.strokeEnd = [NSString stringWithFormat:@"%.2f",rata/100].floatValue;
    self.progressLab.text = [NSString stringWithFormat:@"%.2f%%",rata/100];
}
//显示进度条类型
-(void)setShowOuterProgress:(BOOL)showOuterProgress{
    _showOuterProgress = showOuterProgress;
    if (_showOuterProgress == YES) {
        [_innerbottomShapeLayer removeFromSuperlayer];
        _innerbottomShapeLayer = nil;
        _isProgress = 1;
    }else{
        [_outerBottomShapeLayer removeFromSuperlayer];
        _outerBottomShapeLayer = nil;
        _isProgress = 2;
    }
}
//设置开始的角度
-(void)setStartAngle:(CGFloat)startAngle{
    _startAngle = startAngle;
    
    [_innerbottomShapeLayer removeFromSuperlayer];
    [_outerBottomShapeLayer removeFromSuperlayer];
    _innerbottomShapeLayer = nil;
    _outerBottomShapeLayer = nil;
    [self drawLayers];
    [self judement];
}
//设置结束的角度
-(void)setEndAngle:(CGFloat)endAngle{
    _endAngle = endAngle;
    [_innerbottomShapeLayer removeFromSuperlayer];
    [_outerBottomShapeLayer removeFromSuperlayer];
    _innerbottomShapeLayer = nil;
    _outerBottomShapeLayer = nil;
    [self drawLayers];
    [self judement];
}

-(void)judement{
    if (_isProgress == 1) {
        [_innerbottomShapeLayer removeFromSuperlayer];
        _innerbottomShapeLayer = nil;
    }else if (_isProgress == 2){
        [_outerBottomShapeLayer removeFromSuperlayer];
        _outerBottomShapeLayer = nil;
    }
}
//进度数据显示
-(UILabel * )progressLab{
    if (_progressLab == nil) {
        _progressLab = [UILabel new];
        _progressLab.frame = CGRectMake(0, 0, _innerRadius/1.5, _innerRadius/1.5);
        _progressLab.center = CENTER;
        _progressLab.textAlignment = NSTextAlignmentCenter;
        _progressLab.font = [UIFont systemFontOfSize:_innerRadius * 0.2];
        [self addSubview:_progressLab];
    }
    return _progressLab;
}

-(void)XSMProgressDataWithDashWith:(int)dashWith dashDistanse:(int)dashDistanse outerLineWith:(CGFloat)outerLineWith{
    _dashDistanse = dashDistanse;
    _dashWith = dashWith;
    _outerLineWith = outerLineWith;
    _dashWith = _dashWith<=0?_innerRadius * 0.02:_dashWith;
    _dashDistanse = _dashDistanse<=0?_innerRadius * 0.05:_dashDistanse;
    _outerLineWith = _outerLineWith<=0?_innerRadius * 0.02:_outerLineWith;
    _innerbottomShapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:_dashWith],[NSNumber numberWithInt:_dashDistanse],nil];
    _innerShapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:_dashWith],[NSNumber numberWithInt:_dashDistanse], nil];
    _outerBottomShapeLayer.lineWidth = _outerLineWith;
    _outerProgressShapeLayer.lineWidth = _outerLineWith;
}

-(void)drawLayers{
    _startAngle = _startAngle == 0? -225:_startAngle;
    _endAngle = _endAngle <= 0?45:_endAngle;
    _innerRadius = (WIDTH * 0.66)/2;
    _outerRadius = (WIDTH * 0.8)/2;
    _innerLineWith = _innerRadius * 0.2;
    self.progressLab.text = @"0.00%";
    _outerLineWith = _outerLineWith<=0?_innerRadius * 0.02:_outerLineWith;
    _dashWith = _dashWith<=0?_innerRadius * 0.02:_dashWith;
    _dashDistanse = _dashDistanse<=0?_innerRadius * 0.05:_dashDistanse;
    //渐变Layer的颜色数组
    _colors = [NSMutableArray arrayWithObjects:(id)[UIColor blueColor].CGColor,(id)[UIColor greenColor].CGColor,(id)[UIColor orangeColor].CGColor,(id)[UIColor redColor].CGColor, nil];
    //设置贝瑟尔曲线
    [self setUpBezierPath];
    //添加内圆进度条
    [self addInnerProgressFounctions];
    //添加外圆进度条
    [self addOuterProgressFounctions];
}

-(void)setUpBezierPath{
    //根据数据创建内圆Bezier曲线
    _innerPath = [UIBezierPath bezierPathWithArcCenter:CENTER radius:_innerRadius startAngle:AngleToRadian(_startAngle) endAngle:AngleToRadian(_endAngle) clockwise:YES];
    //根据数据创建外圆Bezier曲线
    _outerPath = [UIBezierPath bezierPathWithArcCenter:CENTER radius:_outerRadius startAngle:AngleToRadian(_startAngle) endAngle:AngleToRadian(_endAngle) clockwise:YES];
}

-(void)addOuterProgressFounctions{
    [self drawOuterBottomLayer];
    [self drawOuterGradientLayer];
    [self drawOuterShapeLayer];
    [self.layer addSublayer:_outerBottomShapeLayer];
    [_outerBottomShapeLayer addSublayer:_outergradientLayer];
    [_outergradientLayer setMask:_outerProgressShapeLayer];
}
-(void)addInnerProgressFounctions{
    [self drawInnerBottomLayer];//绘制底部灰色填充Layer
    [self drawInnerGradientLayer];//绘制颜色渐变layer
    [self drawInnerShapelayer];//绘制底部的进度显示
#pragma ------注意添加Layer顺序------
    //将底部layer添加到底层layer上
    [self.layer addSublayer:_innerbottomShapeLayer];
    //将颜色渐变Layer添加到底部layer上
    [_innerbottomShapeLayer addSublayer:_innergradientLayer];
    //将进度layer添加到颜色渐变layer上
    [_innergradientLayer setMask:_innerShapeLayer];
}



-(void)drawInnerBottomLayer{
    _innerbottomShapeLayer = [[CAShapeLayer alloc]init];
    _innerbottomShapeLayer.frame = self.frame;
    //将曲线路径赋予Layer路径
    _innerbottomShapeLayer.path = _innerPath.CGPath;
    //曲线头部的形状 /* The cap style used when stroking the path. Options are `butt', `round'
    /* and `square'. Defaults to `butt'. */
    _innerbottomShapeLayer.lineCap = kCALineCapButt;
    //设置曲线的样式为虚线 /* The dash pattern (an array of NSNumbers) applied when creating the/* stroked version of the path. Defaults to nil. */
    //第一个是虚线的长度 第二个是虚线之间的间隔
    _innerbottomShapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:_dashWith],[NSNumber numberWithInt:_dashDistanse],nil];
    //设置曲线的宽度
    _innerbottomShapeLayer.lineWidth = _innerLineWith;
    //笔画颜色
    _innerbottomShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    //填充色
    _innerbottomShapeLayer.fillColor = [UIColor clearColor].CGColor;
}

//  绘制渐变色的layer
-(void)drawInnerGradientLayer{
    _innergradientLayer = [CAGradientLayer layer];
    _innergradientLayer.frame = self.frame;
    _innergradientLayer.shadowPath = _innerPath.CGPath;
    /*[0,0] is the bottom-left corner of the layer, [1,1] is the top-right corner.) The default values  are [0.5,0] and [0.5,1] respectively*/
    //颜色的走势从左上角向右下角
    _innergradientLayer.startPoint = CGPointMake(0, 1);
    _innergradientLayer.endPoint = CGPointMake(1, 0);
    /*The array of CGColorRef objects defining the color of each gradient  stop. Defaults to nil.*/
    //数组里面的颜色定义了每一个梯度停止的颜色
    [_innergradientLayer setColors:_colors];
}

-(void)drawInnerShapelayer{
    _innerShapeLayer = [[[CAShapeLayer alloc]init]init];
    _innerShapeLayer.frame = self.frame;
    _innerShapeLayer.path = _innerPath.CGPath;
    /*The values must be in the range [0,1] strokeStart defaults to zero and strokeEnd to one.*/
    //进度条的颜色进度
    _innerShapeLayer.strokeStart = 0;
    _innerShapeLayer.strokeEnd = 0;
    _innerShapeLayer.lineWidth = _innerLineWith;
    _innerShapeLayer.lineCap = kCALineCapButt;
    _innerShapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:_dashWith],[NSNumber numberWithInt:_dashDistanse], nil];
    _innerShapeLayer.strokeColor = [UIColor redColor].CGColor;
    _innerShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //[self performSelector:@selector(shapeChange) withObject:nil afterDelay:5];
}
-(void)drawOuterBottomLayer{
    _outerBottomShapeLayer = [CAShapeLayer layer];
    _outerBottomShapeLayer.frame = self.frame;
    _outerBottomShapeLayer.path = _outerPath.CGPath;
    _outerBottomShapeLayer.lineWidth = _outerLineWith;
    _outerBottomShapeLayer.lineCap = kCALineCapButt;
    _outerBottomShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    _outerBottomShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
}

-(void)drawOuterGradientLayer{
    _outergradientLayer = [CAGradientLayer layer];
    _outergradientLayer.frame = self.frame;
    _outergradientLayer.shadowPath = _outerPath.CGPath;
    _outergradientLayer.startPoint = CGPointMake(0, 1);
    _outergradientLayer.endPoint = CGPointMake(1, 0);
    [_outergradientLayer setColors:_colors];
}

-(void)drawOuterShapeLayer{
    _outerProgressShapeLayer = [CAShapeLayer layer];
    _outerProgressShapeLayer.frame = self.frame;
    _outerProgressShapeLayer.path = _outerPath.CGPath;
    _outerProgressShapeLayer.lineWidth = _outerLineWith;
    _outerProgressShapeLayer.lineCap = kCALineCapButt;
    _outerProgressShapeLayer.strokeStart = 0;
    _outerProgressShapeLayer.strokeEnd = 0;
    _outerProgressShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    _outerProgressShapeLayer.fillColor = [UIColor clearColor].CGColor;
}


















@end
