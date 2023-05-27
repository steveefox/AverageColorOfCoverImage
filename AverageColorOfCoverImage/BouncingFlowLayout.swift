//
//  BouncingFlowLayout.swift
//  AverageColorOfCoverImage
//
//  Created by Nikita on 26/05/2023.
//

import UIKit

final class BouncingFlowLayout: UICollectionViewFlowLayout {
	let sideItemScale: CGFloat
	let sideItemAlpha: CGFloat
	let interItemSpacing: CGFloat
	let direction: UICollectionView.ScrollDirection
	
	init(sideItemScale: CGFloat,
		 sideItemAlpha: CGFloat,
		 interItemSpacing: CGFloat,
		 itemSize: CGSize,
		 direction: UICollectionView.ScrollDirection,
		 sectionInset: UIEdgeInsets) {
		self.sideItemScale = sideItemScale
		self.sideItemAlpha = sideItemAlpha
		self.interItemSpacing = interItemSpacing
		self.direction = direction
		
		super.init()
		super.sectionInset = sectionInset
		super.itemSize = itemSize
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override public func prepare() {
		super.prepare()
		
		scrollDirection = direction
		
		collectionView?.decelerationRate = .normal
		collectionView?.isPagingEnabled = false
		updateLayout()
	}

	private func updateLayout() {
		let isHorizontal = (self.scrollDirection == .horizontal)
		let side = isHorizontal ? self.itemSize.width : self.itemSize.height
		let scaledItemOffset = (side - side*self.sideItemScale) / 2
		minimumLineSpacing = interItemSpacing - scaledItemOffset
	}

	override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}

	override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let superAttributes = super.layoutAttributesForElements(in: rect),
			let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
			else { return nil }
		return attributes.map({ self.transformLayoutAttributes(attributes: $0) })
	}

	private func transformLayoutAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		guard let collectionView = self.collectionView else { return attributes }
		let isHorizontal = (self.scrollDirection == .horizontal)

		let collectionCenter = isHorizontal ? collectionView.frame.size.width/2 : collectionView.frame.size.height/2
		let offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
		let normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset

		let maxDistance = (isHorizontal ? self.itemSize.width : self.itemSize.height) + self.minimumLineSpacing
		let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
		let ratio = (maxDistance - distance)/maxDistance

		let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
		let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
		attributes.alpha = alpha
		attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)

		return attributes
	}

	override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView = collectionView, !collectionView.isPagingEnabled,
			  let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds)
		else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }

		let isHorizontal = (self.scrollDirection == .horizontal)

		let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
		let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide

		var targetContentOffset: CGPoint
		if isHorizontal {
			let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
			targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
		} else {
			let closest = layoutAttributes
				.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }
				.first ?? UICollectionViewLayoutAttributes()
			targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - midSide))
		}

		return targetContentOffset
	}
}

