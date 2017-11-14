//
//  NodeJSRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 10/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class NodeJSRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var name: String { get { return "Node JS" } }
    var description: String { get { return "Multi-platform server framework built on  JavaScript." } }
    var iconName: String { get { return "NodeJS_icon" } }

    var prerequisites: [EnvironmentRequirement] { get { return [HomeBrewRequirement()] } }

    var fullPathVersionExecutable: String { get { return "/usr/local/bin/node" } }
    var argumentsForVersion: [String] { get { return ["-v"] } }
    var minVersionComponents: [Int] { get { return [4, 5] } }
    
    var fullPathInstallExecutable: String { get { return "/usr/local/bin/brew" } }
    var argumentsForInstall: [String] { get { return ["install", "node"] } }
    
    var fullPathUpdateExecutable: String { get { return "/usr/local/bin/brew" } }
    var argumentsForUpdate: [String] { get { return ["upgrade", "node"] } }
}
