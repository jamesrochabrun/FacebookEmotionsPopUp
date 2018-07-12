//
//  ViewController.swift
//  FacebookEmotionsPopUp
//
//  Created by James Rochabrun on 7/3/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpLongGesture()
    }
    
    let iconsContainerView: UIView = {
        
        let container = UIView()
        container.backgroundColor = .white
        let iconHeight: CGFloat = 50
        
        let arrangedSubviews = [UIColor.red, .blue, .purple, .yellow, .green, .orange].map { (color) -> UIView in
            let v = UIImageView()
            v.backgroundColor = color
            v.layer.cornerRadius = iconHeight / 2
            v.isUserInteractionEnabled = true
            return v
        }
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fillEqually
        
        /// configuratiosn options
        let padding: CGFloat = 8
        
        let numIcons: CGFloat = CGFloat(stackView.arrangedSubviews.count)
        // we need to add the padding as a constant + for the width
        let totalPadding = (numIcons + 1) * padding
        let containerWidth: CGFloat = numIcons * iconHeight + totalPadding
        let containerHeigth: CGFloat = iconHeight + 2 * padding

        stackView.spacing = padding
        stackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        container.addSubview(stackView)
        
        container.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeigth)
        container.layer.cornerRadius = container.frame.height / 2
        
        // shadow
        container.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.5
        /// moving the shadow to the bottom
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.borderColor = UIColor.black.cgColor
        container.layer.borderWidth = 1.0
        
        stackView.frame = container.frame
        
        return container
    }()
    
    private func setUpLongGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        view.addGestureRecognizer(longPress)
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
        
        let pressedLocation = gesture.location(in: self.iconsContainerView)
        
        /// keep track of the Y coordinate in the full screen
        let fixedYLocation = CGPoint(x: pressedLocation.x, y: self.iconsContainerView.frame.height / 2)
        
        let hitTestView = iconsContainerView.hitTest(fixedYLocation, with: nil)
        
        if hitTestView is UIImageView {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                let stackView = self.iconsContainerView.subviews.first
                stackView?.subviews.forEach { imageView in
                    imageView.transform = .identity
                }
                
                hitTestView?.transform = CGAffineTransform(translationX: 0, y: -50)
            })
        }
    }
    
    private func handleGestureBegan(_ gesture: UILongPressGestureRecognizer) {
        
        view.addSubview(iconsContainerView)
        
        let pressedLocation = gesture.location(in: self.view)
        let centeredX = (view.frame.width - iconsContainerView.frame.width) / 2
        
        iconsContainerView.alpha = 0
        self.iconsContainerView.transform = CGAffineTransform(translationX: centeredX, y: pressedLocation.y)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.iconsContainerView.alpha = 1
            self.iconsContainerView.transform = CGAffineTransform(translationX: centeredX, y: pressedLocation.y - self.iconsContainerView.frame.height)
        }) { (_) in }
    }
    
    private func handleGestureEnd(_ gesture: UILongPressGestureRecognizer) {
        // clean up the animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let stackView = self.iconsContainerView.subviews.first
            stackView?.subviews.forEach { imageView in
                imageView.transform = .identity
            }
            self.iconsContainerView.transform = self.iconsContainerView.transform.translatedBy(x: 0, y: self.iconsContainerView.frame.height)
            self.iconsContainerView.alpha = 0
        }, completion: { (_) in
            self.iconsContainerView.removeFromSuperview()
        })
    }
}















