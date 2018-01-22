//
//  SwaggerMethodTagsViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/3/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class SwaggerMethodTagsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, SwaggerMethodTagTableCellDelegate
{
    @IBOutlet weak var tagTextField: NSTextField!
    @IBOutlet weak var addTagButton: NSButton!
    @IBOutlet weak var tagsTable: NSTableView!
    
    var modalDelegate: ModalDialogDelegate?
    private(set) var sortedTags: [String] = []
    
    // MARK:- Initialization
    
    func configureWithTags(_ tags: [String])
    {
        self.sortedTags = tags.sorted()
    }
    
    // MARK:- Event Handlers
    
    @IBAction func addTagButtonPressed(_ sender: NSButton)
    {
        guard self.tagTextField.stringValue.count > 0 else
        {
            return
        }
        self.sortedTags.append(self.tagTextField.stringValue)
        self.sortedTags.sort()
        self.tagsTable.reloadData()
        self.tagTextField.stringValue = ""
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton)
    {
        self.modalDelegate?.dismissedWithCancel(dialog: self)
        self.dismiss(self)
    }
    
    @IBAction func okButtonPressed(_ sender: Any)
    {
        self.modalDelegate?.dismissedWithOK(dialog: self)
        self.dismiss(self)
    }
    
    // MARK:- NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        // One row per tag.
        return self.sortedTags.count
    }
    
    // MARK:- NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // No out-of-bounds crashes please.
        if row < self.sortedTags.count
        {
            // Instantiate a view for the cell.
            guard let tagCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "swaggerMethodTagTableCell"), owner: self) as? SwaggerMethodTagTableCell else
            {
                return nil
            }

            // Configure the view and return it.
            tagCell.delegate = self
            tagCell.configureForTag(self.sortedTags[row])
            return tagCell
        }
        else
        {
            return nil
        }
    }
    
    // MARK:- SwaggerMethodTagTableCellDelegate
    
    func deleteButtonPressedForTagInCell(_ tagCell: SwaggerMethodTagTableCell, tag: String)
    {
        guard let index = self.sortedTags.index(of: tag) else
        {
            return
        }
        self.sortedTags.remove(at: index)
        self.tagsTable.reloadData()
    }
}
