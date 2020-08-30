//
//  RestaurantRequestReservationViewController.swift
//  LUJO
//
//  Created by Iker Kristian on 8/27/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import Intercom

class RestaurantRequestReservationViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "RestaurantRequestReservationViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(restaurant: Restaurants) -> RestaurantRequestReservationViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! RestaurantRequestReservationViewController
        viewController.restaurant = restaurant
        return viewController
    }
    
    //MARK:- Globals
    
    @IBOutlet var peopleNumber: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var contentViewBottomConstraint: NSLayoutConstraint!
    
    private(set) var restaurant: Restaurants!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        // preparing for initial animation
        contentViewBottomConstraint.constant = -400
        
        setupDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activateKeyboardManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        contentViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.view.updateConstraintsIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func minusButton_onClick(_ sender: Any) {
        if var number = Int(peopleNumber.text ?? ""), number > 0 {
            number -= 1
            peopleNumber.text = "\(number)"
        }
    }
    
    @IBAction func plusButton_onClick(_ sender: Any) {
        if var number = Int(peopleNumber.text ?? "") {
            number += 1
            peopleNumber.text = "\(number)"
        }
    }
    
    @IBAction func sendRequestButton_onClick(_ sender: Any) {
        if datePicker.date > Date() {
            
            guard let restaurant = restaurant else { return }
            guard let userFirstName = LujoSetup().getLujoUser()?.firstName else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateStr = dateFormatter.string(from: datePicker.date)
            dateFormatter.dateFormat = "H:mm"
            let timeStr = dateFormatter.string(from: datePicker.date)
            
            GoLujoAPIManager.shared.sendRequestForSalesForce(itemId: restaurant.id, date: dateStr, time: timeStr, persons: Int(peopleNumber.text!) ?? 1)
            
            dateFormatter.dateFormat = "E, MMM d 'at' H:mm a"
            
            let initialMessage = """
            Hi Concierge team,
            
            I would like to book a table for \(peopleNumber.text!) \(Int(peopleNumber.text!) ?? 1 > 1 ? "people" : "person"), at \(restaurant.name), \(restaurant.location.first?.city?.name ?? "No city") on \(dateFormatter.string(from: datePicker.date)).
            
            \(userFirstName)
            """
            
            if let presentingViewController = self.presentingViewController {
                self.dismiss(animated: true) {
                    presentingViewController.startChatWithInitialMessage(initialMessage)
                }
            }
            
        } else {
            showInformationPopup(withTitle: "Info", message: "Please, select date in future.")
        }
    }
    
    @objc func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            contentViewBottomConstraint.constant = -400
            UIView.animate(withDuration: 0.25, animations: {
                self.view.updateConstraintsIfNeeded()
                self.view.layoutIfNeeded()
            }) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func setupDatePicker() {
        for subview in datePicker.subviews {
            if subview.frame.height <= 5 {
                subview.backgroundColor = UIColor.white
                subview.tintColor = UIColor.white
                subview.layer.borderColor = UIColor.white.cgColor
                subview.layer.borderWidth = 0.5
            }
        }
        
        if let pickerView = self.datePicker.subviews.first {
            for subview in pickerView.subviews {
                if subview.frame.height <= 5 {
                    subview.backgroundColor = UIColor.white
                    subview.tintColor = UIColor.white
                    subview.layer.borderColor = UIColor.white.cgColor
                    subview.layer.borderWidth = 0.5
                }
            }
            datePicker.setValue(UIColor.white, forKey: "textColor")
        }
        
        datePicker.minimumDate = Date()
    }
}
