import UIKit

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        cell.contentView.backgroundColor = .lightGray
        
        cell.titleLabel.textColor = .selectionBlue
        cell.titleLabel.text = "Трекер \(indexPath.item + 1)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! HeaderView
        view.titleLabel.text = "qqwe"
        return view
    }
    
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50) 
//        let headerView = HeaderView()
//        headerView.titleLabel.text = ""
//        headerView.setNeedsLayout()
//        headerView.layoutIfNeeded()
//
//        let targetSize = CGSize(
//            width: collectionView.frame.width,
//            height: UIView.layoutFittingCompressedSize.height)
//
//        let calculatedSize = headerView.systemLayoutSizeFitting(
//            targetSize, withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel)
//
//        return calculatedSize
    }
}
