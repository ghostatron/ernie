//
//  NativeAppTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 11/16/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class NativeAppTableViewCell: NSTableCellView
{
    // MARK:- IBOutlet Properties
    
    @IBOutlet private weak var nativeAppName: NSTextField!
    @IBOutlet private weak var nativeAppFolder: NSTextField!
    @IBOutlet private weak var nativeAppDescription: NSTextField!
    @IBOutlet private weak var openButton: NSButton!
    @IBOutlet private weak var detailsButton: NSButton!
    
    func configureForNativeApp(_ app: NativeApp)
    {
        
    }
    
    // MARK:- Event Handlers
    
    @IBAction func openButtonPressed(_ sender: NSButton)
    {
        print("OPEN")
    }
    
    @IBAction func detailsButtonPressed(_ sender: NSButton)
    {
        print("DETAILS")
    }
}
