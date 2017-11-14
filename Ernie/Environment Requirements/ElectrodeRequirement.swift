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
    
    var name: String { get { return "Electrode" } }
    var description: String { get { return "The platform used for building mini-apps.  It's the 'E' in 'Ernie', so yeah, kinda the whole reason you're here." } }
    var iconName: String { get { return "Electrode_Native_icon" } }

    var prerequisites: [EnvironmentRequirement] { get { return [NodeJSRequirement(), NPMRequirement()] } }
    
    var fullPathVersionExecutable: String { get { return "" } }
    var argumentsForVersion: [String] { get { return [""] } }
    var minVersionComponents: [Int] { get { return [0] } }
    var scriptLinesForVersion: [String]?
    {
        get
        {
            return [
                "export NVM_DIR=\"$HOME/.nvm\"",
                "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"",
                "[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"",
                "npm list -g --depth=0 | grep electrode"]
        }
    }
    
    var fullPathInstallExecutable: String { get { return "" } }
    var argumentsForInstall: [String] { get { return [""] } }
    var scriptLinesForInstall: [String]?
    {
        get
        {
            return [
                "export NVM_DIR=\"$HOME/.nvm\"",
                "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"",
                "[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"",
                "npm install -g electrode-native && ern"]
        }
    }

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
                "npm install -g electrode-native"]
        }
    }
}
