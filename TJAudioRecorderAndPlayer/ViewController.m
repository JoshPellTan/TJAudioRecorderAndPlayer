//
//  ViewController.m
//  TJAudioRecorderAndPlayer
//
//  Created by TanJian on 17/5/18.
//  Copyright © 2017年 Joshpell. All rights reserved.
//

#import "ViewController.h"
#import "TJRecorderTool.h"


@interface ViewController ()<AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder; //音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;     //音频播放器
@property (nonatomic,strong) NSTimer *timer;            //录音监控

@property (nonatomic,strong) AVPlayer *player;

@property (nonatomic,strong) UIProgressView *audioPower;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    
}

-(void)setUI{
    
    UIButton *startBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 50, 50, 50)];
    [startBtn setTitle:@"开始" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    UIButton *pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(200, 50, 50, 50)];
    [pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [pauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pauseBtn addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseBtn];
    
    UIButton *cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 130, 50, 50)];
    [cancleBtn setTitle:@"网络" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(playNetwork:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancleBtn];
    
    UIButton *goonBtn = [[UIButton alloc]initWithFrame:CGRectMake(200, 130, 50, 50)];
    [goonBtn setTitle:@"恢复" forState:UIControlStateNormal];
    [goonBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [goonBtn addTarget:self action:@selector(goon:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goonBtn];
    
    UIButton *stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 210, 50, 50)];
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    [stopBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopBtn];
    
    UIButton *playBtn = [[UIButton alloc]initWithFrame:CGRectMake(200, 210, 50, 50)];
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    
}

-(void)startRecord:(id)sender {
    
    [TJRecorderTool sharedInstance].configureRecorder().startRecord();
    
}

-(void)playNetwork:(id)sender {
    [TJRecorderTool sharedInstance].configureNetwork().playNetworkaAudio([NSURL URLWithString:@"http://weizitest-10076841.video.myqcloud.com/8a2c1fde57b20f550157b2151dad00042017/05/23/10/45/54.mp3"]);
    
}

- (void)pause:(id)sender {
    [TJRecorderTool sharedInstance].pauseRecord();
}

- (void)goon:(id)sender {
    [TJRecorderTool sharedInstance].startRecord();
}

- (void)stop:(id)sender {
    [TJRecorderTool sharedInstance].stopRecorder();
}

- (void)play:(id)sender {
    
    [TJRecorderTool sharedInstance].getRecorderDataBlock();
    [TJRecorderTool sharedInstance].playRecorderLocal();
    
}



@end
