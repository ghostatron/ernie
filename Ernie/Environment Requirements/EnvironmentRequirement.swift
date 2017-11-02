//
//  EnvironmentRequirement.swift
//  Ernie
//
//  Created by Randy Haid on 11/1/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

fileprivate extension String
{
    /**
     Generates an Int by stripping all non-digits from the String and using that result
     in the constructor for Int.  If an Int can't be generated, then |defaultValue| is returned
     instead.
     */
    func intByRemovingNonDigits(defaultValue: Int? = nil) -> Int?
    {
        // Remove anything that isn't a number digit and try to turn whatever is left into an Int.
        let onlyDigits = String(self.filter { "01234567890.".contains($0) })
        if let intValue = Int(onlyDigits)
        {
            return intValue
        }
        else
        {
            return defaultValue
        }
    }
    
    /**
     Splits the String based on |separator| and then attempts to convert each component to an Int.
     The resulting array contains the Int conversion attempts.
     */
    func parseIntoVersionsArray(separator: String = ".") -> [Int?]
    {
        var versionArray: [Int?] = []
        
        // Split this String by |separator| and convert each element to an Int.
        let separators = NSMutableCharacterSet()
        separators.formUnion(with: .newlines)
        separators.addCharacters(in: separator)
        let versionComponents = self.components(separatedBy: separators as CharacterSet)
        for subversion in versionComponents
        {
            versionArray.append(subversion.intByRemovingNonDigits())
        }
        
        return versionArray
    }
    
    /**
     Treats this String as a version string and compares it to the version represented by
     |otherVersionComponents|.
     */
    func compareToVersionArray(otherVersionComponents: [Int]) -> ComparisonResult
    {
        // Get my components, for comparing to |otherVersionComponents|.
        let myVersionComponents = self.parseIntoVersionsArray()
        
        // Compare the component in each array at matching indexes.  If one array is shorter
        // than the other, then the shorter one is assumed to have zero for the missing ones.
        let maxSubVersions = max(myVersionComponents.count, otherVersionComponents.count)
        for index in 0..<maxSubVersions
        {
            // My component version at the current index.
            var mySubversion = 0
            if index < myVersionComponents.count
            {
                mySubversion = myVersionComponents[index] ?? 0
            }
            
            // The other components version at the current index.
            var otherSubversion = 0
            if index < otherVersionComponents.count
            {
                otherSubversion = otherVersionComponents[index]
            }
            
            // We can leave early if they are not the same.
            if mySubversion > otherSubversion
            {
                return .orderedDescending
            }
            else if mySubversion < otherSubversion
            {
                return .orderedAscending
            }
        }
        
        return  .orderedSame
    }
}

class EnvironmentRequirement
{
    /**
     Provides information specific to a given requirement, such as paths and arguments.  Inheriting classes
     MUST set this, probably by overriding init, or crashes will almost certainly result.
     */
    var delegate: EnvironmentRequirementDelegate!
    
    // MARK:- Init
    
    /**
     Configures the command line environment to hopefully make things work fairly smoothly.  It's designed
     to only run once during the application's lifetime.
     */
    private func setupEnvironmentOnce()
    {
        struct ErnieEnvironment
        {
            static var configure : Void = {
                let envVars = ProcessInfo.processInfo.environment
                let pathVar = envVars["PATH"] ?? ""
                let erniePath = "\(pathVar):/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
                setenv("PATH", erniePath, 1)
            }()
        }
        let _ = ErnieEnvironment.configure
    }

    /**
     Creates an EnvironmentRequirement object.
     */
    init()
    {
        self.setupEnvironmentOnce()
    }
    
    // MARK:- Version Methods
    
    /**
     Returns a string that indicates the version that is currently installed.  Returns nil if not installed.
     */
    func currentlyInstalledVersion() -> String?
    {
        let response = CommandLineHelper.executeCommandLineAndWait(command: self.delegate.fullPathExecutable, arguments: self.delegate.argumentsForVersionCheck)
        return response.output
    }
    
    /**
     Indicates whether or not the currently installed version is compatible for use with Electrode.
     */
    func isCurrentlyInstalledVersionCompatible() -> Bool
    {
        guard let currentVersion = self.currentlyInstalledVersion() else
        {
            return false
        }
        
        // The min version is currently 4.5.
        return currentVersion.compareToVersionArray(otherVersionComponents: self.delegate.minVersionComponents) != .orderedAscending
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
