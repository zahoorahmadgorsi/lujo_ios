//
//  AviationLuggageSelectionViewController.swift
//  LUJO
//
//  Created by Kristian Iker on 9/4/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

class AviationLuggageSelectionViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "AviationLuggageSelectionViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(luggage: AviationLuggage) -> AviationLuggageSelectionViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! AviationLuggageSelectionViewController
        viewController.luggage = luggage
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var luggage: AviationLuggage!
    
    weak var delegate: LuggageSelectionViewDelegate?
    
    @IBOutlet var carryOnLabel: UILabel!
    @IBOutlet var holdLuggageLabel: UILabel!
    @IBOutlet var golfBagLabel: UILabel!
    @IBOutlet var skisLabel: UILabel!
    @IBOutlet var otherLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLuggageLabels()
    }
    
    private func updateLuggageLabels() {
        carryOnLabel.text = String(luggage.carryOn)
        holdLuggageLabel.text = String(luggage.hold)
        golfBagLabel.text = String(luggage.golfBag)
        skisLabel.text = String(luggage.skis)
        otherLabel.text = String(luggage.other)
    }
    
    @IBAction func increase(_ sender: Any) {
        guard let caller = sender as? UIView else {
            print("This is not a button")
            return
        }
        
        switch caller.tag {
        case 1: luggage.carryOn += 1
        case 2: luggage.hold += 1
        case 3: luggage.golfBag += 1
        case 4: luggage.skis += 1
        case 5: luggage.other += 1
        default:
            fatalError("Shouldn't be here")
        }
        
        updateLuggageLabels()
    }
    
    @IBAction func decrease(_ sender: Any) {
        guard let caller = sender as? UIView else {
            print("This is not a button")
            return
        }
        
        switch caller.tag {
        case 1: if luggage.carryOn > 0 { luggage.carryOn -= 1 }
        case 2: if luggage.hold > 0    { luggage.hold -= 1 }
        case 3: if luggage.golfBag > 0 { luggage.golfBag -= 1 }
        case 4: if luggage.skis > 0    { luggage.skis -= 1 }
        case 5: if luggage.other > 0   { luggage.other -= 1 }
        default:
            fatalError("Shouldn't be here")
        }
        
        updateLuggageLabels()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        delegate?.select(luggage)
        dismiss(animated: true, completion: nil)
    }
}
