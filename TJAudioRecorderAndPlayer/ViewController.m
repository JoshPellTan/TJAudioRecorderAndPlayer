
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
@property (nonatomic,assign) CGFloat currentRecordTime;     //当前录音时长
@property (nonatomic,assign) CGFloat currentPlayLocalTime;  //当前本地录音剩余时长
@property (nonatomic,assign) CGFloat currentPlayNetworkTime;  //当前本地录音剩余时长
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) UIProgressView *audioPower;

//录音时长
@property (nonatomic,strong) UILabel *recordTimeLabel;
//本地录音播放时长
@property (nonatomic,strong) UILabel *localPlayTimeLabel;
//网络录音播放时长
@property (nonatomic,strong) UILabel *netPlayTimeLabel;
//本地播放计时
@property (nonatomic, strong) NSTimer *playLocalTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
}

-(void)setUI{
    
    CALayer *layer1 = [[CALayer alloc]init];
    layer1.frame = CGRectMake(self.view.bounds.size.width*0.5, 0, self.view.bounds.size.width*0.5, self.view.bounds.size.height*0.5);
    layer1.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.view.layer addSublayer:layer1];
    
    CALayer *layer2 = [[CALayer alloc]init];
    layer2.frame = CGRectMake(0, self.view.bounds.size.height*0.5, self.view.bounds.size.width*0.5, self.view.bounds.size.height*0.5);
    layer2.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.view.layer addSublayer:layer2];
    
    UIButton *startBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 30, 100, 40)];
    [startBtn setTitle:@"开始录音" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    UIButton *pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 70, 100, 40)];
    [pauseBtn setTitle:@"暂停录音" forState:UIControlStateNormal];
    [pauseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pauseBtn addTarget:self action:@selector(pauseRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseBtn];
    
    UIButton *goonBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 110, 100, 40)];
    [goonBtn setTitle:@"继续录音" forState:UIControlStateNormal];
    [goonBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [goonBtn addTarget:self action:@selector(goonRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goonBtn];
    
    UIButton *stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 150, 100, 40)];
    [stopBtn setTitle:@"停止录音" forState:UIControlStateNormal];
    [stopBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopBtn];
    
    _recordTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 210, 120, 30)];
    _recordTimeLabel.text = @"00'00";
    [self.view addSubview:_recordTimeLabel];
    
    UIButton *playBtn = [[UIButton alloc]initWithFrame:CGRectMake(200, 30, 120, 40)];
    [playBtn setTitle:@"播放本地录音" forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playRecordLocal:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    
    UIButton *pauseLocalPlayBtn = [[UIButton alloc]initWithFrame:CGRectMake(200, 70, 120, 40)];
    [pauseLocalPlayBtn setTitle:@"暂停本地播放" forState:UIControlStateNormal];
    [pauseLocalPlayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pauseLocalPlayBtn addTarget:self action:@selector(pausePlayLocal:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseLocalPlayBtn];
    
    UIButton *continueLocalPlayBtn = [[UIButton alloc]initWithFrame:CGRectMake(200, 110, 120, 40)];
    [continueLocalPlayBtn setTitle:@"继续本地播放" forState:UIControlStateNormal];
    [continueLocalPlayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [continueLocalPlayBtn addTarget:self action:@selector(continuePlayLocal:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueLocalPlayBtn];
    
    UIButton *stopLocalPlayBtn = [[UIButton alloc]initWithFrame:CGRectMake(200, 150, 120, 40)];
    [stopLocalPlayBtn setTitle:@"停止本地播放" forState:UIControlStateNormal];
    [stopLocalPlayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [stopLocalPlayBtn addTarget:self action:@selector(stopPlayLocal:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopLocalPlayBtn];
    
    _localPlayTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, 210, 120, 30)];
    _localPlayTimeLabel.text = @"00'00";
    [self.view addSubview:_localPlayTimeLabel];
    
    UIButton *playNetworkBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, self.view.bounds.size.height*0.5+30, 120, 40)];
    [playNetworkBtn setTitle:@"播放网络音频" forState:UIControlStateNormal];
    [playNetworkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playNetworkBtn addTarget:self action:@selector(playCurrentNetwork:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playNetworkBtn];
    
    UIButton *pauseNetworkBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, self.view.bounds.size.height*0.5+70, 120, 40)];
    [pauseNetworkBtn setTitle:@"暂停网络音频" forState:UIControlStateNormal];
    [pauseNetworkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pauseNetworkBtn addTarget:self action:@selector(pauseCurrentNetwork:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseNetworkBtn];
    
    UIButton *continueNetworkBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, self.view.bounds.size.height*0.5+110, 120, 40)];
    [continueNetworkBtn setTitle:@"继续网络音频" forState:UIControlStateNormal];
    [continueNetworkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [continueNetworkBtn addTarget:self action:@selector(cuontinueCurrentNetwork:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueNetworkBtn];
    
    UIButton *stopNetworkBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, self.view.bounds.size.height*0.5+150, 120, 40)];
    [stopNetworkBtn setTitle:@"停止网络音频" forState:UIControlStateNormal];
    [stopNetworkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [stopNetworkBtn addTarget:self action:@selector(stopCurrentNetwork:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopNetworkBtn];
    
    _netPlayTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, self.view.bounds.size.height*0.5+210, 120, 30)];
    _netPlayTimeLabel.text = @"00'00";
    [self.view addSubview:_netPlayTimeLabel];
    
    
    
}


#pragma mark 录音相关
-(void)startRecord:(id)sender {
    
    [TJRecorderTool sharedInstance].recordTimeObserverBlock = ^(NSString *totalTime,NSString *currentTime){
        
        CGFloat currentTimeFloat = currentTime.floatValue;
        self.recordTimeLabel.text = [self convertStringWithTime:currentTimeFloat];
        self.currentRecordTime = currentTimeFloat;
    };
    
    [TJRecorderTool sharedInstance].configureRecorder().startRecord();
    
}

- (void)pauseRecord:(id)sender {
    [TJRecorderTool sharedInstance].pauseRecord();
}

- (void)goonRecord:(id)sender {
    [TJRecorderTool sharedInstance].continueRecord();
}

- (void)stopRecord:(id)sender {
    [TJRecorderTool sharedInstance].stopRecorder();
    NSData *data = [TJRecorderTool sharedInstance].getRecorderDataBlock();
    
    NSLog(@"录音文件长度%ld",data.length);
}

#pragma mark 播放录音相关
- (void)playRecordLocal:(id)sender {
    
    [TJRecorderTool sharedInstance].playRecorderLocal();
    _currentPlayLocalTime = [[TJRecorderTool sharedInstance] getLocalRecordTime];
    if (!_playLocalTimer) {
        
        _playLocalTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playTimeViewer) userInfo:nil repeats:YES];
        
    }else{
        
        [self.playLocalTimer setFireDate:[NSDate distantPast]];
    }

    
}

- (void)pausePlayLocal:(UIButton *)sender{
    
    [TJRecorderTool sharedInstance].pauseRecorderPlayLocal();
    
}

- (void)continuePlayLocal:(UIButton *)sender{
    
    [TJRecorderTool sharedInstance].continueRecorderPlayLocal();
}

-(void)stopPlayLocal:(UIButton *)sender{
    
    [TJRecorderTool sharedInstance].stopRecorderPlayLocal();
    
}

#pragma mark 播放网络音频相关
-(void)playCurrentNetwork:(id)sender {
    
    [TJRecorderTool sharedInstance].stopRecorderPlayLocal();
    [TJRecorderTool sharedInstance].configureNetwork().downloadNetworkaAudio(@"http://cc.stream.qqmusic.qq.com/C100003j8IiV1X8Oaw.m4a?fromtag=52").playNetwork();
    [TJRecorderTool sharedInstance].timeObserverBlock = ^(NSString *totalTime,NSString *currentTime){
        
        
        _currentPlayNetworkTime = totalTime.floatValue-currentTime.floatValue;
        _netPlayTimeLabel.text = [self convertStringWithTime:_currentPlayNetworkTime];
        
    };
}

-(void)pauseCurrentNetwork:(UIButton *)sender{
    
    [TJRecorderTool sharedInstance].pauseNetwork();
}

-(void)cuontinueCurrentNetwork:(UIButton *)sender{
    
    [TJRecorderTool sharedInstance].playNetwork();
}

-(void)stopCurrentNetwork:(UIButton *)sender{
    
    [TJRecorderTool sharedInstance].stopNetwork();
}


-(void)playTimeViewer{
    
    self.currentPlayLocalTime --;
    
    _localPlayTimeLabel.text = [self convertStringWithTime:_currentPlayLocalTime];
    if (_currentPlayLocalTime <= 0) {
        
        [_playLocalTimer invalidate];
        _playLocalTimer = nil;
        
    }
    
}

- (NSString *)convertStringWithTime:(CGFloat)time {
    
    //过滤无穷大和无穷小的数,乱数
    if (isnan(time)) {
        time = 0.f;
    }
    int min = time / 60.0;
    int sec = time - min * 60;
    NSString * minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d",min];
    NSString * secStr = sec > 9 ? [NSString stringWithFormat:@"%d",sec] : [NSString stringWithFormat:@"0%d",sec];
    NSString * timeStr = [NSString stringWithFormat:@"%@'%@",minStr, secStr];
    return timeStr;
}



@end
