import UIKit

protocol HomeEventsLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class HomeEventsLayout: UICollectionViewLayout {
    weak var delegate: HomeEventsLayoutDelegate!

    fileprivate var numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 6
    fileprivate var cellHeight: CGFloat = 246

    fileprivate var cache = [UICollectionViewLayoutAttributes]()

    fileprivate var contentHeight: CGFloat = 0

    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }

        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()

        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            let height = cellPadding * 2 + cellHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributers = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributers.frame = insetFrame
            cache.append(attributers)

            yOffset[column] = yOffset[column] + height

            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
        var totalRows = collectionView.numberOfItems(inSection: 0) / 2
        if collectionView.numberOfItems(inSection: 0) % 2 != 0 { totalRows += 1 }

        contentHeight = (cellPadding * 2 + cellHeight) * CGFloat(totalRows)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

    func clearCache() {
        cache.removeAll()
    }
}
