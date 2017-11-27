//
//  MiniAppsTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 11/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class MiniAppsTableViewCell: NSTableCellView
{
    @IBOutlet weak var miniAppNameLabel: NSTextField!
    
    func configureForMiniApp(_ app: MiniApp)
    {
        self.miniAppNameLabel.stringValue = app.miniAppName ?? "<No Name>"
    }
}
