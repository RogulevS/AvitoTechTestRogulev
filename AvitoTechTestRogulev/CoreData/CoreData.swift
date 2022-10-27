//
//  CoreData.swift
//  AvitoTechTestRogulev
//
//  Created by Rogulev Sergey on 27.10.2022.
//

import Foundation
import CoreData

final class CoreData {
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Employees")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func remove(completion: @escaping () -> Void) {
        self.persistentContainer.performBackgroundTask { context in
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Employee")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                completion()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveEmployee(name: String, phoneNumber: String, skills: [String], doCompletion: @escaping (Employee) -> Void, errorCompletion: @escaping (NSError) -> Void) {
        
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: Employee.description(), in: context) else { return }
        
        let taskObject = Employee(entity: entity, insertInto: context)
        taskObject.name = name
        taskObject.phoneNumber = phoneNumber
        taskObject.skills = skills
        
        do {
            try context.save()
            doCompletion(taskObject)
        } catch let error as NSError {
            errorCompletion(error)
        }
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


