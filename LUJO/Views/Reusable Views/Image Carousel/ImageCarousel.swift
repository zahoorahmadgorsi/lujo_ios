import UIKit
import AVFoundation

protocol ImageCarouselDelegate: class {
    func didMoveTo(position: Int)
}

class ImageCarousel: UIView {
    lazy var carouselView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let contentView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        contentView.dataSource = self
        contentView.delegate = self
        contentView.register(UINib(nibName: ImageCarouselCell.identifier, bundle: nil), forCellWithReuseIdentifier: ImageCarouselCell.identifier)
        contentView.isPagingEnabled = true
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
//        contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    weak var delegate: ImageCarouselDelegate?
    var shouldRemoveOverlay: Bool = false {
        didSet {
            carouselView.reloadData()
        }
    }

    var itemsList: [EventsExperiences] = [] {
        didSet {
            carouselView.reloadData()
        }
    }
    
    var imageURLList: [String] = [] {
        didSet {
            carouselView.reloadData()
        }
    }

    var titleList: [String] = [] {
        didSet {
            carouselView.reloadData()
        }
    }

    var categoryList: [String] = [] {
        didSet {
            carouselView.reloadData()
        }
    }

    var starList: [String] = [] {
        didSet {
            carouselView.reloadData()
        }
    }

    var locationList: [String] = [] {
        didSet {
            carouselView.reloadData()
        }
    }

    var tagsList: [String] = [] {
        didSet {
            carouselView.reloadData()
        }
    }

    var overlay = false

    var currentIndex: Int? {
        return carouselView.indexPathsForVisibleItems.first?.row
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .red
        addSubview(carouselView)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate(
            [carouselView.topAnchor.constraint(equalTo: topAnchor),
             carouselView.bottomAnchor.constraint(equalTo: bottomAnchor),
             carouselView.leadingAnchor.constraint(equalTo: leadingAnchor),
             carouselView.trailingAnchor.constraint(equalTo: trailingAnchor)]
        )
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension ImageCarousel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = carouselView.dequeueReusableCell(withReuseIdentifier: ImageCarouselCell.identifier,
                                                    for: indexPath) as! ImageCarouselCell
        cell.primaryImage.downloadImageFrom(link: imageURLList[indexPath.row], contentMode: .scaleAspectFill)
        //Zahoor started 20201027
        if ( itemsList.count > indexPath.row){  //in gallery, itemsList count would be 0
            let model = itemsList[indexPath.row]
            if( model.primaryMedia?.type == "video"){
                
                cell.primaryImage.isHidden = false;
                cell.containerView.removeLayer(layerName: "videoPlayer")//removing video player if was added
                var avPlayer: AVPlayer!
                //Playing the video
                if let videoLink = URL(string: model.primaryMedia?.mediaUrl ?? ""){
                    avPlayer = AVPlayer(playerItem: AVPlayerItem(url: videoLink))
                    let avPlayerLayer = AVPlayerLayer(player: avPlayer)
                    avPlayerLayer.name = "videoPlayer"
                    avPlayerLayer.frame = cell.containerView.bounds
                    avPlayerLayer.videoGravity = .resizeAspectFill
                    cell.containerView.layer.insertSublayer(avPlayerLayer, at: 0)
                    avPlayer.play()
                    cell.primaryImage.isHidden = true;

                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                        avPlayer?.seek(to: CMTime.zero)
                        avPlayer?.play()
                    }
                }else
                    if let mediaLink = model.primaryMedia?.thumbnail {
                    cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            }
        }
        //Zahoor end
        
        if titleList.count > indexPath.row, !titleList[indexPath.row].isEmpty {
            cell.titleLabel.text = titleList[indexPath.row]
        }

        if categoryList.count > indexPath.row, !categoryList[indexPath.row].isEmpty {
            cell.categoryLabel.isHidden = false
            cell.categoryLabel.text = "featured".uppercased() // categoryList[indexPath.row].uppercased()
            cell.categoryLabel.setCharacterSpacing(characterSpacing: 5)
        } else {
            cell.categoryLabel.isHidden = true
        }

        if starList.count > indexPath.row, !starList[indexPath.row].isEmpty {
            cell.starsContainerView.isHidden = false
            cell.starsLabel.text = starList[indexPath.row].uppercased()
        } else {
            cell.starsContainerView.isHidden = true
        }

        if locationList.count > indexPath.row, !locationList[indexPath.row].isEmpty {
            cell.locationContainerView.isHidden = false
            cell.locationLabel.text = locationList[indexPath.row].uppercased()
        } else {
            cell.locationContainerView.isHidden = true
        }

        if tagsList.count > indexPath.row, !tagsList[indexPath.row].isEmpty {
            cell.tagsContainerView.alpha = 1
            cell.tagLabel.text = tagsList[indexPath.row].uppercased()
        }

        cell.gradientImageView.isHidden = shouldRemoveOverlay

        return cell
        // swiftlint:enable force_cast
    }
}

extension ImageCarousel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.didMoveTo(position: indexPath.row)
    }
}

extension ImageCarousel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
