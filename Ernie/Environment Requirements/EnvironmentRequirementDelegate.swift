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
     Returns a string that indicates the version that is currently installed.  Returns nil if not installed.
     */
    func currentlyInstalledVersion() -> String?
    
    /**
     Indicates whether or not the currently installed version is compatible for use with Electrode.
     */
    func isCurrentlyInstalledVersionCompatible() -> Bool
    
    /**
     Installs the latest version and calls |completeion| with the String that indicates the version installed.
     |completion| will be called with nil if the installation fails.
     */
    func installLatestVersion(completion: @escaping (String?) -> ())
}
