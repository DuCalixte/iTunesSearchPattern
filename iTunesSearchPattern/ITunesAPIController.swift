//
//  ITunesAPIController.swift
//  iTunesSearchPattern
//
//  Created by STANLEY CALIXTE on 10/25/14.
//  Copyright (c) 2014 STANLEY CALIXTE. All rights reserved.
//

import Foundation

protocol ITunesAPIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
}

class ITunesAPIController {
    
    var delegate: ITunesAPIControllerProtocol
    
    init(delegate: ITunesAPIControllerProtocol) {
        self.delegate = delegate
    }
    
    func get(path: String) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            let results: NSArray = jsonResult["results"] as NSArray
            self.delegate.didReceiveAPIResults(jsonResult) // THIS IS THE NEW LINE!!
        })
        task.resume()
    }
    
    func searchItunesFor(searchTerm: String, mediaType: String) {
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        var association = ""
        
        switch mediaType.lowercaseString{
        case "music":
            association = "media=music&entity=album"
            break;
        case "movie":
            association = "media=movie&entity=movie"
        case "podcast":
            association = "media=podcast&entity=podcast"
        case "software":
            association = "media=software&entity=software"
        case "ebook":
            association = "media=ebook&entity=ebook"
        default:
            association = "media=all&entity=album"
        }
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&\(association)"
//            let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music&entity=album"
            get(urlPath)
        }
    }
    
    func lookupAlbum(collectionId: Int) {
        get("https://itunes.apple.com/lookup?id=\(collectionId)&entity=song")
    }
    
}
