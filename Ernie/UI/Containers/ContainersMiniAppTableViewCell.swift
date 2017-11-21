//
//  ContainersMiniAppTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 11/21/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class ContainersMiniAppTableViewCell: NSTableCellView
{
    @IBOutlet weak var miniAppNameLabel: NSTextField!
    
    func configureForMiniApp(_ miniApp: MiniApp)
    {
        self.miniAppNameLabel.stringValue = miniApp.miniAppName ?? "<No Name>"
    }
}
