//
//  SwaggerMethodProductsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/3/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodProductsViewController: NSViewController
{
    @IBOutlet weak var gifCheckBox: NSButton!
    @IBOutlet weak var jpgCheckBox: NSButton!
    @IBOutlet weak var jsonCheckBox: NSButton!
    @IBOutlet weak var pdfCheckBox: NSButton!
    @IBOutlet weak var pngCheckBox: NSButton!
    @IBOutlet weak var xmlCheckBox: NSButton!
    
    var modalDelegate: ModalDialogDelegate?
    var products: [SwaggerProductEnum] = []
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureForProducts()
    }
    
    private func configureForProducts()
    {
        // Start with all checkbox unselected.
        self.gifCheckBox.state = NSControl.StateValue.off
        self.jpgCheckBox.state = NSControl.StateValue.off
        self.jsonCheckBox.state = NSControl.StateValue.off
        self.pdfCheckBox.state = NSControl.StateValue.off
        self.pngCheckBox.state = NSControl.StateValue.off
        self.xmlCheckBox.state = NSControl.StateValue.off
        
        // Turn them back on if they have an entry in |self.products|.
        for product in self.products
        {
            switch product
            {
            case .GIF:
                self.gifCheckBox.state = NSControl.StateValue.on
            case .JPG:
                self.jpgCheckBox.state = NSControl.StateValue.on
            case .JSON:
                self.jsonCheckBox.state = NSControl.StateValue.on
            case .PDF:
                self.pdfCheckBox.state = NSControl.StateValue.on
            case .PNG:
                self.pngCheckBox.state = NSControl.StateValue.on
            case .XML:
                self.xmlCheckBox.state = NSControl.StateValue.on
            }
        }
    }
    
    // MARK:- Event Handlers
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func okButtonPressed(_ sender: Any)
    {
        // Update the products array based on which checkboxes are selected.
        self.products = []
        if self.gifCheckBox.state == NSControl.StateValue.on
        {
            self.products.append(.GIF)
        }
        if self.jpgCheckBox.state == NSControl.StateValue.on
        {
            self.products.append(.JPG)
        }
        if self.jsonCheckBox.state == NSControl.StateValue.on
        {
            self.products.append(.JSON)
        }
        if self.pdfCheckBox.state == NSControl.StateValue.on
        {
            self.products.append(.PDF)
        }
        if self.pngCheckBox.state == NSControl.StateValue.on
        {
            self.products.append(.PNG)
        }
        if self.xmlCheckBox.state == NSControl.StateValue.on
        {
            self.products.append(.XML)
        }
        
        // Tell the delegate we're done. K byeee
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
}
