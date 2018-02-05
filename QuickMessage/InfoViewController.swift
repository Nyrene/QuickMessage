//
//  InfoViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 2/2/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit

class InfoViewController:UIViewController {
    
    override func viewDidLoad() {
        // background view
        let thisImage = UIImage(named: "background_3.jpg")
        let backgroundColor = UIColor(patternImage: thisImage!)
        self.view.backgroundColor = backgroundColor

    }
    
    @IBAction func BackBtnPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
