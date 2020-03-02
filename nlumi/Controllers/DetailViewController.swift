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
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var annotationMarker: UILabel!
    @IBOutlet weak var bookmarkLabel: UIBarButtonItem!
    
    var ptWord = ""
    var trWord = ""
    var laWord = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        
        ptLabel.text = ptWord
        translationLabel.text = trWord
        languageLabel.text = laWord
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        annotationMarker.text = ""
    }

    @IBAction func addBookmark(_ sender: UIBarButtonItem) {
        if self.bookmarkLabel.image == UIImage(systemName: "bookmark.fill") {
            print("yo we are a not favorite atm")
            deleteData()
            retrieveData()
            self.annotationMarker.alpha = 1
            annotationMarker.isHidden = true
            
        } else {
            print("yo we are a favorite atm")
            createData()
            annotationMarker.isHidden = false
            self.annotationMarker.alpha = 1
            retrieveData()
            bookSuccessAnimated()
        }
    }
    
    @IBAction func copyLabel(_ sender: UIButton) {
        UIPasteboard.general.string = trWord
        annotationMarker.isHidden = false
        self.annotationMarker.alpha = 1
        copySuccessAnimated()
    }
    
    func bookSuccessAnimated() {
        //success message
        annotationMarker.text = "Anotado"
        UIView.animate(withDuration: 0.75, delay: 1.0, animations: { () -> Void in
            self.annotationMarker.alpha = 0
        })
    }
    
    func copySuccessAnimated() {
        //success message
        annotationMarker.text = "Copiado"
        UIView.animate(withDuration: 0.75, delay: 1.0, animations: { () -> Void in
            self.annotationMarker.alpha = 0
        })
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
        user.setValue(trWord, forKeyPath: "trNoted")
        user.setValue(laWord, forKeyPath: "laNoted")

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

        do {
            let result = try managedContext.fetch(fetchRequest)
            
            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {
                
                //check if they are saving
                print(data.value(forKeyPath: "ptNoted") as! String)
                print(data.value(forKeyPath: "trNoted") as! String)
                print(data.value(forKeyPath: "laNoted") as! String)
                
                //retrieved data is stored translation term
                let retrievedData = data.value(forKey: "trNoted") as! String
                
                //if coredata word  matches translated term on screen
                if retrievedData == "\(trWord)" {
                    
                    //check if is favorite
                    print("It is a Fav")

                    //change bookmark icon to filled
                    self.bookmarkLabel.image = UIImage(systemName: "bookmark.fill")
                    
                } else {
                    print("Not a Fav")
                    annotationMarker.text = ""
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    //MARK: - Delete Data
    
    func deleteData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Annotations")
        fetchRequest.predicate = NSPredicate(format: "trNoted = %@", trWord)
       
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            //change bookmark icon
            self.bookmarkLabel.image = UIImage(systemName: "bookmark")
            
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
    }
}
