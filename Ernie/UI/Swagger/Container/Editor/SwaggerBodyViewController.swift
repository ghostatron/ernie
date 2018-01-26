//
//  SwaggerBodyViewController.swift
//  Ernie
//
//  Created by Randy Haid on 1/26/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class SwaggerBodyViewController: NSViewController
{
    @IBOutlet var swaggerBodyTextView: NSTextView!
    private var container: SwaggerContainer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if  let jsonDictionary = self.container?.generateSwaggerJson()
        {
            self.swaggerBodyTextView.string = (jsonDictionary as NSDictionary).description
        }
    }
    
    func configureForContainer(_ container: SwaggerContainer?)
    {
        self.container = container
        guard let textView = self.swaggerBodyTextView, let jsonDictionary = self.container?.generateSwaggerJson() else
        {
            return
        }
        textView.string = (jsonDictionary as NSDictionary).description
    }
    
    @IBAction func copyToClipboardButtonPressed(_ sender: NSButton)
    {
        let board = NSPasteboard.general
        board.clearContents()
        NSPasteboard.general.setString(self.swaggerBodyTextView.string, forType: NSPasteboard.PasteboardType.string)
    }
    
    @IBAction func okButtonPressed(_ sender: NSButton)
    {
        self.dismiss(self)
    }
}
