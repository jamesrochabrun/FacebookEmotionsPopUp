//
//  ViewController.swift
//  FacebookEmotionsPopUp
//
//  Created by James Rochabrun on 7/3/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FacebookEmotionsPopUpViewDelegate {

   var facebookPopUp: FacebookEmotionsPopUpView<[UIColor]>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let items = [UIColor.red, .blue, .purple, .yellow, .green, .orange]
        facebookPopUp = FacebookEmotionsPopUpView(items: items, iconHeight: 50, padding: 8, parentView: self.view)
        facebookPopUp?.delegate = self
    }
}















