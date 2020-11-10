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
    
    /// Init method that will init and return view controller.
    class func instantiate(dataSource: [String]) -> GalleryViewControllerNEW {
        let viewController = UIStoryboard.main.instantiate(identifier) as! GalleryViewControllerNEW
        viewController.dataSource = dataSource
        return viewController
    }
    
    //MARK:- Globals
    
    @IBOutlet var imageSlider: ImageCarousel!
    @IBOutlet var currentImageNum: UILabel!
    @IBOutlet var allImagesNum: UILabel!
    
    private(set) var dataSource: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSlider.imageURLList = dataSource
        imageSlider.shouldRemoveOverlay = true
        
        imageSlider.delegate = self
        allImagesNum.text = "\(dataSource.count)"
    }
    
    @IBAction func closeButton_onClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension GalleryViewControllerNEW: ImageCarouselDelegate {
//    func didTappedOnHeartAt(index: Int, sender: ImageCarousel) {
//        print("Allah Ho Akbar")
//    }
    
    
    func didMoveTo(position: Int) {
        currentImageNum.text = "\(position + 1)"
    }
    
}
