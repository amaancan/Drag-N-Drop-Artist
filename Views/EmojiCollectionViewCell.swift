//
//  EmojiCollectionViewCell.swift
//  DragNDropArtist
//
//  Created by Amaan on 2018-08-19.
//  Copyright © 2018 amaancan. All rights reserved.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var label: UILabel!
    
    private var font: UIFont {
        // TODO: preferred fontSize should cause collectionView (and it's cells') size to expand and dynmaically accomodate large fontSize
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    
    func configure(using emoji: String) {
        let text = NSAttributedString(string: emoji, attributes: [.font: font])
        
        label.attributedText = text
    }
}
