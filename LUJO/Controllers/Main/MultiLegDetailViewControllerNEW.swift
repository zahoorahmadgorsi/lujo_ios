//
//  MultiLegDetailViewControllerNEW.swift
//  LUJO
//
//  Created by Kristian Iker on 9/4/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit

protocol MultiLegDataSourceProtocol: class {
    func updateDataSource(newDataSource: [AviationSegment])
}

class MultiLegDetailViewControllerNEW: UIViewController, CalendarViewDelegate, AirportSearchViewDelegate {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "MultiLegDetailViewControllerNEW" }
    
    /// Init method that will init and return view controller.
    class func instantiate(segments: [AviationSegment], at selectedIndex: Int?, addMore: Bool) -> MultiLegDetailViewControllerNEW {
        let viewController = UIStoryboard.main.instantiate(identifier) as! MultiLegDetailViewControllerNEW
        viewController.segments = segments
        viewController.selectedIndex = selectedIndex
        viewController.addMore = addMore
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var segments: [AviationSegment]! // Required
    private(set) var selectedIndex: Int? // Optional
    private(set) var addMore: Bool! // Required
    
    weak var searchDelegate: AviationSearchCriteriaDelegate?
    weak var dataSourceDelegate: MultiLegDataSourceProtocol?
    
    @IBOutlet var contentContainerView: UIView!
    
    lazy var addLegView: AviationSingleLegSearchOptionsView = {
        guard let subviews = Bundle.main.loadNibNamed("AviationSearchOptions",
                                                      owner: self,
                                                      options: nil) else {
                                                        fatalError("Nib file not found at Aviation Options")
        }
        guard let newView = subviews.first(where: { $0 is AviationSingleLegSearchOptionsView }),
            newView is SearchCriteriaDelegate else {
                fatalError("Nib file not found at Aviation Options")
        }
        guard let addView: AviationSingleLegSearchOptionsView = newView as? AviationSingleLegSearchOptionsView else {
            fatalError("Nib file not found at Aviation Options")
        }
        
        addView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(addView)
        
        NSLayoutConstraint.activate(
            [addView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
             addView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
             addView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
             addView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor)]
        )
        
        addView.tripType = .multiCity
        
        return addView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLegView.aviationSearchCriteriaDelegate = self
        if addMore {
            addLegView.setupAsNextLegFor(departure: segments.last!.endAirport)
        } else if let index = selectedIndex, let currentSegment = try? AviationSegmentInformation(segments[index]) {
            addLegView.legNumber = index
            addLegView.segmentData = currentSegment
        }
    }
    
    @IBAction func cancelButton_onClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func showFeedback(_ message: String) {
        showInformationPopup(withTitle: "Information", message: message)
    }
    
    func tripDatesSelected(departure: Date, return returnDate: Date?) {
        addLegView.set(departure: departure, returnDate: returnDate)
    }
    
    func select(_ airport: Airport, forOrigin: OriginAirport) {
        addLegView.set(airport, for: forOrigin)
    }
}

extension MultiLegDetailViewControllerNEW: AviationSearchCriteriaDelegate {
    
    func showSearchFeedback(_ message: String) {
        showFeedback(message)
    }
    
    func get(destination airport: OriginAirport) {
        let viewController = AviationAirportSelectionViewController.instantiate(destination: airport)
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    func getTripDates(from date: Date?, isReturnDate: Bool) {
        // First leg?
        guard !segments.isEmpty else {
            showDate(from: nil)
            return
        }
        
        // Is Adding new leg?
        guard let index = addLegView.legNumber else {
            showDate(from: segments.last!.dateTime.toDate)
            return
        }
        
        // Is editing
        showDate(from: segments[index].dateTime.toDate)
    }
    
    func getLuggage(from luggage: AviationLuggage?) {
        let luggage = luggage ?? AviationLuggage(carryOn: 0, hold: 0, golfBag: 0, skis: 0, other: 0)
        let viewController = AviationLuggageSelectionViewController.instantiate(luggage: luggage)
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    func search(using criteria: AviationSearch) {
        if let newSegment = criteria.data.first {
            if let editIndex = addLegView.legNumber {
                segments[editIndex] = newSegment
                addLegView.legNumber = nil
            } else {
                segments.append(newSegment)
            }
        }
        
        dataSourceDelegate?.updateDataSource(newDataSource: segments)
        dismiss(animated: true, completion: nil)
    }
    
    func showMultiLegDetailVC(selectedIndex: Int?, segments: [AviationSegment], addMore: Bool) {}
    
    private func showDate(from date: Date?) {
        let viewController = CalendarViewController.instantiate(firstValidDate: date, customTitle: "Departure date")
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    func showError(error: Error) {
        showErrorPopup(withTitle: "Aviation Error", error: error)
    }
}

extension MultiLegDetailViewControllerNEW: LuggageSelectionViewDelegate {
    func select(_ luggage: AviationLuggage) {
        addLegView.set(luggage: luggage)
    }
}

