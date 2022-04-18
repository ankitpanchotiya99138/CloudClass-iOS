//
//  AgoraStudentsRenderUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/9.
//

import UIKit
import AudioToolbox
import FLAnimatedImage
import AgoraEduContext
import AgoraUIBaseViews

class AgoraStudentsRenderUIController: UIViewController {
    
    private weak var delegate: AgoraRenderUIControllerDelegate?
    
    private let kItemGap: CGFloat = AgoraFit.scale(2)
    private let kItemMaxCount: CGFloat = 4
        
    var collectionView: UICollectionView!    
    
    var leftButton: UIButton!
    
    var rightButton: UIButton!
    
    var dataSource = [AgoraRenderMemberModel]()
    
    var contextPool: AgoraEduContextPool!
    
    init(context: AgoraEduContextPool,
         delegate: AgoraRenderUIControllerDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.contextPool = context
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViews()
        createConstraint()
        
        contextPool.user.registerUserEventHandler(self)
        contextPool.stream.registerStreamEventHandler(self)
        contextPool.room.registerRoomEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
    }
    
    public func renderViewForUser(with userId: String) -> UIView? {
        var view: UIView?
        let indexes = self.collectionView.indexPathsForVisibleItems
        for (i, model) in self.dataSource.enumerated() {
            if model.uuid == userId {
                if let indexPath = indexes.first(where: {$0.row == i}) {
                    view = self.collectionView.cellForItem(at: indexPath)
                }
                break
            }
        }
        return view
    }
    
    public func setRenderEnable(with userId: String, rendEnable: Bool) {
        if let model = self.dataSource.first(where: {$0.uuid == userId}) {
            model.rendEnable = rendEnable
        }
    }
}
// MARK: - Private
private extension AgoraStudentsRenderUIController {
    func setup() {
        if let students = contextPool.user.getCoHostList()?.filter({$0.userRole == .student}) {
            var temp = [AgoraRenderMemberModel]()
            for student in students {
                let model = AgoraRenderMemberModel.model(with: contextPool.user,
                                                         streamController: contextPool.stream,
                                                         uuid: student.userUuid,
                                                         name: student.userName)
                temp.append(model)
            }
            dataSource = temp
            self.reloadData()
        }
    }
    
    func reloadData() {
        let sigleWidth = (self.view.bounds.width + kItemGap) / kItemMaxCount - kItemGap
        let floatCount = CGFloat(self.dataSource.count)
        let count = floatCount > kItemMaxCount ? kItemMaxCount: floatCount
        let width = (sigleWidth + kItemGap) * count - kItemGap
        if collectionView.width != width {
            collectionView.mas_updateConstraints { make in
                make?.width.equalTo()(width)
            }
        }
        let pageEnable = floatCount <= kItemMaxCount
        self.leftButton.isHidden = pageEnable
        self.rightButton.isHidden = pageEnable
        collectionView.reloadData()
    }
    
    func updateStream(stream: AgoraEduContextStreamInfo?) {
        guard stream?.videoSourceType != .screen else {
            return
        }
        
        for model in self.dataSource {
            if stream?.owner.userUuid == model.uuid {
                model.updateStream(stream)
            }
        }
    }
    
    func showRewardAnimation() {
        guard let url = Bundle.agoraEduUI().url(forResource: "img_reward", withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        let imageView = FLAnimatedImageView()
        imageView.animatedImage = animatedImage
        imageView.loopCompletionBlock = {[weak imageView] (loopCountRemaining) -> Void in
            imageView?.removeFromSuperview()
        }
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(imageView)
            imageView.mas_makeConstraints { make in
                make?.center.equalTo()(0)
                make?.width.equalTo()(AgoraFit.scale(238))
                make?.height.equalTo()(AgoraFit.scale(238))
            }
        }
        // sounds
        guard let rewardUrl = Bundle.agoraEduUI().url(forResource: "sound_reward", withExtension: "mp3") else {
            return
        }
        var soundId: SystemSoundID = 0;
        AudioServicesCreateSystemSoundID(rewardUrl as CFURL,
                                         &soundId);
        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, {
            (soundId, clientData) -> Void in
            AudioServicesDisposeSystemSoundID(soundId)
        }, nil)
        AudioServicesPlaySystemSound(soundId)
    }
}
// MARK: - Action
extension AgoraStudentsRenderUIController {
    @objc func onClickLeft(_ sender: UIButton) {
        let idxs = collectionView.indexPathsForVisibleItems
        if let min = idxs.min(),
           min.row > 0 {
            let previous = IndexPath(row: min.row - 1 , section: 0)
            collectionView.scrollToItem(at: previous, at: .left, animated: true)
        }
    }
    
    @objc func onClickRight(_ sender: UIButton) {
        let idxs = collectionView.indexPathsForVisibleItems
        if let max = idxs.max(),
           max.row < dataSource.count - 1 {
            let next = IndexPath(row: max.row + 1 , section: 0)
            collectionView.scrollToItem(at: next, at: .right, animated: true)
        }
    }
}
// MARK: - AgoraEduUserHandler
extension AgoraStudentsRenderUIController: AgoraEduUserHandler {
    func onCoHostUserListAdded(userList: [AgoraEduContextUserInfo],
                               operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            if user.userRole == .student {
                let model = AgoraRenderMemberModel.model(with: contextPool.user,
                                                         streamController: contextPool.stream,
                                                         uuid: user.userUuid,
                                                         name: user.userName)
                dataSource.append(model)
            }
        }
        reloadData()
    }
    
    func onCoHostUserListRemoved(userList: [AgoraEduContextUserInfo],
                                 operatorUser: AgoraEduContextUserInfo?) {
        for user in userList {
            if user.userRole == .student {
                dataSource.removeAll(where: {$0.uuid == user.userUuid})
            }
        }
        reloadData()
    }
    
    func onUserHandsWave(userUuid: String,
                         duration: Int,
                         payload: [String : Any]?) {
        if let model = dataSource.first(where: {$0.uuid == userUuid}) {
            model.isHandsUp = true
        }
    }
    
    func onUserHandsDown(userUuid: String,
                         payload: [String : Any]?) {
        if let model = dataSource.first(where: {$0.uuid == userUuid}) {
            model.isHandsUp = false
        }
    }
    
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operatorUser: AgoraEduContextUserInfo?) {
        if let model = dataSource.first(where: {$0.uuid == user.userUuid}) {
            model.rewardCount = rewardCount
        }
        showRewardAnimation()
    }
}
// MARK: - AgoraEduStreamHandler
extension AgoraStudentsRenderUIController: AgoraEduStreamHandler {
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        self.updateStream(stream: stream)
    }
    
    func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                         operatorUser: AgoraEduContextUserInfo?) {
        self.updateStream(stream: stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        self.updateStream(stream: stream.toEmptyStream())
    }
}
// MARK: - AgoraEduMediaHandler
extension AgoraStudentsRenderUIController: AgoraEduMediaHandler {
    func onVolumeUpdated(volume: Int,
                         streamUuid: String) {
        for model in self.dataSource {
            if streamUuid == model.streamID {
                model.volume = volume
            }
        }
    }
}
// MARK: - AgoraEduRoomHandler
extension AgoraStudentsRenderUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        self.setup()
    }
}
// MARK: - AgoraRenderMemberViewDelegate
extension AgoraStudentsRenderUIController: AgoraRenderMemberViewDelegate {
    func memberViewRender(memberView: AgoraRenderMemberView,
                          in view: UIView,
                          renderID: String) {
        let renderConfig = AgoraEduContextRenderConfig()
        renderConfig.mode = .hidden
        renderConfig.isMirror = true
        contextPool.stream.setRemoteVideoStreamSubscribeLevel(streamUuid: renderID,
                                                              level: .low)
        contextPool.media.startRenderVideo(view: view,
                                           renderConfig: renderConfig,
                                           streamUuid: renderID)
    }

    func memberViewCancelRender(memberView: AgoraRenderMemberView, renderID: String) {
        contextPool.media.stopRenderVideo(streamUuid: renderID)
    }
}

// MARK: - UICollectionView Call Back
extension AgoraStudentsRenderUIController: UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: AgoraRenderMemberCell.self,
                                                      for: indexPath)
        let item = self.dataSource[indexPath.row]
        cell.renderView.setModel(model: item, delegate: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let current = cell as? AgoraRenderMemberCell {
            current.renderView.setModel(model: nil, delegate: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let model = self.dataSource[indexPath.row]
        if let current = cell as? AgoraRenderMemberCell {
            current.renderView.setModel(model: model, delegate: self)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let u = dataSource[indexPath.row]
        if let cell = collectionView.cellForItem(at: indexPath),
           let UUID = u.uuid {
            delegate?.onClickMemberAt(view: cell,
                                      UUID: UUID)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (view.bounds.width + kItemGap) / kItemMaxCount - kItemGap
        return CGSize(width: itemWidth, height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kItemGap
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}
// MARK: - Creations
private extension AgoraStudentsRenderUIController {
    func createViews() {
        let ui = AgoraUIGroup()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(cellWithClass: AgoraRenderMemberCell.self)
        view.addSubview(collectionView)
        
        leftButton = UIButton(type: .custom)
        leftButton.isHidden = true
        leftButton.layer.cornerRadius = ui.frame.render_left_right_button_radius
        leftButton.clipsToBounds = true
        leftButton.backgroundColor = ui.color.render_left_right_button_color
        leftButton.addTarget(self,
                             action: #selector(onClickLeft(_:)),
                             for: .touchUpInside)
        leftButton.setImage(UIImage.agedu_named("ic_member_arrow_left"),
                            for: .normal)
        view.addSubview(leftButton)
        
        rightButton = UIButton(type: .custom)
        rightButton.isHidden = true
        rightButton.layer.cornerRadius = ui.frame.render_left_right_button_radius
        rightButton.clipsToBounds = true
        rightButton.backgroundColor = ui.color.render_left_right_button_color
        rightButton.addTarget(self,
                              action: #selector(onClickRight(_:)),
                              for: .touchUpInside)
        rightButton.setImage(UIImage.agedu_named("ic_member_arrow_right"),
                             for: .normal)
        view.addSubview(rightButton)
    }
    
    func createConstraint() {
        collectionView.mas_makeConstraints { make in
            make?.centerX.top().bottom().equalTo()(0)
            make?.width.equalTo()(0)
        }
        leftButton.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
        }
        rightButton.mas_makeConstraints { make in
            make?.right.top().bottom().equalTo()(collectionView)
            make?.width.equalTo()(24)
        }
    }
}
