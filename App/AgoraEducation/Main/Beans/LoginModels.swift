//
//  File.swift
//  AgoraEducation
//
//  Created by Cavan on 2021/12/28.
//  Copyright © 2021 Agora. All rights reserved.
//

#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import Foundation

/** 房间信息项*/
enum RoomInfoItemType: Int, CaseIterable {
    // 房间名
    case roomName = 0
    // 昵称
    case nickName
    // 类型
    case roomStyle
    // 服务类型：CDN、RTC等服务类型
    case serviceType
    // 角色
    case roleType
    // IM
    case im
    // 开始时间
    case startTime
    // 时长
    case duration
    // 拖堂时长
    case delay
    // 密钥
    case encryptKey
    // 模式
    case encryptMode
    // 上台是否直接授权音视频发流权限
    case mediaAuth
    // 环境
    case env
}

enum IMType: String {
    case rtm, easemob
}

/** 房间可选项*/
let kRoomOptions: [(AgoraEduRoomType, String)] = [
    (.oneToOne, NSLocalizedString("Login_onetoone", comment: "")),
    (.small, NSLocalizedString("Login_small", comment: "")),
    (.lecture, NSLocalizedString("Login_lecture", comment: "")),
    (.vocational, NSLocalizedString("Login_vocational_lecture", comment: "")),
]
/** 角色可选项*/
let kRoleOptions: [(AgoraEduUserRole, String)] = [
    (.student, NSLocalizedString("login_role_student", comment: "")),
    (.teacher, NSLocalizedString("login_role_teacher", comment: "")),
    (.observer, NSLocalizedString("login_role_observer", comment: "")),
]

let kIMOptions: [(IMType, String)] = [
    (.rtm, "rtm"),
    (.easemob, "easemon")
]

/** 加密方式可选项*/
let kEncryptionOptions: [(AgoraEduMediaEncryptionMode, String)] = [
    (.none, "None"),
    (.SM4128ECB, "sm4-128-ecb"),
    (.AES128GCM2, "aes-128-gcm2"),
    (.AES256GCM2, "aes-256-gcm2"),
]

/** 环境可选项*/
let kEnvironmentOptions: [(FcrEnvironment.Environment, String)] = [
    (.dev, NSLocalizedString("login_env_test", comment: "")),
    (.pre, NSLocalizedString("login_pre_test", comment: "")),
    (.pro, NSLocalizedString("login_pro_test", comment: ""))
]

/** 上台后音视频是否自动发流权限*/
let kMediaAuthOptions: [(AgoraEduMediaAuthOption, String)] = [
    (.none, NSLocalizedString("login_auth_none", comment: "")),
    (.audio, NSLocalizedString("login_auth_audio", comment: "")),
    (.video, NSLocalizedString("login_auth_video", comment: "")),
    (.both, NSLocalizedString("login_auth_both", comment: ""))
]

/** 服务类型可选项*/
let kVocationalServiceOptions: [(AgoraEduServiceType, String)] = [
    (.RTC, NSLocalizedString("Login_service_rtc", comment: "")),
    (.fastRTC, NSLocalizedString("Login_service_fast_rtc", comment: "")),
    (.onlyCDN, NSLocalizedString("Login_service_only_cdn", comment: "")),
    (.mixedCDN, NSLocalizedString("Login_service_mixed_cdn", comment: "")),
    (.mixStreamCDN, "合流转推"),
    (.hostingScene, "伪直播"),
]

/** 入参模型*/
struct RoomInfoModel {
    var roomName: String?
    var nickName: String?
    var roomStyle: AgoraEduRoomType?
    var serviceType: AgoraEduServiceType?
    var roleType: AgoraEduUserRole = .student
    var im: IMType = .easemob
    var duration: Int = 1800
    var encryptKey: String?
    var encryptMode: AgoraEduMediaEncryptionMode = .none
    
    var startTime: NSNumber?
    
    var mediaAuth: AgoraEduMediaAuthOption = .both

    /** 入参默认值 */
    static func defaultValue() -> RoomInfoModel {
        var room = RoomInfoModel()
        room.roomName = nil
        room.nickName = nil
        return room
    }
    
    func publicCoursewares() -> Array<String> {
        let publicJson1 = """
        {
            "resourceUuid": "9196d03d87ab1e56933f911eafe760c3",
            "resourceName": "AgoraFlexibleClassroomE.pptx",
            "ext": "pptx",
            "size": 10914841,
            "url": "https://agora-adc-artifacts.oss-cn-beijing.aliyuncs.com/cloud-disk/f488493d1886435f963dfb3d95984fd4/jasoncai4/9196d03d87ab1e56933f911eafe760c3.pptx",
            "updateTime": 1641805816941,
            "taskUuid": "203197d071f511ecb84859b705e54fae",
            "conversion": {
                "type": "dynamic",
                "preview": true,
                "scale": 2,
                "outputFormat": "png"
            },
            "taskProgress": {
                "status": "Finished",
                "totalPageSize": 24,
                "convertedPageSize": 24,
                "convertedPercentage": 100,
                "currentStep": "Packaging",
                "convertedFileList": [{
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/1.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/1.slide"
                    },
                    "name": "1"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/2.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/2.slide"
                    },
                    "name": "2"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/3.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/3.slide"
                    },
                    "name": "3"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/4.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/4.slide"
                    },
                    "name": "4"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/5.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/5.slide"
                    },
                    "name": "5"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/6.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/6.slide"
                    },
                    "name": "6"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/7.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/7.slide"
                    },
                    "name": "7"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/8.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/8.slide"
                    },
                    "name": "8"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/9.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/9.slide"
                    },
                    "name": "9"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/10.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/10.slide"
                    },
                    "name": "10"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/11.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/11.slide"
                    },
                    "name": "11"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/12.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/12.slide"
                    },
                    "name": "12"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/13.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/13.slide"
                    },
                    "name": "13"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/14.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/14.slide"
                    },
                    "name": "14"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/15.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/15.slide"
                    },
                    "name": "15"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/16.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/16.slide"
                    },
                    "name": "16"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/17.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/17.slide"
                    },
                    "name": "17"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/18.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/18.slide"
                    },
                    "name": "18"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/19.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/19.slide"
                    },
                    "name": "19"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/20.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/20.slide"
                    },
                    "name": "20"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/21.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/21.slide"
                    },
                    "name": "21"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/22.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/22.slide"
                    },
                    "name": "22"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/23.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/23.slide"
                    },
                    "name": "23"
                }, {
                    "ppt": {
                        "width": 1280,
                        "height": 720,
                        "preview": "https://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/preview/24.png",
                        "src": "pptx://convertcdn.netless.link/dynamicConvert/203197d071f511ecb84859b705e54fae/24.slide"
                    },
                    "name": "24"
                }]
            }
        }
        """
        let publicJson2 = """
            {
                "resourceUuid":"20c2281deddefa96a97fe16b3628b456",
                "resourceName":"Agora Flexible Classroom v2.1 Demo Instructions.pptx",
                "ext":"pptx",
                "size":8478024,
                "url":"https://agora-adc-artifacts.oss-accelerate.aliyuncs.com/scenario/cloud-disk/47b7535dcb9a4bb4aa592115266eae98/jasoncai4/20c2281deddefa96a97fe16b3628b456.pptx",
                "updateTime":1645759841545,
                "taskUuid":"36b372508efe11ecb24daf1de36fc2eb",
                "taskToken":"NETLESSTASK_YWs9MU53eWgwbDFvWWs4WkVjbmRtZGloMHJiY1VlbEJxNVJKTzFTJm5vbmNlPTE2NDQ5OTgzMDMzOTgwMCZyb2xlPTAmc2lnPTFiZDUzZjc4MGZkOGJlMjkyMDcwMDE2MzZkZWE0YmU4NGVlMDZmZTRhMmQ1ODRkMGJmNGQyZTdmZDMzOWNiNGUmdXVpZD0zNmIzNzI1MDhlZmUxMWVjYjI0ZGFmMWRlMzZmYzJlYg",
                "conversion":{
                    "type":"dynamic",
                    "preview":true,
                    "scale":1.2,
                    "outputFormat":"png",
                    "canvasVersion":true
                },
                "taskProgress":{
                    "status":"Finished",
                    "totalPageSize":14,
                    "convertedPageSize":14,
                    "convertedPercentage":100,
                    "convertedFileList":[
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/1.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/1.slide"
                        },
                        "name":"1"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/2.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/2.slide"
                        },
                        "name":"2"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/3.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/3.slide"
                        },
                        "name":"3"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/4.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/4.slide"
                        },
                        "name":"4"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/5.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/5.slide"
                        },
                        "name":"5"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/6.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/6.slide"
                        },
                        "name":"6"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/7.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/7.slide"
                        },
                        "name":"7"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/8.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/8.slide"
                        },
                        "name":"8"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/9.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/9.slide"
                        },
                        "name":"9"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/10.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/10.slide"
                        },
                        "name":"10"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/11.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/11.slide"
                        },
                        "name":"11"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/12.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/12.slide"
                        },
                        "name":"12"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/13.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/13.slide"
                        },
                        "name":"13"
                    },
                                         {
                        "ppt":{
                            "width":1280,
                            "height":720,
                            "preview":"https://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/preview/14.png",
                            "src":"pptx://convertcdn.netless.link/dynamicConvert/36b372508efe11ecb24daf1de36fc2eb/14.slide"
                        },
                        "name":"14"
                    }
                                         ],
                    "currentStep":"Packaging",
                    "prefix":"https://convertcdn.netless.link/dynamicConvert"
                }
            }
            """
        return [publicJson1, publicJson2]
    }
}
