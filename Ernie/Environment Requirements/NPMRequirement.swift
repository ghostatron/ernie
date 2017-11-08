//
//  NPMRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/2/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class NPMRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var fullPathExecutable: String { get { return "/usr/local/bin/npm" } }
    
    var argumentsForVersionCheck: [String] { get { return ["-v"] } }
    
    var minVersionComponents: [Int] { get { return [3] } }
    
    var fullPathInstallExecutable: String { get { return "" } }
    
    var argumentsForInstall: [String] { get { return [""] } }
    
    var fullPathUpdateExecutable: String { get { return "" } }
    
    var argumentsForUpdate: [String] { get { return [""] } }
}
