//
//  CauldronHomeViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class CauldronHomeViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate
{
    // MARK:- NSOutlineViewDataSource
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
    {
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        return "hi"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        return true
    }
    
    // MARK:- NSOutlineViewDelegate
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        var view: NSTableCellView?
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        guard let outlineView = notification.object as? NSOutlineView else
        {
            return
        }

        let selectedIndex = outlineView.selectedRow
//        if let feedItem = outlineView.item(atRow: selectedIndex) as? FeedItem {
//            //3
//            let url = URL(string: feedItem.url)
//            //4
//            if let url = url {
//                //5
//                self.webView.mainFrame.load(URLRequest(url: url))
//            }
//        }
    }
}
