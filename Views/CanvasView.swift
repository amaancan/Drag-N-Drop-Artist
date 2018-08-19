//
//  CanvasView.swift
//  DragNDropArtist
//
//  Created by Amaan on 2018-08-18.
//  Copyright © 2018 amaancan. All rights reserved.
//

import UIKit

class CanvasView: UIView { // Question: Should be an ImageView?

    var backgroundImage: UIImage? {
        didSet {
            setNeedsDisplay() // calls draw(_ rect)
        }
    }

    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }


}
