//
//  ViewController.m
//  麦克风音量
//
//  Created by 史博 on 17/2/14.
//  Copyright © 2017年 史博. All rights reserved.
//

#import "ViewController.h"
#import "XSMSectorProgressView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    AVAudioRecorder * recorder;
    NSTimer * levelTimer;
    XSMSectorProgressView * view;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    view = [[XSMSectorProgressView alloc]initWithFrame:self.view.frame];
    view.showOuterProgress = YES;
//    view.startAngle = 0;
//    view.endAngle = 360;
//    [view XSMProgressDataWithDashWith:2 dashDistanse:5 outerLineWith:2];
    [self.view addSubview:view];
    
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    /* 不需要保存录音文件 */
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
                               nil];
    
    NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (recorder)
    {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    } else {
        NSLog(@"%@", [error description]);
    }
    
}


/* 该方法确实会随环境音量变化而变化，但具体分贝值是否准确暂时没有研究 */
- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels){ 
        level = 0.0f;
    }else if (decibels >= 0.0f){
        level = 1.0f;
    }else{
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    
    /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"音量--%f",level);
        view.rata = level * 100;
    });
}  

-(void)dealloc{
    [levelTimer invalidate];
    levelTimer = nil;

}

@end
