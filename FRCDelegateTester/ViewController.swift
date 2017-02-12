//
//  ViewController.swift
//  FRCDelegateTester
//
//  Created by Tim Ekl on 2017.02.07.
//  Copyright © 2017 Tim Ekl. All rights reserved.
//

import Cocoa
import CoreData
import Foundation

class ViewController: NSViewController, NSFetchedResultsControllerDelegate {

    class LabeledStepperField: NSObject, NSTextFieldDelegate {
        private var label: NSTextField
        private var field: NSTextField
        private var stepper: NSStepper
        
        var value: Int {
            get {
                return stepper.integerValue
            }
            set(newValue) {
                stepper.integerValue = newValue
                field.integerValue = newValue
            }
        }
        
        init(label: String) {
            self.label = NSTextField(labelWithString: label)
            self.field = NSTextField()
            self.stepper = NSStepper()
            
            super.init()
            
            for view in views() {
                view.translatesAutoresizingMaskIntoConstraints = false
            }
            
            self.field.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
            self.field.delegate = self
            
            self.stepper.maxValue = 100
            self.stepper.target = self
            self.stepper.action = #selector(stepperValueChanged(_:))
        }
        
        func views() -> [NSView] {
            return [label, field, stepper]
        }
        
        override func controlTextDidEndEditing(_ obj: Notification) {
            value = field.integerValue
        }
        
        @objc private func stepperValueChanged(_ sender: NSStepper) {
            precondition(sender === stepper)
            value = sender.integerValue
        }
    }
    
    private var managedObjectContext = NSManagedObjectContext(storeURL: nil, concurrencyType: .mainQueueConcurrencyType)
    private var fetchedResultsController: NSFetchedResultsController<Thing>!
    
    private var insertField: LabeledStepperField!
    private var updateField: LabeledStepperField!
    private var deleteField: LabeledStepperField!
    
    private var gridView: NSGridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        insertField = LabeledStepperField(label: "Insert")
        updateField = LabeledStepperField(label: "Update")
        deleteField = LabeledStepperField(label: "Delete")
        let goButton = NSButton(title: "Go", target: self, action: #selector(commitChanges(_:)))
        
        for field in [insertField, updateField, deleteField] {
            field?.value = 0
        }
        
        gridView = NSGridView(views: [insertField.views(), updateField.views(), deleteField.views(), [goButton]])
        gridView.mergeCells(inHorizontalRange: NSMakeRange(0, 3), verticalRange: NSMakeRange(3, 1))
        gridView.xPlacement = .center
        gridView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(gridView)
        view.centerXAnchor.constraint(equalTo: gridView.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: gridView.centerYAnchor).isActive = true
        
        let fetchRequest: NSFetchRequest<Thing> = Thing.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "dateAdded", ascending: true) ]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
    
    @objc private func commitChanges(_ sender: Any!) {
        if let responder = sender as? NSResponder {
            view.window?.makeFirstResponder(responder)
        }
        
        let insertCount = insertField.value
        let updateCount = updateField.value
        let deleteCount = deleteField.value
        
        let existingCount = fetchedResultsController.sections!.first!.numberOfObjects
        if updateCount + deleteCount > existingCount {
            print("cannot update \(updateCount) and delete \(deleteCount) – only \(existingCount) in existence")
            NSBeep()
            return
        }
        
        for i in 0..<deleteCount {
            let thing = fetchedResultsController.object(at: IndexPath(item: i, section: 0))
            managedObjectContext.delete(thing)
        }
        
        for i in deleteCount..<(deleteCount+updateCount) {
            let thing = fetchedResultsController.object(at: IndexPath(item: i, section: 0))
            thing.identifier = UUID().uuidString
        }
        
        for _ in 0..<insertCount {
            _ = managedObjectContext.insertThing()
        }
        
        try! managedObjectContext.save()
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controller will change content")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        assertionFailure("shouldn't be sectioned")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("controller did change object: \(changeDescription(for: type, from: indexPath, to: newIndexPath))")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controller did change content")
    }
    
    private func changeDescription(for type: NSFetchedResultsChangeType, from indexPath: IndexPath?, to newIndexPath: IndexPath?) -> String {
        var result: String
        switch type {
        case .insert: result = "insert"
        case .update: result = "update"
        case .move: result = "move"
        case .delete: result = "delete"
        }
        
        func itemDescription(for indexPath: IndexPath?) -> String {
            if let item = indexPath?.item {
                return String(describing: item)
            }
            return "nil"
        }
        
        result += " "
        result += itemDescription(for: indexPath)
        result += " -> "
        result += itemDescription(for: newIndexPath)
        
        return result
    }

}
