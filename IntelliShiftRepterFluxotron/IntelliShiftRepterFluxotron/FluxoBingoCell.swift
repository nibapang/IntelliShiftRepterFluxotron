//
//  FluxoBingoCell.swift
//  IntelliShiftRepterFluxotron
//
//  Created by SunTory on 2025/3/7.
//

import UIKit

class FluxoBingoCell: UICollectionViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        cellBackgroundView.layer.cornerRadius = 0
        cellBackgroundView.layer.borderWidth = 1
        cellBackgroundView.layer.borderColor = UIColor.black.cgColor
        cellBackgroundView.backgroundColor = .clear
    }
    
    func configure(number: Int?, isSelected: Bool, backgroundColor: UIColor = UIColor(named: "Color 3") ?? .yellow) {
        if let number = number {
            numberLabel.text = "\(number)"
            numberLabel.isHidden = false
        } else {
            numberLabel.text = nil
            numberLabel.isHidden = true // Hide the label if the number is nil
        }
        
        if isSelected {
            cellBackgroundView.backgroundColor = UIColor.systemBlue
            bgImage.image = UIImage(named: "ic_blue_square")
            numberLabel.textColor = .white
        } else {
            cellBackgroundView.backgroundColor = backgroundColor
            numberLabel.textColor = .black
            bgImage.image = UIImage(named: "ic_green_square")
        }
    }
}
