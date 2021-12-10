//
//  AgoraEduContext.swift
//  AgoraEduContext
//
//  Created by SRS on 2021/4/16.
//

import AgoraExtApp
import AgoraWidget
import Foundation

public typealias AgoraEduExtAppContext = AgoraExtAppProtocol
public typealias AgoraEduWidgetContext = AgoraWidgetProtocol

/* AgoraEduContextPool: 能力池
 * 你可以通过这个对象使用和监听目前灵动课堂提供的各种业务能力
 */
@objc public protocol AgoraEduContextPool: NSObjectProtocol {
    // 房间控制
    var room: AgoraEduRoomContext { get }
    // 媒体控制
    var media: AgoraEduMediaContext { get }
    // 个人
    var user: AgoraEduUserContext { get }
    // 扩展容器：该应用容器提供了生命周期、扩展
    var extApp: AgoraEduExtAppContext { get }
    // 插件， 属于UIKit一部分。 每个插件是一个功能模块。
    var widget: AgoraEduWidgetContext { get }
    // 流控制
    var stream: AgoraEduStreamContext { get }
    // SDK状态
    var monitor: AgoraEduMonitorContext { get }
}
