//
//  DebugTableCellView.swift
//
//  Created by Purananunaka, Chanon on 26/7/2565 BE.
//  Copyright © 2565 BE . All rights reserved.
//

import UIKit
// import Model

final class DebugTableCellView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private let title = UILabel()
  private let dateTimeLabel = UILabel()
  
  func setUI(with titleText: String, name: String, color :UIColor = .black) {
    title.attributedText = NSMutableAttributedString()
                            .bold(titleText)
                            .normal(name)
    title.textColor = color
    title.numberOfLines = 0
    title.lineBreakMode = .byWordWrapping
  }
  
  func setUI(requestType: DebugCellData.RequestType) {
    switch requestType {
    case .API(let data):
      let color: UIColor = {
        switch data.requestHTTPMethod {
        case .GET: return .systemBlue
        case .POST: return .systemGreen
        case .PUT: return .systemOrange
        case .DELETE: return .systemRed
        }
      }()
      title.attributedText = NSMutableAttributedString()
                              .boldHighlight(" \(data.requestHTTPMethod.rawValue) ", backgroundColor: color)
                              .normal(" \(data.url)")
      title.layer.masksToBounds = true
      title.numberOfLines = 0
      title.lineBreakMode = .byWordWrapping
      dateTimeLabel.attributedText = NSMutableAttributedString().bold(data.dateTime)
    case .FIREBASE_TRACKING(let data):
      title.attributedText = NSMutableAttributedString()
                              .boldWithColor("FIREBASE ", color: .systemOrange)
                              .normal("event: \(data.eventName)")
      title.layer.masksToBounds = true
      title.numberOfLines = 0
      title.lineBreakMode = .byWordWrapping
      dateTimeLabel.attributedText = NSMutableAttributedString().bold(data.dateTime)
    case .APPFLYER(let data):
      title.attributedText = NSMutableAttributedString()
                              .boldWithColor("APPS", color: .systemGreen)
                              .boldWithColor("FLYER ", color: .systemBlue)
                              .normal("event: \(data.eventName)")
      title.layer.masksToBounds = true
      title.numberOfLines = 0
      title.lineBreakMode = .byWordWrapping
      dateTimeLabel.attributedText = NSMutableAttributedString().bold(data.dateTime)
    }
  }
  
  func commonInit() {
    addSubview(title)
    addSubview(dateTimeLabel)
    title.translatesAutoresizingMaskIntoConstraints = false
    dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
    
    title.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
    title.bottomAnchor.constraint(equalTo: dateTimeLabel.topAnchor).isActive = true
    title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
    title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
    
    let dateTimeLabelConstraint = [
      dateTimeLabel.topAnchor.constraint(equalTo: title.bottomAnchor),
      dateTimeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
      dateTimeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
    ]
    NSLayoutConstraint.activate(dateTimeLabelConstraint)
  }
}

final class DebugTableDetailView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
      
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
      
  private let title = UILabel()
  private let button = UIButton()

  func setUI(with string: String, image: UIImage) {
    title.attributedText = NSMutableAttributedString().normal(string)
    title.numberOfLines = 0
    title.lineBreakMode = .byWordWrapping
    let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .small)
    let smallBoldDoc = UIImage(systemName: "doc.on.doc.fill", withConfiguration: config)
    smallBoldDoc?.withRenderingMode(.alwaysTemplate)
    button.setImage(smallBoldDoc, for: .normal)
    button.tintColor = .systemGreen
    button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchCopyAction)))
  }
      
  func commonInit() {
    addSubview(title)
    addSubview(button)
    button.widthAnchor.constraint(equalToConstant: 30).isActive = true
    button.heightAnchor.constraint(equalToConstant: 30).isActive = true
    title.translatesAutoresizingMaskIntoConstraints = false
    button.translatesAutoresizingMaskIntoConstraints = false
    let buttonConstraint = [
      button.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
      button.bottomAnchor.constraint(equalTo: title.topAnchor, constant: -8),
      button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
      button.trailingAnchor.constraint(equalTo: title.leadingAnchor, constant: -8)
    ]
    NSLayoutConstraint.activate(buttonConstraint)
    title.topAnchor.constraint(equalTo: button.bottomAnchor, constant: -8).isActive = true
    title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
    title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
    title.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
  
  @objc private func touchCopyAction() {
    UIPasteboard.general.string = title.text
    let alert = UIAlertController(title: "Copy", message: title.text, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default))
    self.parentViewController?.present(alert, animated: false, completion: nil)
  }
}
