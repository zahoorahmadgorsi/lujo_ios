import UIKit
import JGProgressHUD

protocol CityCountrySelectionDelegate: AnyObject {
    func didSelect(_ country: Taxonomy,_ selectionType: SelectionType, at view: CityCountrySelectionViewController)
}

//user is loading city or country
enum SelectionType {
    case city
    case country
}

class CityCountrySelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var txtSearch: DesignableUITextField!
    @IBOutlet var tblView: UITableView!

    weak var delegate: CityCountrySelectionDelegate?

    private var items = [[Taxonomy]]()
    private let naHUD = JGProgressHUD(style: .dark)
    private var selectionType:SelectionType = .country
    private var country:Taxonomy? // cities of the following countries are required
    
    /// Class storyboard identifier.
    class var identifier: String { return "CityCountrySelectionViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(_ selectionType: SelectionType,_ country:Taxonomy?) -> CityCountrySelectionViewController {
        let viewController = UIStoryboard.accountNEW.instantiate(identifier) as! CityCountrySelectionViewController
        viewController.selectionType = selectionType
        viewController.country = country
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectionType == .country{
            self.lblTitle.text = "Select Country"
            self.txtSearch.placeholder = "Country"
        }else if selectionType == .city{
            self.lblTitle.text = "Select City"
            self.txtSearch.placeholder = "City"
        }
        txtSearch.addTarget(self,
                             action: #selector(searchFieldDidChange(_:)),
                             for: .editingChanged)
        txtSearch.placeHolderColor = .placeholderText
        
        tblView.dataSource = self
        tblView.delegate = self

        txtSearch.becomeFirstResponder()
        if selectionType == .country{
            getCountries()
        }else if selectionType == .city{
            getCities()
        }
        
    }
    
    func getCountries(){
        showNetworkActivity()
        GoLujoAPIManager.shared.getCounntries { items, error in
            self.hideNetworkActivity()
            if error != nil {
                self.showFeedback("Couldn't load countries at the moment, please try again later.")
                self.dismiss(animated: true, completion: nil)
            } else {
                self.setItems(list: items)
                self.txtSearch.becomeFirstResponder()
            }
        }
    }
    
    func getCities(){
        showNetworkActivity()
        if let country = self.country{
            GoLujoAPIManager.shared.getCities(country) { items, error in
                self.hideNetworkActivity()
                if error != nil {
                    self.showFeedback("Couldn't load cities at the moment, please try again later.")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.setItems(list: items)
                    self.txtSearch.becomeFirstResponder()
                }
            }
        }
    }
    
    func setItems(list: [Taxonomy]) {
        let sortedItems = list.sorted(by: { $0.name < $1.name })

        items = sortedItems.reduce([[Taxonomy]]()) {
            guard var last = $0.last else { return [[$1]] }
            var collection = $0
            if last.first!.name.prefix(1) == $1.name.prefix(1) {
                last += [$1]
                collection[collection.count - 1] = last
            } else {
                collection += [[$1]]
            }
            return collection
        }
        tblView.reloadData()
    }

    @IBAction func cancelSelection(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func searchFieldDidChange(_ textField: UITextField) {
        guard var searchText = textField.text else {
            return
        }

        guard !searchText.isEmpty else {
            tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            return
        }

        searchText.capitalizeFirstLetter()
        var section = -1

        for (index, countrySection) in items.enumerated() {
            if countrySection.first!.name.prefix(1) == searchText.prefix(1) {
                section = index
                break
            }
        }

        guard section >= 0 else { return }

        if let index = items[section].firstIndex(where: { $0.name.hasPrefix(searchText) }) {
            tblView.scrollToRow(at: IndexPath(row: index, section: section), at: .top, animated: true)
        }
    }
    
    func showNetworkActivity() {
        naHUD.show(in: view)
    }
    
    func hideNetworkActivity() {
        naHUD.dismiss()
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }

    // MARK: Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].first!.name.prefix(1).uppercased()
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(named: "Black Backgorund")
        // swiftlint:disable force_cast
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.rgMid
        header.textLabel?.font = UIFont.systemFont(ofSize: 19)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tblView.dequeueReusableCell(withIdentifier: "searchCell",
                                                          for: indexPath) as! SearchCell
        let itemsData = items[indexPath.section][indexPath.row]

        cell.lblSearch.text = itemsData.name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            let country = items[indexPath.section][indexPath.row]
            delegate.didSelect(country, self.selectionType, at: self)
            self.dismiss(animated: true)
        }
    }
}
