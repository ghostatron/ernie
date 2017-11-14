//
//  HomebrewRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/6/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class HomeBrewRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var name: String { get { return "Homebrew" } }
    var description: String { get { return "Command line tool used for managing packages." } }
    
    var fullPathVersionExecutable: String { get { return "/usr/local/bin/brew" } }
    var argumentsForVersion: [String] { get { return ["config"] } }
    var minVersionComponents: [Int] { get { return [1] } }
    
    var fullPathInstallExecutable: String { get { return "/usr/bin/ruby" } }
    var argumentsForInstall: [String] { get { return ["-e", "\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""] } }
    
    var fullPathUpdateExecutable: String { get { return "/usr/local/bin/brew" } }
    var argumentsForUpdate: [String] { get { return ["update"] } }
}
