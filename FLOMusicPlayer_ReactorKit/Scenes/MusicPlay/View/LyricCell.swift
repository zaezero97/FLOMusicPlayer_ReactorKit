//
//  LyricCell.swift
//  FLOMusicPlayer_ReactorKit
//
//  Created by 재영신 on 2022/04/24.
//

import UIKit
import SnapKit
import Then

final class LyricCell: UITableViewCell {
    static let identifier = "LyricCell"
    
    private let lyricLabel = UILabel().then {
        $0.textAlignment = .center
    }

//    override var isSelected: Bool {
//        willSet {
//            print(" \(lyricLabel.text) isSelected: \(isSelected)")
//            lyricLabel.textColor = newValue ? .black : .gray
//        }
//    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lyricLabel.textColor = .gray
    }
    
    private func configureUI() {
        
        contentView.addSubview(lyricLabel)
        selectionStyle = .none
        
        lyricLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func update(with lyric: String) {
        lyricLabel.text = lyric
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {

        lyricLabel.textColor = selected ? .black : .gray
    }
    
}
