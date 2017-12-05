//
//  CauldronHomeViewController.swift
//  Ernie
//
//  Created by Randy Haid on 11/27/17.
//  Copyright © 2017 Randy Haid. All rights reserved.
//

import Foundation
import Cocoa

// MARK:- Cauldron Data Source Classes

private class CHVCDataSource
{
    var repositories: [CHVCRepository] = []
}

private class CHVCRepository
{
    var repository: CauldronRepository
    var nativeApps: [CHVCNativeApp] = []
    init(with repository: CauldronRepository)
    {
        self.repository = repository
        
        // Build the array of native apps.
        if let nativeAppsSet = self.repository.nativeApps as? Set<CRNativeApp>
        {
            for nativeApp in nativeAppsSet
            {
                self.nativeApps.append(CHVCNativeApp(with: nativeApp))
            }
        }
        
        // Sort the array of native apps.
        self.nativeApps = self.nativeApps.sorted { $0.nativeApp.nativeAppName ?? "" < $1.nativeApp.nativeAppName ?? "" }
    }
}

private class CHVCNativeApp
{
    var nativeApp: CRNativeApp
    var platforms: [CHVCPlatform] = []
    init(with nativeApp: CRNativeApp)
    {
        self.nativeApp = nativeApp
        
        // Build the array of platforms.
        if let platformsSet = self.nativeApp.platforms as? Set<CRPlatform>
        {
            for platform in platformsSet
            {
                self.platforms.append(CHVCPlatform(with: platform))
            }
        }
       
        // Sort the array of platforms.
        self.platforms = self.platforms.sorted { $0.platform.platformName ?? "" < $1.platform.platformName ?? "" }
    }
}

private class CHVCPlatform
{
    var platform: CRPlatform
    var versions: [CHVCVersion] = []
    init(with platform: CRPlatform)
    {
        self.platform = platform
        
        // Build the array of versions.
        if let versionsSet = self.platform.versions as? Set<CRVersion>
        {
            for version in versionsSet
            {
                self.versions.append(CHVCVersion(with: version))
            }
        }
        
        // Sort the array of versions.
        self.versions = self.versions.sorted { $0.version.appVersion ?? "" < $1.version.appVersion ?? "" }
    }
}

private class CHVCVersion
{
    var version: CRVersion
    var miniApps: [CHVCMiniApp] = []
    var dependencies: [CHVCDependency] = []
    var codePushes: [CHVCCodePush] = []
    init(with version: CRVersion)
    {
        self.version = version
        
        // Build the array of mini apps.
        if let miniAppsSet = self.version.miniApps as? Set<CRMiniApp>
        {
            for miniApp in miniAppsSet
            {
                self.miniApps.append(CHVCMiniApp(with: miniApp))
            }
        }
        
        // Sort the array of mini apps.
        self.miniApps = self.miniApps.sorted { $0.miniApp.miniAppName ?? "" < $1.miniApp.miniAppName ?? "" }

        // Build the array of dependencies.
        if let dependenciesSet = self.version.dependencies as? Set<CRDependency>
        {
            for dependency in dependenciesSet
            {
                self.dependencies.append(CHVCDependency(with: dependency))
            }
        }
        
        // Sort the array of dependencies.
        self.dependencies = self.dependencies.sorted { $0.dependency.dependencyName ?? "" < $1.dependency.dependencyName ?? "" }

        // Build the array of code pushes.
        if let codePushesSet = self.version.codePushes as? Set<CRCodePush>
        {
            for codePush in codePushesSet
            {
                self.codePushes.append(CHVCCodePush(with: codePush))
            }
        }
        
        // Sort the array of code pushes.
        self.codePushes = self.codePushes.sorted { $0.codePush.sequenceNumber < $1.codePush.sequenceNumber }
    }
}

private class CHVCMiniApp
{
    var miniApp: CRMiniApp
    init(with miniApp: CRMiniApp)
    {
        self.miniApp = miniApp
    }
}

private class CHVCDependency
{
    var dependency: CRDependency
    init(with dependency: CRDependency)
    {
        self.dependency = dependency
    }
}

private class CHVCCodePush
{
    var codePush: CRCodePush
    var lineItems: [CHVCCodePushLineItem] = []
    init(with codePush: CRCodePush)
    {
        self.codePush = codePush
        
        // Build the array of line item.
        if let lineItemSet = self.codePush.lineItems as? Set<CRCodePushLineItem>
        {
            for lineItem in lineItemSet
            {
                self.lineItems.append(CHVCCodePushLineItem(with: lineItem))
            }
        }
        
        // Sort the array of line items.
        self.lineItems = self.lineItems.sorted { $0.lineItem.codePushName ?? "" < $1.lineItem.codePushName ?? "" }
    }
}

private class CHVCCodePushLineItem
{
    var lineItem: CRCodePushLineItem
    init(with lineItem: CRCodePushLineItem)
    {
        self.lineItem = lineItem
    }
}

// MARK:- The Actual View Controller Class

class CauldronHomeViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate
{
    private var dataSource = CHVCDataSource()
    
    func buildDataSource()
    {
        let moc = AppDelegate.mainManagedObjectContext()
        let request: NSFetchRequest<CauldronRepository> = CauldronRepository.fetchRequest()
        guard let cauldronRepositories = try? moc.fetch(request) else
        {
            return
        }
        
        for repository in cauldronRepositories
        {
            self.dataSource.repositories.append(CHVCRepository(with: repository))
        }
    }
    
    // MARK:- NSOutlineViewDataSource
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int
    {
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        return "hi"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        return true
    }
    
    // MARK:- NSOutlineViewDelegate
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        var view: NSTableCellView?
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        guard let outlineView = notification.object as? NSOutlineView else
        {
            return
        }

        let selectedIndex = outlineView.selectedRow
//        if let feedItem = outlineView.item(atRow: selectedIndex) as? FeedItem {
//            //3
//            let url = URL(string: feedItem.url)
//            //4
//            if let url = url {
//                //5
//                self.webView.mainFrame.load(URLRequest(url: url))
//            }
//        }
    }
}
