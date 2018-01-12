//
//  CalendarCell.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/7/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import UIKit
import EventKit

open class CalendarCell:UICollectionViewCell {
    
    @IBOutlet weak var dotMarkerLbl: UILabel!
    @IBOutlet var displayNum:UILabel!
    
    var ekEvents:[EKEvent] = []
    var events:[Event] = []
    var beginDate:Date = Date()
    
    override open func prepareForReuse() {
        ekEvents = []
        events = []
    }
    
}
