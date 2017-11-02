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
        let onlyDigits = String(self.filter { "01234567890.".contains($0) })
        if onlyDigits.isEmpty
        {
            return defaultValue
        }
        else
        {
            return Int(onlyDigits)
        }
    }
    
    /**
     Splits the String based on |separator| and then attempts to convert each component to an Int.
     The resulting array contains the Int conversion attempts.
     */
    func parseIntoVersionsArray(separator: String = ".") -> [Int?]
    {
        var versionArray: [Int?] = []
        
        let versionComponents = self.components(separatedBy: separator)
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
        let myVersionComponents = self.parseIntoVersionsArray()
        let maxSubVersions = max(myVersionComponents.count, otherVersionComponents.count)
        for index in 0..<maxSubVersions
        {
            var mySubversion = 0
            if index < myVersionComponents.count
            {
                mySubversion = myVersionComponents[index] ?? 0
            }
            
            var otherSubversion = 0
            if index < otherVersionComponents.count
            {
                otherSubversion = otherVersionComponents[index]
            }
            
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
    /// Provides information specific to a given requirement, such as paths and arguments.
    private var delegate: EnvironmentRequirementDelegate
    
    /**
     Creates an EnvironmentRequirement object that will use the given |delegate| for details.
     */
    init(delegate: EnvironmentRequirementDelegate)
    {
        self.delegate = delegate
    }
    
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
