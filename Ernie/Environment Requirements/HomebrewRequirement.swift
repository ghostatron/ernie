//
//  HomebrewRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/6/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class HomeBrewRequiremewnt : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var setupScriptLines: [String]? { get { return nil } }

    var fullPathExecutable: String { get { return "" } }
    
    var argumentsForVersionCheck: [String] { get { return [""] } }
    
    var minVersionComponents: [Int] { get { return [1] } }
    
    var fullPathInstallExecutable: String { get { return "" } }
    
    var argumentsForInstall: [String] { get { return [""] } }
    
    var fullPathUpdateExecutable: String { get { return "" } }
    
    var argumentsForUpdate: [String] { get { return [""] } }
}
    

    //ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

// vagrant init jhcook/macos-sierra; vagrant up
