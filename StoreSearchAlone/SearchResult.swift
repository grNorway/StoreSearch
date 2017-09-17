//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/7/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation

private var displayNamesForKind = [
    "album" : NSLocalizedString("Album", comment: "Localized kind : Album"),
    "audiobook" : NSLocalizedString("Audio Book", comment: "Localized kind : Audio Book"),
    "book" : NSLocalizedString("Book", comment: "Localized kind : Book"),
    "ebook" : NSLocalizedString("E-book", comment: "Localized kind : e-book"),
    "feature-movie" :  NSLocalizedString("Movie", comment: "Localized kind : Feature Movie"),
    "music-video" :  NSLocalizedString("Music Video", comment: "Localized kind : Music Video"),
    "podcast" :  NSLocalizedString("Podcast", comment: "Localized kind : podcast"),
    "software" :  NSLocalizedString("App", comment: "Localized kind : Software"),
    "song" :  NSLocalizedString("Song", comment: "Localized kind : Song"),
    "tv-episode" : NSLocalizedString("TV Episode", comment: "TV Episode")
]



class SearchResult {
    
    var name = ""
    var artistName = ""
    var artworkSmallURL = ""
    var artworkLargeURL = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
    
    
    
    
    func kindForDisplay() -> String{
        return displayNamesForKind[kind] ?? kind
    }
    
}



func < (lhs : SearchResult,rhs:SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}

