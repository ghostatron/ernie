//
//  NVMRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/6/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class NVMRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var name: String { get { return "NVM" } }
    var description: String { get { return "Command line tool for Node JS that manages its versions." } }

    var fullPathVersionExecutable: String { get { return "nvm" } }
    var argumentsForVersion: [String] { get { return ["--version"] } }
    var scriptLinesForVersion: [String]?
    {
        get
        {
            return [
                "export NVM_DIR=\"$HOME/.nvm\"",
                "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"",
                "[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"",
                "nvm --version"]
        }
    }
    var minVersionComponents: [Int] { get { return [0] } }
    
    var fullPathInstallExecutable: String { get { return "" } }
    var argumentsForInstall: [String] { get { return [""] } }
    var scriptLinesForInstall: [String]? { get { return ["usr/bin/curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash"] } }

    var fullPathUpdateExecutable: String { get { return "" } }
    var argumentsForUpdate: [String] { get { return [""] } }
    var scriptLinesForUpdate: [String]? { get { return self.scriptLinesForInstall } }
}
