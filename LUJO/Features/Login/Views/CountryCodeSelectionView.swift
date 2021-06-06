import UIKit
import JGProgressHUD

protocol CountrySelectionDelegate: class {
    func didSelect(_ country: PhoneCountryCode, at view: CountryCodeSelectionView)
}

class CountryCodeSelectionView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var searchText: DesignableUITextField!
    @IBOutlet var countriesTableView: UITableView!

    weak var delegate: CountrySelectionDelegate?

    private var countriesList = [[PhoneCountryCode]]()
    private let naHUD = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()

        searchText.addTarget(self,
                             action: #selector(searchFieldDidChange(_:)),
                             for: .editingChanged)
        searchText.placeHolderColor = .placeholderText
        
        countriesTableView.dataSource = self
        countriesTableView.delegate = self

        guard let list = LujoSetup().getCountryCodes() else {
            showNetworkActivity()
            GoLujoAPIManager.shared.getCountryCodes { codes, error in
                self.hideNetworkActivity()
                if error != nil {
                    self.showFeedback("Can't load countries at the moment, please try again later.")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    LujoSetup().store(codes)
                    self.setCountriesList(list: codes)
                    self.searchText.becomeFirstResponder()
                }
            }
            return
        }
        
        setCountriesList(list: list)
        searchText.becomeFirstResponder()
    }
    
    func setCountriesList(list: [PhoneCountryCode]) {
        let sortedCountries = list.sorted(by: { $0.country < $1.country })
        
        countriesList = sortedCountries.reduce([[PhoneCountryCode]]()) {
            guard var last = $0.last else { return [[$1]] }
            var collection = $0
            if last.first!.country.prefix(1) == $1.country.prefix(1) {
                last += [$1]
                collection[collection.count - 1] = last
            } else {
                collection += [[$1]]
            }
            return collection
        }
        
        countriesTableView.reloadData()
    }

    @IBAction func cancelSelection(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func searchFieldDidChange(_ textField: UITextField) {
        guard var searchText = textField.text else {
            return
        }

        guard !searchText.isEmpty else {
            countriesTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            return
        }

        searchText.capitalizeFirstLetter()
        var section = -1

        for (index, countrySection) in countriesList.enumerated() {
            if countrySection.first!.country.prefix(1) == searchText.prefix(1) {
                section = index
                break
            }
        }

        guard section >= 0 else { return }

        if let index = countriesList[section].firstIndex(where: { $0.country.hasPrefix(searchText) }) {
            countriesTableView.scrollToRow(at: IndexPath(row: index, section: section), at: .top, animated: true)
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
        return countriesList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countriesList[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return countriesList[section].first!.country.prefix(1).uppercased()
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(named: "Black Backgorund")
        // swiftlint:disable force_cast
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(named: "White Text")
        header.textLabel?.font = UIFont.systemFont(ofSize: 17)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = countriesTableView.dequeueReusableCell(withIdentifier: "countryCodeCell",
                                                          for: indexPath) as! CountryCodeCell
        let countryData = countriesList[indexPath.section][indexPath.row]

        cell.code.text = countryData.phonePrefix
        cell.name.text = countryData.country
        cell.flag.image = UIImage(named: "flag_\(countryData.alpha2Code.lowercased())")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            let country = countriesList[indexPath.section][indexPath.row]
            delegate.didSelect(country, at: self)
        }
    }
}
