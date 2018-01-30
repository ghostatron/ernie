//
//  SwaggerMethodFromSwiftViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/30/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class SwaggerMethodFromSwiftViewController: NSViewController
{
    @IBOutlet weak var swiftMethodTextField: NSTextField!
    private(set) var method: SwaggerMethod?
    var modalDelegate: ModalDialogDelegate?
    
    @IBAction func okButtonPressed(_ sender: NSButton)
    {
        self.method = SwaggerMethod.methodFromSwiftMethodSignature(self.swiftMethodTextField.stringValue)
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
}
