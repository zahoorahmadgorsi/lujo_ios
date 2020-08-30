@testable import LUJO
import XCTest

class MockView: Viewable {}

class MockInteractor: Interactuable {}

class MockPresenter: Presentable {
    var view: Viewable
    var route: String = ""
    var router: WireFrame?

    var interactor: Interactuable

    required init(view: Viewable, interactor: Interactuable) {
        self.view = view
        self.interactor = interactor
    }
}

class TrieShould: XCTestCase {
    func test_have_no_features_when_created() {
        let trie = Trie()

        XCTAssertThrowsError(try trie.getPresenter(at: ""))
    }

    func test_fail_when_empty_route_is_inserted() {
        let trie = Trie()
        let presenterBuilder: PresentableBuilder = {
            MockPresenter(view: MockView(), interactor: MockInteractor())
        }

        XCTAssertThrowsError(try trie.insert(presenterBuilder, at: ""))
    }

    func test_insert_new_features_when_are_not_present() {
        let trie = Trie()
        let presenterBuilder1: PresentableBuilder = {
            MockPresenter(view: MockView(), interactor: MockInteractor())
        }
        let presenterBuilder2: PresentableBuilder = {
            MockPresenter(view: MockView(), interactor: MockInteractor())
        }

        do {
            try trie.insert(presenterBuilder1, at: "/login/google")
            try trie.insert(presenterBuilder2, at: "/login/lujo")

            let currentPresenter1 = try trie.getPresenter(at: "/login/google")!()
            let currentPresenter2 = try trie.getPresenter(at: "/login/lujo")!()

            XCTAssertTrue(currentPresenter1 is MockPresenter)
            XCTAssertTrue(currentPresenter2 is MockPresenter)
        } catch {
            XCTFail()
        }
    }

    func test_fail_when_inserting_an_existing_feature() {
        let trie = Trie()
        let presenter: PresentableBuilder = {
            MockPresenter(view: MockView(), interactor: MockInteractor())
        }

        do {
            try trie.insert(presenter, at: "/login/google")
        } catch {
            XCTFail()
        }

        XCTAssertThrowsError(try trie.insert(presenter, at: "/login/google"))
    }

    func test_fail_when_requested_feature_for_unexisting_presenter() {}
}
