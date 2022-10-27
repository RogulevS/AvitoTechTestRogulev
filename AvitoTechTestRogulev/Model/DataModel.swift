//
//  DataModel.swift
//  AvitoTechTestRogulev
//
//  Created by Rogulev Sergey on 24.10.2022.
//

import Foundation

struct DataModel: Decodable {
    let company: CompanyData
}

struct CompanyData: Decodable {
    let name: String
    let employees: [EmployeeData]
}

struct EmployeeData: Decodable {
    let name: String
    let phoneNumber: String
    let skills: [String]
  
    enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "phone_number"
        case skills 
    }
}



