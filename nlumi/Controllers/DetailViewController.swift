//
//  DetailViewController.swift
//  nlumi
//
//  Created by Paulo Custódio on 25/02/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var ptLabel: UILabel!
    @IBOutlet weak var grammarLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var annotationMarker: UILabel!
    
    var ptWord = ""
    var trWord = ""
    var laWord = ""
    var grWord = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ptLabel.text = ptWord
        grammarLabel.text = grWord
        translationLabel.text = trWord
        languageLabel.text = laWord
    
        retrieveData()
    }

    
    @IBAction func addBookmark(_ sender: UIBarButtonItem) {
        createData()
        retrieveData()
    }
    
    
    //MARK: - Create Data
    func createData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "Annotations", in: managedContext)!
        
        //finally, we need to add some data to our newly created record for each keys
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue(ptWord, forKeyPath: "ptNoted")
        user.setValue(trWord, forKey: "trNoted")

        //Now we have set all the values. The next step is to save them inside the Core Data
        do {
            try managedContext.save()
           
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Retrieve Data
    
    func retrieveData() {
            
            //As we know that container is set up in the AppDelegates so we need to refer that container.
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            //We need to create a context from this container
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //Prepare the request of type NSFetchRequest  for the entity
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotations")
            
    //        fetchRequest.fetchLimit = 1
    //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
    //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]

            do {
                let result = try managedContext.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    
                    print(data.value(forKey: "ptNoted") as! String)
                    print(data.value(forKey: "trNoted") as! String)
                    
                    let retrievedData = data.value(forKey: "ptNoted") as! String
                    
                    if retrievedData == "\(ptWord)" {
                        print("It is a Fav")
                        annotationMarker.text = "Anotado"
                        
                    } else {
                        print("Not a Fav")
                        annotationMarker.text = ""
                    }
                }
                
            } catch {
                
                print("Failed")
            }
        }
    
}
