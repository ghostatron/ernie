//
//  CauldronWrapper.swift
//  Ernie
//
//  Created by Randy Haid on 11/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class CauldronWrapper
{
    class func analyzeAndUpdateCache(completion: @escaping (CommandLineResponse) -> ())
    {
        let response = CommandLineResponse()
        completion(response)
    }
    
    // MARK:- Repository Methods
    
    /**
     Adds a new repository with the given |alias| located at |location|.  The |completion| block
     will be called with TRUE if the process succeeds.
     */
    class func addRepository(_ alias: String, location: URL, completion: @escaping (Bool) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "add", alias, location.absoluteString, "--current false"]) { (response) in
            let successText = "Added Cauldron repository \(location.absoluteString) with alias \(alias)"
            completion(response.output?.contains(successText) ?? false)
        }
    }
    
    /**
     Removes the rrepository with the given |alias|.  The |completion| block
     will be called with TRUE if the process succeeds.
     */
    class func removeRepository(_ alias: String, completion: @escaping (Bool) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "remove", alias]) { (response) in
            let successText = "Removed Cauldron repository exists with alias \(alias)"
            completion(response.output?.contains(successText) ?? false)
        }
    }
    
    /**
     Returns a list of all local repositories via |completion|.
     */
    class func listOfRepositories(completion: @escaping ([(alias: String, location: String)]?) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "list"]) { (response) in
            
            // The output starts out with some electrode header info and ends with the
            // actual listing of repositories.  We can find where that list begins by locating
            // the key phrase "[Cauldron Repositories]"
            guard let twoHalves = response.output?.components(separatedBy: "[Cauldron Repositories]"), twoHalves.count == 2 else
            {
                completion(nil)
                return
            }
            
            // Our return value, initially empty.
            var repositoryList: [(alias: String, location: String)] = []
            
            // We're only interested in the second half of that output, which has 1 repository
            // listing per line.  So break that up by newline characters.
            let repositoryLines = twoHalves[1].components(separatedBy: .newlines)
            for line in repositoryLines
            {
                // Each line is something like "alias -> url".
                let aliasAndLocation = line.components(separatedBy: " -> ")
                if aliasAndLocation.count == 2
                {
                    repositoryList.append((alias: aliasAndLocation[0], location: aliasAndLocation[1]))
                }
            }

            // Send the results back to the listener.
            completion(repositoryList)
        }
    }
    
    /**
     Returns the |alias| and |location| of the currently active repository via |completion|.
     */
    class func currentRepository(completion: @escaping ((alias: String, location: String)?) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "current"]) { (response) in
            
            // The output has the electrode header and then the current repository as the last line.
            // So start by splitting that into lines and grabbing the last one.
            guard let outputLines = response.output?.components(separatedBy: .newlines), outputLines.count > 0 else
            {
                completion(nil)
                return
            }
            let currentRepositoryLine = outputLines.last!

            // The last line should look like "alias location".
            var currentRepository: (alias: String, location: String)?
            let aliasAndLocation = currentRepositoryLine.components(separatedBy: " ")
            if aliasAndLocation.count == 2
            {
                currentRepository = (alias: aliasAndLocation[0], location: aliasAndLocation[1])
            }
            completion(currentRepository)
        }
    }
    
    /**
     Changes the currently active repository to be |alias|.  Returns TRUE if the process succeeds via |completion|.
     */
    class func switchToRepository(_ alias: String, completion: @escaping (Bool) -> ())
    {
        CommandLineHelper.executeCommandLine(command: "/usr/local/bin/ern", arguments: ["cauldron", "repo", "use", alias]) { (response) in
            let successText = "\(alias) Cauldron is now in use"
            completion(response.output?.contains(successText) ?? false)
        }
    }
}
