//
//  CountryTableViewCell.swift
//  ArticleList
//
//  Created by sathvika muthyala on 9/18/25.
//

import UIKit

protocol CountryTableViewCellDelegate: AnyObject {
    func didTapDeleteButton(forCountry country: Country, row indexPath: IndexPath)
}

class CountryTableViewCell: UITableViewCell {

    weak var delegate: CountryTableViewCellDelegate?
    private var currentIndexPath: IndexPath?
    private var currentCountry: Country?
    private let nameRegionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .systemCyan
        return label
    }()
    
//    private let abbriLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.font = .systemFont(ofSize: 17, weight: .semibold)
//        return label
//    }()
//    
    private let capitalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        return button
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
        contentView.addSubview(deleteButton)
        contentView.addSubview(capitalLabel)
        
        nameRegionLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        capitalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameRegionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameRegionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameRegionLabel.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor, constant: -8),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            capitalLabel.topAnchor.constraint(equalTo: nameRegionLabel.bottomAnchor, constant: 8),
            capitalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            capitalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            capitalLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    func configure(with viewModel: CountryViewModel, at indexPath: IndexPath, in recentsTableView: UITableView){
        let country = viewModel.getCountry(row: indexPath.row)
        self.currentCountry = country                    
        self.currentIndexPath = indexPath
        self.nameRegionLabel.text = "\(viewModel.getCountryName(row: indexPath.row)),\(viewModel.getRegion(row: indexPath.row))"
//        self.abbriLabel.text = viewModel.getCode(row: indexPath.row)
//        self.capitalLabel.text = viewModel.getCapital(row: indexPath.row)
        self.capitalLabel.text = currentCountry?.capital
    }
    
    @objc private func deleteButtonTapped() {
            if let country = currentCountry, let indexPath = currentIndexPath {
                delegate?.didTapDeleteButton(forCountry: country, row: indexPath)
            }
        }
}
