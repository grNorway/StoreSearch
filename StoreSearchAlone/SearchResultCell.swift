//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/7/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    var downloadTask : URLSessionDownloadTask?
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1.0)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(searchResult : SearchResult){
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty{
            artistLabel.text = NSLocalizedString("uknown", comment: "artistNameLabel.text : unknown")
        }else{
            artistLabel.text = String(format:NSLocalizedString("ARTIST_NAME_LABEL_FORMAT", comment: "format for the artist Label") , searchResult.artistName,searchResult.kindForDisplay())
        }
        artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string:searchResult.artworkSmallURL){
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
    
    override func prepareForReuse() {
        downloadTask?.cancel()
        downloadTask = nil
    }


}
