//
//  CommandLineHelper.swift
//  Ernie
//
//  Created by Randy Haid on 10/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation

class CommandLineResponse
{
    var output: String?
    var errorMessage: String?
}

class CommandLineHelper
{
    // MARK:- Init

    /**
     Configures the command line environment to hopefully make things work fairly smoothly.  It's designed
     to only run once during the application's lifetime.
     */
    public class func setupEnvironmentOnce()
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
     Executes |command| with |arguments| passed in to it and passes the resulting output back via |completion|.
     */
    class func executeCommandLine(command: String, arguments: [String]?, completion: @escaping (CommandLineResponse) -> ())
    {
        let response = self.executeCommandLineAndWait(command: command, arguments: arguments)
        completion(response)
    }
    
    /**
     Executes |command| with |arguments| passed in to it and returns the resulting output.
     */
    @discardableResult class func executeCommandLineAndWait(command: String, arguments: [String]?) -> CommandLineResponse
    {
        // A non-empty command is actually required...
        let response = CommandLineResponse()
        guard !command.isEmpty else
        {
            response.errorMessage = "No command was given"
            return response
        }
        
        // Set up the process that will run the command.
        let task = Process()
        task.launchPath = command
        task.arguments = arguments
        
        // Attach a pipe to the process so we can read the output.
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Kick off the command and capture the output for the caller.
        task.launch()
        response.output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)?.trimmingCharacters(in: .newlines)
        return response
    }
    
    /**
     Creates and executes a temporary shell script that only has the content given by |scriptLines|.
     Each element of the array will be on a separate line in the script.
     The script will be deleted after it finishes running.
     */
    class func executeCommandsAsShellScript(scriptLines: [String], completion: @escaping (CommandLineResponse) -> ())
    {
        let response = self.executeCommandsAsShellScriptAndWait(scriptLines: scriptLines)
        completion(response)
    }
    
    /**
     Creates and executes a temporary shell script that only has the content given by |scriptLines|.
     Each element of the array will be on a separate line in the script.
     The script will be deleted after it finishes running.
     */
    @discardableResult class func executeCommandsAsShellScriptAndWait(scriptLines: [String]) -> CommandLineResponse
    {
        let response = CommandLineResponse()
        
        // The script name doesn't matter since we'll delete it later...just make sure it's unique.
        let tempFileName = "\(UUID().uuidString).sh"
        
        // We want to create the script in the application script folder.
        guard let path = NSSearchPathForDirectoriesInDomains(.applicationScriptsDirectory, .userDomainMask, true).first else
        {
            response.errorMessage = "Unable to access the Application Scripts folder."
            return response
        }
        
        // Create a TempScripts folder for the script, because we're OCD like that.
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent("TempScripts") else
        {
            response.errorMessage = "Unable to create URL for TempScripts folder."
            return response
        }
        do
        {
            try FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        }
        catch
        {
            response.errorMessage = error.localizedDescription
            return response
        }
        
        // Generate the actual script.
        let tempScript = writePath.appendingPathComponent(tempFileName)
        let scriptContent = scriptLines.joined(separator: "\n")
        do
        {
            try scriptContent.write(to: tempScript, atomically: false, encoding: String.Encoding.utf8)
        }
        catch
        {
            response.errorMessage = error.localizedDescription
            return response
        }
        
        // Make the script executable.
       let chmodResponse = CommandLineHelper.executeCommandLineAndWait(command: "/bin/chmod", arguments: ["a+x", tempScript.path])
        guard chmodResponse.errorMessage?.isEmpty ?? true else
        {
            return chmodResponse
        }
        
        // Run the script.
        let bashResponse = CommandLineHelper.executeCommandLineAndWait(command: "/bin/bash", arguments: [tempScript.path])
        guard bashResponse.errorMessage?.isEmpty ?? true else
        {
            return bashResponse
        }
        
        // Delete the script.
        let deleteResponse = CommandLineHelper.executeCommandLineAndWait(command: "/bin/rm", arguments: [tempScript.path])
        guard deleteResponse.errorMessage?.isEmpty ?? true else
        {
            deleteResponse.errorMessage = "\(bashResponse.errorMessage ?? "") - Shell executed, but delete of temp script failed: \(deleteResponse.errorMessage ?? "") - \(deleteResponse.output  ?? ""))"
            deleteResponse.output = bashResponse.output
            return deleteResponse
        }
        
        return bashResponse
    }
}
