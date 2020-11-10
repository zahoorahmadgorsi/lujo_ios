import UIKit

protocol LuggageSelectionViewDelegate: class {
    func select(_ luggage: AviationLuggage)
}

class AviationLuggageSelectionView: UIViewController {
    @IBOutlet var carryOnLabel: UILabel!
    @IBOutlet var holdLuggageLabel: UILabel!
    @IBOutlet var golfBagLabel: UILabel!
    @IBOutlet var skisLabel: UILabel!
    @IBOutlet var otherLabel: UILabel!

    var luggageSelection = AviationLuggage(carryOn: 0, hold: 0, golfBag: 0, skis: 0, other: 0)

    weak var delegate: LuggageSelectionViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLuggageLabels()
    }

    private func updateLuggageLabels() {
        carryOnLabel.text = String(luggageSelection.carryOn)
        holdLuggageLabel.text = String(luggageSelection.hold)
        golfBagLabel.text = String(luggageSelection.golfBag)
        skisLabel.text = String(luggageSelection.skis)
        otherLabel.text = String(luggageSelection.other)
    }

    @IBAction func increase(_ sender: Any) {
        guard let caller = sender as? UIView else {
//            print("This is not a button")
            return
        }

        switch caller.tag {
        case 1:
            luggageSelection.carryOn += 1
        case 2:
            luggageSelection.hold += 1
        case 3:
            luggageSelection.golfBag += 1
        case 4:
            luggageSelection.skis += 1
        case 5:
            luggageSelection.other += 1
        default:
            fatalError("Shouldn't be here")
        }

        updateLuggageLabels()
    }

    @IBAction func decrease(_ sender: Any) {
        guard let caller = sender as? UIView else {
//            print("This is not a button")
            return
        }

        switch caller.tag {
        case 1:
            if luggageSelection.carryOn > 0 {
                luggageSelection.carryOn -= 1
            }
        case 2:
            if luggageSelection.hold > 0 {
                luggageSelection.hold -= 1
            }
        case 3:
            if luggageSelection.golfBag > 0 {
                luggageSelection.golfBag -= 1
            }
        case 4:
            if luggageSelection.skis > 0 {
                luggageSelection.skis -= 1
            }
        case 5:
            if luggageSelection.other > 0 {
                luggageSelection.other -= 1
            }
        default:
            fatalError("Shouldn't be here")
        }

        updateLuggageLabels()
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        delegate?.select(luggageSelection)
        dismiss(animated: true, completion: nil)
    }
}
