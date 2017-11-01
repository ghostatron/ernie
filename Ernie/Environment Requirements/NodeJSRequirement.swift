//
//  NodeJSRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 10/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class NodeJSRequirement : EnvironmentRequirementDelegate
{
    /**
     Returns a string that indicates the version that is currently installed.  Returns nil if not installed.
     */
    func currentInstalledVersion() -> String?
    {
        let response = CommandLineHelper.executeCommandLineAndWait(command: "/usr/local/bin/node", arguments: ["-v"])
        return response.output
    }
    
    /**
     Indicates whether or not the currently installed version is compatible for use with Electrode.
     */
    func isCurrentlyInstalledVersionCompatible() -> Bool
    {
        guard let currentVersion = self.currentInstalledVersion() else
        {
            return false
        }
        
        // The format of the version for Node is "v[int].[int].[int]". e.g. v6.11.4
        // The min version is currently 4.5.
        let minMajorVersion = 4
        let minMinorVersion = 5
        let minPatchVersion = 0
        
        // First check the major version.
        let versionComponents = currentVersion.components(separatedBy: ".")
        var majorVersionInt = 0
        if versionComponents.count > 0
        {
            var majorVersion = versionComponents[0]
            if majorVersion.first == "v"
            {
                majorVersion.remove(at: majorVersion.startIndex)
                majorVersionInt = Int(majorVersion) ?? 0
            }
        }
        if majorVersionInt < minMajorVersion
        {
            return false
        }
        else if majorVersionInt > minMajorVersion
        {
            return true
        }
        else
        {
            // The major version matches the min major version exactly, so check the minor version.
        }
        
        // Check the minor version.
        var minorVersionInt = 0
        if versionComponents.count > 1
        {
            minorVersionInt = Int(versionComponents[1]) ?? 0
        }
        if minorVersionInt < minMinorVersion
        {
            return false
        }
        else if minorVersionInt > minMinorVersion
        {
            return true
        }
        else
        {
            // The minor version matches the min minor version exactly, so check the patch version.
        }
        
        // Check the patch version.
        var patchVersionInt = 0
        if versionComponents.count > 2
        {
            patchVersionInt = Int(versionComponents[2]) ?? 0
        }
        return patchVersionInt >= minPatchVersion
    }
    
    /**
     Installs the latest version and calls |completeion| with the String that indicates the version installed.
     |completion| will be called with nil if the installation fails.
     */
    func installLatestVersion(completion: @escaping (String?) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "", arguments: nil) { (response) in
            completion(nil)
        }
    }
}
