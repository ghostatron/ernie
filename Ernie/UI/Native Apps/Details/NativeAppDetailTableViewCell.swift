//
//  NativeAppsTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 11/20/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class NativeAppDetailTableViewCell: NSTableCellView
{
    @IBOutlet weak var miniAppNameLabel: NSTextField!
    @IBOutlet weak var miniAppDescriptionLabel: NSTextField!
    
    func configureForMiniApp(_ miniApp: MiniApp)
    {
        self.miniAppNameLabel.stringValue = miniApp.miniAppName ?? "<No Name>"
        self.miniAppDescriptionLabel.stringValue = miniApp.miniAppDescription ?? ""
    }
}
