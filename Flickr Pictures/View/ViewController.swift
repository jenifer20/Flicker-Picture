//
//  ViewController.swift
//  Flickr Pictures
//
//  Created by jenifer_s on 27/01/23.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var recentSarch = [String]()
    var isShowREcentSearch: Bool = false
    
    var flickrImageUrl = [URL]()
    var flickrImageTitle = [String]()
    var flickrImageThumbnail = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flickr Pictures"
        tableViewSetup()
        searchBarSetup()
    }
    
    func tableViewSetup() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = self.view.frame.size.height/3
        tableView.keyboardDismissMode = .onDrag
    }
    
    func searchBarSetup() {
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        isShowREcentSearch = true
        self.tableView.reloadData()
        return true
    }
    
    //MARK: tableView DataSource and Delegae methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowREcentSearch {
            return recentSarch.count
        }
        return self.flickrImageUrl.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowREcentSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
            cell.textLabel?.text = recentSarch[indexPath.row]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoTableViewCell
        cell.url = self.flickrImageThumbnail[indexPath.row]
        cell.titleLabel.text = self.flickrImageTitle[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isShowREcentSearch {
            recentSearchTapped(recenttext: recentSarch[indexPath.row])
        } else {
            let url = self.flickrImageUrl[indexPath.row]
            let nextVC = storyboard?.instantiateViewController(withIdentifier: "photoVC") as! PhotoViewController
            nextVC.url = url
            nextVC.title = self.flickrImageTitle[indexPath.row]
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isShowREcentSearch {
            return 30
        } else {
            return 150
        }
    }
}

extension ViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {return}
        
        recentSearchTapped(recenttext:searchText)
    }
    
    func recentSearchTapped(recenttext:String) {
        
        let searchText = recenttext
        self.searchBar.text = recenttext
        if searchText == "" {
            
        } else {
            if !recentSarch.contains(searchText) {
                recentSarch.append(searchText)
            }
            if recentSarch.count > 5 {
                recentSarch.remove(at: 0)
            }
            
            let requestURL = FlickrAPI.buildRequestURL(text: searchText)
            FlickrAPI.downloadData(with: requestURL) { data, error in
                guard let data = data, let json = try? JSON(data:data) else {
                    print("failed to download data from Flickr, error:\(String(describing: error?.localizedDescription))")
                    return
                }
                
                let response = FlickrAPI.parseJSON_Search(with: searchText, json: json)
                self.flickrImageThumbnail = response.thumbnail
                self.flickrImageUrl = response.url
                self.flickrImageTitle = response.title
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        DispatchQueue.main.async {
            self.searchBar.resignFirstResponder()
            self.isShowREcentSearch = false
            self.tableView.reloadData()
        }
    }
}
