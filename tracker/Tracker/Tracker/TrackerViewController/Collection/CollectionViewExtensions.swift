import UIKit

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }

        cell.prepareForReuse()
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted: Bool

        do {
            isCompleted = try Dependencies.shared.recordStore.isTrackerCompleted(tracker.id, on: currentDate)
        } catch {
            isCompleted = completedTrackers.contains(tracker.id)
        }

        let completionCount: Int

        do {
            completionCount = try Dependencies.shared.recordStore.countRecords(for: tracker)
        } catch {
            completionCount = 0
        }

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
        let count = visibleCategories[section].trackers.count
        return count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? HeaderView

            header?.titleLabel.text = visibleCategories[indexPath.section].title
            header?.titleLabel.font = .systemFont(ofSize: 19, weight: .bold)

            return header ?? UICollectionReusableView()
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

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            self?.createContextMenu(for: tracker)
        }
    }

    private func createContextMenu(for tracker: Tracker) -> UIMenu {
        let editAction = UIAction(
            title: "Редактировать",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.editTracker(tracker)
        }

        let deleteAction = UIAction(
            title: "Удалить",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker)
        }

        return UIMenu(title: "", children: [editAction, deleteAction])
    }

    private func editTracker(_ tracker: Tracker) {
        let completionCount: Int
        do {
            completionCount = try Dependencies.shared.recordStore.countRecords(for: tracker)
        } catch {
            completionCount = 0
        }

        let editVC = EditTrackerViewController(tracker: tracker, completionCount: completionCount)
        editVC.modalPresentationStyle = .popover
        present(editVC, animated: true)
    }

    private func deleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены, что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            do {
                try Dependencies.shared.trackerStore.deleteTracker(tracker)
                self?.loadCategories()
            } catch {
                return
            }
        }

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
