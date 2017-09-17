//
//  Search.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/11/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
    
    
    
    var searchResults : [SearchResult] = []
    var hasSearched = false
    var isLoading = false
    
    private var dataTask : URLSessionDataTask? = nil
    
    private(set) var state : State = .notSearchedYet
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var entityName : String {
            switch self {
            case .all : return ""
            case .music : return "musicTrack"
            case .software : return "software"
            case .ebooks : return "ebook"
            }
        }
    }
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    func performSearch(for text: String , category: Category, completion: @escaping SearchComplete){
        
        if !text.isEmpty{
            dataTask?.cancel()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
                state = .loading
            
        
            
                let url = iTunesURL(text, category: category)
        
                let session = URLSession.shared
        
                dataTask = session.dataTask(with: url!) { (data, response, error) in
                    self.state = .notSearchedYet
                    var success = false
                    
                    if let error = error as NSError?,error.code == -999{
                        print("error with :\(error)")
                        
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200 ,
                        let jsonData = data , let jsonDictionary = self.parse(json: jsonData){
        
                            let searchResults = self.parse(dictionary: jsonDictionary)
                            if searchResults.isEmpty{
                                self.state = .noResults
                            }else{
                                self.searchResults.sort(by: <)
                                self.state = .results(searchResults)
                            }
                            print("Success")
                            success = true
                    
                    }
        
                    
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        completion(success)
                    }
                }
                dataTask?.resume()
        
        }
    }
    
    func iTunesURL(_ searchText: String, category:Category) -> URL? {
        
        
        let entityName = category.entityName
        let locale = Locale.autoupdatingCurrent
        let language = locale.identifier
        let countryCode = locale.regionCode ?? "en_US"
                
        let escapedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&entity=%@&limit=200&lang=%@&country=%@",escapedText!,entityName,language,countryCode)
        
        let url = URL(string: urlString)
        print(url!)
        return url
    }
    
    func parse(json data :Data) -> [String : Any]? {
        
        do{
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
        }catch {
            print("error")
            return nil
        }
    }
    
    func parse(dictionary : [String : Any]) -> [SearchResult]{
        
        guard let array = dictionary["results"] as? [Any] else {
            print("expected 'results' array")
            return []
        }
        print(array)
        var searchResults = [SearchResult]()
        for resultDict in array {
            if let resultDict = resultDict as? [String : Any]{
                var searchResult : SearchResult?
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track":
                        searchResult = self.parse(track: resultDict)
                    case "audiobook":
                        searchResult = self.parse(audiobook: resultDict)
                    case "software":
                        searchResult = self.parse(software: resultDict)
                    default:
                        break
                    }
                }else if let kind = resultDict["kind"] as? String, kind == "ebook"{
                    searchResult = self.parse(ebook: resultDict)
                }
                if let result = searchResult{
                    searchResults.append(result)
                }
            }
        }
        
        return searchResults
    }
    
    func parse(track dictionary : [String:Any]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        searchResult.genre = dictionary["primaryGenreName"] as! String
        
        return searchResult
        
    }
    
    func parse(audiobook dictionary: [String:Any]) -> SearchResult{
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["collectionPrice"] as? Double{
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String{
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parse(software dictionary : [String: Any]) -> SearchResult{
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double{
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String{
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parse(ebook dictionary: [String:Any]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        
        if let genres = dictionary["genres"] {
            searchResult.genre = ((genres as? [String])?.joined(separator: ", "))!
        }
        
        return searchResult
    }



}
