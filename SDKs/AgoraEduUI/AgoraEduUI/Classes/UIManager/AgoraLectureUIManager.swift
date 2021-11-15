//
//  AgoraEduUI+Lecture.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/22.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import AudioToolbox
import AgoraExtApp
import AgoraWidget

/// 房间控制器:
/// 用以处理全局状态和子控制器之间的交互关系
class AgoraLectureUIManager: AgoraUIManager {
    private let region: String
    private let roomType: AgoraEduContextRoomType = .lecture
    /// 视图部分，支持feature的UI交互显示
    /** 容器视图，用以保持比例*/
    private var contentView: UIView!
    /** 工具栏*/
    private var toolsView: AgoraRoomToolstView!
    /** 画笔工具*/
    private var brushToolButton: AgoraRoomToolZoomButton!
    /// 控制器部分，除了视图显示，还包含和SDK之间的事件及数据交互
    /** 房间状态 控制器*/
    private var stateController: AgoraRoomStateUIController!
    /** 远程视窗渲染 控制器*/
    private var renderController: AgoraPaintingRenderUIController!
    /** 白板的渲染 控制器*/
    private var whiteBoardController: AgoraPaintingBoardUIController!
    /// 弹窗控制器
    /** 控制器遮罩层，用来盛装控制器和处理手势触发消失事件*/
    private var ctrlMaskView: UIView!
    /** 弹出显示的控制widget视图*/
    private weak var ctrlView: UIView? {
        willSet {
            if let view = ctrlView {
                ctrlView?.removeFromSuperview()
                ctrlMaskView.isHidden = true
            }
            if let view = newValue {
                ctrlMaskView.isHidden = false
                self.view.addSubview(view)
            }
        }
    }
    /** 工具箱 控制器*/
    private lazy var toolBoxViewController: AgoraToolBoxUIController = {
        let vc = AgoraToolBoxUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 画板工具 控制器*/
    private lazy var brushToolsViewController: AgoraBoardToolsUIController = {
        let vc = AgoraBoardToolsUIController(context: contextPool)
        vc.delegate = self
        self.addChild(vc)
        return vc
    }()
    /** 聊天窗口 控制器*/
    private var messageController: AgoraBaseWidget?
    /** 设置界面 控制器*/
    private lazy var settingViewController: AgoraSettingUIController = {
        let vc = AgoraSettingUIController(context: contextPool)
        self.addChild(vc)
        return vc
    }()
    
    private var loadingView: AgoraAlertView?
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(contextPool: AgoraEduContextPool,
         region: String) {
        self.region = region
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = contextPool
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contextPool.room.joinClassroom()
        
        createViews()
        createConstrains()
        contextPool.room.registerEventHandler(self)
        contextPool.user.registerEventHandler(self)
    }
}

// MARK: - Actions
extension AgoraLectureUIManager {
    @objc func onClickBrushTools(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            toolsView.deselectAll()
            ctrlView = brushToolsViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.right.equalTo()(brushToolButton.mas_left)?.offset()(-7)
                make?.bottom.equalTo()(brushToolButton)?.offset()(-10)
            }
        } else {
            ctrlView = nil
        }
    }
    
    @objc func onClickCtrlMaskView(_ sender: UITapGestureRecognizer) {
        toolsView.deselectAll()
        brushToolButton.isSelected = false
        ctrlView = nil
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraLectureUIManager: AgoraEduRoomHandler {
    // 连接状态
    public func onConnectionState(_ state: AgoraEduContextConnectionState) {
        switch state {
        case .aborted:
            // 踢出
            loadingView?.removeFromSuperview()
            AgoraUtils.showToast(message: AgoraKitLocalizedString("LoginOnAnotherDeviceText"))
            contextPool.room.leaveRoom()
        case .connecting:
            if loadingView == nil {
                self.loadingView = AgoraUtils.showLoading(message: AgoraKitLocalizedString("LoaingText"),
                                                          shared: true)
            }
        case .disconnected, .reconnecting:
            if loadingView == nil {
                self.loadingView = AgoraUtils.showLoading(message: AgoraKitLocalizedString("ReconnectingText"),
                                                          shared: true)
            }
        case .connected:
            loadingView?.removeFromSuperview()
        }
    }
    
    func onClassroomJoined() {
        initWidgets()
    }
    
    func onShowErrorInfo(_ error: AgoraEduContextError) {
        AgoraUtils.showToast(message: error.message)
    }
}

// MARK: - AgoraEduRoomHandler
extension AgoraLectureUIManager: AgoraEduUserHandler {
    func onKickedOut() {
        let btnLabel = AgoraAlertLabelModel()
        btnLabel.text = AgoraKitLocalizedString("SureText")
        let btnModel = AgoraAlertButtonModel()
        
        btnModel.titleLabel = btnLabel
        btnModel.tapActionBlock = { [weak self] (index) -> Void in
            self?.contextPool.room.leaveRoom()
        }
        AgoraUtils.showAlert(imageModel: nil,
                             title: AgoraKitLocalizedString("KickOutNoticeText"),
                             message: AgoraKitLocalizedString("KickOutText"),
                             btnModels: [btnModel])
    }
    
    func onShowUserReward(_ user: AgoraEduContextUserInfo) {
        
    }
}

// MARK: - AgoraToolListViewDelegate
extension AgoraLectureUIManager: AgoraRoomToolsViewDelegate {
    func toolsViewDidSelectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        brushToolButton.isSelected = false
        switch tool {
        case .setting:
            ctrlView = settingViewController.view
            ctrlView?.mas_makeConstraints { make in
                make?.width.equalTo()(201)
                make?.height.equalTo()(281)
                make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                make?.centerY.equalTo()(toolsView)
            }
        case .message:
            if let message = messageController {
                message.widgetDidReceiveMessage("max")
                
                ctrlView = message.containerView
                ctrlView?.mas_remakeConstraints { make in
                    make?.right.equalTo()(toolsView.mas_left)?.offset()(-7)
                    make?.centerY.equalTo()(toolsView)
                    make?.width.equalTo()(200)
                    make?.height.equalTo()(287)
                }
            }
        default: break
        }
    }
    
    func toolsViewDidDeselectTool(_ tool: AgoraRoomToolstView.AgoraRoomToolType) {
        ctrlView = nil
    }
}
// MARK: - PaintingToolBoxViewDelegate
extension AgoraLectureUIManager: AgoraToolBoxUIControllerDelegate {
    func toolBoxDidSelectTool(_ tool: AgoraToolBoxToolType) {
        toolsView.deselectAll()
        ctrlView = nil
        switch tool {
        case .cloudStorage:
            // 云盘工具操作
            
            break
        case .saveBoard: break
        case .record: break
        case .vote: break
        case .countDown: break
        case .answerSheet: // 答题器
            guard let extAppInfos = contextPool.extApp.getExtAppInfos(),
                  let info = extAppInfos.first(where: {$0.appIdentifier == "io.agora.answerSheet"}) else {
                return
            }
            contextPool.extApp.willLaunchExtApp(info.appIdentifier)
        default: break
        }
    }
}

// MARK: - AgoraBoardToolsUIControllerDelegate
extension AgoraLectureUIManager: AgoraBoardToolsUIControllerDelegate {
    func brushToolsViewDidBrushChanged(_ tool: AgoraBoardToolItem) {
        brushToolButton.setImage(tool.image(self))
    }
}

// MARK: - PaintingBoardUIControllerDelegate
extension AgoraLectureUIManager: AgoraPaintingBoardUIControllerDelegate {
    func controller(_ controller: AgoraPaintingBoardUIController,
                    didUpdateBoard permission: Bool) {
        // 当白板变为未授权时，弹窗取消
        if !permission,
           let view = ctrlView,
           view == brushToolsViewController.view {
            ctrlView = nil
        }
        
        brushToolButton.isHidden = !permission
    }
}

// MARK: - Creations
private extension AgoraLectureUIManager {
    func createViews() {
        view.backgroundColor = .black
        
        contentView = UIView(frame: self.view.bounds)
        contentView.backgroundColor = UIColor(rgb: 0xECECF1)
        view.addSubview(contentView)
        
        stateController = AgoraRoomStateUIController(context: contextPool)
        stateController.themeColor = UIColor(rgb: 0x1D35AD)
        addChild(stateController)
        contentView.addSubview(stateController.view)
        
        whiteBoardController = AgoraPaintingBoardUIController(context: contextPool)
        whiteBoardController.delegate = self
        contentView.addSubview(whiteBoardController.view)
        
        renderController = AgoraPaintingRenderUIController(context: contextPool)
        renderController.themeColor = UIColor(rgb: 0x75C0FE)
        addChild(renderController)
        contentView.addSubview(renderController.view)
        
        ctrlMaskView = UIView(frame: .zero)
        ctrlMaskView.isHidden = true
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(onClickCtrlMaskView(_:)))
        ctrlMaskView.addGestureRecognizer(tap)
        contentView.addSubview(ctrlMaskView)
        
        brushToolButton = AgoraRoomToolZoomButton(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: 44,
                                                        height: 44))
        brushToolButton.isHidden = true
        brushToolButton.setImage(AgoraUIImage(object: self,
                                              name: "ic_brush_pencil"))
        brushToolButton.addTarget(self,
                                  action: #selector(onClickBrushTools(_:)),
                                  for: .touchUpInside)
        contentView.addSubview(brushToolButton)
        
        toolsView = AgoraRoomToolstView(frame: .zero)
        toolsView.tools = [.setting, .message]
        toolsView.delegate = self
        contentView.addSubview(toolsView)
    }
    
    func initWidgets() {
        guard let widgetInfos = contextPool.widget.getWidgetInfos() else {
            return
        }
        
        if let message = createChatWidget() {
            messageController = message
            message.addMessageObserver(self)
            contentView.addSubview(message.containerView)
        }
    }
    
    func createConstrains() {
        let width = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let height = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        if width/height > 667.0/375.0 {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.height.equalTo()(height)
                make?.width.equalTo()(height * 16.0/9.0)
            }
        } else {
            contentView.mas_makeConstraints { make in
                make?.center.equalTo()(contentView.superview)
                make?.width.equalTo()(width)
                make?.height.equalTo()(width * 9.0/16.0)
            }
        }
        stateController.view.mas_makeConstraints { make in
            make?.top.left().right().equalTo()(stateController.view.superview)
            make?.height.equalTo()(20)
        }
        renderController.view.mas_makeConstraints { make in
            make?.left.right().equalTo()(renderController.view.superview)
            make?.top.equalTo()(stateController.view.mas_bottom)
            make?.height.equalTo()(AgoraFit.scale(80))
        }
        whiteBoardController.view.mas_makeConstraints { make in
            make?.top.equalTo()(renderController.view.mas_bottom)
            make?.left.right().bottom().equalTo()(whiteBoardController.view.superview)
        }
        ctrlMaskView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(self.view)
        }
        brushToolButton.mas_makeConstraints { make in
            make?.right.equalTo()(-9)
            make?.bottom.equalTo()(-14)
            make?.width.height().equalTo()(AgoraFit.scale(46))
        }
        toolsView.mas_makeConstraints { make in
            make?.right.equalTo()(brushToolButton)
            make?.centerY.equalTo()(toolsView.superview)
        }
    }
}

// MARK: - AgoraWidgetDelegate
extension AgoraLectureUIManager: AgoraWidgetDelegate {
    func widget(_ widget: AgoraBaseWidget,
                didSendMessage message: String) {
        switch widget.widgetId {
        case "AgoraChatWidget":
            if let dic = message.json(),
               let isMin = dic["isMinSize"] as? Bool,
               isMin{
                ctrlView == nil
            }
        case "HyChatWidget":
            if message == "min" {
                ctrlView == nil
            }
        default:
            break
        }
    }
}
