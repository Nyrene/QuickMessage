//
//  CalendarListCell.swift
//  TextHelper
//
//  Created by Rachael Little on 3/29/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit

class CalendarListCell:UITableViewCell {
    @IBOutlet var calendarName:UILabel!
    @IBOutlet var includeSwitch:UISwitch!
    
    override open func prepareForReuse() {
        if includeSwitch != nil {
            includeSwitch.isOn = false
        }
    }
}
