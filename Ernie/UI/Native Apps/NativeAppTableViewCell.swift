//
//  NativeAppTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 11/16/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

protocol NativeAppTableViewCellDelegate
{
    func detailsButtonPressed(nativeApp: NativeApp)
}

class NativeAppTableViewCell: NSTableCellView
{
    var delegate: NativeAppTableViewCellDelegate?
    private var nativeApp: NativeApp?
    
    // MARK:- IBOutlet Properties
    
    @IBOutlet private weak var nativeAppName: NSTextField!
    @IBOutlet private weak var nativeAppFolder: NSTextField!
    @IBOutlet private weak var nativeAppDescription: NSTextField!
    @IBOutlet private weak var openButton: NSButton!
    @IBOutlet private weak var detailsButton: NSButton!
    
    // MARK:- Public methods
    
    /**
     Configures the cell's UI elements based on the given native app.
     */
    func configureForNativeApp(_ app: NativeApp)
    {
        self.nativeApp = app
        self.nativeAppName.stringValue = app.appName ?? ""
        self.nativeAppDescription.stringValue = app.appDescription ?? ""
        self.nativeAppFolder.stringValue = app.appFolder ?? ""
    }
    
    // MARK:- Event Handlers
    
    @IBAction func openButtonPressed(_ sender: NSButton)
    {
        print("OPEN")
    }
    
    /**
     When the details button is clicked, we need to inform the delegate that the user wants more information
     regarding the native app currently associated with this cell.
     */
    @IBAction func detailsButtonPressed(_ sender: NSButton)
    {
        if let nativeApp = self.nativeApp
        {
            self.delegate?.detailsButtonPressed(nativeApp: nativeApp)
        }
    }
}
