import UIKit
import AVFoundation

protocol ImageCarouselDelegate: class {
    func didMoveTo(position: Int)
    func didTappedOnHeartAt(index: Int, sender: ImageCarousel)
}

class ImageCarousel: UIView {
    lazy var collectionView: UICollectionView = {
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
            collectionView.reloadData()
        }
    }

    //Zahoor to be used in dining only
    var restaurantsList: [Product] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var itemsList: [Product] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var imageURLList: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var scrollToItem: Int = 0 {
        didSet {
            if (scrollToItem > 0){
                self.collectionView.reloadData()
                self.collectionView.layoutIfNeeded()
                let indexPath = IndexPath(item: scrollToItem, section: 0)
                self.collectionView.isPagingEnabled = false //because there is a bug in ios14 xcode 12
//                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                self.collectionView.isPagingEnabled = true
            }
        }
    }
    
    var titleList: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var categoryList: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var starList: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var locationList: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var tagsList: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var overlay = false

    var currentIndex: Int? {
        return collectionView.indexPathsForVisibleItems.first?.row
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
        addSubview(collectionView)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate(
            [collectionView.topAnchor.constraint(equalTo: topAnchor),
             collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
             collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
             collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)]
        )
    }

    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    //Zahoor
    @objc func tappedOnHeart(_ sender:AnyObject){
        delegate?.didTappedOnHeartAt(index: sender.view.tag, sender: self)
    }
}

extension ImageCarousel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCarouselCell.identifier,
                                                    for: indexPath) as! ImageCarouselCell
        cell.primaryImage.downloadImageFrom(link: imageURLList[indexPath.row], contentMode: .scaleAspectFill)
        //*****
        //Home*
        //*****
        if ( itemsList.count > indexPath.row){  //in gallery, itemsList count would be 0
            let model = itemsList[indexPath.row]
            if( model.thumbnail?.mediaType == "video"){
                cell.primaryImage.isHidden = false;
                cell.containerView.removeLayer(layerName: "videoPlayer")//removing video player if was added
                var avPlayer: AVPlayer!
                //Playing the video
                if let videoLink = URL(string: model.thumbnail?.mediaUrl ?? ""){
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
                }else if let mediaLink = model.thumbnail?.thumbnail {
                    cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            }
            //checking favourite image red or white
            if (model.isFavourite ?? false){
                cell.imgHeart.image = UIImage(named: "heart_red")
            }else{
                cell.imgHeart.image = UIImage(named: "heart_white")
            }
        }else
        //********
        //Dinning*
        //********
        if ( restaurantsList.count > indexPath.row){  //in gallery, itemsList count would be 0
            let model = restaurantsList[indexPath.row]
            if( model.thumbnail?.mediaType == "video"){
                cell.primaryImage.isHidden = false;
                cell.containerView.removeLayer(layerName: "videoPlayer")//removing video player if was added
                var avPlayer: AVPlayer!
                //Playing the video
                if let videoLink = URL(string: model.thumbnail?.mediaUrl ?? ""){
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
                    if let mediaLink = model.thumbnail?.thumbnail {
                    cell.primaryImage.downloadImageFrom(link: mediaLink, contentMode: .scaleAspectFill)
                }
            }
            //checking favourite image red or white
            if (model.isFavourite ?? false){
                cell.imgHeart.image = UIImage(named: "heart_red")
            }else{
                cell.imgHeart.image = UIImage(named: "heart_white")
            }
        }
        //Add tap gesture on favourite
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageCarousel.tappedOnHeart(_:)))
        cell.imgHeart.isUserInteractionEnabled = true   //can also be enabled from IB
        cell.imgHeart.tag = indexPath.row
        cell.imgHeart.addGestureRecognizer(tapGestureRecognizer)
        //Zahoor end

        
        if titleList.count > indexPath.row, !titleList[indexPath.row].isEmpty {
            cell.titleLabel.text = titleList[indexPath.row]
            cell.imgHeart.isHidden = false
        }else{  // on gallery there are no titles
            cell.imgHeart.isHidden = true
        }

        if categoryList.count > indexPath.row, !categoryList[indexPath.row].isEmpty {
            cell.categoryLabel.isHidden = false
            cell.imgHeart.isHidden = false
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
//        print(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.row)
        delegate?.didMoveTo(position: indexPath.row)    //because of a bug in ios14 xcode12.. its not working properly
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
