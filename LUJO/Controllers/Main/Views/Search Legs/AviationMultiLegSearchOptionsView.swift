import UIKit

class AviationMultiLegSearchOptionsView: UIView {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addLeg: UIButton!

    lazy var footerView: UIView = {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 162))
        customView.backgroundColor = UIColor.blackBackgorund

        let addButton = DarkActionButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("+ ADD A LEG", for: .normal)
        addButton.addTarget(self, action: #selector(addMoreLegs), for: .touchUpInside)
        customView.addSubview(addButton)

        NSLayoutConstraint.activate(
            [addButton.topAnchor.constraint(equalTo: customView.topAnchor),
             addButton.heightAnchor.constraint(equalToConstant: 44),
             addButton.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
             addButton.trailingAnchor.constraint(equalTo: customView.trailingAnchor)]
        )

        let searchButton = ActionButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setTitle("SEARCH", for: .normal)
        searchButton.addTarget(self, action: #selector(performSearch), for: .touchUpInside)
        customView.addSubview(searchButton)

        NSLayoutConstraint.activate(
            [searchButton.bottomAnchor.constraint(equalTo: customView.bottomAnchor, constant: -50),
             searchButton.heightAnchor.constraint(equalToConstant: 44),
             searchButton.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
             searchButton.trailingAnchor.constraint(equalTo: customView.trailingAnchor)]
        )

        return customView
    }()

    var segments: [AviationSegment] = [] {
        didSet {
            if !segments.isEmpty {
                tableView.isHidden = false
                tableView.reloadData()
            }
        }
    }

    var tripType: AviationTripType = .multiCity
    weak var aviationSearchCriteriaDelegate: AviationSearchCriteriaDelegate?

    private func setupSubViews() {
        tableView.rowHeight = AviationLegCell.cellHeight
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AviationLegCell", bundle: nil),
                           forCellReuseIdentifier: AviationLegCell.reuseIdentifier)

        tableView.tableFooterView = footerView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        setupSubViews()
    }

    @IBAction func addNewLeg(_ sender: Any) {
        aviationSearchCriteriaDelegate?.showMultiLegDetailVC(selectedIndex: nil, segments: segments, addMore: false)
    }

    @objc func addMoreLegs(_ sender: UIButton!) {
        aviationSearchCriteriaDelegate?.showMultiLegDetailVC(selectedIndex: nil, segments: segments, addMore: true)
    }

    @objc func performSearch() {
        guard (2 ... 5).contains(segments.count) else {
            aviationSearchCriteriaDelegate?.showSearchFeedback("Multi Leg search should contain between 2 and 5 legs")
            return
        }

        let criteria = AviationSearch(customerId: 0,
                                      data: segments,
                                      additional: AviationAditionalRequirements(smoker: 0))

        aviationSearchCriteriaDelegate?.search(using: criteria)
    }
}

extension AviationMultiLegSearchOptionsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "AviationLegCell",
                                                 for: indexPath) as! AviationLegCell
        let segmentData = segments[indexPath.row]

        cell.delegate = self
        cell.legNum = indexPath.row
        cell.setupCell(with: segmentData)

        return cell
    }
}

extension AviationMultiLegSearchOptionsView: SearchCriteriaDelegate {
    func set(_ airport: Airport, for destination: OriginAirport) {}

    func set(departure: Date, returnDate: Date?) {}

    func set(luggage: AviationLuggage) {}
}

extension AviationMultiLegSearchOptionsView: AviationLegCellDelegate {
    func editRow(at index: Int) {
        if (try? AviationSegmentInformation(segments[index])) != nil {
            aviationSearchCriteriaDelegate?.showMultiLegDetailVC(selectedIndex: index, segments: segments, addMore: false)
        }
    }

    func deleteRow(at index: Int) {
        segments.remove(at: index)
        tableView.reloadData()
        if segments.isEmpty {
            tableView.isHidden = true
        }
    }
}
