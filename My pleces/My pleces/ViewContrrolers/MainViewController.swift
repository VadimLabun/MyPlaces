//
//  MainViewController.swift
//  My pleces
//
//  Created by Vadim Labun on 8/28/19.
//  Copyright © 2019 Vadim Labun. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITabBarDelegate, UITableViewDelegate {
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredPlaces: Results<Place>!
    private var places: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var sortingButton: UIBarButtonItem!
    
    var token: NotificationToken?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        token = places.observe { (change) in
            self.tableView.reloadData()
        }
        
//        Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CasstomTableViewCell
        
        let place: Place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLable.text = place.location
        cell.typeLabel.text = place.type
        
        if let image = place.imageData {
            cell.imageOfPlaces.image = UIImage(data: image)
        } else {
            cell.imageOfPlaces.image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        cell.cosmosView.rating = place.rating

        return cell
    }
    //    MARK: - Table View Deleget
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delet") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place: Place
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.curentPlace = place
        }
    }
    
    @IBAction func unwinSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.sevePlace()
        //tgtableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reverstSorting(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        if ascendingSorting {
            sortingButton.image = #imageLiteral(resourceName: "AZ")
        }else{
            sortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    
    private func sorting(){
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        }else{
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
}
