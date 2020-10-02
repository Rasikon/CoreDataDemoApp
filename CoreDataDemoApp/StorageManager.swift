//
//  CoreDataManager.swift
//  CoreDataDemoApp
//
//  Created by Rasikon on 02.10.2020.
//

import UIKit
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemoApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(_ taskName: String, completion: @escaping (Task) -> ()) {
        let context = StorageManager.shared.persistentContainer.viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.name = taskName
        completion(task)
        saveContext()
    }
    
    func update(_ taskOld: Task,_ taskName: String) {
        let context = StorageManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        var tasks = [Task]()
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
        for task in tasks {
            if task.name == taskOld.name {
                task.name = taskName
            }
        }
        saveContext()
    }
    
    func delete(_ task: Task) {
        let context = StorageManager.shared.persistentContainer.viewContext
        context.delete(task)
        saveContext()
    }
}
