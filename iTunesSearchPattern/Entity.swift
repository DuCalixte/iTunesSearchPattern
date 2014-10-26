//
//  Entity.swift
//  iTunesSearchPattern
//
//  Created by STANLEY CALIXTE on 10/25/14.
//  Copyright (c) 2014 STANLEY CALIXTE. All rights reserved.
//

import Foundation

class Entity{
    var title: String
    var price: String
    var thumbnailImageURL: String
    var largeImageURL: String
    var itemURL: String
    var authorURL: String
    var collectionId: Int
    
    init(name: String, price: String, thumbnailImageURL: String, largeImageURL: String, itemURL: String, authorURL: String, collectionId: Int)  {
        self.title = name
        self.price = price
        self.thumbnailImageURL = thumbnailImageURL
        self.largeImageURL = largeImageURL
        self.itemURL = itemURL
        self.authorURL = authorURL
        self.collectionId = collectionId
    }
}