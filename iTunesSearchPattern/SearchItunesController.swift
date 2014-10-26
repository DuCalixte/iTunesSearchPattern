//
//  SearchItunesController.swift
//  iTunesSearchPattern
//
//  Created by STANLEY CALIXTE on 10/25/14.
//  Copyright (c) 2014 STANLEY CALIXTE. All rights reserved.
//

import Foundation
import UIKit

class SearchItunesController: UIViewController,  UITableViewDataSource, UITableViewDelegate, ITunesAPIControllerProtocol {
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet var tableView : UITableView?
    @IBOutlet weak var searchField: UITextField!
    
    let kCellIdentifier: String = "SearchResultCell"
    var api : ITunesAPIController?
    var imageCache = [String : UIImage]()
    var albums = [Album]()
    var entities = [Entity]()
    var mediaOption: String = "music"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        api = ITunesAPIController(delegate: self)
        
        self.tableView?.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin

//        UIViewAutoresizingFlexibleTopMargin;
//        UIViewAutoresizingFlexibleHeight;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
//        self.tableView.delegate = self
        self.tableView.showsVerticalScrollIndicator=true
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        api!.searchItunesFor("Beatles", mediaType: self.mediaOption)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        switch self.mediaOption{
        case "music":
            count = self.albums.count
            break;
        default:
            count = self.entities.count
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell: UITableViewCell = (tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell?)!
        switch self.mediaOption{
        case "music":
            self.setCellFromAlbum(tableView, displayCell: cell, forRowAtIndexPath: indexPath)
            break;
        default:
            break;
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    
    func setCellFromAlbum(tableView: UITableView, displayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let album = self.albums[indexPath.row]
        cell.textLabel.text = album.title
        cell.imageView.image = UIImage(named: "Blank52")
        
        // Get the formatted price string for display in the subtitle
        let formattedPrice = album.price
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString = album.thumbnailImageURL
        
        // Check our image cache for the existing key. This is just a dictionary of UIImages
        //var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
        var image = self.imageCache[urlString]
        
        
        if( image == nil ) {
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: urlString)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    cellToUpdate.imageView.image = image
                }
            })
        }
        
        cell.detailTextLabel?.text = formattedPrice
    }

    
    func didReceiveAPIResults(results: NSDictionary){
        switch self.mediaOption{
        case "music":
            self.updateAlbumsContent(results)
            break;
        default:
            break;
        }
        
    }
    
    func updateAlbumsContent(results: NSDictionary){
        var resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.albums = Album.albumsWithJSON(resultsArr)
            self.tableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    
    
    @IBAction func onOptionChange(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            mediaOption = "music"
            break;
        case 1:
            mediaOption = "movie"
        default:
            mediaOption = "all"
        }
    }
    
    @IBAction func onSearch(sender: UIButton) {
        if self.searchField.text != ""{
            api!.searchItunesFor(self.searchField.text, mediaType: self.mediaOption)
        }
    }
}
