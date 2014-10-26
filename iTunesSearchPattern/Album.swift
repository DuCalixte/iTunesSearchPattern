//
//  Album.swift
//  iTunesSearchPattern
//
//  Created by STANLEY CALIXTE on 10/26/14.
//  Copyright (c) 2014 STANLEY CALIXTE. All rights reserved.
//

import Foundation

class Album: Entity {
    
    class func albumsWithJSON(allResults: NSArray) -> [Album] {
        
        // Create an empty array of Albums to append to from this list
        var albums = [Album]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                
                var name = result["trackName"] as? String
                if name == nil {
                    name = result["collectionName"] as? String
                }
                
                // Sometimes price comes in as formattedPrice, sometimes as collectionPrice.. and sometimes it's a float instead of a string. Hooray!
                var price = result["formattedPrice"] as? String
                if price == nil {
                    price = result["collectionPrice"] as? String
                    if price == nil {
                        var priceFloat: Float? = result["collectionPrice"] as? Float
                        var nf: NSNumberFormatter = NSNumberFormatter()
                        nf.maximumFractionDigits = 2
                        if priceFloat != nil {
                            price = "$"+nf.stringFromNumber(priceFloat!)!
                        }
                    }
                }
                
                let thumbnailURL = result["artworkUrl60"] as? String ?? ""
                let imageURL = result["artworkUrl100"] as? String ?? ""
                let artistURL = result["artistViewUrl"] as? String ?? ""
                
                var itemURL = result["collectionViewUrl"] as? String
                if itemURL == nil {
                    itemURL = result["trackViewUrl"] as? String
                }
                
                var collectionId = result["collectionId"] as? Int
                
                var newAlbum = Album(name: name!, price: price!, thumbnailImageURL: thumbnailURL, largeImageURL: imageURL, itemURL: itemURL!, authorURL: artistURL, collectionId: collectionId!)
                albums.append(newAlbum)
                
            }
        }
        return albums
    }
}
