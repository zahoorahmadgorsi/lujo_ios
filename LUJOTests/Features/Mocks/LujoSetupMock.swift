@testable import LUJO
import UIKit

class SpyLuJoSetup: LoginDataStorable {
    var invokedStoreCurrentUser = false
    var invokedStoreCurrentUserCount = 0
    var invokedStoreCurrentUserParameters: (currentUser: LoginUser, Void)?
    var invokedStoreCurrentUserParametersList = [(currentUser: LoginUser, Void)]()
    func store(currentUser: LoginUser) {
        invokedStoreCurrentUser = true
        invokedStoreCurrentUserCount += 1
        invokedStoreCurrentUserParameters = (currentUser, ())
        invokedStoreCurrentUserParametersList.append((currentUser, ()))
    }

    var invokedGetCurrentUser = false
    var invokedGetCurrentUserCount = 0
    var stubbedGetCurrentUserResult: LoginUser!
    func getCurrentUser() -> LoginUser? {
        invokedGetCurrentUser = true
        invokedGetCurrentUserCount += 1
        return stubbedGetCurrentUserResult
    }

    var invokedStoreUserInfo = false
    var invokedStoreUserInfoCount = 0
    var invokedStoreUserInfoParameters: (userInfo: LujoUser, Void)?
    var invokedStoreUserInfoParametersList = [(userInfo: LujoUser, Void)]()
    func store(userInfo: LujoUser) {
        invokedStoreUserInfo = true
        invokedStoreUserInfoCount += 1
        invokedStoreUserInfoParameters = (userInfo, ())
        invokedStoreUserInfoParametersList.append((userInfo, ()))
    }

    var invokedGetUserInformation = false
    var invokedGetUserInformationCount = 0
    var stubbedGetUserInformationResult: LujoUser!
    func getUserInformation() -> LujoUser? {
        invokedGetUserInformation = true
        invokedGetUserInformationCount += 1
        return stubbedGetUserInformationResult
    }

    var invokedStoreVerificationCode = false
    var invokedStoreVerificationCodeCount = 0
    var invokedStoreVerificationCodeParameters: (code: String, Void)?
    var invokedStoreVerificationCodeParametersList = [(code: String, Void)]()
    func storeVerificationCode(_ code: String) {
        invokedStoreVerificationCode = true
        invokedStoreVerificationCodeCount += 1
        invokedStoreVerificationCodeParameters = (code, ())
        invokedStoreVerificationCodeParametersList.append((code, ()))
    }

    var invokedGetVerificationCode = false
    var invokedGetVerificationCodeCount = 0
    var stubbedGetVerificationCodeResult: String!
    func getVerificationCode() -> String? {
        invokedGetVerificationCode = true
        invokedGetVerificationCodeCount += 1
        return stubbedGetVerificationCodeResult
    }

    var invokedDeleteCurrentUser = false
    var invokedDeleteCurrentUserCount = 0
    func deleteCurrentUser() {
        invokedDeleteCurrentUser = true
        invokedDeleteCurrentUserCount += 1
    }

    var invokedStoreUserImage = false
    var invokedStoreUserImageCount = 0
    var invokedStoreUserImageParameters: (image: UIImage, Void)?
    var invokedStoreUserImageParametersList = [(image: UIImage, Void)]()
    func storeUserImage(_ image: UIImage) {
        invokedStoreUserImage = true
        invokedStoreUserImageCount += 1
        invokedStoreUserImageParameters = (image, ())
        invokedStoreUserImageParametersList.append((image, ()))
    }

    var invokedGetUserImage = false
    var invokedGetUserImageCount = 0
    var stubbedGetUserImageResult: UIImage!
    func getUserImage() -> UIImage? {
        invokedGetUserImage = true
        invokedGetUserImageCount += 1
        return stubbedGetUserImageResult
    }
}
