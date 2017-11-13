//
//  XcodeRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/2/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class XcodeRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var name: String { get { return "Xcode" } }
    var description: String { get { return "IDE that allows mini-apps to target the iOS platform generate containers targeting iOS mobile applications." } }
    
    var fullPathVersionExecutable: String { get { return "/usr/bin/xcodebuild" } }
    var argumentsForVersion: [String] { get { return ["-version"] } }
    var minVersionComponents: [Int] { get { return [8, 3, 2] } }
    
    var fullPathInstallExecutable: String { get { return "/usr/bin/open" } }
    // TODO:- I'd like to launch directly into the app store, or better yet, download via command line.
    // For now, launching to Xcode in Safari.
    var argumentsForInstall: [String] { get { return ["-a", "safari", "https://www.apple.com/us/search/xcode"] } }
    
    var fullPathUpdateExecutable: String { get { return "/usr/bin/open" } }
    // TODO:- I'd like to launch directly into the app store, or better yet, download via command line.
    // For now, launching to Xcode in Safari.
    var argumentsForUpdate: [String] { get { return ["-a", "safari", "https://www.apple.com/us/search/xcode"] } }
}
