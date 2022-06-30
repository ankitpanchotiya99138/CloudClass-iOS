//
//  AgoraBoardUIController.swift
//  AgoraEduUI
//
//  Created by LYY on 2021/12/9.
//

import AgoraEduContext
import AgoraWidget

protocol AgoraBoardUIControllerDelegate: NSObjectProtocol {
    func onBoardActiveStateChanged(isActive: Bool)
    func onStageStateChanged(stageOn: Bool)
    func onBoardGrantedUserListRemoved(userList: [String])
    func onBoardGrantedUserListAdded(userList: [String])
}

extension AgoraBoardUIControllerDelegate {
    func onStageStateChanged(stageOn: Bool) {
        
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        
    }
    
    func onBoardGrantedUserListAdded(userList: [String]) {
        
    }
}

class AgoraBoardUIController: UIViewController {
    private(set) var grantedUsers = [String]() {
        didSet {
            onGrantedUsersChanged(oldList: oldValue,
                                  newList: grantedUsers)
        }
    }
    
    var localGranted = false {
        didSet {
            guard localGranted != oldValue,
                  contextPool.user.getLocalUserInfo().userRole != .teacher else {
                return
            }
            if !localGranted {
                AgoraToast.toast(msg: "fcr_netless_board_ungranted".agedu_localized(),
                                 type: .error)
            } else {
                AgoraToast.toast(msg: "fcr_netless_board_granted".agedu_localized(),
                                 type: .notice)
            }
        }
    }
    
    var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    var contextPool: AgoraEduContextPool
    var subRoom: AgoraEduSubRoomContext?
    private var boardWidget: AgoraBaseWidget?
    private(set) weak var delegate: AgoraBoardUIControllerDelegate?
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: AgoraBoardUIControllerDelegate? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    func saveBoard() {
        if let message = AgoraBoardWidgetSignal.SaveBoard.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        UIApplication.shared.windows[0].endEditing(true)
    }
    
    // for subVC
    func onViewWillActive() {
        contextPool.media.registerMediaEventHandler(self)
        widgetController.add(self)
        
        guard widgetController.getWidgetActivity(kBoardWidgetId) else {
            delegate?.onBoardActiveStateChanged(isActive: false)
            return
        }
        delegate?.onBoardActiveStateChanged(isActive: true)
        
        setUp()
        joinBoardWidget()
    }
    
    func onGrantedUsersChanged(oldList: Array<String>,
                               newList: Array<String>) {
        let localUser = contextPool.user.getLocalUserInfo()
        if localUser.userRole == .teacher {
            localGranted = true
        } else {
            localGranted = newList.contains(localUser.userUuid)
        }
        
        if let insertList = oldList.insert(from: newList) {
            delegate?.onBoardGrantedUserListAdded(userList: insertList)
        }
        
        if let deletedList = oldList.delete(from: newList) {
            delegate?.onBoardGrantedUserListRemoved(userList: deletedList)
        }
    }
    
    func onViewWillInactive() {
        contextPool.media.unregisterMediaEventHandler(self)
        
        widgetController.remove(self)
        
        deinitBoardWidget()
    }
}

// MARK: - AgoraUIActivity
extension AgoraBoardUIController: AgoraUIActivity {
    func viewWillActive() {
        onViewWillActive()
    }
    
    func viewWillInactive() {
        onViewWillInactive()
    }
}

// MARK: - private
private extension AgoraBoardUIController {
    func joinBoardWidget() {
        guard let boardConfig = widgetController.getWidgetConfig(kBoardWidgetId),
              self.boardWidget == nil else {
            return
        }
        
        let widget = widgetController.create(boardConfig)
        widgetController.add(self,
                             widgetId: boardConfig.widgetId)
        
        let group = AgoraUIGroup()
        widget.view.backgroundColor = group.color.board_bg_color
        widget.view.layer.borderColor = group.color.board_border_color
        widget.view.layer.borderWidth = group.frame.board_border_width
        widget.view.layer.cornerRadius = group.frame.board_corner_radius
        widget.view.layer.masksToBounds = true
        
        view.addSubview(widget.view)
        boardWidget = widget

        widget.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        if let message = AgoraBoardWidgetSignal.JoinBoard.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    func deinitBoardWidget() {
        boardWidget?.view.removeFromSuperview()
        boardWidget = nil
        widgetController.remove(self,
                                widgetId: kBoardWidgetId)
    }
    
    func setUp() {
        guard let props = contextPool.room.getRoomProperties(),
              let stageState = props["stage"] as? Int else {
            return
        }
        if stageState == 1 {
            delegate?.onStageStateChanged(stageOn: true)
        } else {
            delegate?.onStageStateChanged(stageOn: false)
        }
    }
    
    func handleAudioMixing(_ data: AgoraBoardWidgetAudioMixingRequestData) {
        var contextError: AgoraEduContextError?
        switch data.requestType {
        case .start:
            contextError = contextPool.media.startAudioMixing(filePath: data.filePath,
                                                              loopback: data.loopback,
                                                              replace: data.replace,
                                                              cycle: data.cycle)
        case .stop:
            contextError = contextPool.media.stopAudioMixing()
        case .setPosition:
            contextError = contextPool.media.setAudioMixingPosition(position: data.position)
        default:
            break
        }
        
        if let error = contextError,
           let message = AgoraBoardWidgetSignal.AudioMixingStateChanged(AgoraBoardWidgetAudioMixingChangeData(stateCode: 714,
                                                                                                              errorCode: error.code)).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    func handlePhotoNoAuth(_ result: FcrBoardWidgetSnapshotResult) {
        switch result {
        case .savedToAlbum:
            AgoraToast.toast(msg: "fcr_savecanvas_tips_save_successfully".agedu_localized(),
                             type: .success)
        case .noAlbumAuth:
            let action = AgoraAlertAction(title: "fcr_savecanvas_tips_save_failed_sure".agedu_localized(), action: nil)
            AgoraAlertModel()
                .setMessage("fcr_savecanvas_tips_save_failed_tips".agedu_localized())
                .addAction(action: action)
                .show(in: self)
        case .failureToSave:
            AgoraToast.toast(msg: "fcr_savecanvas_tips_save_failed".agedu_localized(),
                             type: .error)
        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraBoardUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
            return
        }
        
        switch signal {
        case .BoardAudioMixingRequest(let requestData):
            handleAudioMixing(requestData)
        case .GetBoardGrantedUsers(let list):
            grantedUsers = list
        case .OnBoardSaveResult(let result):
            handlePhotoNoAuth(result)
        default:
            break
        }
    }
}

extension AgoraBoardUIController: AgoraWidgetActivityObserver {
    func onWidgetActive(_ widgetId: String) {
        guard widgetId == kBoardWidgetId else {
            return
        }
        delegate?.onBoardActiveStateChanged(isActive: true)
        
        joinBoardWidget()
    }
    
    func onWidgetInactive(_ widgetId: String) {
        guard widgetId == kBoardWidgetId else {
            return
        }
        delegate?.onBoardActiveStateChanged(isActive: false)
        
        deinitBoardWidget()
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraBoardUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        onViewWillActive()
    }
    
    func onRoomPropertiesUpdated(changedProperties: [String : Any],
                                 cause: [String : Any]?,
                                 operatorUser: AgoraEduContextUserInfo?) {
        // 讲台开关
        guard let stageState = changedProperties["stage"] as? Int else {
            return
        }
        if stageState == 1 {
            delegate?.onStageStateChanged(stageOn: true)
        } else {
            delegate?.onStageStateChanged(stageOn: false)
        }
    }
    
    func onRoomPropertiesDeleted(keyPaths: [String],
                                 cause: [String : Any]?,
                                 operatorUser: AgoraEduContextUserInfo?) {
        
    }
}

// MARK: - AgoraEduSubRoomHandler
extension AgoraBoardUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        onViewWillActive()
        
        let localUserInfo = contextPool.user.getLocalUserInfo()
        
        guard !localGranted,
              localUserInfo.userRole != .teacher else {
            return
        }
        
        let type = AgoraBoardWidgetSignal.UpdateGrantedUsers(.add([localUserInfo.userUuid]))

        if let message = type.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    func onSubRoomClosed() {
        deinitBoardWidget()
    }
}

// MARK: - AgoraEduMediaHandler
extension AgoraBoardUIController: AgoraEduMediaHandler {
    public func onAudioMixingStateChanged(stateCode: Int,
                                          errorCode: Int) {
        let data = AgoraBoardWidgetAudioMixingChangeData(stateCode: stateCode,
                                                         errorCode: errorCode)
        if let message = AgoraBoardWidgetSignal.AudioMixingStateChanged(data).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
}

extension Array where Element == String {
    func insert(from: [String]) -> [String]? {
        var insertArray = [String]()
    
        for item in from {
            guard !self.contains(item) else {
                continue
            }
            
            insertArray.append(item)
        }
        
        if insertArray.count == 0 {
            return nil
        } else {
            return insertArray
        }
    }
    
    func delete(from: [String]) -> [String]? {
        var deleteArray = [String]()
        
        for item in self {
            guard !from.contains(item) else {
                continue
            }
            
            deleteArray.append(item)
        }
        
        if deleteArray.count == 0 {
            return nil
        } else {
            return deleteArray
        }
    }
}
