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
    @IBOutlet weak var annotationMarker: UILabel!
    @IBOutlet weak var bookmarkLabel: UIBarButtonItem!
    @IBOutlet weak var imgLanguageLabel: UIImageView!
    
    let data = DictionaryLoader().dictionary
    
    var ptWord = ""
    var trWord = ""
    var laWord = ""
    var laHolder = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide nav bar shadow
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")

        ptLabel.text = ptWord
        translationLabel.text = trWord
        //languageLabel.text = laWord
        
        if laWord == "Português > Changana" {
            imgLanguageLabel.image = UIImage(named: "translate_cha.pdf")
        } else if laWord == "Português > Macua" {
            imgLanguageLabel.image = UIImage(named: "translate_mac.pdf")
        } else {
            imgLanguageLabel.image = UIImage(named: "translate_xir.pdf")
        }
        
        retrieveData()
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        print("viewDidAppear is running")
//        retrieveData()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("viewWillAppear is running")
        annotationMarker.text = ""
        retrieveData()
    }


    @IBAction func addBookmark(_ sender: UIBarButtonItem) {
        if self.bookmarkLabel.image == UIImage(systemName: "bookmark.fill") {
            //print("yo we are a not favorite atm")
            deleteData()
            retrieveData()
            self.annotationMarker.alpha = 1
            annotationMarker.isHidden = true
            
        } else {
            //print("yo we are a favorite atm")
            createData()
            retrieveData()
            annotationMarker.isHidden = false
            self.annotationMarker.alpha = 1
            
            bookSuccessAnimated()
        }
    }
    
    @IBAction func copyLabel(_ sender: UIBarButtonItem) {
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
        
        //get date
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = formatter.string(from: date)
        
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
        user.setValue(currentDate, forKeyPath: "dateNoted")

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
            //print(result)
            
            //if there are no stored items remove 
            if result.isEmpty {
                //print("there is no stuff")
                self.bookmarkLabel.image = UIImage(systemName: "bookmark")
            }
            
            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {
                
                //check if they are saving
//                print(data.value(forKeyPath: "ptNoted") as! String)
//                print(data.value(forKeyPath: "trNoted") as! String)
//                print(data.value(forKeyPath: "laNoted") as! String)
//                print(data.value(forKeyPath: "dateNoted") as! String)
                
                //retrieved data is stored translation term
                let retrievedData = data.value(forKey: "ptNoted") as! String
                
                //if coredata word  matches portuguese term on screen
                if retrievedData.contains("\(ptWord)") == true {
                    
                    //check if is favorite
                    //print("It is a Fav")

                    //change bookmark icon to filled
                    self.bookmarkLabel.image = UIImage(systemName: "bookmark.fill")
                    
                } else {
                    //print("Not a Fav")
                    self.bookmarkLabel.image = UIImage(systemName: "bookmark")
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
            
            //check if there are items to delete to prevent crash
            let checkist = test.count
            if checkist <= 0 {
                //print("blimey")
            } else {
                let objectToDelete = test[0] as! NSManagedObject
                managedContext.delete(objectToDelete)
            }
            
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
