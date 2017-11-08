//
//  ErnWrapper.swift
//  Ernie
//
//  Created by Randy Haid on 11/3/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class ErnWrapper
{
    /**
     Creates a new mini app named |appName| located in |parentFolderPath|.  If |createFolderIfNeeded| is true,
     then the method will create the parent folder and any intermediate folders as needed.  The result is returned
     via |completion|.
     */
    class func createMiniApp(parentFolderPath: String, createFolderIfNeeded: Bool, appName: String, completion: @escaping (CommandLineResponse) -> ())
    {
        // Create the parent folder if needed.
        do
        {
            try FileManager.default.createDirectory(atPath: parentFolderPath, withIntermediateDirectories: createFolderIfNeeded)
        }
        catch
        {
            let response = CommandLineResponse()
            response.errorMessage = error.localizedDescription
            completion(response)
            return
        }
        
        // We need to cd into the parentFolder and run ern from there.  ern will prompt for an app name,
        // so we pipe in a carriage return in order to accept the default.
        let scriptLines = [
            "cd \(parentFolderPath)",
            "printf '\\n' | /usr/local/bin/ern create-miniapp \(appName)"]
        CommandLineHelper.executeCommandsAsShellScript(scriptLines: scriptLines) { (response) in
            print("error = \(response.errorMessage ?? "")")
            print("output = \(response.output ?? "")")
            completion(response)
        }
    }
    
    /**
     Launches the mini app located in |miniAppFolderPath| and returns the results via |completion|.  That result
     is the command line output, and could very likeyly come back before the simulator itself is launched.
     */
    class func launchMiniApp(miniAppFolderPath: String, completion: @escaping (CommandLineResponse) -> ())
    {
        // We need to cd into the mini app folder and run ern from there.  ern will prompt us to select a simulator,
        // so we pipe in a carriage return in order to accept the first one.
        let scriptLines = [
            "cd \(miniAppFolderPath)",
            "printf '\\n' | /usr/local/bin/ern run-ios"]
        CommandLineHelper.executeCommandsAsShellScript(scriptLines: scriptLines) { (response) in
            print("error = \(response.errorMessage ?? "")")
            print("output = \(response.output ?? "")")
            completion(response)
        }
    }
    
    // install brew
    // use brew to install yarn and node
    
    // list versions (auto include 1000.0.0 (ern platform list)
    
    // current version (ern platform current)
    
    // switch to version (ern platform use 1000.0.0)
    
    // install latest version (npm i -g electrode-native)
}
