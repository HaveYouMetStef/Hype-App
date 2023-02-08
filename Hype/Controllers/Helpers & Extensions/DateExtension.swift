//
//  DateExtension.swift
//  Hype
//
//  Created by Stef Castillo on 1/27/23.
//

import Foundation


extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
