//
//  File.swift
//  FacebookEmotionsPopUp
//
//  Created by James Rochabrun on 7/12/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit

/// All the work is internal just need to expose the delegate, if needed create a function to display any other UI in the controller
protocol FacebookEmotionsPopUpViewDelegate: class {}

class FacebookEmotionsPopUpView<T: Collection>: UIView {
    
    private var items: T!
    var iconHeight: CGFloat = 0
    var padding: CGFloat = 0
    var parentView: UIView?
    weak var delegate: FacebookEmotionsPopUpViewDelegate?
    
    convenience init(items: T, iconHeight: CGFloat, padding: CGFloat, parentView: UIView) {
        
        /// setting the frame of the container
        let totalPadding: CGFloat = CGFloat((items.count + 1)) * padding
        let containerWidth: CGFloat = CGFloat(items.count) * iconHeight + totalPadding
        let containerHeigth: CGFloat = iconHeight + 2 * padding
        let frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeigth)
        self.init(frame: frame)
        
        self.items = items
        self.iconHeight = iconHeight
        self.padding = padding
        self.backgroundColor = .white
        self.parentView = parentView
        self.setUpUI()
        self.setUpLongGesture(in: parentView)
    }
    
    private func setUpUI() {
        
        let arrangedSubviews = items.map { (item) -> UIView in
            let v = UIImageView()
            if let color = item as? UIColor {
                v.backgroundColor = color
            }
            if let image = item as? UIImage {
                v.image = image
            }
            v.layer.cornerRadius = iconHeight / 2
            v.isUserInteractionEnabled = true
            return v
        }
        self.setUpStackView(with: arrangedSubviews)
        
        self.layer.cornerRadius = self.frame.height / 2
        // shadow
        self.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.5
        /// moving the shadow to the bottom
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
    }
    
    private func setUpStackView(with arrangedSubviews: [UIView]) {
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        stackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        self.addSubview(stackView)
        stackView.frame = self.frame
    }
    
    private func setUpLongGesture(in parentView: UIView) {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        parentView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case .began: self.handleGestureBegan(gesture)
        case .ended: self.handleGestureEnd(gesture)
        case .changed: self.handleGestureChanged(gesture)
        default: break
        }
    }
    
    private func handleGestureChanged(_ gesture: UILongPressGestureRecognizer) {
        
        let pressedLocation = gesture.location(in: self)
        
        /// keep track of the Y coordinate in the full screen
        let fixedYLocation = CGPoint(x: pressedLocation.x, y: self.frame.height / 2)
        
        let hitTestView = self.hitTest(fixedYLocation, with: nil)
        
        if hitTestView is UIImageView {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                let stackView = self.subviews.first
                stackView?.subviews.forEach { imageView in
                    imageView.transform = .identity
                }
                
                hitTestView?.transform = CGAffineTransform(translationX: 0, y: -50)
            })
        }
    }
    
    private func handleGestureBegan(_ gesture: UILongPressGestureRecognizer) {
        
        guard let superView = parentView else { return }
        superView.addSubview(self)
        
        let pressedLocation = gesture.location(in: superView)
        let centeredX = (superView.frame.width - self.frame.width) / 2
        
        self.alpha = 0
        self.transform = CGAffineTransform(translationX: centeredX, y: pressedLocation.y)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(translationX: centeredX, y: pressedLocation.y - self.frame.height)
        }) { (_) in }
    }
    
    private func handleGestureEnd(_ gesture: UILongPressGestureRecognizer) {
        // clean up the animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let stackView = self.subviews.first
            stackView?.subviews.forEach { imageView in
                imageView.transform = .identity
            }
            self.transform = self.transform.translatedBy(x: 0, y: self.frame.height)
            self.alpha = 0
        }, completion: { (_) in
            self.removeFromSuperview()
        })
    }
}
