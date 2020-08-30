//
//  ChatViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/29/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "ChatViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate() -> ChatViewController {
        return UIStoryboard.main.instantiate(identifier)
    }
    
    //MARK:- Globals
    
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK:- User Interaction
    
    
    //MARK:- Utilities
}
