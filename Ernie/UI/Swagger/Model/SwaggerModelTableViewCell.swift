//
//  SwaggerModelTableViewCell.swift
//  Ernie
//
//  Created by Randy Haid on 12/18/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Cocoa

protocol SwaggerModelTableViewCellDelegate
{
    func deleteButtonPressed(sender: SwaggerModelTableViewCell, model: SwaggerObjectModel?)
}

class SwaggerModelTableViewCell: NSTableCellView
{
    private(set) var model: SwaggerObjectModel?
    @IBOutlet weak var modelInfoLabel: NSTextField!
    var delegate: SwaggerModelTableViewCellDelegate?
    
    func configureFor(model: SwaggerObjectModel)
    {
        self.model = model
        self.modelInfoLabel.stringValue = model.modelName
    }
    
    @IBAction func deleteButtonPressed(_ sender: NSButton)
    {
        self.delegate?.deleteButtonPressed(sender: self, model: self.model)
    }
}
