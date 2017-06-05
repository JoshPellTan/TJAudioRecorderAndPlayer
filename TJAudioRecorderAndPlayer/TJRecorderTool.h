//
//  TJRecorderTool.h
//  TJAudioRecorderAndPlayer
//
//  Created by TanJian on 17/5/19.
//  Copyright © 2017年 Joshpell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@class TJRecorderTool ;

typedef TJRecorderTool *(^configerOrAction)();
typedef TJRecorderTool *(^configureURL)(NSString *url);
typedef void (^configerTimeFeedback)(NSString *totalTime,NSString *currentTime);
typedef void (^configerVolume)(CGFloat colume);
typedef NSData *(^configerRecorderData)();

@interface TJRecorderTool : NSObject

/*
 *  录音工具单例
 */
+ (instancetype)sharedInstance;
/*
 *  录音前需要做的配置
 */
@property (nonatomic, copy, readonly) configerOrAction configureRecorder;
/*
 *  开始录音
 */
@property (nonatomic, copy, readonly) configerOrAction startRecord;
/*
 *  继续录音
 */
@property (nonatomic, copy, readonly) configerOrAction continueRecord;
/*
 *  结束录音
 */
@property (nonatomic, copy, readonly) configerOrAction stopRecorder;
/*
 *  暂停录音
 */
@property (nonatomic, copy, readonly) configerOrAction pauseRecord;
/*
 *  本地录音播放
 */
@property (nonatomic, copy, readonly) configerOrAction playRecorderLocal;
/*
 *  本地录音播放暂停
 */
@property (nonatomic, copy, readonly) configerOrAction pauseRecorderPlayLocal;
/*
 *  本地录音播放继续
 */
@property (nonatomic, copy, readonly) configerOrAction continueRecorderPlayLocal;
/*
 *  本地录音停止
 */
@property (nonatomic, copy, readonly) configerOrAction stopRecorderPlayLocal;
/*
 *  播放网络音频前需要做的配置
 */
@property (nonatomic, copy, readonly) configerOrAction configureNetwork;
/*
 *  播放网络音频前的加载
 */
@property (nonatomic, copy, readonly) configureURL downloadNetworkaAudio;
/*
 *  播放网络音频
 */
@property (nonatomic, copy, readonly) configerOrAction playNetwork;
/*
 *  暂停播放网络音频
 */
@property (nonatomic, copy, readonly) configerOrAction pauseNetwork;
/*
 *  停止播放网络音频
 */
@property (nonatomic, copy, readonly) configerOrAction stopNetwork;

#pragma mark block操作
/*
 *  播放时间回调Block
 */
@property (nonatomic, copy) configerTimeFeedback timeObserverBlock;
/*
 *  录音时长回调Block
 */
@property (nonatomic, copy) configerTimeFeedback recordTimeObserverBlock;
/*
 *  音量监听回调Block
 */
@property (nonatomic, copy) configerVolume volumeObserverBlock;
/*
 *  获取最后一次录音的数据
 */
@property (nonatomic, copy) configerRecorderData getRecorderDataBlock;
/*
 *  播放完成回调
 */
@property (nonatomic, copy) void (^playerFinished)();


#pragma mark 外部调用方法
-(NSString *)getRecorderPath;
-(BOOL)isRecording;
-(CGFloat)getLocalRecordTime;//获取本地播放的录音文件时长

@end
