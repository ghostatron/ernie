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
     OPTIONAL
     If a requirement requires other requirements in order to be installed/updated/used, then they should
     be listed in |prerequisites|.  This is an empty array by default.
     */
    var prerequisites: [EnvironmentRequirement] { get }
    
    // MARK:- Setup
    
    /**
     OPTIONAL
     Some requirements need a little more info about their environment whenever their executable
     is run.  If supplied, scriptLinesForSetup will always be run before triggering this requirement's executable.
     (Also note that if supplied, all commands will be run as scripts instead of straight command line.)
     */
    var scriptLinesForSetup: [String]? { get }
    
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
    
    /**
     OPTIONAL
     Sometimes the command line for installing a requirement is too complex to be a one-liner
     (Using pipes is a great example).  If that's the case, then implement scriptLinesForInstall
     instead of fullPathInstallExecutable and argumentsForInstall.
     */
    var scriptLinesForInstall: [String]? { get }
    
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
    
    /**
     OPTIONAL
     Sometimes the command line for installing a requirement is too complex to be a one-liner
     (Using pipes is a great example).  If that's the case, then implement scriptLinesForUpdate
     instead of fullPathUpdateExecutable and argumentsForUpdate.
     */
    var scriptLinesForUpdate: [String]? { get }
    
    // MARK:- Version
    
    /**
     Requirements get version checked via command line and require a full path to the executable file.
     e.g. /bin/echo
     */
    var fullPathVersionExecutable: String { get }
    
    /**
     In order to check the version of an executable, the entity at fullPathExecutable will be executed
     with the arguments listed in argumentsForVersionCheck.
     */
    var argumentsForVersion: [String] { get }
    
    /**
     Version information is typically broken up in some kind of dot notation, such as 1.2.3, where the
     numbers might refer to "major", "minor", and "patch" releases.  minVersionComponents is simply
     the number portions of that release version, going left to right.
     */
    var minVersionComponents: [Int] { get }
    
    /**
     OPTIONAL
     Sometimes the command line for installing a requirement is too complex to be a one-liner
     (Using pipes is a great example).  If that's the case, then implement scriptLinesForVersion
     instead of fullPathVersionExecutable and argumentsForVersionCheck.
     */
    var scriptLinesForVersion: [String]? { get }
}

extension EnvironmentRequirementDelegate
{
    var prerequisites: [EnvironmentRequirement] { get { return [] } }
    
    //
    // Returning nil for these effectively makes them optional in the protocol.  When these properties return
    // nil, the application logic will switch over and use the more efficient fullPath* and argumentsFor* properties.
    //
    
    var scriptLinesForSetup: [String]? { get { return nil } }
    var scriptLinesForInstall: [String]? { get { return nil } }
    var scriptLinesForUpdate: [String]? { get { return nil } }
    var scriptLinesForVersion: [String]? { get { return nil } }
}
