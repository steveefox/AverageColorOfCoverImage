//
//  ViewController.swift
//  AverageColorOfCoverImage
//
//  Created by Nikita on 26/05/2023.
//

import UIKit

// MARK: - Types
extension ViewController {
	struct Cover {
		let image: UIImage?
	}
}

final class ViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var backgroundView: UIView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var colorValueTitleLabel: UILabel!
	
	@IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
	
	// MARK: - Properties
	private let cellReuseIdentifier: String = "cover_image_cell"
	
	private let safelyBackgroundColor: UIColor = .clear
	private let alphaForAverageColor: CGFloat = 0.6
	
	// MARK: - DataSource
	private let covers: [Cover] = (0...10).compactMap { .init(image: .init(named: "cover_\($0)")) }
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		baseConfigure()
		updateBackgroundFor(image: covers.first?.image, animated: false)
	}
}

// MARK: - Main Methods
private extension ViewController {
	var middleItemIndexPath: IndexPath? {
		let collectionBounds: CGRect = collectionView.bounds
		let center: CGPoint = .init(x: collectionBounds.midX, y: collectionBounds.midY)
		
		return collectionView.indexPathForItem(at: center)
	}
	
	func updateBackgroundColorForCurrentCover(animated: Bool) {
		guard let middleItemIndexPath else {
			updateBackgroundFor(color: nil, animated: animated)
			return
		}
		
		let image: UIImage? = (collectionView.cellForItem(at: middleItemIndexPath) as? CoverImageCell)?.coverImage
		updateBackgroundFor(image: image, animated: animated)
	}
	
	func updateBackgroundFor(image: UIImage?, animated: Bool) {
		let averageColor: UIColor? = image?.averageColor?.withAlphaComponent(alphaForAverageColor)
		updateBackgroundFor(color: averageColor, animated: animated)
	}
	
	func updateBackgroundFor(color: UIColor?, animated: Bool) {
		let backgroundColor: UIColor = color ?? safelyBackgroundColor
		let text: String = color?.hexString ?? "default (\(safelyBackgroundColor.hexString))"
		
		if animated {
			let duration: TimeInterval = 0.3
			let options: UIView.AnimationOptions = [.curveLinear, .beginFromCurrentState, .allowUserInteraction]
			UIView.animate(withDuration: duration, delay: .zero, options: options) {
				self.backgroundView.backgroundColor = backgroundColor
			}
			
			UIView.transition(with: colorValueTitleLabel, duration: 0.3, options: options) {
				self.colorValueTitleLabel.text = text
			}
		} else {
			backgroundView.backgroundColor = backgroundColor
			colorValueTitleLabel.text = text
		}
	}
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		covers.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cover: Cover = covers[indexPath.row]
		let cell: CoverImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CoverImageCell
		
		cell.configure(image: cover.image)
		
		return cell
	}
}

// MARK: - ScrollDelegate
extension ViewController: UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		updateBackgroundColorForCurrentCover(animated: true)
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard !decelerate else { return }
		
		updateBackgroundColorForCurrentCover(animated: true)
	}
}

// MARK: - Base configuration
private extension ViewController {
	func baseConfigure() {
		setupCollectionView()
		colorValueTitleLabel.text = ""
	}
	
	func setupCollectionView() {
		collectionView.dataSource = self
		collectionView.register(CoverImageCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
		
		let height: CGFloat = configureCollectionViewHeightConstraint()
		setupCollectionViewLayout(collectionHeight: height, animated: false)
	}
	
	func setupCollectionViewLayout(collectionHeight: CGFloat, animated: Bool) {
		let itemWidth: CGFloat = UIScreen.main.bounds.width * 0.8
		let itemHeight: CGFloat = collectionHeight
		let layout = BouncingFlowLayout(sideItemScale: 0.8,
										sideItemAlpha: 0.9,
										interItemSpacing: 20,
										itemSize: .init(width: itemWidth, height: itemHeight),
										direction: .horizontal,
										sectionInset: .init(top: .zero, left: 20, bottom: .zero, right: 20))
		collectionView.setCollectionViewLayout(layout, animated: animated)
	}
	
	@discardableResult func configureCollectionViewHeightConstraint() -> CGFloat {
		let width: CGFloat = UIScreen.main.bounds.width * 0.8
		let height: CGFloat = width / 333 * 217
		collectionViewHeightConstraint.constant = height
		return height
	}
}
