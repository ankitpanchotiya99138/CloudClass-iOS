//
//  FcrSubWindowRenderUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/3.
//

import UIKit

protocol FcrWindowRenderUIControllerDelegate: NSObjectProtocol {
    func renderUIController(_ controller: FcrWindowRenderUIController,
                            didDataSouceCountUpdated count: Int)
}

class FcrWindowRenderUIController: UIViewController {
    // Data
    private(set) var dataSource: [FcrWindowRenderViewState] {
        didSet {
            showScrollButtons()
            
            delegate?.renderUIController(self,
                                         didDataSouceCountUpdated: dataSource.count)
        }
    }
    
    // backup for `onDidEndDisplaying`
    private var deletedBackup = [Int: FcrWindowRenderViewState]()
    
    private let maxShowItemCount: Int
    private let reverseItem: Bool
    
    // Views
    private(set) var layout: UICollectionViewFlowLayout
    private(set) lazy var prevButton = UIButton(type: .custom)
    private(set) lazy var nextButton = UIButton(type: .custom)
    
    let collectionView: UICollectionView
    
    weak var delegate: FcrWindowRenderUIControllerDelegate?
    
    init(dataSource: [FcrWindowRenderViewState]? = nil,
         layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout(),
         maxShowItemCount: Int = Int.max,
         reverseItem: Bool = false) {
        if let source = dataSource {
            self.dataSource = source
        } else {
            self.dataSource = [FcrWindowRenderViewState]()
        }
        
        self.layout = layout
        self.maxShowItemCount = maxShowItemCount
        self.reverseItem = reverseItem
        self.collectionView = UICollectionView(frame: .zero,
                                               collectionViewLayout: layout)
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
        showScrollButtons()
    }
    
    // UI
    func updateLayout(_ layout: UICollectionViewFlowLayout) {
        self.layout = layout
        updateViewFrame()
        collectionView.setCollectionViewLayout(layout,
                                               animated: false)
    }
    
    func scrollToTop() {
        var position: UICollectionView.ScrollPosition
        
        switch layout.scrollDirection {
        case .horizontal: position = .left
        case .vertical:   position = .top
        }
        
        let indexPath = IndexPath(item: 0,
                                  section: 0)
        
        collectionView.scrollToItem(at: indexPath,
                                    at: position,
                                    animated: false)
    }
    
    func getRenderView(userId: String) -> FcrWindowRenderView? {
        guard let index = dataSource.firstItemIndex(userId: userId) else {
            return nil
        }
        
        let indexPath = IndexPath(item: index,
                                  section: 0)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? FcrWindowRenderCell else {
            return nil
        }
        
        return cell.renderView
    }
    
    func updateVolume(streamId: String,
                      volume: Int) {
        guard let index = dataSource.firstItemIndex(streamId: streamId) else {
            return
        }
        
        let item = dataSource[index]
        
        guard item.isShow else {
            return
        }
        
        let indexPath = IndexPath(item: index,
                                  section: 0)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? FcrWindowRenderCell else {
            return
        }
        
        cell.renderView.updateVolume(volume)
    }
    
    func updateViewFrame() {
        let buttonWidth: CGFloat = 24
        let buttonHeight: CGFloat = buttonWidth
        
        switch layout.scrollDirection {
        case .horizontal:
            if reverseItem {
                collectionView.transform = CGAffineTransform(scaleX: -1,
                                                             y: 1)
            }
            
            prevButton.mas_makeConstraints { make in
                make?.left.top().bottom().equalTo()(0)
                make?.width.equalTo()(buttonWidth)
            }
            
            nextButton.mas_makeConstraints { make in
                make?.right.top().bottom().equalTo()(0)
                make?.width.equalTo()(buttonWidth)
            }
        case .vertical:
            if reverseItem {
                collectionView.transform = CGAffineTransform(scaleX: 1,
                                                             y: -1)
            }
            
            prevButton.mas_makeConstraints { make in
                make?.top.left().right().equalTo()(0)
                make?.height.equalTo()(buttonHeight)
            }
            
            nextButton.mas_makeConstraints { make in
                make?.bottom.left().right().equalTo()(0)
                make?.height.equalTo()(buttonHeight)
            }
        }
    }
    
    // Item operation
    func getItem(userId: String) -> FcrWindowRenderViewState? {
        let item = dataSource.firstItem(userId: userId)
        
        return item
    }
    
    func getItem(streamId: String) -> FcrWindowRenderViewState? {
        let item = dataSource.firstItem(streamId: streamId)
        
        return item
    }
    
    func addItem(_ item: FcrWindowRenderViewState) {
        if let data = item.data,
           let index = dataSource.firstItemIndex(userId: data.userId) {
            
            updateItem(item,
                       index: index)
        } else {
            let index = dataSource.count
            
            dataSource.insert(item,
                              at: index)

            let indexPath = IndexPath(item: index,
                                      section: 0)

            collectionView.insertItems(at: [indexPath])

            onDidAddItem(item)
        }
    }
    
    func updateItem(_ item: FcrWindowRenderViewState,
                    animation: Bool = true) {
        guard let data = item.data,
              let index = dataSource.firstItemIndex(userId: data.userId) else {
            return
        }
        
        updateItem(item,
                   index: index,
                   animation: animation)
    }
    
    func updateItem(_ item: FcrWindowRenderViewState,
                    index: Int,
                    animation: Bool = true) {
        let prevItem = dataSource[index]
        
        guard prevItem != item else {
            return
        }
        
        dataSource[index] = item
        
        let indexPath = IndexPath(item: index,
                                  section: 0)
        
        dataSource[index] = item
        
        if !(prevItem.isHide && item.isHide) {
            if animation {
                collectionView.reloadItems(at: [indexPath])
            } else {
                UIView.performWithoutAnimation {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        onDidUpdateItem(item)
    }
    
    func deleteItem(of userId: String) {
        guard let index = dataSource.firstItemIndex(userId: userId) else {
            return
        }
        
        deleteItem(of: index)
    }
    
    func deleteItem(of index: Int) {
        guard index >= 0 else {
            return
        }
        
        let item = dataSource[index]
        
        // backup for `onDidEndDisplaying`
        deletedBackup[index] = item
        
        let indexPath = IndexPath(item: index,
                                  section: 0)
        
        dataSource.remove(at: index)
        
        collectionView.deleteItems(at: [indexPath])
        
        onDidDeleteItem(item)
    }
    
    func onDidAddItem(_ item: FcrWindowRenderViewState) {
        
    }
    
    func onDidUpdateItem(_ item: FcrWindowRenderViewState) {
        
    }
    
    func onDidDeleteItem(_ item: FcrWindowRenderViewState) {
        
    }
    
    func onWillDisplayItem(_ item: FcrWindowRenderViewState,
                           renderView: FcrWindowRenderVideoView) {
        
    }
    
    func onDidEndDisplayingItem(_ item: FcrWindowRenderViewState,
                                renderView: FcrWindowRenderVideoView) {
        
    }
}

// MARK: - AgoraUIContentContainer
extension FcrWindowRenderUIController: AgoraUIContentContainer {
    func initViews() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false
        collectionView.isScrollEnabled = false
        collectionView.register(FcrWindowRenderCell.self,
                                forCellWithReuseIdentifier: FcrWindowRenderCell.cellId)
        
        view.addSubview(collectionView)
        
        prevButton.isHidden = true
        prevButton.addTarget(self,
                             action: #selector(onClickPrev(_:)),
                             for: .touchUpInside)
        
        view.addSubview(prevButton)
        
        nextButton.isHidden = true
        
        nextButton.addTarget(self,
                             action: #selector(onClickNext(_:)),
                             for: .touchUpInside)
        
        view.addSubview(nextButton)
    }
    
    func initViewFrame() {
        collectionView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        
        prevButton.clipsToBounds = true
        
        prevButton.setImage(UIImage.agedu_named("ic_member_arrow_left"),
                            for: .normal)
        
        prevButton.layer.cornerRadius = ui.frame.render_left_right_button_radius
        prevButton.backgroundColor = ui.color.render_left_right_button_color
        
        nextButton.clipsToBounds = true
        
        nextButton.setImage(UIImage.agedu_named("ic_member_arrow_right"),
                            for: .normal)
        
        nextButton.layer.cornerRadius = ui.frame.render_left_right_button_radius
        nextButton.backgroundColor = ui.color.render_left_right_button_color
    }
}

private extension FcrWindowRenderUIController {
    func showScrollButtons() {
        let isHidden = (dataSource.count <= maxShowItemCount)
        
        prevButton.isHidden = isHidden
        nextButton.isHidden = isHidden
    }
    
    func updateCell(_ cell: FcrWindowRenderCell,
                    with item: FcrWindowRenderViewState) {
        switch item {
        case .none:
            cell.maskImageView.isHidden = false
            cell.renderView.isHidden = true
        case .show(let data):
            cell.maskImageView.isHidden = true
            cell.renderView.isHidden = false
            
            updateRenderView(cell.renderView,
                             data: data)
        case .hide(let data):
            cell.maskImageView.isHidden = true
            cell.renderView.isHidden = true
        }
        
        guard reverseItem else {
            return
        }
        
        switch layout.scrollDirection {
        case .horizontal:
            cell.contentView.transform = CGAffineTransform(scaleX: -1,
                                                           y: 1)
        case .vertical:
            cell.contentView.transform = CGAffineTransform(scaleX: 1,
                                                           y: -1)
        }
    }
    
    func updateRenderView(_ renderView: FcrWindowRenderView,
                          data: FcrWindowRenderViewData) {
        renderView.nameLabel.text = data.userName
        
        switch data.videoState {
        case .none(let image):
            renderView.videoMaskView.isHidden = false
            renderView.videoMaskView.image = image
        case .hasStreamPublishPrivilege(let image):
            renderView.videoMaskView.isHidden = false
            renderView.videoMaskView.image = image
        case .mediaSourceOpen(let image):
            renderView.videoMaskView.isHidden = false
            renderView.videoMaskView.image = image
        case .both:
            renderView.videoMaskView.isHidden = true
        }
        
        switch data.audioState {
        case .none(let image):
            renderView.micView.imageView.image = image
            renderView.micView.updateVolume(0)
        case .hasStreamPublishPrivilege(let image):
            renderView.micView.imageView.image = image
            renderView.micView.updateVolume(0)
        case .mediaSourceOpen(let image):
            renderView.micView.imageView.image = image
            renderView.micView.updateVolume(0)
        case .both(let image):
            renderView.micView.imageView.image = image
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FcrWindowRenderUIController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FcrWindowRenderCell.cellId,
                                                      for: indexPath) as! FcrWindowRenderCell
        
        let item = dataSource[indexPath.item]
        
        updateCell(cell,
                   with: item)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath,
                                    animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let `cell` = cell as? FcrWindowRenderCell else {
            return
        }
        
        let item = dataSource[indexPath.item]
        
        onWillDisplayItem(item,
                          renderView: cell.renderView.videoView)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let `cell` = cell as? FcrWindowRenderCell else {
            return
        }
        
        print(">>>>>> indexPath item: \(indexPath.item)")
        
        // cell object changed also call this ‘didEndDisplaying’
        // but need to ignore this case
        let indexs = collectionView.indexPathsForVisibleItems
        
        for i in indexs {
            print(">>>>>> indexPath i: \(i.item)")
        }
        
        guard !indexs.contains(indexPath) else {
            return
        }
        
        var item: FcrWindowRenderViewState
        
        if let state = deletedBackup[indexPath.item] {
            item = state
            deletedBackup.removeValue(forKey: indexPath.item)
        } else {
            guard indexPath.item < dataSource.count else {
                return
            }
            
            item = dataSource[indexPath.item]
        }
        
        onDidEndDisplayingItem(item,
                               renderView: cell.renderView.videoView)
    }
}

// MARK: - Actions
extension FcrWindowRenderUIController {
    @objc func onClickPrev(_ sender: UIButton) {
        let indexs = collectionView.indexPathsForVisibleItems
        
        guard let min = indexs.min(),
              min.item > 0 else {
            return
        }
        
        var position: UICollectionView.ScrollPosition
        
        switch layout.scrollDirection {
        case .horizontal:
            position = .left
        case .vertical:
            position = .top
        }
        
        let previous = IndexPath(row: min.item - 1 ,
                                 section: 0)
        
        collectionView.scrollToItem(at: previous,
                                    at: position,
                                    animated: true)
    }
    
    @objc func onClickNext(_ sender: UIButton) {
        let indexs = collectionView.indexPathsForVisibleItems
        
        guard let max = indexs.max(),
              max.item < dataSource.count - 1 else {
            return
        }
        
        var position: UICollectionView.ScrollPosition
        
        switch layout.scrollDirection {
        case .horizontal:
            position = .right
        case .vertical:
            position = .bottom
        }
        
        let next = IndexPath(row: max.item + 1 ,
                             section: 0)
        
        collectionView.scrollToItem(at: next,
                                    at: position,
                                    animated: true)
    }
}

fileprivate extension Array where Element == FcrWindowRenderViewState {
    func firstItemIndex(userId: String) -> Int? {
        let index = firstIndex { (element) in
            guard let data = element.data else {
                return false
            }
            
            return (data.userId == userId)
        }
        
        return index
    }
    
    func firstItemIndex(streamId: String) -> Int? {
        let index = firstIndex { (element) in
            guard let data = element.data else {
                return false
            }
            
            return (data.streamId == streamId)
        }
        
        return index
    }
    
    func firstItem(userId: String) -> FcrWindowRenderViewState? {
        let item = first { (element) -> Bool in
            guard let data = element.data else {
                return false
            }
            
            return (data.userId == userId)
        }
        
        return item
    }
    
    func firstItem(streamId: String) -> FcrWindowRenderViewState? {
        let item = first { (element) -> Bool in
            guard let data = element.data else {
                return false
            }
            
            return (data.streamId == streamId)
        }
        
        return item
    }
}

