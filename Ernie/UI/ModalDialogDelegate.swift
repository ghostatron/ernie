//
//  ModalDialogDelegate.swift
//  Ernie
//
//  Created by Randy Haid on 11/16/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

protocol ModalDialogDelegate
{
    func dismissedWithOK(dialog: NSViewController)
    func dismissedWithCancel(dialog: NSViewController)
}
