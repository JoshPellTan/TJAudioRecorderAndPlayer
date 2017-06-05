//
//  TJRecorderTool.m
//  TJAudioRecorderAndPlayer
//
//  Created by TanJian on 17/5/19.
//  Copyright © 2017年 Joshpell. All rights reserved.
//

#import "TJRecorderTool.h"

static const CGFloat volumeObserverMargin = 1; //录音时timer间隔
static const CGFloat playerTimeObserverMargin = 0.05; //音量监听的timer间隔


@interface TJRecorderTool ()
{
    
    AVAudioSession *session;
    //录音器设置
    NSDictionary *recorderSettingsDict;
    //音量监控定时器
    NSTimer *volumeTimer;
    //进度监控定时器
    NSTimer *progressTimer;
    double lowPassResults;
    
    id timeObserve;
    
}
//录音器
@property (nonatomic, strong) AVAudioRecorder *recorder;
//本地播放器
@property (nonatomic, strong) AVAudioPlayer *playerLocal;
//网络播放器
@property (nonatomic, strong) AVPlayer *networkAudioPlayer;
//网路播放item
@property (nonatomic, strong) AVPlayerItem *songItem;
//当前播放url
@property (nonatomic,   copy) NSString *currentURL;
//网络媒体总时长
@property (nonatomic, assign) NSString *netAudioTime;
//当前播放时间(秒)
@property (nonatomic,   copy) NSString *currentPlayTime;
//当前录音时长(秒)
@property (nonatomic,   copy) NSString *currentRecordTime;

@end

@implementation TJRecorderTool

//添加getter
@synthesize configureRecorder = _configureRecorder;
@synthesize configureNetwork = _configureNetwork;
@synthesize startRecord = _startRecord;
@synthesize continueRecord = _continueRecord;
@synthesize stopRecorder = _stopRecorder;
@synthesize playRecorderLocal = _playRecorderLocal;
@synthesize pauseRecorderPlayLocal = _pauseRecorderPlayLocal;
@synthesize continueRecorderPlayLocal = _continueRecorderPlayLocal;
@synthesize stopRecorderPlayLocal = _stopRecorderPlayLocal;
@synthesize downloadNetworkaAudio = _downloadNetworkaAudio;
@synthesize playNetwork = _playNetwork;
@synthesize pauseNetwork = _pauseNetwork;
@synthesize stopNetwork = _stopNetwork;
@synthesize getRecorderDataBlock = _getRecorderDataBlock;
@synthesize pauseRecord = _pauseRecord;



+ (instancetype)sharedInstance {
    static TJRecorderTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TJRecorderTool new];
        
    });
    return instance;
}

-(configerOrAction)configureRecorder{
    
    if (!_configureRecorder) {
        
        __weak typeof(self) weakSelf = self;
        return ^(){
            
            //录音设置
            recorderSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                                    [NSNumber numberWithInt:8000],AVSampleRateKey,
                                    [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                    [NSNumber numberWithInteger:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                    nil];
            
            return weakSelf;
        };
    }
    
    return _configureRecorder;
}

-(configerOrAction)configureNetwork{
    
    if (!_configureNetwork) {
        
        __weak typeof(self) weakSelf = self;
        return ^(){
            
            NSError *sessionError;
            //AVAudioSessionCategoryPlay用于播放
            if(session == nil){
                
                session = [AVAudioSession sharedInstance];
                [session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
                [session setActive:YES error:nil];
            }
            
            if (sessionError) {
                NSLog(@"Error creating session: %@", [sessionError description]);
            }
            
            
            if (![self isHeadsetPluggedIn]) {
                NSError *audioError = nil;
                BOOL success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&audioError];
                if(!success)
                {
                    NSLog(@"error doing outputaudioportoverride - %@", [audioError localizedDescription]);
                }
            }
            
            
            return weakSelf;
        };
    }
    
    return _configureNetwork;
}


-(configerOrAction)startRecord{
    
    if (!_startRecord) {
        //开始录音
        __weak typeof(self) weakSelf = self;
        return ^(){
            if ([weakSelf canRecord]) {
                
                session = [AVAudioSession sharedInstance];
                [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
                [session setActive:YES error:nil];
                
                weakSelf.currentRecordTime = @"0";
                
                if (weakSelf.recorder) {
                    _recorder.meteringEnabled = YES;
                    [_recorder prepareToRecord];
                    [_recorder record];
                    
                    //启动定时器
                    if (!volumeTimer) {
                        volumeTimer = [NSTimer scheduledTimerWithTimeInterval:volumeObserverMargin target:weakSelf selector:@selector(levelTimer:) userInfo:nil repeats:YES];
                    }
                    NSLog(@"开始录音");
                    
                } else{
                    
                    NSLog(@"录音机初始化失败");
                }
            }else{
                NSLog(@"权限失败");
            }
            
            return weakSelf;
        };
        
    }
    return _startRecord;
}

-(configerOrAction)continueRecord{
    
    if (!_continueRecord) {
        __weak typeof(self) weakself = self;
        
        return ^(){
            
            _recorder.meteringEnabled = YES;
            [_recorder prepareToRecord];
            [_recorder record];
            
            //启动定时器
            if (!volumeTimer) {
                volumeTimer = [NSTimer scheduledTimerWithTimeInterval:volumeObserverMargin target:weakself selector:@selector(levelTimer:) userInfo:nil repeats:YES];
            }
            NSLog(@"开始录音");
            
            return weakself;
        };
        
    }
    return _configureNetwork;
}


-(configerOrAction)stopRecorder{
    if (!_stopRecorder) {
        
        __weak typeof(self) weakSelf = self;
        return ^(){
            //录音停止
            [weakSelf.recorder stop];
            weakSelf.recorder = nil;
            //结束定时器
            [volumeTimer invalidate];
            volumeTimer = nil;
            
            NSLog(@"停止录音");
            return weakSelf;
        };
    }
    return _stopRecorder;
}

-(configerOrAction)pauseRecord{
    
    if (!_pauseRecord) {
        
        __weak typeof(self) weakSelf = self;
        return  ^(){
            
            [weakSelf.recorder pause];
            
            //结束定时器
            [volumeTimer invalidate];
            volumeTimer = nil;
            
            NSLog(@"暂停录音");
            return weakSelf;
        };
        
    }
    return _pauseRecord;
}

-(configerOrAction)playRecorderLocal{
    
    if (!_playRecorderLocal) {
        
        if ([self.recorder isRecording]) {
            [self.recorder stop];

            self.recorder = nil;
            //结束定时器
            [volumeTimer invalidate];
            volumeTimer = nil;
        }
        
        __weak typeof(self) weakSelf = self;
        return ^(){
            
            if (![self isHeadsetPluggedIn]) {
                
                //无耳机，打开外放模式
                NSError *audioError = nil;
                BOOL success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&audioError];
                if(!success)
                {
                    NSLog(@"error doing outputaudioportoverride - %@", [audioError localizedDescription]);
                }
            }
            
            if (weakSelf.playerLocal){
                
                [weakSelf.playerLocal play];
                
                NSLog(@"播放本地录音");
            }else{
                NSLog(@"本地录音播放器初始化失败");
                
            }
        
            //启动定时器
            if (!progressTimer) {
                
                progressTimer = [NSTimer scheduledTimerWithTimeInterval:playerTimeObserverMargin target:self selector:@selector(recorderTimeViewer) userInfo:nil repeats:YES];
            }else{
                
                [progressTimer  setFireDate:[NSDate distantPast]];
            }
            return weakSelf;
        };
        
    }
    return _playRecorderLocal;
}

-(configerOrAction)pauseRecorderPlayLocal{
    
    if (!_pauseRecorderPlayLocal) {
        
        __weak typeof(self) weakSelf = self;
        return ^(){
            
            
            if (_playerLocal){
                
                [weakSelf.playerLocal pause];
                
                NSLog(@"暂停播放本地录音");
                [progressTimer setFireDate:[NSDate distantFuture]];
            }
            
            return weakSelf;
        };
        
    }
    return _pauseRecorderPlayLocal;
}

-(configerOrAction)continueRecorderPlayLocal{
    
    if (!_continueRecorderPlayLocal) {
        __weak typeof(self) weakself = self;
        return ^(){
            
            if (_playerLocal) {
                [weakself.playerLocal play];
                
                //启动定时器
                if (!progressTimer) {
                    
                    progressTimer = [NSTimer scheduledTimerWithTimeInterval:playerTimeObserverMargin target:self selector:@selector(recorderTimeViewer) userInfo:nil repeats:YES];
                }else{
                    
                    [progressTimer  setFireDate:[NSDate distantPast]];
                }
                
                NSLog(@"继续播放本地录音");
            }

            return weakself;
        };
        
    }
    return _continueRecorderPlayLocal;
}


-(configerOrAction)stopRecorderPlayLocal{
    
    if (!_stopRecorderPlayLocal) {
        
        __weak typeof(self) weakSelf = self;
        return ^(){
            
            
            if (_playerLocal){
                
                [weakSelf.playerLocal stop];
                weakSelf.playerLocal = nil;
                
                NSLog(@"停止播放本地录音");
                [progressTimer invalidate];
                progressTimer = nil;
            }
            
            return weakSelf;
        };
        
    }
    return _stopRecorderPlayLocal;
}


-(configureURL)downloadNetworkaAudio{
    
    if (!_downloadNetworkaAudio) {
        
        __weak typeof(self) weakSelf = self;
        return ^(NSString *url){
            
            weakSelf.songItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:url]];
            
            weakSelf.networkAudioPlayer = [[AVPlayer alloc]initWithPlayerItem:_songItem];
            weakSelf.currentURL = url;
            
            //给当前歌曲添加监控
            [weakSelf addObserver];
            
            return weakSelf;
        };
    }
    
    return _downloadNetworkaAudio;
}

-(configerOrAction)playNetwork{
    
    if (!_playNetwork) {
        
        
        __weak typeof(self) weakself = self;
        
        return ^(){
            
            
            //启动定时器
            if (!progressTimer) {
                
                progressTimer = [NSTimer scheduledTimerWithTimeInterval:playerTimeObserverMargin target:self selector:@selector(recorderTimeViewer) userInfo:nil repeats:YES];
            }else{
                
                [progressTimer  setFireDate:[NSDate distantPast]];
            }
            
            [_networkAudioPlayer play];
            
            return weakself;
        };
    }
    
    return _playNetwork;
    
}

-(configerOrAction)pauseNetwork{
    
    if (!_pauseNetwork) {
        
        __weak typeof(self) weakself = self;
        
        return ^(){
            
            [_networkAudioPlayer  pause];
            
            if (progressTimer) {
                //定时器暂停
                [progressTimer setFireDate:[NSDate distantFuture]];
            }
            
            return weakself;
        };
    }
    
    return _playNetwork;
    
}

-(configerOrAction)stopNetwork{
    
    if (!_stopNetwork) {
        
        __weak typeof(self) weakself = self;
        
        return ^(){
            
            [weakself.networkAudioPlayer pause];
            weakself.currentPlayTime = @"0";
            weakself.networkAudioPlayer = nil;
            
            if (progressTimer) {
                
                [progressTimer invalidate];
                progressTimer = nil;
                
            }
            
            
            return weakself;
        };
    }
    
    return _pauseNetwork;
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    [self.networkAudioPlayer pause];
    self.netAudioTime = @"0";
    
    [progressTimer invalidate];
    progressTimer = nil;
    if (self.playerFinished) {
        self.playerFinished();
    }
    
}

-(configerRecorderData)getRecorderDataBlock{
    
    if (!_getRecorderDataBlock) {
        
        return ^(){
            
            NSData *data = [NSData dataWithContentsOfFile:[self getRecorderPath]];
            NSLog(@"录音文件长度%ld",data.length);
            return data;
        };
    }
    
    return _getRecorderDataBlock;
}


#pragma mark 辅助方法

- (void)addObserver {
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [_songItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //监控网络加载情况属性
    [_songItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //网络音频结束监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_songItem];    //更新播放器进度
    
    AVPlayerItem *currentItem = self.networkAudioPlayer.currentItem;
    __weak typeof(self) weakSelf = self;
    timeObserve = [self.networkAudioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(currentItem.duration);
        
        if (current) {
            
            weakSelf.currentPlayTime = [NSString stringWithFormat:@"%.f",current];
            weakSelf.netAudioTime = [NSString stringWithFormat:@"%.2f",total];
            
        }
    }];
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}


/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    AVPlayerItem * songItem = object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        switch (self.networkAudioPlayer.status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"网路音频播放器状态不明");
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"网路音频播放器状态可播放");
                _netAudioTime = [NSString stringWithFormat:@"%.2f", CMTimeGetSeconds(_songItem.asset.duration)];
                NSLog(@"网络媒体总时长%f",CMTimeGetSeconds(_songItem.asset.duration));
                
            }
                break;
            case AVPlayerStatusFailed:
            {
                NSLog(@"网路音频播放器状态失败");
            }
                break;
            default:
                break;
        }
        
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray * array = songItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        NSLog(@"共缓冲%.2f",totalBuffer);
    }
}

//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
-(BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:nil
                                                    message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                                   delegate:nil
                                          cancelButtonTitle:@"关闭"
                                          otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}


-(void)levelTimer:(NSTimer*)timer_
{
    
    CGFloat currentRecordTimeFloat = self.currentRecordTime.floatValue;
    currentRecordTimeFloat ++;
    self.currentRecordTime = [NSString stringWithFormat:@"%.0f",currentRecordTimeFloat];
    
    NSLog(@"当前录音时长%.0f",currentRecordTimeFloat);
    //外部的录音时长监听回调
    if ( self.recordTimeObserverBlock) {
        self.recordTimeObserverBlock(0,self.currentRecordTime);
    }
    
    //call to refresh meter values刷新平均和峰值功率,此计数是以对数刻度计量的,-160表示完全安静，0表示最大输入值
    
    //输入声音的分贝大小计算
    [_recorder updateMeters];
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    
    //分贝测试打印
    //NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [_recorder averagePowerForChannel:0], [_recorder peakPowerForChannel:0], lowPassResults);
    
    if (lowPassResults>=0.8) {
        
    }else if(lowPassResults>=0.7){
        
    }else if(lowPassResults>=0.6){
        
    }else if(lowPassResults>=0.5){
        
    }else if(lowPassResults>=0.4){
        
    }else if(lowPassResults>=0.3){
        
    }else if(lowPassResults>=0.2){
        
    }else if(lowPassResults>=0.1){
        
    }else{
        
    }
    
}

-(void)recorderTimeViewer{
    
    if (self.timeObserverBlock) {
        if (_playerLocal) {
            
            
            if ((_playerLocal.duration-_playerLocal.currentTime) < playerTimeObserverMargin*5) {
                
                [progressTimer invalidate];
                progressTimer = nil;
                
                NSLog(@"完毕");
            }
            
        }else{
            
            
            self.timeObserverBlock(self.netAudioTime,self.currentPlayTime);
            
        }
    }
}

-(CGFloat)getLocalRecordTime{
    
    if (_playerLocal) {
        return _playerLocal.duration;
    }
    
    return 0;
}

//录音文件路径
-(NSString *)getRecorderPath{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/play.aac",docDir];
}

//判断是否插入耳机
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [session currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

-(BOOL)isRecording{
    return self.recorder.isRecording;
}

#pragma mark lazy=====================
-(AVAudioRecorder *)recorder{
    
    if (!_recorder) {
        NSError *error = nil;
        //必须真机上测试,模拟器上可能会崩溃
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:[self getRecorderPath]] settings:recorderSettingsDict error:&error];
    }
    return _recorder;
}
-(AVAudioPlayer *)playerLocal{
    
    if (!_playerLocal) {
        NSError *playerError;
        _playerLocal = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[self getRecorderPath]] error:&playerError];
    }
    return _playerLocal;
}

@end

