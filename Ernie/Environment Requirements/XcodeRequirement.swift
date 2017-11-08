//
//  XcodeRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/2/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class XcodeRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var fullPathExecutable: String { get { return "/usr/bin/xcodebuild" } }
    
    var argumentsForVersionCheck: [String] { get { return ["-version"] } }
    
    var minVersionComponents: [Int] { get { return [8, 3, 2] } }
    
    var fullPathInstallExecutable: String { get { return "" } }
    
    var argumentsForInstall: [String] { get { return [""] } }
    
    var fullPathUpdateExecutable: String { get { return "" } }
    
    var argumentsForUpdate: [String] { get { return [""] } }
}
