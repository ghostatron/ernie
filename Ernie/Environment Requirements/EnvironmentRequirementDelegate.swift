//
//  EnvironmentRequirementDelegate.swift
//  Ernie
//
//  Created by Randy Haid on 10/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

protocol EnvironmentRequirementDelegate
{
    /**
     Some requirements need a little more info about their environment whenever their executable
     is run.  If supplied, setupScriptLines will always be run before triggering this requirement's executable.
     */
    var setupScriptLines: [String]? { get }

    /**
     Requirements get executed via command line and require a full path to the executable file.
     e.g. /bin/echo
     */
    var fullPathExecutable: String { get }
    
    // MARK:- Install
    
    /**
     Requirements get installed via command line and require a full path to the executable file.
     e.g. /bin/echo
     */
    var fullPathInstallExecutable: String { get }
    
    /**
     In order to install the requirement, the entity at fullPathInstallExecutable will be executed
     with the arguments listed in argumentsForInstall.
     */
    var argumentsForInstall: [String] { get }
    
    // MARK:- Update
    
    /**
     Requirements get updated via command line and require a full path to the executable file.
     e.g. /bin/echo
     */
    var fullPathUpdateExecutable: String { get }

    /**
     In order to update the requirement, the entity at fullPathUpdateExecutable will be executed
     with the arguments listed in argumentsForUpdate.
     */
    var argumentsForUpdate: [String] { get }
    
    // MARK:- Version
    
    /**
     In order to check the version of an executable, the entity at fullPathExecutable will be executed
     with the arguments listed in argumentsForVersionCheck.
     */
    var argumentsForVersionCheck: [String] { get }
    
    /**
     Version information is typically broken up in some kind of dot notation, such as 1.2.3, where the
     numbers might refer to "major", "minor", and "patch" releases.  minVersionComponents is simply
     the number portions of that release version, going left to right.
     */
    var minVersionComponents: [Int] { get }
}
