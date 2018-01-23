//
//  SwaggerMethodResponseTableCell.swift
//  Ernie
//
//  Created by Randy Haid on 1/23/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

protocol SwaggerMethodResponseTableCellDelegate
{
    func deleteButtonPressed(sender: SwaggerMethodResponseTableCell, response: SwaggerResponse?)
}

class SwaggerMethodResponseTableCell: NSTableCellView
{
    @IBOutlet weak var responseInfoTextField: NSTextField!
    private(set) var response: SwaggerResponse?
    var delegate: SwaggerMethodResponseTableCellDelegate?
    
    func configureForResponse(_ response: SwaggerResponse)
    {
        self.response = response
        self.responseInfoTextField.stringValue = "\(response.responseHttpCode) - \(response.responseDataType.stringValue())"
    }
    
    @IBAction func deleteButtonPressed(_ sender: NSButton)
    {
        self.delegate?.deleteButtonPressed(sender: self, response: self.response)
    }
}
