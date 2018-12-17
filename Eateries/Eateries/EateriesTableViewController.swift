//
//  EateriesTableViewController.swift
//  Eateries
//
//  Created by User on 27.06.18.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import CoreData

class EateriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var fetchResultsController: NSFetchedResultsController<EateriesClass>!
    var searchController: UISearchController!
    var filteredResultArray: [EateriesClass] = []
    var eateries: [EateriesClass] = []
    
    //        EateriesClass(name: "Momento", location : "Kiev, Zlatoustivska st. 2/4", image : "momento.jpg", isVisited : false, type : "pizzeria"),
    //        EateriesClass(name: "Mario", location : "Kiev, Saksahanskoho st. 117", image : "mario.jpg",isVisited : false, type : "pizzeria"),
    //        EateriesClass(name: "ilMolino", location : "Kiev, Saksahanskoho st. 120", image : "ilmolino.jpg",isVisited : false, type : "pizzeria"),
    //        EateriesClass(name: "Dominos", location : "Kiev, Saksahanskoho st. 68/21", image : "dominos.jpg",isVisited : false, type : "pizzeria"),
    //        EateriesClass(name: "Murakami", location : "Kiev, Velyka Vasylkivska st. 57/3", image : "murakami.jpg",isVisited : false, type : "sushi"),
    //        EateriesClass(name: "Ukr dishes", location : "Kiev, Vidradnyi Avenue 22", image : "ukrdishes.jpg",isVisited : false, type : "ukrainian kitchen"),
    //        EateriesClass(name: "Two beavers", location : "Kyiv region, Vyshneve district, Mila Village", image : "twobeavers.jpg",isVisited : false, type : "restaurant"),
    //        EateriesClass(name: "Rukkola", location : "Kiev, Peremohy Avenue 33/1", image : "rukkola.jpg",isVisited : false, type : "pizzeria"),
    //        EateriesClass(name: "Tiger", location : "Kiev, Vadyma Hetmana st. 4", image : "tiger.jpg",isVisited : false, type : "pizzeria"),
    //        EateriesClass(name: "Mr.Cat", location : "Kiev, Velyka Vasylkivska st. 72", image : "mrcat.jpg",isVisited : false, type : "pizzeria"),
    //        EateriesClass(name: "Maffia", location : "Kiev, Velyka Vasylkivska st. 76", image : "mafia.jpg",isVisited : false, type : "pizzeria"),
    //        EateriesClass(name: "Kozachok", location : "Kiev, Tsentralna st. 11", image : "kozachok.jpg",isVisited : false, type : "ukrainian kitchen"),
    //        EateriesClass(name: "Pervak", location : "Kiev, Rognidunska st. 2", image : "pervak.jpg",isVisited : false, type : "ukrainian kitchen"),
    //        EateriesClass(name: "Spezzo", location : "Kiev, Rusanivska Embankment 8", image : "spezzo.jpg",isVisited : false, type : "pizzeria"),
    //        EateriesClass(name: "Dogs&Tails", location : "Kiev, Shota Rustaveli st. 19", image : "dogsandtails.jpg",isVisited : false, type : "grill-bar")]
    
    
    @IBAction func close(segue: UIStoryboardSegue) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = true
    }
    
    func filterContentFor(searchText text: String) {
        filteredResultArray = eateries.filter { (restaurant) -> Bool in
            return (restaurant.name?.lowercased().contains(text.lowercased()))!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        searchController.searchBar.tintColor = .white
        
        definesPresentationContext = true // search controller не переходит на следующий экран
        
        tableView.estimatedRowHeight = 85
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // create fetch request with descriptor
        let fetchRequest: NSFetchRequest<EateriesClass> = EateriesClass.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true) // sorting
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // getting context
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
            // creating fetch result controller
            fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultsController.delegate = self
            
            // trying to retrieve (получить) data
            do {
                try fetchResultsController.performFetch()
                // save retrieved data into eateries array
                eateries = fetchResultsController.fetchedObjects!
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        let userDefaults = UserDefaults.standard
        let wasIntroWatched = userDefaults.bool(forKey: "wasIntroWatched")
        
        guard !wasIntroWatched else { return }
        
        if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "pageViewController") as? PageViewController {
            present(pageViewController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Fetch results controller delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert: guard let indexPath = newIndexPath else { break }
        tableView.insertRows(at: [indexPath], with: .fade)
        case .delete: guard let indexPath = newIndexPath else { break }
        tableView.deleteRows(at: [indexPath], with: .fade)
        case .update: guard let indexPath = newIndexPath else { break }
        tableView.reloadRows(at: [indexPath], with: .fade)
        default:
            tableView.reloadData()
        }
        
        eateries = controller.fetchedObjects as! [EateriesClass]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Table view data source
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredResultArray.count
        }
        return eateries.count
    }
    
    func restaurantToDisplayAt(indexPath: IndexPath) -> EateriesClass {
        let restaurant: EateriesClass
        
        if searchController.isActive && searchController.searchBar.text != "" {
            restaurant = filteredResultArray[indexPath.row]
        } else {
            restaurant = eateries[indexPath.row]
        }
        return restaurant
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EateriesTableViewCell
        
        let restaurant = restaurantToDisplayAt(indexPath: indexPath)
        
        cell.cellImageView.image = UIImage(data: restaurant.image! as Data)
        cell.cellImageView.layer.cornerRadius = 32.5
        cell.cellImageView.clipsToBounds = true
        cell.NameLabel.text = restaurant.name
        cell.LocationLabel.text = restaurant.location
        cell.TypeLabel.text = restaurant.type
        
        cell.accessoryType = restaurant.isVisited ? .checkmark : .none
        
        //cell.backgroundColor = #colorLiteral(red: 0.8274518023, green: 0.9509440683, blue: 0.9764705896, alpha: 1)
        //cell.layoutMargins.bottom = 1
        return cell
    }
    
    
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //
    //        if editingStyle == .delete {
    //            self.eateries.remove(at: indexPath.row)
    //        }
    //        tableView.deleteRows(at: [indexPath], with: .fade)
    //    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            
            let defaultText = "I'm at " + self.eateries[indexPath.row].name! + " now"
            if let image = UIImage(data: self.eateries[indexPath.row].image! as Data) {
                let activityController = UIActivityViewController(activityItems: [defaultText, image], applicationActivities: nil)
                
                self.present(activityController, animated: true, completion: nil)
            }
        }
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.eateries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
                
                let objectToDelete = self.fetchResultsController.object(at: indexPath)
                context.delete(objectToDelete)
                
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        share.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        delete.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return [delete, share]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let dvc = segue.destination as! EateryDetailViewController
                dvc.restaurant = restaurantToDisplayAt(indexPath: indexPath)
            }
        }
    }
    
    
}

extension EateriesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentFor(searchText: searchController.searchBar.text!)
        tableView.reloadData()
    }
}

extension EateriesTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            navigationController?.hidesBarsOnSwipe = false
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        navigationController?.hidesBarsOnSwipe = true
    }
}





