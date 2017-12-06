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

private class CHVCArrayWithTitle
{
    var title: String
    var array: [Any]
    init(title: String, array: [Any])
    {
        self.title = title
        self.array = array
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.buildDataSource()
    }
    
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
        if let repository = item as? CHVCRepository
        {
            return repository.nativeApps.count
        }
        else if let nativeApp = item as? CHVCNativeApp
        {
            return nativeApp.platforms.count
        }
        else if let platform = item as? CHVCPlatform
        {
            return platform.versions.count
        }
        else if let _ = item as? CHVCVersion
        {
            // A version object has 3 arrays for children: mini-apps, dependencies, and code pushes.
            return 3
        }
        else if let itemArray = item as? CHVCArrayWithTitle
        {
            return itemArray.array.count
        }
        else if let codePush = item as? CHVCCodePush
        {
            return codePush.lineItems.count
        }
        else
        {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any
    {
        var arrayWithItem: [Any] = []
        
        if let repository = item as? CHVCRepository
        {
            arrayWithItem = repository.nativeApps
        }
        else if let nativeApp = item as? CHVCNativeApp
        {
            arrayWithItem = nativeApp.platforms
        }
        else if let platform = item as? CHVCPlatform
        {
            arrayWithItem = platform.versions
        }
        else if let version = item as? CHVCVersion
        {
            arrayWithItem = [
                CHVCArrayWithTitle(title: "Mini Apps", array: version.miniApps),
                CHVCArrayWithTitle(title: "Dependencies", array: version.dependencies),
                CHVCArrayWithTitle(title: "Code Pushes", array: version.codePushes)]
        }
        else if let itemArray = item as? CHVCArrayWithTitle
        {
            arrayWithItem = itemArray.array
        }
        else if let codePush = item as? CHVCCodePush
        {
            arrayWithItem = codePush.lineItems
        }
        
        if index < arrayWithItem.count
        {
            return arrayWithItem[index]
        }
        else
        {
            return NSNull()
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool
    {
        if let repository = item as? CHVCRepository
        {
            return repository.nativeApps.count > 0
        }
        else if let nativeApp = item as? CHVCNativeApp
        {
            return nativeApp.platforms.count > 0
        }
        else if let platform = item as? CHVCPlatform
        {
            return platform.versions.count > 0
        }
        else if let _ = item as? CHVCVersion
        {
            return true
        }
        else if let itemArray = item as? CHVCArrayWithTitle
        {
            return itemArray.array.count > 0
        }
        else if let codePush = item as? CHVCCodePush
        {
            return codePush.lineItems.count > 0
        }
        else
        {
            return false
        }
    }
    
    // MARK:- NSOutlineViewDelegate
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView?
    {
        guard let columnIdentifier = tableColumn?.identifier.rawValue else
        {
            return nil
        }
        
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cauldronHomeTableViewCell"), owner: self) as? CauldronHomeTableViewCell
        
        if let repository = item as? CHVCRepository
        {
            switch columnIdentifier
            {
            case "nameColumn":
                cell?.titleLabel.stringValue = repository.repository.alias ?? "<No Value>"
            case "versionColumn":
                cell?.titleLabel.stringValue = "Repository"
            default:
                cell?.titleLabel.stringValue = "<Invalid>"
            }
        }
        else if let nativeApp = item as? CHVCNativeApp
        {
            switch columnIdentifier
            {
            case "nameColumn":
                cell?.titleLabel.stringValue = nativeApp.nativeApp.nativeAppName ?? "<No Value>"
            case "versionColumn":
                cell?.titleLabel.stringValue = "Native App"
            default:
                cell?.titleLabel.stringValue = "<Invalid>"
            }
        }
        else if let platform = item as? CHVCPlatform
        {
            switch columnIdentifier
            {
            case "nameColumn":
                cell?.titleLabel.stringValue = platform.platform.platformName ?? "<No Value>"
            case "versionColumn":
                cell?.titleLabel.stringValue = "Platform"
            default:
                cell?.titleLabel.stringValue = "<Invalid>"
            }
        }
        else if let version = item as? CHVCVersion
        {
            switch columnIdentifier
            {
            case "nameColumn":
                cell?.titleLabel.stringValue = version.version.appVersion ?? "<No Value>"
            case "versionColumn":
                cell?.titleLabel.stringValue = "Version"
            default:
                cell?.titleLabel.stringValue = "<Invalid>"
            }
        }
        else if let itemArray = item as? CHVCArrayWithTitle
        {
            switch columnIdentifier
            {
            case "nameColumn":
                cell?.titleLabel.stringValue = itemArray.title
            case "versionColumn":
                cell?.titleLabel.stringValue = "\(itemArray.array.count)"
            default:
                cell?.titleLabel.stringValue = "<Invalid>"
            }
        }
        else if let miniApp = item as? CHVCMiniApp
        {
            switch columnIdentifier
            {
            case "nameColumn":
                cell?.titleLabel.stringValue = miniApp.miniApp.miniAppName ?? "<No Value>"
            case "versionColumn":
                cell?.titleLabel.stringValue = miniApp.miniApp.miniAppVersion ?? "<No Value"
            default:
                cell?.titleLabel.stringValue = "<Invalid>"
            }
        }
        else if let dependency = item as? CHVCDependency
        {
            switch columnIdentifier
            {
            case "nameColumn":
                cell?.titleLabel.stringValue = dependency.dependency.dependencyName ?? "<No Value>"
            case "versionColumn":
                cell?.titleLabel.stringValue = dependency.dependency.dependencyVersion ?? "<No Value"
            default:
                cell?.titleLabel.stringValue = "<Invalid>"
            }
        }
        else if let codePush = item as? CHVCCodePush
        {
            switch columnIdentifier
            {
            case "nameColumn":
                cell?.titleLabel.stringValue = "Code Pushes"
            case "versionColumn":
                cell?.titleLabel.stringValue = "\(codePush.codePush.lineItems?.count ?? 0)"
            default:
                cell?.titleLabel.stringValue = "<Invalid>"
            }
        }
        else if let codePushLineItem = item as? CHVCCodePushLineItem
        {
            switch columnIdentifier
            {
            case "nameColumn":
                cell?.titleLabel.stringValue = codePushLineItem.lineItem.codePushName ?? "<No Value>"
            case "versionColumn":
                cell?.titleLabel.stringValue = codePushLineItem.lineItem.codePushVersion ?? "<No Value"
            default:
                cell?.titleLabel.stringValue = "<Invalid>"
            }
        }
        
        return cell
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification)
    {
        guard let outlineView = notification.object as? NSOutlineView else
        {
            return
        }

        let selectedIndex = outlineView.selectedRow
        let selectedItem = outlineView.item(atRow: selectedIndex)
        if let repository = selectedItem as? CHVCRepository
        {
        }
        else if let nativeApp = selectedItem as? CHVCNativeApp
        {
        }
        else if let platform = selectedItem as? CHVCPlatform
        {
        }
        else if let version = selectedItem as? CHVCVersion
        {
        }
        else if let miniApp = selectedItem as? CHVCMiniApp
        {
        }
        else if let dependency = selectedItem as? CHVCDependency
        {
        }
        else if let codePush = selectedItem as? CHVCCodePush
        {
        }
        else if let lineItem = selectedItem as? CHVCCodePushLineItem
        {
        }
    }
}
