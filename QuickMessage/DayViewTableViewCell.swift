//
//  DayViewTableViewCell.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/8/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit

class DayViewTableViewCell: UITableViewCell {
    // reuse identifier: DayViewTableViewCell
    
    @IBOutlet var titleLbl:UILabel!
    @IBOutlet var dateLbl:UILabel!
    @IBOutlet var eventTypeLbl:UILabel!
    
    var isCalEvent:Bool = false
    
    var indexPath = IndexPath()
    
}
