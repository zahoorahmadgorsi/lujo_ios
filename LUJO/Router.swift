import UIKit

class Router: WireFrame {
    private(set) var mainVC: UIWindow?
    private let routes = RoutingTable()
    private let features = Trie()

    public init(mainVC: UIWindow) {
        self.mainVC = mainVC

        // Initialize routes
        routes.add(Route(origin: "/", condition: "", destiny: "/login"))

        routes.add(Route(origin: "/login", condition: "result: Home", destiny: "/home"))
        routes.add(Route(origin: "/login", condition: "result: Success", destiny: "/home"))
        routes.add(Route(origin: "/login", condition: "result: Verified", destiny: "/aviation"))

        // Fake shit, we will use home view controller anyway. But we need this so login can call it!
        routes.add(Route(origin: "/home", condition: "result: Home", destiny: ""))

        routes.add(Route(origin: "/aviation", condition: "result: Profile", destiny: "/account"))
        routes.add(Route(origin: "/aviation", condition: "result: Home", destiny: "/home"))
        routes.add(Route(origin: "/aviation", condition: "result: Dining", destiny: "/dining"))
        routes.add(Route(origin: "/aviation", condition: "result: Bookings", destiny: "/bookings"))

        // Initialize features
        do {
            try features.insert(getLoginPresenter, at: "/login")
        } catch TrieError.routeAlreadyExists {
            print("Duplicated route")
        } catch TrieError.emptyRoute {
            print("Empty routes???")
        } catch {
            print("What the fuck?")
        }
    }

    func navigate(from: String, data: [String: AnyObject]) {
        
        // Special case, present tab bar controller as MVC.
        if data["result"] as? String == "Home" {
            UserDefaults.standard.set(true, forKey: "showWelcome")
            let viewController = MainTabBarController.instantiate()
            mainVC?.rootViewController = viewController
            return
        }
        
        do {
            var action = ""

            if let result = data["result"] as? String { action = "result: \(result)" }

            let feature = try routes.getDestiny(for: from, withAction: action)
            guard let presenterBuilder = try features.getPresenter(at: feature) else { return }

            var presenter = presenterBuilder()
            presenter.route = feature
            presenter.router = self

            // swiftlint:disable force_cast
            let navigationController = UINavigationController(rootViewController: presenter.view as! UIViewController)
            mainVC?.rootViewController = navigationController

        } catch RoutingError.unexistingRoute {
            print("Unexisting route \(from) with action \(data) requested")
        } catch TrieError.unexistingFeature {
            print("Unexisting feature requested for \(from) with action \(data)")
        } catch {
            print("Unknown error")
        }
    }

    // MARK: Helper methods
    
    let getLoginPresenter: PresentableBuilder = {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        // swiftlint:disable force_cast
        let view = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginView
        let interactor = LoginInteractor(GoLujoAPIManager(), setup: LujoSetup())

        return LoginPresenter(view: view, interactor: interactor)
    }
    
}
