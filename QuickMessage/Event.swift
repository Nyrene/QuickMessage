//
//  Event.swift
//  QuickMessage
//
//  Created by Rachael Little on 1/5/18.
//  Copyright © 2018 Rachael Little. All rights reserved.
//

import Foundation
import CoreData
/*
 
 
 core data info:
 will have attributes:
    title
    occurence date
    [string: messages]
    string uniqueID
    String:ContactIDs - pull contact information from 
 
 
 
 
 
 
    if location:
        double: latitude
        double: longitude
        double: coords(not sure why this is here if we have lat and long, but it was in the old project)
        TDI:^ look into that
        double: radius
        bool alertIfInsideArea
            ^only alerts if the user is inside the selected area, otherwise, outside
        actual address(if possible?)
        if not possible, address string
 
 
 
 */
