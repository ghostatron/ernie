//
//  SwaggerContainerImportConfirmViewController.swift
//  Ernie
//
//  Created by Randy Haid on 2/5/18.
//  Copyright © 2018 Randy Haid. All rights reserved.
//

import Cocoa

class SwaggerContainerImportConfirmViewController: NSViewController
{
    var container: SwaggerContainer?
    var modalDelegate: ModalDialogDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let jsonDictionary = self.container?.generateSwaggerJson()
        {
            print((jsonDictionary as NSDictionary).description)
        }
    }
}
