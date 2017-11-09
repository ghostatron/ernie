//
//  NodeJSRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 10/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class NodeJSRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var setupScriptLines: [String]? { get { return nil } }

    var fullPathExecutable: String { get { return "/usr/local/bin/node" } }
    
    var argumentsForVersionCheck: [String] { get { return ["-v"] } }

    var minVersionComponents: [Int] { get { return [4, 5] } }
    
    var fullPathInstallExecutable: String { get { return "" } }
    
    var argumentsForInstall: [String] { get { return [""] } }
    
    var fullPathUpdateExecutable: String { get { return "" } }
    
    var argumentsForUpdate: [String] { get { return [""] } }
}
