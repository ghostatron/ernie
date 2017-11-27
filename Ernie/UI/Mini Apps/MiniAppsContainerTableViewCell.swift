//
//  MiniAppsContainerTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 11/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class MiniAppsContainerTableViewCell: NSTableCellView
{
    @IBOutlet weak var containerNameLabel: NSTextField!
    
    func configureForContainer(_ container: Container)
    {
        self.containerNameLabel.stringValue = container.containerName ?? "<No Name>"
    }
}
