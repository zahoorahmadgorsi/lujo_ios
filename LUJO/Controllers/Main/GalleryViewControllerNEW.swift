//
//  GalleryViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/28/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class GalleryViewControllerNEW: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "GalleryViewControllerNEW" }
    var scrollToItem:Int = 0
    var product: Product?
    
    /// Init method that will init and return view controller.
    class func instantiate(product: Product?, dataSource: [String], scrollToItem:Int = 0) -> GalleryViewControllerNEW {
        let viewController = UIStoryboard.main.instantiate(identifier) as! GalleryViewControllerNEW
        viewController.product = product
        viewController.dataSource = dataSource
        viewController.scrollToItem = scrollToItem
        return viewController
    }
    
    //MARK:- Globals
    
    @IBOutlet var imageCarousel: ImageCarousel!
    @IBOutlet var currentImageNum: UILabel!
    @IBOutlet var allImagesNum: UILabel!
    
    private(set) var dataSource: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCarousel.shouldRemoveOverlay = true
        imageCarousel.delegate = self
        imageCarousel.product = self.product
        imageCarousel.imageURLList = dataSource
        imageCarousel.scrollToItem = scrollToItem   //after this index counting isn't working properly due to a bug in ios14
        allImagesNum.text = "\(dataSource.count)"
    }
    
    @IBAction func closeButton_onClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension GalleryViewControllerNEW: ImageCarouselDelegate {
    func didTappedOnHeartAt(index: Int, sender: ImageCarousel) {
        print("Allah Ho Akbar")
    }
    
    
    func didMoveTo(position: Int) {
        currentImageNum.text = "\(position + 1)"
    }
    
}
