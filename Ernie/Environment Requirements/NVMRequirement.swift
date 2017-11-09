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
    
    var setupScriptLines: [String]? { get { return nil } }

    var fullPathExecutable: String { get { return "nvm" } }
    
    var argumentsForVersionCheck: [String] { get { return ["--version"] } }
    
    var minVersionComponents: [Int] { get { return [0] } }
    
    var fullPathInstallExecutable: String { get { return "" } }
    
    var argumentsForInstall: [String] { get { return [""] } }
    
    var fullPathUpdateExecutable: String { get { return "" } }
    
    var argumentsForUpdate: [String] { get { return [""] } }
}

//export NVM_DIR="$HOME/.nvm"
//[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
//[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

