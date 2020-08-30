//
//  AviationResultsFilterViewController.swift
//  LUJO
//
//  Created by Kristian Iker on 9/4/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import M13Checkbox

class AviationResultsFilterViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "AviationResultsFilterViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(filter: [Filter]) -> AviationResultsFilterViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! AviationResultsFilterViewController
        viewController.filter = filter
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var filter: [Filter]!
    
    @IBOutlet var filterCheckboxes: [M13Checkbox]!
    @IBOutlet var filterLabels: [UILabel]!
    @IBOutlet var filterValues: [UILabel]!
    @IBOutlet var applyButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterCheckboxes.forEach { checkbox in
            checkbox.markType = .checkmark
            checkbox.boxType = .square
            checkbox.tintColor = UIColor(named: "White Text")
            checkbox.addTarget(self, action: #selector(self.checkboxValueChanged(_:)), for: .valueChanged)
        }
        
        filterLabels.forEach { label in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectFilter(sender:)))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tapGesture)
        }
        
        if let currentFilter = filter {
            for (index, filter) in currentFilter.enumerated() {
                filterCheckboxes[index].checkState = filter.selected ? .checked : .unchecked
                filterLabels[index].text = filter.name
                filterLabels[index].textColor = filter.selected ? UIColor.whiteText : UIColor.placeholderText
                filterValues[index].text = String(filter.count)
            }
        }
    }
    
    @IBAction func dismissFilters(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        var filters: [Filter] = []
        
        for (index, checkbox) in filterCheckboxes.enumerated()
            where checkbox.checkState == .checked {
                let newFilter = Filter(name: filterLabels[index].text!,
                                       selected: true,
                                       count: 0)
                filters.append(newFilter)
        }
        
        let presenter = self.presentingViewController as? AviationResultsViewController
        self.dismiss(animated: true, completion: {
            presenter?.filterFlights(matching: filters)
        })
        
    }
    
    @objc func selectFilter(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        
        guard let index = filterLabels.firstIndex(of: label) else { return }
        
        filterCheckboxes[index].toggleCheckState()
        filterLabels[index].textColor = filterCheckboxes[index].checkState == .checked ? UIColor.whiteText : UIColor.placeholderText
    }
    
    @objc func checkboxValueChanged(_ sender: M13Checkbox) {
        guard let index = filterCheckboxes.firstIndex(of: sender) else { return }
        filterLabels[index].textColor = filterCheckboxes[index].checkState == .checked ? UIColor.whiteText : UIColor.placeholderText
    }

}

extension AviationResultsFilterViewController {
    
    
    
}
