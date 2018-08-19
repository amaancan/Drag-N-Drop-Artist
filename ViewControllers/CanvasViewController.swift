//
//  CanvasViewController.swift
//  DragNDropArtist
//
//  Created by Amaan on 2018-08-18.
//  Copyright © 2018 amaancan. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController {

    // 1) keeping track of URLs happens in controller, don't want view to know this info 2) scrollView
    @IBOutlet weak var dropZoneView: UIView! {
        didSet {
            dropZoneView.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    @IBOutlet weak var canvasView: CanvasView!
    
    var imageFetcher: ImageFetcher!
  
}

extension CanvasViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        
        // NSURL is Obj-C class, URL is Swift struct. Can "as" one to another. But here we want the class itself, not instance
        
        // I'm only interested in getting an image+url otw, won't proceed to funcs below
        return session.canLoadObjects(ofClass: NSURL.self)
            && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        // Always accepting iamges from outside our app, .move is for w/in app only but don't need that here
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        // ImageFetcher: takes a url, makes sure it is an image, fetches it's image, calls handler you provide, sets backup image if fetch fails
        imageFetcher = ImageFetcher(handler: { (url, image) in
            DispatchQueue.main.async {
                self.canvasView.backgroundImage = image
                // TODO: will save url later
            }
        })
        
        // Give me classes that conform to NSURLProvider and do closure using an array of said objects (urls, images)
        session.loadObjects(ofClass: NSURL.self) { [unowned self] (nsurls) in
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { (images) in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
}
