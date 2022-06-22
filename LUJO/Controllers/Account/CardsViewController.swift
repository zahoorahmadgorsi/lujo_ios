//
//  cardsViewController.swift
//  LUJO
//
//  Created by Zahoor Gorsi on 22/06/2022.
//  Copyright © 2022 Baroque Access. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import FirebaseCrashlytics

class CardsViewController: UIViewController {
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "CardsViewController" }
    private let naHUD = JGProgressHUD(style: .dark)
    var cards = [Card](){
        didSet{
            tblView.reloadData()
        }
    }
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var viewAddANewCard: UIView!
    @IBOutlet weak var txtNameOnCard: LujoTextField!
    @IBOutlet weak var txtCardNumber: LujoTextField!
    @IBOutlet weak var txtCVV: LujoTextField!
    @IBOutlet weak var txtYY: LujoTextField!
    @IBOutlet weak var txtMM: LujoTextField!
    @IBOutlet weak var viewSetAsDefault: UIView!
    
    @IBOutlet weak var lblSetAsDefault: UILabel!
    @IBOutlet weak var btnAddANewCard: ActionButton!
    
    /// Init method that will init and return view controller.
    class func instantiate() -> CardsViewController {
        return UIStoryboard.accountNEW.instantiate(identifier)
    }
    var deleteIndexPath: IndexPath? = nil //used while deleting at swipe left
    var boolSetAsDefault:Bool = false
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 24.0)
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.title = "Cards"
        
        //adding tap gesture and border around "set as default"
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnViewSetAsDefault (_:)))
        self.viewSetAsDefault.addGestureRecognizer(gesture)
        viewSetAsDefault.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.getCards()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func tappedOnViewSetAsDefault(_ sender:UITapGestureRecognizer){
        boolSetAsDefault = !boolSetAsDefault
        if (boolSetAsDefault == true){
            self.viewSetAsDefault.backgroundColor = UIColor.rgMid
            self.lblSetAsDefault.textColor = UIColor.white
        }else{
            self.viewSetAsDefault.backgroundColor = UIColor.clear
            self.lblSetAsDefault.textColor = UIColor.rgMid
        }
    }
    
    func getCards() {
        if (self.cards.count == 0){
            self.showNetworkActivity()  //if no data is cached then fetch openly else silently
        }
        getCards() {cards, error in
            self.hideNetworkActivity()
            if let error = error {
                self.showError(error)
                return
            }
            if let informations = cards {
                if informations.count > 0{  //it will contain zero in case of hard coded values
                    self.cards = informations
                    self.tblView.reloadData()
                }
            } else {
                let error = BackendError.parsing(reason: "Could not obtain the list of cards")
                self.showError(error)
            }
        }
    }
    
    func getCards(completion: @escaping ([Card]?, Error?) -> Void) {
        GoLujoAPIManager().getCards() { cards, error in
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                let error = BackendError.parsing(reason: "Could not obtain the list of cards")
                completion(nil, error)
                return
            }
            completion(cards, error)
        }
    }
    
    func showError(_ error: Error , isInformation:Bool = false) {
        if (isInformation){
            showErrorPopup(withTitle: "Information", error: error)
        }else{
            showErrorPopup(withTitle: "Card Error", error: error)
        }
        
    }
    
    func showNetworkActivity() {
        // Safe guard to that won't display both loaders at same time.
            naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        // Safe guard that will call dismiss only if HUD is shown on screen.
        if naHUD.isVisible {
            naHUD.dismiss()
        }
    }
    
    @IBAction func btnAddANewCardTapped(_ sender: Any) {
        
        if self.viewAddANewCard.isHidden{
            btnAddANewCard.setTitle("S A V E   N E W   C A R D", for: .normal)
        }else{
            if let nameOnCard = txtNameOnCard.text, let cardNumber = txtCardNumber.text, let cvv = txtCVV.text, let mm = Int(txtMM.text!), let yy = Int(txtYY.text!){
                var card = Card("",nameOnCard, cardNumber, cvv, mm, yy, boolSetAsDefault)
                showNetworkActivity()
                GoLujoAPIManager().cardAdd(card) { cardResponse, error in
                    self.hideNetworkActivity()
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        _ = BackendError.parsing(reason: "Could not save the card")
                        return
                    }
                    if let item = cardResponse{
                        card.id = item.id
                        self.cards.append(card)
                        self.tblView.reloadData()
                    }
                }
                btnAddANewCard.setTitle("A D D   A   N E W   C A R D", for: .normal)
            }
            
        }
        UIView.transition(with: view, duration: 0.5, options: .curveEaseInOut, animations: {
            self.viewAddANewCard.isHidden = !self.viewAddANewCard.isHidden
            })
        
        
    }
    
}

extension CardsViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.cards.count == 0 {
            self.tblView.setEmptyMessage("No card(s) are available", txtColor: .white)
        }else{
            self.tblView.restore()
        }
        return self.cards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell") as! CardCell
        let model = cards[indexPath.row]
        
        
        //Title of the card
        cell.lblOwnerName.text = model.ownerName
        cell.lblCardNumber.text = model.card_token
        cell.lblCardExpiry.text = model.expiryDate
        if(model.default_card){ //if default is true then update button title
            cell.btnSetAsDefault.setTitle("D E F A U L T", for: .normal)
        }else{
            cell.btnSetAsDefault.tag = indexPath.row
            cell.btnSetAsDefault.addTarget(self, action: #selector(btnSetAsDefaultTapped(sender:)), for: .touchUpInside)
        }
        

        
        //settings tags on cell and both buttons so that i can catch the tapp
        cell.tag = indexPath.row
        cell.btnRemoveCard.tag = indexPath.row
        
        cell.btnRemoveCard.addTarget(self, action: #selector(btnRemoveCardTapped(sender:)), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func btnRemoveCardTapped(sender: UIButton){
        let card = cards[sender.tag]
        self.deleteIndexPath = IndexPath(row: sender.tag, section: 0)
        confirmDelete(card)
    }
    
    @objc func btnSetAsDefaultTapped(sender: UIButton){
        var card = cards[sender.tag]
        card.default_card = true
        showNetworkActivity()
        GoLujoAPIManager().cardUpdate(card) { stringResponse, error in
            self.hideNetworkActivity()
            guard error == nil else {
                Crashlytics.crashlytics().record(error: error!)
                _ = BackendError.parsing(reason: "Could not obtain the list of cards")
                return
            }
            self.cards[sender.tag] = card    //updating the array
            self.tblView.reloadData()
        }
    }
    
    func confirmDelete(_ card: Card) {
        let alert = UIAlertController(title: "Delete \(card.card_token)", message: "Are you sure you want to permanently delete this card?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteCard)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancelChannel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
   }
    
    func handleDeleteCard(alertAction: UIAlertAction! ) -> Void {
        if let indexPath = self.deleteIndexPath {
            let card = cards[indexPath.row]
            showNetworkActivity()
            GoLujoAPIManager().cardDelete(card) { stringResponse, error in
                self.hideNetworkActivity()
                guard error == nil else {
                    AlertService.showAlert(style: .actionSheet, title: nil, message: "You can not delete this card.")
                    return
                }
                
                // Note that indexPath is wrapped in an array:  [indexPath]
                self.cards.remove(at: indexPath.row)
//                self.tblView.deleteRows(at: [indexPath], with: .automatic)
                self.tblView.reloadData()
                self.deleteIndexPath = nil
            }
        }
    }
    
    func handleCancelChannel(alertAction: UIAlertAction! ) -> Void {
        deleteIndexPath = nil       //re setting the index
    }
    
    
}
