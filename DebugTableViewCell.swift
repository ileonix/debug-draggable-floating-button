//
//  DebugTableViewCell.swift
//
//  Created by Purananunaka, Chanon on 26/7/2565 BE.
//  Copyright © 2565 BE . All rights reserved.
//

import UIKit
// import Model

final class DebugTableViewCell: UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    commonInit()
  }
      
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private let containerView = UIStackView()
  private let cellView = DebugTableCellView()
  private let detailView = DebugTableDetailView()
  
  func setUI(with data: DebugCellData) {
    switch data.requestType {
    case .API(let _data):
//      cellView.setUI(with: "[\(data.requestHTTPMethod.rawValue)] " ,name: "\(data.url)", color: .systemBlue)
      cellView.setUI(requestType: data.requestType)
      detailView.setUI(with: "\(_data)", image: Asset.SuperApp.icX.image)
      let color: UIColor = {
        switch _data.requestHTTPMethod {
        case .GET: return .systemBlue
        case .POST: return .systemGreen
        case .PUT: return .systemOrange
        case .DELETE: return .systemRed
        }
      }()
      containerView.backgroundColor = color.withAlphaComponent(0.5)
      containerView.layer.borderColor = color.cgColor
    case .FIREBASE_TRACKING(let _data):
//      cellView.setUI(with: "FIREBASE ", name: "evet: \(data.eventName)", color: .systemOrange)
      cellView.setUI(requestType: data.requestType)
      detailView.setUI(with: "\(_data.parameters)", image: Asset.SuperApp.icX.image)
      let color: UIColor = .systemOrange
      containerView.backgroundColor = color.withAlphaComponent(0.5)
      containerView.layer.borderColor = color.cgColor
    case .APPFLYER(let _data):
//      cellView.setUI(with: "APPSFLYER ", name: "event: \(data.eventName)", color: .systemGreen)
      cellView.setUI(requestType: data.requestType)
      detailView.setUI(with: "\(_data.parameters)", image: Asset.SuperApp.icX.image)
      let color: UIColor = .systemGray
      containerView.backgroundColor = color.withAlphaComponent(0.5)
      containerView.layer.borderColor = color.cgColor
    }
    containerView.layer.borderWidth = 1
    containerView.cornerRadius = 8
    containerView.clipsToBounds = true
  }
  
  func commonInit() {
    selectionStyle = .none
    detailView.isHidden = true
    containerView.axis = .vertical

    contentView.addSubview(containerView)
    containerView.addArrangedSubview(cellView)
    containerView.addArrangedSubview(detailView)
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
    cellView.translatesAutoresizingMaskIntoConstraints = false
    detailView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 4).isActive = true
    containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -4).isActive = true
    containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4).isActive = true
    containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
  }
}

extension DebugTableViewCell {
  var isDetailViewHidden: Bool {
    return detailView.isHidden
  }

  func showDetailView() {
    detailView.isHidden = false
  }

  func hideDetailView() {
    detailView.isHidden = true
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    if isDetailViewHidden, selected {
      showDetailView()
    } else {
      hideDetailView()
    }
  }
}
