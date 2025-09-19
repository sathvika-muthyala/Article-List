//
//  CountryTableViewCell.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/18/25.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    private let nameRegionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .systemCyan
        return label
    }()
    
    private let abbriLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let capitalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupViews() {
        contentView.addSubview(nameRegionLabel)
        contentView.addSubview(abbriLabel)
        contentView.addSubview(capitalLabel)
        
        nameRegionLabel.translatesAutoresizingMaskIntoConstraints = false
        abbriLabel.translatesAutoresizingMaskIntoConstraints = false
        capitalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameRegionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameRegionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameRegionLabel.trailingAnchor.constraint(lessThanOrEqualTo: abbriLabel.leadingAnchor, constant: -8),
            
            abbriLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            abbriLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            capitalLabel.topAnchor.constraint(equalTo: nameRegionLabel.bottomAnchor, constant: 8),
            capitalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            capitalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            capitalLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with viewModel: CountryViewModel, at indexPath: IndexPath, in recentsTableView: UITableView){
        self.nameRegionLabel.text = "\(viewModel.getCountryName(row: indexPath.row)),\(viewModel.getRegion(row: indexPath.row))"
        self.abbriLabel.text = viewModel.getCode(row: indexPath.row)
        self.capitalLabel.text = viewModel.getCapital(row: indexPath.row)
    }
}
