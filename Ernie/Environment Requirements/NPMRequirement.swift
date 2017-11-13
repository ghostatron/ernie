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
    
    var name: String { get { return "NPM" } }
    var description: String { get { return "Command line package manager associated with Node JS." } }
    
    var prerequisites: [EnvironmentRequirement] { get { return [NVMRequirement()] } }

    var fullPathVersionExecutable: String { get { return "/usr/local/bin/npm" } }
    var argumentsForVersion: [String] { get { return ["-v"] } }
    var minVersionComponents: [Int] { get { return [3] } }

    // NPM is installed as part of NodeJS.
    var nodeRequirement = NodeJSRequirement()
    var fullPathInstallExecutable: String { get { return self.nodeRequirement.fullPathInstallExecutable } }
    var argumentsForInstall: [String] { get { return self.nodeRequirement.argumentsForInstall } }
    var scriptLinesForInstall: [String]? { get { return self.nodeRequirement.scriptLinesForInstall } }
    
    var fullPathUpdateExecutable: String { get { return "" } }
    var argumentsForUpdate: [String] { get { return [""] } }
    var scriptLinesForUpdate: [String]?
    {
        get
        {
            return [
                "export NVM_DIR=\"$HOME/.nvm\"",
                "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"",
                "[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"",
                "npm install npm@latest -g"]
        }
    }
}
