//
//  AgoraBoardUIController.swift
//  AgoraEduUI
//
//  Created by LYY on 2021/12/9.
//

import AgoraEduCore
import AgoraWidget

protocol FcrBoardUIComponentDelegate: NSObjectProtocol {
    func onBoardActiveStateChanged(isActive: Bool)
    func onStageStateChanged(stageOn: Bool)
    func onBoardGrantedUserListRemoved(userList: [String])
    func onBoardGrantedUserListAdded(userList: [String])
}

extension FcrBoardUIComponentDelegate {
    func onStageStateChanged(stageOn: Bool) {
        
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        
    }
    
    func onBoardGrantedUserListAdded(userList: [String]) {
        
    }
}

class FcrBoardUIComponent: FcrUIComponent {
    private(set) var grantedUsers = [String]() {
        didSet {
            onGrantedUsersChanged(oldList: oldValue,
                                  newList: grantedUsers)
        }
    }
    
    var localGranted = false {
        didSet {
            guard localGranted != oldValue else {
                return
            }
            guard userController.getLocalUserInfo().userRole != .teacher else {
                return
            }
            let msgKey = localGranted ? "fcr_netless_board_granted" : "fcr_netless_board_ungranted"
            let type: AgoraToastType = localGranted ? .notice : .error
            
            AgoraToast.toast(message: msgKey.agedu_localized(),
                             type: type)
        }
    }
    
    private(set) var roomController: AgoraEduRoomContext
    private(set) var userController: AgoraEduUserContext
    private(set) var widgetController: AgoraEduWidgetContext
    private(set) var mediaController: AgoraEduMediaContext
    
    var subRoom: AgoraEduSubRoomContext?
    
    private var roomProperties: [String: Any]? {
        get {
            guard let subRoom = subRoom else {
                return roomController.getRoomProperties()
            }
            
            return subRoom.getSubRoomProperties()
        }
    }
    private var boardWidget: AgoraBaseWidget?
    private(set) weak var delegate: FcrBoardUIComponentDelegate?
    
    /** Data */
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         widgetController: AgoraEduWidgetContext,
         mediaController: AgoraEduMediaContext,
        subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrBoardUIComponentDelegate? = nil) {
        self.roomController = roomController
        self.userController = userController
        self.widgetController = widgetController
        self.mediaController = mediaController
        self.subRoom = subRoom
        
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    func saveBoard() {
        sendSignal(.saveBoard)
    }
    
    func updateBoardRatio() {
        sendSignal(.changeRatio)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIConfig.netlessBoard.backgroundColor
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            roomController.registerRoomEventHandler(self)
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
        mediaController.registerMediaEventHandler(self)
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
        let localUser = userController.getLocalUserInfo()
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
        mediaController.unregisterMediaEventHandler(self)
        
        widgetController.remove(self)
        
        deinitBoardWidget()
    }
}

// MARK: - AgoraUIActivity
extension FcrBoardUIComponent: AgoraUIActivity {
    func viewWillActive() {
        onViewWillActive()
    }
    
    func viewWillInactive() {
        onViewWillInactive()
    }
}

// MARK: - private
private extension FcrBoardUIComponent {
    func sendSignal(_ signal: AgoraBoardWidgetSignal) {
        guard let message = signal.toMessageString() else {
            return
        }
        widgetController.sendMessage(toWidget: kBoardWidgetId,
                                     message: message)
    }
    
    func joinBoardWidget() {
        guard UIConfig.netlessBoard.enable,
              let boardConfig = widgetController.getWidgetConfig(kBoardWidgetId),
              self.boardWidget == nil else {
            return
        }
        
        let widget = widgetController.create(boardConfig)
        widgetController.add(self,
                             widgetId: boardConfig.widgetId)
        
        let config = UIConfig.netlessBoard
        widget.view.layer.borderColor = config.borderColor.cgColor
        widget.view.layer.borderWidth = config.borderWidth
        
        view.addSubview(widget.view)
        boardWidget = widget

        widget.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        sendSignal(.joinBoard)
    }
    
    func deinitBoardWidget() {
        boardWidget?.view.removeFromSuperview()
        boardWidget = nil
        widgetController.remove(self,
                                widgetId: kBoardWidgetId)
    }
    
    func setUp() {
        guard let stageState = roomProperties?["stage"] as? Int else {
            return
        }
        
        if stageState == 1 {
            delegate?.onStageStateChanged(stageOn: true)
        } else {
            delegate?.onStageStateChanged(stageOn: false)
        }
    }
    
    func handleAudioMixing(_ type: AgoraBoardWidgetAudioMixingRequestType) {
        var contextError: AgoraEduContextError?
        switch type {
        case .start(let data):
            contextError = mediaController.startAudioMixing(filePath: data.filePath,
                                                            loopback: data.loopback,
                                                            replace: data.replace,
                                                            cycle: data.cycle)
        case .pause:
            break
        case .resume:
            break
        case .stop:
            contextError = mediaController.stopAudioMixing()
        case .setPosition(let position):
            contextError = mediaController.setAudioMixingPosition(position: position)
        }
        
        guard let error = contextError else {
            return
        }
        let data = AgoraBoardWidgetAudioMixingChangeData(stateCode: 714,
                                                         errorCode: error.code)
        let signal = AgoraBoardWidgetSignal.audioMixingStateChanged(data)
        sendSignal(signal)
    }
    
    func handlePhotoNoAuth(_ result: FcrBoardWidgetSnapshotResult) {
        switch result {
        case .savedToAlbum:
            AgoraToast.toast(message: "fcr_savecanvas_tips_save_successfully".agedu_localized(),
                             type: .notice)
        case .noAlbumAuth:
            let action = AgoraAlertAction(title: "fcr_savecanvas_tips_save_failed_sure".agedu_localized(), action: nil)
            AgoraAlertModel()
                .setMessage("fcr_savecanvas_tips_save_failed_tips".agedu_localized())
                .addAction(action: action)
                .show(in: self)
        case .failureToSave:
            AgoraToast.toast(message: "fcr_savecanvas_tips_save_failed".agedu_localized(),
                             type: .error)
        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrBoardUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
            return
        }
        
        switch signal {
        case .boardAudioMixingRequest(let requestData):
            handleAudioMixing(requestData)
        case .getBoardGrantedUsers(let list):
            grantedUsers = list
        case .onBoardSaveResult(let result):
            handlePhotoNoAuth(result)
        default:
            break
        }
    }
}

extension FcrBoardUIComponent: AgoraWidgetActivityObserver {
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
extension FcrBoardUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        onViewWillActive()
    }
    
    func onRoomPropertiesUpdated(changedProperties: [String : Any],
                                 cause: [String : Any]?,
                                 operatorUser: AgoraEduContextUserInfo?) {
        guard let stageState = roomProperties?["stage"] as? Int else {
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
extension FcrBoardUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        onViewWillActive()
        
        let localUserInfo = userController.getLocalUserInfo()
        
        guard !localGranted,
              localUserInfo.userRole != .teacher else {
            return
        }
        
        let signal = AgoraBoardWidgetSignal.updateGrantedUsers(.add([localUserInfo.userUuid]))
        
        sendSignal(signal)
    }
    
    func onSubRoomClosed() {
        deinitBoardWidget()
    }
}

// MARK: - AgoraEduMediaHandler
extension FcrBoardUIComponent: AgoraEduMediaHandler {
    public func onAudioMixingStateChanged(stateCode: Int,
                                          errorCode: Int) {
        let data = AgoraBoardWidgetAudioMixingChangeData(stateCode: stateCode,
                                                         errorCode: errorCode)
        let signal = AgoraBoardWidgetSignal.audioMixingStateChanged(data)
        sendSignal(signal)
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
