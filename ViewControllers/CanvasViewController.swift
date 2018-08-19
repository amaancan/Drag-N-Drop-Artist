//
//  CanvasViewController.swift
//  DragNDropArtist
//
//  Created by Amaan on 2018-08-18.
//  Copyright © 2018 amaancan. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController {
    // MARK: - OUTLETS
    // 1) keeping track of URLs happens in controller, don't want view to know this info 2) scrollView
    @IBOutlet weak var dropZoneView: UIView! {
        didSet {
            // view's interaction obj passes user drag/drop data to it's delegate (self) via args in func call,
            // so that delegate can: a) use data and do sth with it (update it's own UI) OR b) pass back some data only it knows how to produce (e.g. canHandle)
            // view (delegator) decides when to call the func since it's receiving user's events
            dropZoneView.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(canvasView)
        }
    }
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet {
            // Must do when hook up a CV/TV that's not pre-packaged w/ it's VC
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
        }
    }
    
    // MARK: - MEMBER VARS
    var canvasView = CanvasView()
    var imageFetcher: ImageFetcher!
    var canvasBackgroundImage: UIImage? {
        get {  return canvasView.backgroundImage  }
        set {
            scrollView.zoomScale = 1.0 // reset for new image
            canvasView.backgroundImage = newValue
            
            // new background image's size dictates size of: 1) it's canvasView 2) scrollView's contentSize
            let size = newValue?.size ?? CGSize.zero
            canvasView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            setScrollViewSizeEqualToItsContentSize()
            
            if let dropZoneView =
                self.dropZoneView, // Question: don't need this since implicitly unwrapped?
                size.width > 0, 
                size.height > 0 {
            
                scrollView?.zoomScale = max(
                    // sets zoomScale so contentSize fills up either width or height of scrollView every time, whichever is smaller
                    dropZoneView.bounds.size.width / size.width,
                    dropZoneView.bounds.size.height / size.height)
            }
        }
    }
    
    // collectionView's model
    var emojis = "😀🎃🤖👾👻💀👽😻👀👅🐱🦁🐝🦄🌲🌳🌴🌹🍄🌻🌼🌙✨🌈☀️☁️🌧🍎🚗🚲🏎🚀🚁🏡🎁❤️🇨🇦".map { String($0) }
    
    // MARK: - HELPER FUNCTIONS
    private func setScrollViewSizeEqualToItsContentSize() {
        // Question: optionally chain in case it gets called from prepare(for segue:)
        scrollViewHeight?.constant = scrollView.contentSize.height
        scrollViewWidth?.constant = scrollView.contentSize.width
    }
}

extension CanvasViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        
        // chose not to optionally bind because confident it'll be able to do this stuff for the indexPath given
        let draggedCell = emojiCollectionView.cellForItem(at: indexPath) as! EmojiCollectionViewCell
        let draggedEmoji = draggedCell.label.attributedText!
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: draggedEmoji))
        
        // for drops w/in app it'll use this property instead of having to implement UIDropInteractionDelegate methods like we did for canvasView
        dragItem.localObject = draggedEmoji
        
        return [dragItem]
    }
}


extension CanvasViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! EmojiCollectionViewCell
        
        cell.configure(using: emojis[indexPath.item])
        return cell
    }
    
    
}


extension CanvasViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setScrollViewSizeEqualToItsContentSize()
    }
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
                self.canvasBackgroundImage = image
                // TODO: will save url later
            }
        })
        
        // Give me classes that conform to NSURLProvider and do closure using an array of said objects (urls, images)
        session.loadObjects(ofClass: NSURL.self) { [unowned self] (nsurls) in // Question: Do I need unowned self here, since I'm w/in scope of func?
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url) // Question: what's the point of fetching if we're saving the image itself anyway?
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { [unowned self] (images) in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
}
