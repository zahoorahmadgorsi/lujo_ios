//
//  ChatOptionsViewController.swift
//  LUJO
//
//  Created by iMac on 08/09/2021.
//  Copyright © 2021 Baroque Access. All rights reserved.
//

import UIKit

class ChatOptionsViewController: UIViewController {
    
    /// Class storyboard identifier.
    class var identifier: String { return "ChatOptionsViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> ChatOptionsViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! ChatOptionsViewController
        return viewController
    }
    @IBOutlet weak var imgCross: UIImageView!
    @IBOutlet weak var innerContentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.innerContentView.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 0.0, borderCornerRadius: 18.0)
        //tap gesture on cross button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgCrossTapped))
        imgCross.isUserInteractionEnabled = true
        imgCross.addGestureRecognizer(tapGesture)

    }
    
    @objc func imgCrossTapped(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    
    @IBAction func btnFindATableTapped(_ sender: Any) {
        print("btnFindATableTapped")
    }
    
    @IBAction func btnEventTapped(_ sender: Any) {
        print("btnEventTapped")
    }
    
    @IBAction func btnAviationTapped(_ sender: Any) {
        print("btnAviationTapped")
    }
    
    @IBAction func btnCharterAYachtTapped(_ sender: Any) {
        print("btnCharterAYachtTapped")
    }
    
    @IBAction func btnVillaTapped(_ sender: Any) {
        print("btnVillaTapped")
    }
    
    @IBAction func btnTravelTapped(_ sender: Any) {
        print("btnTravelTapped")
    }
}
