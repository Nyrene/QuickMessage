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
    
    @IBOutlet var displayNum:UILabel!
    
    var ekEvents:[EKEvent] = []
    
}
