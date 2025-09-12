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
