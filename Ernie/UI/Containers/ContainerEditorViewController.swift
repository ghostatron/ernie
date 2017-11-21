//
//  ContainerEditorViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/21/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class ContainerEditorViewController: NSViewController
{
    enum EditorMode
    {
        case New, Register, Edit
    }
    var mode = EditorMode.New
    
    var modalDelegate: ModalDialogDelegate?
    
    var container: Container?
    
    private func configureForNewMode()
    {
        
    }
    
    private func configureForRegisterMode()
    {
        
    }
    
    private func configureForEditMode()
    {
        
    }
}
