import UIKit

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let isCompleted = completedTrackers.contains(tracker.id)
        let completionCount = TrackerStore.shared.completionCount(trackerId: tracker.id.uuidString)

        cell.configure(
            with: tracker,
            date: currentDate,
            isCompleted: isCompleted,
            completionCount: completionCount,
            onCompletion: { [weak self] trackerId, date, isCompleted in
                self?.handleTrackerCompletion(
                    trackerId: UUID(uuidString: trackerId) ?? UUID(),
                    date: date,
                    isCompleted: isCompleted
                )
            }
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = categories[section].trackers.count
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let categories = TrackerStore.shared.getCategories()
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as! HeaderView

            header.titleLabel.text = categories[indexPath.section].title
            header.titleLabel.font = .systemFont(ofSize: 19, weight: .bold)

            return header
        }
        return UICollectionReusableView()
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availibleWidth = collectionView.frame.width - 48
        let cellWidth = availibleWidth / 2
        return CGSize(width: cellWidth, height: cellWidth * 3 / 4)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 10, right: 16)
    }
}
