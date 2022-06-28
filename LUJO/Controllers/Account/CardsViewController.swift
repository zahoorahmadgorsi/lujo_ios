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
    @IBOutlet weak var txtMM: LujoTextField!
    @IBOutlet weak var txtYY: LujoTextField!
    
    @IBOutlet weak var viewCross: UIView!
    @IBOutlet weak var viewSetAsDefault: UIView!
    @IBOutlet weak var lblSetAsDefault: UILabel!
    
    @IBOutlet weak var btnAddANewCard: ActionButton!
    
    /// Init method that will init and return view controller.
    class func instantiate() -> CardsViewController {
        return UIStoryboard.accountNEW.instantiate(identifier)
    }
    var deleteIndexPath: IndexPath? = nil //used while deleting at swipe left
    var boolSetAsDefault:Bool = false
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    
    //MARK:- View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addViewBorder(borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 24.0)
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        self.title = "Cards"
    
        //adding tap gesture and border around "set as default" which is inside viewAddANewCard
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnViewSetAsDefault (_:)))
        self.viewSetAsDefault.addGestureRecognizer(gesture)
        viewSetAsDefault.addViewBorder( borderColor: UIColor.rgMid.cgColor, borderWidth: 1.0, borderCornerRadius: 0.0)
        //adding background image to viewAddANewCard
        self.viewAddANewCard.addBackGroundImage(imageName: "card_background")
        self.viewAddANewCard.addViewBorder( borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 12.0)
        //adding gesture on cross in subuiview viewAddANewCard
        let gestureCross = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnViewCross (_:)))
        self.viewCross.addGestureRecognizer(gestureCross)
        // to apply mask on credit card
        txtCardNumber.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
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
    
    func getCards(showActivity: Bool = true) {
        if (showActivity){
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
                    self.cards.removeAll()
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
                let description = error?.localizedDescription ?? "Could not obtain the list of cards"
                let error = BackendError.parsing(reason: description)
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
            btnAddANewCard.setTitle("S A V E   C A R D", for: .normal)
            self.hideUnhideWithAnimation()
        }else{
            guard let nameOnCard = txtNameOnCard.text,
                  let cardNumber = txtCardNumber.text?.replacingOccurrences(of: " ", with: ""),
                  let cvv = txtCVV.text,
                  let mm = txtMM.text,
                  let yy = txtYY.text
                else {
                    let error = LoginError.errorLogin(description: "All fields are mandatory")
                    showError(error)
                    return
            }
            
            guard !nameOnCard.isEmpty, !cardNumber.isEmpty, !cvv.isEmpty, !mm.isEmpty, !yy.isEmpty else {
                let error = LoginError.errorLogin(description: "All fields are mandatory")
                showError(error)
                return
            }
            
            guard cvv.count == 3, let cvvv = Int(cvv) else {
                let error = LoginError.errorLogin(description: "CVV must have 3 digits.")
                showError(error)
                txtCVV.becomeFirstResponder()
                return
            }
            
            guard let mmm = Int(mm), mmm <= 12 else {
                let error = LoginError.errorLogin(description: "Invalid expiry month.")
                showError(error)
                txtMM.becomeFirstResponder()
                return
            }
            
            guard let yyy = Int(yy), yyy > 22 else {
                let error = LoginError.errorLogin(description: "Invalid expiry year.")
                showError(error)
                txtYY.becomeFirstResponder()
                return
            }
            
            
//            if  let cvv = Int(txtCVV.text!), let mm = Int(mm), let yy = Int(yy){
                let card = Card("",nameOnCard.uppercased(), cardNumber, cvvv, mmm, yyy, boolSetAsDefault)
                showNetworkActivity()
                GoLujoAPIManager().cardAdd(card) { cardResponse, error in
                    self.hideNetworkActivity()
                    guard error == nil else {
                        Crashlytics.crashlytics().record(error: error!)
                        let description = error?.localizedDescription ?? "Card could not be added."
                        let error = BackendError.parsing(reason: description)
                        self.showError(error)
                        return
                    }
                    //refreshing the data, not doing locally because backend has some processing on this
                    self.getCards(showActivity: false)
                    self.hideUnhideWithAnimation()
                }
                btnAddANewCard.setTitle("A D D   A   N E W   C A R D", for: .normal)
//            }
        }
    }
    
    @objc func tappedOnViewCross(_ sender:UITapGestureRecognizer){
        btnAddANewCard.setTitle("A D D   A   N E W   C A R D", for: .normal)
        hideUnhideWithAnimation()
    }
    
    func hideUnhideWithAnimation(){
        UIView.transition(with: view, duration: 0.5, options: .curveEaseInOut, animations: {
            self.viewAddANewCard.isHidden = !self.viewAddANewCard.isHidden
        })
    }
}

extension CardsViewController: UITableViewDelegate, UITableViewDataSource{

    //The basic idea is to create a new section (rather than a new row) for each array item. The sections can then be spaced using the section header height.
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.cards.count == 0 {
            self.tblView.setEmptyMessage("No card(s) are available", txtColor: .white)
        }else{
            self.tblView.restore()
        }
        return self.cards.count
        }
        
    
        // There is just one row in every section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        // Set the spacing between sections
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 1
        }
        
        // Make the background color show through
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell") as! CardCell
        let index = indexPath.section
        let model = cards[index]

        //Title of the card
        cell.lblCardHolderName.text = model.card_holder_name
        cell.lblCardNumber.text = model.masked_card_number
        cell.lblCardExpiry.text = model.expiryDate
        
        if(model.default_card){ //if default is true then update button title
            cell.lblCardSetAsDefault.text =  "D E F A U L T"
            cell.viewSetAsDefault.backgroundColor = UIColor.lightGrey
            cell.lblCardSetAsDefault.textColor = UIColor.white
        }else{
            cell.viewSetAsDefault.tag = indexPath.section
            cell.lblCardSetAsDefault.text =  "S E T   A S   D E F A U L T"
            cell.viewSetAsDefault.backgroundColor = UIColor.rgMid
            cell.lblCardSetAsDefault.textColor = UIColor.white
            let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnLblSetAsDefault (_:)))
            cell.viewSetAsDefault.addGestureRecognizer(gesture)
        }
        
        //settings tags on cell and both buttons so that i can catch the tapp
        cell.tag = index
        cell.viewRemoveCard.tag = index
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.tappedOnRemoveCard (_:)))
        cell.viewRemoveCard.addGestureRecognizer(gesture)
        
        cell.contentView.addViewBorder( borderColor: UIColor.clear.cgColor, borderWidth: 1.0, borderCornerRadius: 12.0)

        
        return cell
    }
    
    @objc func tappedOnRemoveCard(_ sender:UITapGestureRecognizer){
        if let tag = sender.view?.tag{
            let card = cards[tag]
            self.deleteIndexPath = IndexPath(row:0, section: tag)
            confirmDelete(card)
        }
        
    }
    
    @objc func tappedOnLblSetAsDefault(_ sender:UITapGestureRecognizer){
        if let tag = sender.view?.tag{
            var card = cards[tag]
            card.default_card = true
            showNetworkActivity()
            GoLujoAPIManager().cardUpdate(card) { stringResponse, error in
                self.hideNetworkActivity()
                guard error == nil else {
                    Crashlytics.crashlytics().record(error: error!)
                    let description = error?.localizedDescription ?? "Card could not be updated."
                    let error = BackendError.parsing(reason: description)
                    self.showError(error)
                    return
                }
                self.getCards(showActivity: false)
            }
        }

    }
    
    func confirmDelete(_ card: Card) {
        let alert = UIAlertController(title: "Delete \(card.masked_card_number)", message: "Are you sure you want to permanently delete this card?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteCard)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancelChannel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
   }
    
    func handleDeleteCard(alertAction: UIAlertAction! ) -> Void {
        if let indexPath = self.deleteIndexPath {
            let index = indexPath.section
            let card = cards[index]
            showNetworkActivity()
            GoLujoAPIManager().cardDelete(card) { stringResponse, error in
                self.hideNetworkActivity()
                guard error == nil else {
                    let description = error?.localizedDescription ?? "Card can not be deleted."
                    AlertService.showAlert(style: .actionSheet, title: nil, message: description)
                    return
                }
//                // Note that indexPath is wrapped in an array:  [indexPath]
                self.cards.remove(at: index)
                self.tblView.reloadData()
                self.deleteIndexPath = nil
//                self.getCards(showActivity: false)
            }
        }
    }
    
    func handleCancelChannel(alertAction: UIAlertAction! ) -> Void {
        deleteIndexPath = nil       //re setting the index
    }
}

extension CardsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        previousTextFieldContent = textField.text;
        previousSelection = textField.selectedTextRange;
        return true
    }

    @objc func reformatAsCardNumber(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }

        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }

        if cardNumberWithoutSpaces.count > 19 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }

        let cardNumberWithSpaces = self.insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces

        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }

    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition

        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }

        return digitsOnlyString
    }

    func insertCreditCardSpaces(_ string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        // Mapping of card prefix to pattern is taken from
        // https://baymard.com/checkout-usability/credit-card-patterns

        // UATP cards have 4-5-6 (XXXX-XXXXX-XXXXXX) format
        let is456 = string.hasPrefix("1")

        // These prefixes reliably indicate either a 4-6-5 or 4-6-4 card. We treat all these
        // as 4-6-5-4 to err on the side of always letting the user type more digits.
        let is465 = [
            // Amex
            "34", "37",

            // Diners Club
            "300", "301", "302", "303", "304", "305", "309", "36", "38", "39"
        ].contains { string.hasPrefix($0) }

        // In all other cases, assume 4-4-4-4-3.
        // This won't always be correct; for instance, Maestro has 4-4-5 cards according
        // to https://baymard.com/checkout-usability/credit-card-patterns, but I don't
        // know what prefixes identify particular formats.
        let is4444 = !(is456 || is465)

        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition

        for i in 0..<string.count {
            let needs465Spacing = (is465 && (i == 4 || i == 10 || i == 15))
            let needs456Spacing = (is456 && (i == 4 || i == 9 || i == 15))
            let needs4444Spacing = (is4444 && i > 0 && (i % 4) == 0)

            if needs465Spacing || needs456Spacing || needs4444Spacing {
                stringWithAddedSpaces.append(" ")

                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }

            let characterToAdd = string[string.index(string.startIndex, offsetBy:i)]
            stringWithAddedSpaces.append(characterToAdd)
        }

        return stringWithAddedSpaces
    }
}
