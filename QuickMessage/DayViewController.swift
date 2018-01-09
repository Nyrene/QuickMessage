//
//  DayViewController.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/7/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit


class DayViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    override func viewDidLoad() {
        //
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisCell = UITableViewCell()
        return thisCell
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
}
