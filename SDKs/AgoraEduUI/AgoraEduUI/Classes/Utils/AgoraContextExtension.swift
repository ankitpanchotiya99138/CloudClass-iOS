//
//  AgoraContextExtension.swift
//  AgoraEduUI
//
//  Created by Cavan on 2021/10/16.
//

import AgoraEduContext

let kFrontCameraStr = "front"
let kBackCameraStr = "back"
extension AgoraEduContextUserInfo {
    static func ==(left: AgoraEduContextUserInfo,
                   right: AgoraEduContextUserInfo) -> Bool {
        return left.userUuid == right.userUuid
    }
    
    static func !=(left: AgoraEduContextUserInfo,
                   right: AgoraEduContextUserInfo) -> Bool {
        return left.userUuid != right.userUuid
    }
}

extension AgoraEduContextMediaStreamType {
    var hasAudio: Bool {
        switch self {
        case .none:          return false
        case .audio:         return true
        case .video:         return false
        case .both:          return true
        @unknown default:    return false
        }
    }
    
    var hasVideo: Bool {
        switch self {
        case .none:          return false
        case .audio:         return false
        case .video:         return true
        case .both:          return true
        @unknown default:    return false
        }
    }
}

extension AgoraRenderMemberModel {
    static func model(with userController: AgoraEduUserContext,
                      streamController: AgoraEduStreamContext,
                      uuid: String,
                      name: String,
                      rendEnable: Bool = true) -> AgoraRenderMemberModel {
        var model = AgoraRenderMemberModel()
        model.uuid = uuid
        model.name = name
        let reward = userController.getUserRewardCount(userUuid: uuid)
        model.rewardCount = reward
        let stream = streamController.getStreamList(userUuid: uuid)?.first{$0.videoSourceType != .screen}
        model.updateStream(stream,
                           rendEnable: rendEnable)
        return model
    }
    
    func updateStream(_ stream: AgoraEduContextStreamInfo?,
                      rendEnable: Bool = true) {
        if let `stream` = stream {
            self.rendEnable = rendEnable
            self.streamID = stream.streamUuid
            // audio
            if stream.streamType.hasAudio,
               stream.audioSourceState == .open {
                self.audioState = .on
            } else if stream.streamType.hasAudio,
                      stream.audioSourceState == .close {
                self.audioState = .off
            } else if stream.streamType.hasAudio == false,
                      stream.audioSourceState == .open {
                self.audioState = .forbidden
            } else {
                self.audioState = .off
            }
            // video
            if stream.streamType.hasVideo,
               stream.videoSourceState == .open {
                self.videoState = .on
            } else if stream.streamType.hasVideo,
                      stream.videoSourceState == .close {
                self.videoState = .off
            } else if stream.streamType.hasVideo == false,
                      stream.videoSourceState == .open {
                self.videoState = .forbidden
            } else {
                self.videoState = .off
            }
        } else {
            self.streamID = nil
            self.audioState = .off
            self.videoState = .off
        }
    }
}

extension AgoraEduContextStreamInfo {
    func toEmptyStream() -> AgoraEduContextStreamInfo {
        let videoSourceType: AgoraEduContextVideoSourceType = (self.videoSourceType == .screen) ? .screen : .none
        let emptyStream = AgoraEduContextStreamInfo(streamUuid: self.streamUuid,
                                                    streamName: self.streamName,
                                                    streamType: .none,
                                                    videoSourceType: videoSourceType,
                                                    audioSourceType: .none,
                                                    videoSourceState: .error,
                                                    audioSourceState: .error,
                                                    owner: self.owner)
        return emptyStream
    }
}
