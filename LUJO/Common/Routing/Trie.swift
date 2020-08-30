import Foundation

enum TrieError: Error {
    case unexistingFeature
    case emptyRoute
    case routeAlreadyExists
}

class TrieNode<T: Hashable> {
    var value: T?
    weak var parentNode: TrieNode?
    var children: [T: TrieNode] = [:]
    var isTerminating = false
    var isLeaf: Bool {
        return children.isEmpty
    }

    /// Initializes a node.
    ///
    /// - Parameters:
    ///   - value: The value that goes into the node
    ///   - parentNode: A reference to this node's parent
    init(value: T? = nil, parentNode: TrieNode? = nil) {
        self.value = value
        self.parentNode = parentNode
    }

    /// Adds a child node to self.  If the child is already present,
    /// do nothing.
    ///
    /// - Parameter value: The item to be added to this node.
    func add(child: T) {
        guard children[child] == nil else {
            return
        }
        children[child] = TrieNode(value: child, parentNode: self)
    }
}

typealias PresentableBuilder = () -> Presentable

class Trie {
    typealias Node = TrieNode<String>
    private let root: Node
    private var presenters: [String: PresentableBuilder] = [:]

    init() {
        root = Node()
    }
}

extension Trie {
    // swiftlint:disable identifier_name
    func insert(_ presenter: @escaping PresentableBuilder, at: String) throws {
        guard !at.isEmpty else {
            throw TrieError.emptyRoute
        }

        guard !contains(at) else {
            throw TrieError.routeAlreadyExists
        }

        var currentNode = root

        let wireframes = at.split(separator: "/")
        var currentIndex = 0

        while currentIndex < wireframes.count {
            let wireFrame: String = String(wireframes[currentIndex])

            if let child = currentNode.children[wireFrame] {
                currentNode = child
            } else {
                currentNode.add(child: wireFrame)
                currentNode = currentNode.children[wireFrame]!
            }

            currentIndex += 1
        }

        if currentIndex == wireframes.count {
            currentNode.isTerminating = true
        }

        presenters[at] = presenter
    }

    private func contains(_ feature: String) -> Bool {
        guard !feature.isEmpty else { return false }

        var currentNode = root

        let wireframes = feature.split(separator: "/")
        var currentIndex = 0

        while currentIndex < wireframes.count, let child = currentNode.children[String(wireframes[currentIndex])] {
            currentIndex += 1
            currentNode = child
        }

        if currentIndex == wireframes.count, currentNode.isTerminating {
            return true
        }

        return false
    }

    // swiftlint:disable identifier_name
    func getPresenter(at: String) throws -> PresentableBuilder? {
        guard contains(at) else {
            throw TrieError.unexistingFeature
        }

        return presenters[at]!
    }
}
