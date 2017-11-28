//
//  CauldronAnalyzeViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

class CauldronAnalyzeViewController: NSViewController
{
    // MARK:- IBOutlet Properties

    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var analyzeButton: NSButton!
    @IBOutlet weak var skipButton: NSButton!
    
    // MARK:- View Lifecycle

    override func viewDidAppear()
    {
        super.viewDidAppear()
        self.view.window?.title = "Analyze Cauldron"
    }
    
    // MARK:- Event Handlers

    /**
     When the user presses the "Analyze" button, we will analyze the Cauldron setup before
     going to the Cauldron Home page.
     */
    @IBAction func analyzeButtonPressed(_ sender: NSButton)
    {
        // Disable the buttons and show the progress bar.
        self.analyzeButton.isEnabled = false
        self.skipButton.isEnabled = false
        self.progressBar.startAnimation(self)
        
        // Kick off the analyze process and go to the home page when done.
        CauldronWrapper.analyzeAndUpdateCache { (response) in
            DispatchQueue.main.async {
                self.progressBar.stopAnimation(self)
                self.goToCauldronHome()
            }
        }
    }
    
    /**
     When the user presses the "Skip" button, we will just go directly to the Cauldron Home page.
     */
    @IBAction func skipButtonPressed(_ sender: NSButton)
    {
        self.goToCauldronHome()
    }
    
    /**
     Segues to the Cauldron Home page and dismisses this page.
     */
    private func goToCauldronHome()
    {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "toCauldronHome"), sender: self)
        self.dismiss(self)
    }
}
