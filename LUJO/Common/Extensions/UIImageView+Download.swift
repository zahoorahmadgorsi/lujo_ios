import FirebaseCrashlytics
import UIKit
import Kingfisher

extension Kingfisher.CacheType {
    var asString: String {
        switch self {
        case .disk:   return "disk"
        case .memory: return "memory"
        case .none:   return "none"
        }
    }
}

extension UIImageView {
    func downloadImageFrom(link: String, contentMode: UIView.ContentMode) {
        guard let imageUrl = URL(string: link) else {
            print("Invalid image url \(link)")
            image = UIImage(named: "placeholder-img")
            return
        }
        
        self.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder-img"), completionHandler: { result in
            switch result {
            case .success(let data):
                //print("✅ Kingfisher - Successfully fetched image from \(link) 💾 cache: \(data.cacheType.asString)")
                self.contentMode = contentMode
                
            case .failure(let error):
                print("🛑 Kingfisher - Failed to fetch image from \(link) ❗️ \(error.localizedDescription)")
            }
        })
    }
}

extension UIImageView {
    func setRounded() {
        let radius = frame.width / 2
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}

extension UIImage {
    public enum ImageFormat {
        case pngFormat
        case jpegFormat(CGFloat)
    }

    func convertImageTobase64(format: ImageFormat) -> String? {
        var imageData: Data?
        var prefix: String!
        switch format {
            case .pngFormat:
                imageData = pngData()
                prefix = "data:image/png;base64,"
            case let .jpegFormat(compression):
                prefix = "data:image/jpeg;base64,"
                imageData = jpegData(compressionQuality: compression)
        }
        return prefix + imageData!.base64EncodedString()
    }
}

extension UIImage {
    convenience init?(withUrl: URL) throws {
        let imageData = try Data(contentsOf: withUrl)
        self.init(data: imageData)
    }
}
