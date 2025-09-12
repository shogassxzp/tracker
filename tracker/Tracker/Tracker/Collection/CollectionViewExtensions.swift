import UIKit

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.inedtifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        cell.contentView.backgroundColor = .whiteDay
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = TrackerCell()
        headerView.titleLabel.text = "Пися попа какашечка"
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let targetSize = CGSize(
            width: collectionView.frame.width,
            height: UIView.layoutFittingCompressedSize.height)

        let calculatedSize = headerView.systemLayoutSizeFitting(
            targetSize, withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)

        return calculatedSize
    }
}
