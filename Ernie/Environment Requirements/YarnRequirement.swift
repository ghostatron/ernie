//
//  YarnRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/2/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class YarnRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var setupScriptLines: [String]? { get { return nil } }
    
    var fullPathExecutable: String { get { return "/usr/local/bin/yarn" } }
    
    var argumentsForVersionCheck: [String] { get { return ["--version"] } }
    
    var minVersionComponents: [Int] { get { return [1] } }
    
    var fullPathInstallExecutable: String { get { return "/usr/local/bin/brew" } }
    
    // Yarn wants to install NodeJS by default, but we don't want that.
    var argumentsForInstall: [String] { get { return ["install", "yarn", "--without-node"] } }
    
    var fullPathUpdateExecutable: String { get { return "/usr/local/bin/brew" } }
    
    var argumentsForUpdate: [String] { get { return ["upgrade", "yarn"] } }
}
