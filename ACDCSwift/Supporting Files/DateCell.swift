//
//  DateCell.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 18/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import Foundation
import SpreadsheetView

class DataCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont (name: "SFCompactDisplay-Regular", size: 13)
        label.textAlignment = .center
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ResultCell: Cell {
    let label = UILabel()
    let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = CGRect(x:10,y:10,width:20,height:20)

        label.frame = CGRect(x:40,y:0,width:100,height:40)
        label.font = UIFont (name: "SFCompactDisplay-Regular", size: 13)
        label.textAlignment = .left
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

