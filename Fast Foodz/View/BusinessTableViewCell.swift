//
//  BusinessTableViewCell.swift
//  Fast Foodz
//
//  Created by Jae Young Choi on 2/19/22.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {

    // MARK: - Interface Builder

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var container: UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        container.backgroundColor = selected ? .powderBlue : .white
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Core Functions

    /// Function to configure each cell with the Business Data Model
    func configureCell(with business: Business) {
        nameLabel.text = business.name
        icon.image = configureIcon(category: business.categories[0].alias)
        infoLabel.attributedText = configureInfoLabel(price: business.price, distance: business.distance)
    }

    /// Function to convert meters into miles and update correct pricing on string
    /// Used NSAttributedString to update the dollar sign color based on Business pricing
    func configureInfoLabel(price: String?, distance: Double) -> NSAttributedString {

        /// Distance conversion from meters to miles
        let meterToMiles = 0.00062137119
        var distanceConversion = distance * meterToMiles
        distanceConversion = round(distanceConversion * 100) / 100.0

        /// Updating price using NSMutableAttributedString and NSRange
        let dollarSignsAmount = price?.count ?? 1
        let dollarSigns = NSMutableAttributedString(string: "$$$$ • \(distanceConversion) miles")
        let range = NSRange(location: 0, length: dollarSignsAmount)
        dollarSigns.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.pickleGreen], range: range)

        return dollarSigns
    }

    /// Function to display correct icon for business
    func configureIcon(category: String) -> UIImage {
        switch category {
        case "mexican":
            return UIImage(named: "mexican")!
        case "chinese", "hotpot", "noodles", "dimsum", "cantonese", "hkcafe", "taiwanese", "soup":
            return UIImage(named: "chinese")!
        case "pizza", "italian", "pastashops":
            return UIImage(named:"pizza")!
        case "burgers", "french", "sportsbars", "hotdogs":
            return UIImage(named:"burgers")!
        default:
            return UIImage(named: "burgers")!
        }
    }


}

