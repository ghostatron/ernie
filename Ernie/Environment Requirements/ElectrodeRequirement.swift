//
//  ElectrodeRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/3/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class ElectrodeRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var fullPathExecutable: String { get { return "/usr/local/bin/ern" } }
    
    var argumentsForVersionCheck: [String] { get { return ["platform", "current"] } }
    
    var minVersionComponents: [Int] { get { return [0] } }
    
    var fullPathInstallExecutable: String { get { return "" } }
    
    var argumentsForInstall: [String] { get { return [""] } }
    
    var fullPathUpdateExecutable: String { get { return "" } }
    
    var argumentsForUpdate: [String] { get { return [""] } }
}
