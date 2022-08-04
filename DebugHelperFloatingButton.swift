//
//  DebugHelperFloatingButton.swift
//
//  Created by Purananunaka, Chanon on 26/7/2565 BE.
//  Copyright © 2565 BE . All rights reserved.
//

import Foundation
import UIKit

// MARK:- Move to Model
// MARK:- Model -> Core -> CommonUI -> ____
//public struct DebugCellData {
//  public enum RequestType {
//    case API(data: API)
//    case FIREBASE_TRACKING(data: FirebaseTracking)
//    case APPFLYER(data: AppFlyer)
//  }
//
//  public struct API {
//    public enum HTTPMethod: String, Codable {
//      case GET = "GET"
//      case POST = "POST"
//      case PUT = "PUT"
//      case DELETE = "DELETE"
//    }
//
//    public struct Response {
//      public var statusCode: String
//      public var headers: String
//      public var body: String
//      public init(statusCode: String,
//                  headers: String,
//                  body: String) {
//        self.statusCode = statusCode
//        self.headers = headers
//        self.body = body
//      }
//    }
//
//    public var requestHTTPMethod: HTTPMethod
//    public var url: String
//    public var headers: String
//    public var body: String
//    public var response: Response
//    public var result: String
//    public init(requestHTTPMethod: HTTPMethod,
//                url: String,
//                headers: String,
//                body: String,
//                response: Response,
//                result: String) {
//      self.requestHTTPMethod = requestHTTPMethod
//      self.url = url
//      self.headers = headers
//      self.body = body
//      self.response = response
//      self.result = result
//    }
//  }
//
//  public struct FirebaseTracking {
//    public var eventName: String
//    public var parameters: [String: Any]?
//    public init(eventName: String,
//                parameters: [String: Any]?) {
//      self.eventName = eventName
//      self.parameters = parameters
//    }
//  }
//
//  public struct AppFlyer {
//    public var eventName: String
//    public var parameters: [String: Any]?
//    public init(eventName: String,
//                parameters: [String: Any]?) {
//      self.eventName = eventName
//      self.parameters = parameters
//    }
//  }
//
//  public var requestType: RequestType
//  public init(requestType: RequestType) {
//    self.requestType = requestType
//  }
//}

// import Model

public class DebugHelperFloatingButton: UIView {
  static let shared = DebugHelperFloatingButton()
  private let screenSize: CGRect = UIScreen.main.bounds
  public var debugCellDatas: [DebugCellData]? = []
  
  private var tableView: UITableView!
  private var isShowing: Bool = false
  private var tableheightX: CGFloat = 100
  public var parentVC: UIViewController?
  private var pointToParent = CGPoint(x: 0, y: 0)
  
  @IBInspectable private var rowHeight: CGFloat = 40
  @IBInspectable private var tableHeaderView: CGFloat = 44
  @IBInspectable private var rowBackgroundColor: UIColor = .white
  @IBInspectable private var listHeight: CGFloat = 150
  
  private var debugButton: UIButton = {
    let button = UIButton()
    button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .small)
    let smallBoldEllipsis = UIImage(systemName: "chevron.down.circle.fill", withConfiguration: config)
    smallBoldEllipsis?.withRenderingMode(.alwaysTemplate)
    smallBoldEllipsis?.withTintColor(.green)
    button.setImage(smallBoldEllipsis, for: .normal)
    return button
  }()
  
  private var backgroundView: UIView = {
    return UIView()
  }()
  
  // Init
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  public func showDebugFloatingButton(vc: UIViewController) {
    self.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    parentVC = vc
    parentVC?.view.addSubview(self)
    parentVC?.view.bringSubviewToFront(self)
    self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlerDraggable)))
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(touchAction),
                                           name: .deviceDidShakeNotification,
                                           object: nil)
    self.setupUI()
  }
  
  private func setupUI() {
    debugButton.translatesAutoresizingMaskIntoConstraints = false
    addSubview(debugButton)
    debugButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchAction)))
    
//    UIApplication.shared.keyWindow?.addSubview(self)
//    UIApplication.shared.keyWindow?.bringSubviewToFront(self)
//    UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
    
    let debugButtonConstraint = [
      debugButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
      debugButton.topAnchor.constraint(equalTo: topAnchor, constant: 0),
      debugButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
      debugButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
    ]
    NSLayoutConstraint.activate(debugButtonConstraint)
    self.setNeedsLayout()
    self.reloadInputViews()
  }
  
  private func showList() {
    debugCellDatas = DebugCellDatas.shared.getDebugCellDatas()
    guard let debugCellDatas = debugCellDatas else {
      return
    }
    
    if parentVC == nil {
      parentVC = self.parentViewController
    }
    
    pointToParent = getConvertedPoint(self, baseView: parentVC?.view)
    
    let count = CGFloat(debugCellDatas.count)
    if listHeight > rowHeight * count {
      self.tableheightX = rowHeight * count
    } else {
      self.tableheightX = rowHeight
    }
    
    tableView = UITableView(frame: CGRect(x: pointToParent.x,
                                          y: pointToParent.y,
                                          width: self.frame.width,
                                          height: self.frame.height))
    tableView.register(DebugTableViewCell.self, forCellReuseIdentifier: "DebugTableViewCell")
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    
    let headerView = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: tableView.frame.width,
                                          height: rowHeight))
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .small)
    let collapseButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let smallBoldUp = UIImage(systemName: "chevron.up.circle.fill", withConfiguration: config)
    smallBoldUp?.withRenderingMode(.alwaysTemplate)
    collapseButton.setImage(smallBoldUp, for: .normal)
    collapseButton.tintColor = .systemOrange
    collapseButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchAction)))
    let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let smallBoldXmark = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
    smallBoldXmark?.withRenderingMode(.alwaysTemplate)
    clearButton.setImage(smallBoldXmark, for: .normal)
    clearButton.tintColor = .systemRed
    clearButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearAction)))
    
    let headerStackView = UIStackView()
    headerStackView.axis = .horizontal
    headerStackView.distribution = .equalSpacing
    headerStackView.alignment = .trailing
    headerStackView.spacing = 4.0
    headerStackView.addArrangedSubview(collapseButton)
    headerStackView.addArrangedSubview(clearButton)
    headerStackView.translatesAutoresizingMaskIntoConstraints = false
    headerView.addSubview(headerStackView)
    let headerStackViewConstraint = [
      headerStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
      headerStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
      headerStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0)
    ]
    NSLayoutConstraint.activate(headerStackViewConstraint)
    
    tableView.tableHeaderView = headerView
    parentVC?.view.addSubview(tableView)
    isShowing = true
    
    UIView.animate(withDuration: 0.9,
                   delay: 0,
                   usingSpringWithDamping: 0.4,
                   initialSpringVelocity: 0.1,
                   options: .transitionFlipFromTop,
                   animations: { () -> Void in
                      self.tableView.frame = CGRect(x: self.screenSize.minX,
                                                    y: self.screenSize.minY,
                                                    width: self.screenSize.width,
                                                    height: self.screenSize.height)
                  }, completion: { (finish) -> Void in
                    self.layoutIfNeeded()
                  })
  }
  
  private func hideList() {
    UIView.animate(withDuration: 1.0,
                   delay: 0.4,
                   usingSpringWithDamping: 0.9,
                   initialSpringVelocity: 0.1,
                   options: .transitionFlipFromBottom,
                   animations: { () -> Void in
                    self.tableView.frame = CGRect(x: self.pointToParent.x,
                                                  y: self.pointToParent.y + self.frame.height,
                                                  width: 0,
                                                  height: 0)
    }, completion: { (didFinish) -> Void in
      self.tableView.removeFromSuperview()
      self.isShowing = false
    })
  }
  
  private func clearData() {
    debugCellDatas?.removeAll()
    tableView.reloadData()
    DebugCellDatas.shared.removeAllDataInDebugCellDatas()
  }
  
  func getConvertedPoint(_ targetView: UIView, baseView: UIView?)->CGPoint{
    var pnt = targetView.frame.origin
    if nil == targetView.superview{
      return pnt
    }
    var superView = targetView.superview
    while superView != baseView{
      pnt = superView!.convert(pnt, to: superView!.superview)
      if nil == superView!.superview{
        break
      } else {
        superView = superView!.superview
      }
    }
    return superView!.convert(pnt, to: baseView)
  }
  
  @objc private func touchAction() {
    isShowing ? hideList() : showList()
  }
  
  @objc private func clearAction() {
    clearData()
  }
  
  @objc public func handlerDraggable(gesture: UIPanGestureRecognizer) {
    let location = gesture.location(in: parentVC?.view)
    let draggedView = gesture.view
    draggedView?.center = location
    
    if gesture.state == .ended {
      if self.frame.midX >= (parentVC?.view.layer.frame.width)! / 2 {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
          self.center.x = (self.parentVC?.view.layer.frame.width)! - 40
        }, completion: nil)
      } else {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.center.x = 40
        }, completion: nil)
      }
    }
  }
}

extension DebugHelperFloatingButton: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    UIView.animate(withDuration: 0.3) {
      tableView.performBatchUpdates(nil)
    }
  }
  
  public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if let cell = self.tableView.cellForRow(at: indexPath) as? DebugTableViewCell {
      cell.hideDetailView()
    }
  }
}

extension DebugHelperFloatingButton: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let debugCellDatas = debugCellDatas {
      if debugCellDatas.isEmpty {
        return 0
      } else {
        return debugCellDatas.count
      }
    } else {
      return 0
    }
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebugTableViewCell") as? DebugTableViewCell,
          let debugCellData = debugCellDatas?[indexPath.row] else {
      return UITableViewCell()
    }
    cell.setUI(with: debugCellData)
    return cell
  }
}

extension NSMutableAttributedString {
  var fontSize:CGFloat { return 14 }
  var boldFont:UIFont { return UIFont(name: "AvenirNext-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
  var normalFont:UIFont { return UIFont(name: "AvenirNext-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    
  func bold(_ value:String) -> NSMutableAttributedString {
    let attributes:[NSAttributedString.Key: Any] = [.font: boldFont]
    self.append(NSAttributedString(string: value, attributes:attributes))
    return self
  }
  
  func boldWithColor(_ value: String, color: UIColor) -> NSMutableAttributedString {
    let attributes:[NSAttributedString.Key: Any] = [
      .font: boldFont,
      .foregroundColor: color
    ]
    self.append(NSAttributedString(string: value, attributes:attributes))
    return self
  }
    
  func normal(_ value: String) -> NSMutableAttributedString {
    let attributes:[NSAttributedString.Key: Any] = [.font: normalFont]
    self.append(NSAttributedString(string: value, attributes:attributes))
    return self
  }
  
  /* Other styling methods */
  func boldHighlight(_ value:String, backgroundColor: UIColor) -> NSMutableAttributedString {
    let attributes:[NSAttributedString.Key : Any] = [
      .font: boldFont,
      .foregroundColor: UIColor.white,
      .backgroundColor: backgroundColor
    ]
    self.append(NSAttributedString(string: value, attributes:attributes))
    return self
  }
  
  func orangeHighlight(_ value:String) -> NSMutableAttributedString {
    let attributes:[NSAttributedString.Key : Any] = [
      .font :  normalFont,
      .foregroundColor: UIColor.white,
      .backgroundColor: UIColor.orange
    ]
    self.append(NSAttributedString(string: value, attributes:attributes))
    return self
  }
    
  func blackHighlight(_ value:String) -> NSMutableAttributedString {
    let attributes:[NSAttributedString.Key : Any] = [
      .font:  normalFont,
      .foregroundColor: UIColor.white,
      .backgroundColor: UIColor.black
    ]
    self.append(NSAttributedString(string: value, attributes:attributes))
    return self
  }
    
  func underlined(_ value:String) -> NSMutableAttributedString {
    let attributes:[NSAttributedString.Key : Any] = [
      .font:  normalFont,
      .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    self.append(NSAttributedString(string: value, attributes:attributes))
    return self
  }
}

extension Notification.Name {
  static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
  open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
    }
  }
}
