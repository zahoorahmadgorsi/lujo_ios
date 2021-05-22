import Crashlytics
import DefaultsKit

extension DefaultsKey {
    static let currentUser = Key<LoginUser>("currentUser")
    static let userInformation = Key<LujoUser>("userInformation")
    static let userImage = Key<Data>("userImage")
    static let verificationCode = Key<String>("verificationCode")
    static let memberMargin = Key<Double>("memberMargin")
    static let nonMemberMargin = Key<Double>("nonMemberMargin")
    static let countryCodes = Key<[PhoneCountryCode]>("countryCodes")
    static let userPreferences = Key<Preferences>("userPreferences")
}

extension Notification.Name {
    static let LujoUserImageDidUpdate = Notification.Name("LujoUserImageWasUpdated")
}

class LujoSetup: LoginDataStorable, AppDefaults {
    private var defaults: Defaults!
    private var dataLayer: GoLujoAPIManager!

    private lazy var userImagePath: String = {
        let imageName = "userImage"
        let userDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let imagePath: String = "\(userDocuments)/\(imageName).png"
        return imagePath
    }()

    init(_ defaults: Defaults, data: GoLujoAPIManager) {
        self.defaults = defaults
        dataLayer = data
    }

    static let zenDeskInfo: [String: String] = {
        guard let zenDeskInfoDictionary = Bundle.main.object(forInfoDictionaryKey: "ZenDesk") as? [String: String] else {
            return [String: String]()
        }
        return zenDeskInfoDictionary
    }()

    static var zenDeskAccountKey: String = {
        guard let accountKey = LujoSetup.zenDeskInfo["AccountKey"] else {
            return ""
        }
        return accountKey
    }()

    init(_ defaults: Defaults) {
        self.defaults = defaults
        dataLayer = GoLujoAPIManager()
    }

    convenience init() {
        self.init(Defaults.shared)
    }

    func store(currentUser: LoginUser) {
        defaults.set(currentUser, for: .currentUser)
    }

    func getCurrentUser() -> LoginUser? {
        return defaults.get(for: .currentUser)
    }

    func store(userInfo: LujoUser) {
        defaults.set(userInfo, for: .userInformation)
    }

    func getLujoUser() -> LujoUser? {
        return defaults.get(for: .userInformation)
    }

    func storeVerificationCode(_ code: String) {
        defaults.set(code, for: .verificationCode)
    }

    func getVerificationCode() -> String? {
        return defaults.get(for: .verificationCode)
    }

    func deleteCurrentUser() {
        defaults.clear(.currentUser)

        // remove cashed items
        PreloadDataManager.HomeScreen.scrollViewData = nil
        PreloadDataManager.DiningScreen.scrollViewData = nil

        if FileManager.default.isDeletableFile(atPath: userImagePath) {
            try? FileManager.default.removeItem(atPath: userImagePath)
        }
    }

    // MARK: Application Defaults
    
    func getSetup() {
        dataLayer.getDefaults { result, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                return
            }
            self.storeDefaults(result)
        }
    }

    func updateDefaults(_ completion: (() -> Void)?) {
        dataLayer.getDefaults { result, error in
            guard error == nil else {
                Crashlytics.sharedInstance().recordError(error!)
                return
            }
            self.storeDefaults(result)
        }

        if getCountryCodes() == nil {
            dataLayer.getCountryCodes { codes, error in
                guard error == nil else {
                    return
                }
                self.store(codes)
            }
        }

        guard let token = getCurrentUser()?.token else {
            if let completion = completion {
                completion()
            }
            return
        }

        dataLayer.userProfile(for: token) { user, error in
            guard error == nil, let user = user else {
                self.deleteCurrentUser()
                if let completion = completion {
                    completion()
                }
                return
            }

            self.storeProfileFor(user: user)

            if let completion = completion {
                completion()
            }
        }
    }

    fileprivate func storeDefaults(_ result: [String: Any]) {
        if let margins = result["margins"] as? [String: Any] {
            if let sMargin = margins["members"] as? String, let mMargin = Double(sMargin) {
                let margin: Double = mMargin / 100.0
                defaults.set(margin, for: .memberMargin)
            }

            if let sNMargin = margins["non-members"] as? String, let nMMargin = Double(sNMargin) {
                let margin: Double = nMMargin / 100.0
                defaults.set(margin, for: .nonMemberMargin)
            }
        }
        
        if let membershipPlans = result["membership_plans"] as? [[String: Any]] {
            var memberships: [Membership] = []
            for plan in membershipPlans {
                memberships.append(Membership(data: plan))
            }
            
            PreloadDataManager.Memberships.memberships = memberships
        }
    }

    fileprivate func storeProfileFor(user: LujoUser) {
        store(userInfo: user)
        store(currentUser: user.getLoginUser())

//        guard !user.avatar.isEmpty else { return }
//        guard var urlComponents = URLComponents(string: user.avatar) else { return }
//
//        urlComponents.scheme = "https"
//
//        guard let newImageUrl = urlComponents.string, let imageURL = URL(string: newImageUrl) else { return }
//
//        do {
//            guard let image = try UIImage(withUrl: imageURL) else { return }
//            storeUserImage(image)
//        } catch {
//            let error = BackendError.parsing(reason: "Error loading Image from \(user.avatar)")
//            Crashlytics.sharedInstance().recordError(error)
//        }
    }

    func store(_ codes: [PhoneCountryCode]) {
        defaults.set(codes, for: .countryCodes)
    }

    func getMembersMargin() -> Double? {
        return defaults.get(for: .memberMargin)
    }

    func getNonMembersMargin() -> Double? {
        return defaults.get(for: .nonMemberMargin)
    }

    func getCountryCodes() -> [PhoneCountryCode]? {
        return defaults.get(for: .countryCodes)
    }

    func getCode(for prefix: String) -> PhoneCountryCode? {
        return getCountryCodes()?.filter({ $0.phonePrefix == prefix }).first
    }
    
    func store( userPreferences: Preferences) {
        defaults.set(userPreferences, for: .userPreferences)
    }
    
    func getUserPreferences() -> Preferences? {
        return defaults.get(for: .userPreferences)
    }
}
