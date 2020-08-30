import Foundation

enum RoutingError: Error {
    case unexistingRoute
}

struct Route {
    var origin: String
    var condition: String
    var destiny: String
}

class RoutingTable {
    private var routes: [Route] = []

    func add(_ route: Route) {
        routes.append(route)
    }

    private func find(origin: String, condition: String) -> Route? {
        for route in routes where route.origin == origin && route.condition == condition {
            return route
        }

        return nil
    }

    func getDestiny(for origin: String, withAction action: String) throws -> String {
        guard let route = find(origin: origin, condition: action) else {
            throw RoutingError.unexistingRoute
        }

        return route.destiny
    }
}
