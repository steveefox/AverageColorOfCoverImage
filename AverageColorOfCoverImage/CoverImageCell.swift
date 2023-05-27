//
//  CoverImageCell.swift
//  AverageColorOfCoverImage
//
//  Created by Nikita on 26/05/2023.
//

import UIKit

final class CoverImageCell: UICollectionViewCell {
	let coverImageView: UIImageView = {
		let imageView: UIImageView = .init()
		imageView.contentMode = .scaleAspectFill
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 16
		imageView.layer.shadowColor = UIColor.black.cgColor
		imageView.layer.shadowOpacity = 0.8
		imageView.layer.shadowOffset = CGSize.zero
		imageView.layer.shadowRadius = 5
		
		return imageView
	}()
	
	// MARK: - Lifecycle
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		baseSetup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		coverImageView.frame = bounds
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		coverImageView.image = nil
	}
}

// MARK: - Configuration
extension CoverImageCell {
	var coverImage: UIImage? {
		coverImageView.image
	}
	
	func configure(image: UIImage?) {
		coverImageView.image = image
	}
}

// MARK: - Base setup
private extension CoverImageCell {
	func baseSetup() {
		backgroundColor = .clear
		addSubviews()
	}
	
	func addSubviews() {
		addSubview(coverImageView)
	}
}
