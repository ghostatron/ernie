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
    
    var name: String { get { return "Yarn" } }
    var description: String { get { return "Command line tool used for managing packages." } }
    var iconName: String { get { return "Yarn_icon" } }

    var prerequisites: [EnvironmentRequirement] { get { return [HomeBrewRequirement()] } }

    var fullPathVersionExecutable: String { get { return "" } }
    var argumentsForVersion: [String] { get { return [""] } }
    var minVersionComponents: [Int] { get { return [1] } }
    var scriptLinesForVersion: [String]?
    {
        get
        {
            // Yarn requires environment info regarding NVM in order to execute.
            return [
                "export NVM_DIR=\"$HOME/.nvm\"",
                "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"",
                "[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"",
                "/usr/local/bin/yarn --version"]
        }
    }
    
    var fullPathInstallExecutable: String { get { return "/usr/local/bin/brew" } }
    // Yarn wants to install NodeJS by default, but we don't want that.
    var argumentsForInstall: [String] { get { return ["install", "yarn", "--without-node"] } }
    
    var fullPathUpdateExecutable: String { get { return "/usr/local/bin/brew" } }
    var argumentsForUpdate: [String] { get { return ["upgrade", "yarn"] } }
}
