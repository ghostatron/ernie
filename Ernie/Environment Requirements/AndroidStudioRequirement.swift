//
//  AndroidStudioRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/13/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class AndroidStudioRequirement : EnvironmentRequirement, EnvironmentRequirementDelegate
{
    // MARK:- Init Methods
    
    override init()
    {
        super.init()
        self.delegate = self
    }
    
    // MARK:- EnvironmentRequirementDelegate
    
    var name: String { get { return "Android Studio" } }
    var description: String { get { return "IDE that allows mini-apps to target the Android platform generate containers targeting Android mobile applications." } }

    var prerequisites: [EnvironmentRequirement] { get { return [HomeBrewRequirement()] } }
    
    // TODO: This is clearly not correct, but I'm hiding from Android for now...
    var fullPathVersionExecutable: String { get { return "/bin/echo" } }
    var argumentsForVersion: [String] { get { return ["0"] } }
    var minVersionComponents: [Int] { get { return [0] } }
    
    var fullPathInstallExecutable: String { get { return "/usr/bin/open" } }
    // TODO:- I'd like to launch directly into the app store, or better yet, download via command line.
    // For now, launching to Xcode in Safari.
    var argumentsForInstall: [String] { get { return ["-a", "safari", "https://developer.android.com/studio/index.html"] } }
    
    var fullPathUpdateExecutable: String { get { return "/usr/bin/open" } }
    // TODO:- I'd like to launch directly into the app store, or better yet, download via command line.
    // For now, launching to Xcode in Safari.
    var argumentsForUpdate: [String] { get { return ["-a", "safari", "https://developer.android.com/studio/index.html"] } }
}
