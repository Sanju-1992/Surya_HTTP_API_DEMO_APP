//
//  ViewController.swift
//  HttpPostApiDemo_Surya
//
//  Created by Toor, Sanju on 30/01/19.
//  Copyright © 2019 Toor, Sanju. All rights reserved.
//

import UIKit
import CoreData

struct Post: Codable {
    let emailId: String
}

class ViewController: UIViewController {
    @IBOutlet weak var itemListTableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var fetchDataButton: UIButton!
    
    var dataProvider: DataProvider!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Users> = {
        let fetchRequest = NSFetchRequest<Users>(entityName:"Users")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending:true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: dataProvider.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.accessibilityIdentifier = "textView"
        itemListTableView.accessibilityIdentifier = "table"
        itemListTableView.delegate = self
        itemListTableView.dataSource = self
    }
    
    @IBAction func fetchDataButton(_ sender: Any) {
            guard let textString = inputTextField.text, !textString.isEmpty else {
                displayAlert("empty text field")
                return
            }
            
            let isValid = isValidEmail(testStr: textString)
            if isValid {
                let myPost = Post(emailId:textString )
                dataProvider.fetchUsersDetails(post: myPost) { (error) in
                    DispatchQueue.main.async {
                        self.itemListTableView.reloadData()
                    }
                }
            } else {
                displayAlert("inValid Email")
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func displayAlert(_ message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ItemListCell else {
            fatalError("Cell not exists in storyboard")
        }
        
        let userDetails = fetchedResultsController.object(at: indexPath)
        let firstName = userDetails.firstName
        let lastName = userDetails.lastName
        let fullName =  "\(firstName) \(lastName)"
        cell.configureListCell(name: fullName, email: userDetails.emailID, imageUrl: userDetails.imageUrl)
        return cell
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        itemListTableView.reloadData()
    }
}

