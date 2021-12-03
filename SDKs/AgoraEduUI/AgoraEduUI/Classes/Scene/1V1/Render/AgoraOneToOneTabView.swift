//
//  AgoraOneToOneTabView.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/30.
//

import UIKit
import SwifterSwift

protocol AgoraOneToOneTabViewDelegate: NSObjectProtocol {
    func onChatTabSelectChanged(isSelected: Bool)
}

class AgoraOneToOneTabView: UIView {
    
    public weak var delegate: AgoraOneToOneTabViewDelegate?
    
    private var videoButton: UIButton!
    
    private var chatButton: UIButton!
    
    private var chatRemindLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateChatRemind(with count: Int) {
        if count == 0 {
            chatRemindLabel.isHidden = true
        } else if count > 99 {
            chatRemindLabel.text = "99+"
            chatRemindLabel.isHidden = false
        } else {
            chatRemindLabel.text = "\(count)"
            chatRemindLabel.isHidden = false
        }
    }
    
    @objc private func onClickVideoButton(_ sender: UIButton) {
        guard sender.isSelected == false else {
            return
        }
        sender.isSelected = true
        chatButton.isSelected = false
        videoButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        delegate?.onChatTabSelectChanged(isSelected: false)
    }
    
    @objc private func onClickChatButton(_ sender: UIButton) {
        guard sender.isSelected == false else {
            return
        }
        sender.isSelected = true
        videoButton.isSelected = false
        videoButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        chatButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        delegate?.onChatTabSelectChanged(isSelected: true)
    }
    
    private func createViews() {
        videoButton = UIButton(type: .custom)
        videoButton.isSelected = true
        videoButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        videoButton.setTitle("one_to_one_tab_video".ag_localizedIn("AgoraEduUI"),
                             for: .normal)
        videoButton.setTitleColor(UIColor(hex: 0x7B88A0),
                                  for: .normal)
        videoButton.setTitleColor(UIColor(hex: 0x191919),
                                  for: .selected)
        videoButton.addTarget(self,
                              action: #selector(onClickVideoButton(_:)),
                              for: .touchUpInside)
        self.addSubview(videoButton)
        
        chatButton = UIButton(type: .custom)
        chatButton.isSelected = false
        chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        chatButton.setTitle("one_to_one_tab_chat".ag_localizedIn("AgoraEduUI"),
                            for: .normal)
        chatButton.setTitleColor(UIColor(hex: 0x7B88A0),
                                 for: .normal)
        chatButton.setTitleColor(UIColor(hex: 0x191919),
                                 for: .selected)
        chatButton.addTarget(self,
                             action: #selector(onClickChatButton(_:)),
                             for: .touchUpInside)
        self.addSubview(chatButton)
        
        chatRemindLabel = UILabel()
        chatRemindLabel.isHidden = true
        chatRemindLabel.textColor = .white
        chatRemindLabel.isUserInteractionEnabled = false
        self.addSubview(chatRemindLabel)
    }
    
    private func createConstrains() {
        videoButton.mas_makeConstraints { make in
            make?.left.top().bottom().equalTo()(0)
            make?.width.equalTo()(50)
        }
        chatButton.mas_makeConstraints { make in
            make?.left.equalTo()(videoButton.mas_right)
            make?.top.bottom().equalTo()(0)
            make?.width.equalTo()(50)
        }
        chatRemindLabel.mas_makeConstraints { make in
            make?.height.equalTo()(14)
            make?.width.greaterThanOrEqualTo()(14)
            make?.top.right().equalTo()(chatButton)
        }
    }
}
