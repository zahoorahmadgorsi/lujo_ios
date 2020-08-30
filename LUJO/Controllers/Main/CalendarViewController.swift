//
//  CalendarViewController.swift
//  LUJO
//
//  Created by Kristian Iker on 9/4/19.
//  Copyright © 2019 Baroque Access. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol CalendarViewDelegate: class {
    func tripDatesSelected(departure: Date, return: Date?)
}

class CalendarViewController: UIViewController {
    
    //MARK:- Init
    
    /// Class storyboard identifier.
    class var identifier: String { return "CalendarViewController" }
    
    /// Init method that will init and return view controller.
    class func instantiate(firstValidDate: Date?, oneWay: Bool = true, customTitle: String) -> CalendarViewController {
        let viewController = UIStoryboard.main.instantiate(identifier) as! CalendarViewController
        viewController.firstValidDate = firstValidDate
        viewController.oneWay = oneWay
        viewController.customTitle = customTitle
        return viewController
    }
    
    //MARK:- Globals
    
    private(set) var oneWay: Bool = true
    private(set) var customTitle: String!
    private(set) var firstValidDate: Date?
    weak var delegate: CalendarViewDelegate?
    
    @IBOutlet var titlelabel: UILabel!
    @IBOutlet var calendar: JTAppleCalendarView!
    
    private var firstDate: Date?
    private let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titlelabel.text = customTitle
        
        setupCalendarView()
    }
    
    func setupCalendarView() {
        // Setup calendar spacing
        calendar.minimumLineSpacing = 0
        calendar.minimumInteritemSpacing = 0
        
        calendar.register(UINib(nibName: "CalendarHeaderView", bundle: Bundle.main),
                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                          withReuseIdentifier: "CalendarHeaderView")
        calendar.allowsMultipleSelection = false //!oneWay
        calendar.isRangeSelectionUsed = false //!oneWay
    }
    
    override func viewDidAppear(_: Bool) {
        calendar.reloadData()
        calendar.scrollToDate(firstValidDate ?? Date())
    }
    
    func handleSelectionColor(for cell: JTAppleCell?, with state: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        
        switch state.selectedPosition() {
        case .full, .left, .right, .middle:
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = UIColor.rgMid
            //        case .middle:
            //            validCell.selectedView.isHidden = false
            //            validCell.selectedView.backgroundColor = UIColor.rgMid.withAlphaComponent(0.1)
        //            validCell.selectedView.layer.borderColor = UIColor.clear.cgColor
        default:
            validCell.selectedView.isHidden = !Calendar.current.isDateInToday(state.date)
            validCell.selectedView.backgroundColor = nil
            validCell.backgroundColor = nil
        }
    }
    
    func handleTextColor(for cell: JTAppleCell?, with state: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        
        if state.isSelected {
            // Ako ocemo po design-u ovom state.selectedPosition() != .middle ? UIColor.actionButtonText : UIColor.whiteText
            validCell.dateLabel.textColor = UIColor.actionButtonText
        } else {
            if state.dateBelongsTo == .thisMonth, state.date.isInThePast(), state.date >= firstValidDate ?? Date() {
                validCell.dateLabel.textColor = UIColor.paragraphWhite
            } else if state.dateBelongsTo != .thisMonth {
                validCell.dateLabel.textColor = UIColor.separator
            } else {
                validCell.dateLabel.textColor = UIColor.tvBorder
            }
        }
    }
    
    @IBAction func acceptSelectedDates(_: Any) {
        guard let startDate = calendar.selectedDates.first else {
            return
        }
        
        delegate?.tripDatesSelected(departure: oneWay ? startDate : self.firstValidDate!, return: !oneWay ? startDate : nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelSelectedDates(_: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_: JTAppleCalendarView) -> ConfigurationParameters {
        let stardDate = firstValidDate ?? Date()
        var dateComponents = DateComponents()
        dateComponents.year = 1
        let endDate = Calendar.current.date(byAdding: dateComponents, to: stardDate)
        
        let parameters = ConfigurationParameters(startDate: stardDate,
                                                 endDate: endDate!,
                                                 numberOfRows: 6,
                                                 calendar: Calendar.current,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        // swiftlint:disable force_cast
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell",
                                                       for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        handleSelectionColor(for: cell, with: cellState)
        handleTextColor(for: cell, with: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date),
                  at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let headerCell = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "CalendarHeaderView",
                                                                          for: indexPath) as! CalendarHeaderView
        let date = range.start
        formatter.dateFormat = "MMMM"
        headerCell.monthName.text = formatter.string(from: date)
        return headerCell
    }
    
    func calendarSizeForMonths(_: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 64)
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(_: JTAppleCalendarView,
                  willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath _: IndexPath) {
        handleSelectionColor(for: cell, with: cellState)
        handleTextColor(for: cell, with: cellState)
    }
    
    func calendar(_: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard date >= (firstValidDate ?? Date()) else { return }
        
//        if !oneWay {
//            if firstDate != nil {
//                var initialDate = firstDate!
//                var finalDate = date
//
//                if date < firstDate! {
//                    initialDate = date
//                    finalDate = firstDate!
//                }
//
//                calendar.selectDates(from: initialDate,
//                                     to: finalDate,
//                                     triggerSelectionDelegate: false,
//                                     keepSelectionIfMultiSelectionAllowed: true)
//            } else {
//                firstDate = date
//            }
//        }
        
        handleSelectionColor(for: cell, with: cellState)
        handleTextColor(for: cell, with: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//        if !oneWay, calendar.selectedDates.count > 2 {
//            guard let initialDate = calendar.selectedDates.first else { return }
//            guard let finalDate = calendar.selectedDates.last else { return }
//            
//            if initialDate < date, finalDate > date {
//                calendar.deselectDates(from: date, to: finalDate, triggerSelectionDelegate: false)
//                calendar.selectDates(from: firstDate!,
//                                     to: date,
//                                     triggerSelectionDelegate: false,
//                                     keepSelectionIfMultiSelectionAllowed: true)
//            }
//        }
        
        handleSelectionColor(for: cell, with: cellState)
        handleTextColor(for: cell, with: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith _: DateSegmentInfo) {
        calendar.reloadData()
    }
}
