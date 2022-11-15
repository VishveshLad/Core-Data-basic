//
//  APIModelName.swift


import Foundation

// NOTE BE SURE MODEL CLASS AND DB TABLE KEY ARE SAME
struct APIModelName: Codable {
    var _id: String?
    var name: String?
    var designation: String?
    var company_name: String?
    var info: [String]?
   // NOTE WE CAN USER HERE ARRAY OF API MODELS DATA KEY AS LIKE INFO ARRAY OBJECT.
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self._id = try values.decode(String.self, forKey: ._id)
        self.name = try values.decode(String.self, forKey: .name)
        self.designation = try values.decode(String.self, forKey: .designation)
        self.company_name = try values.decode(String.self, forKey: .company_name)
        self.info = try values.decode([String].self, forKey: .info)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(_id, forKey: ._id)
        try container.encode(name, forKey: .name)
        try container.encode(designation, forKey: .designation)
        try container.encode(company_name, forKey: .company_name)
        try container.encode(info, forKey: .info)
    }
    
    init(_id: String?, name: String?, designation: String?, company_name: String?, info: [String]? ) {
        self._id = _id
        self.name = name
        self.designation = designation
        self.company_name = company_name
        self.info = info
    }
    
    init(name: String?, designation: String?, company_name: String?, info: [String]?) {
        self.init(_id: UUID().uuidString, name: name, designation: designation, company_name: company_name, info: info)
    }
    
    public enum CodingKeys: String, CodingKey {
        case _id
        case name
        case designation
        case company_name
        case info
    }
}

// BINDING DATA
extension APIModelName {
    var getBindDBData : [String:Any]? {
        guard var objDict = self.dictionary else {
            return nil
        }
        // CHANGE KEY OF DICT MODEL
        objDict = objDict.changeKey(from: [APIModelName.CodingKeys._id.rawValue], to: "_id")
        // ABOVE IS CHANGE KEY TO STORE DATA IN DB AND MAKE SAME KEY AS LIKE TABLE KEY
        
        // CONVERT MODEL TO JSON SSTRING AND STRORE IN DB
        // INSIDE DB DATA TYPE WILL BE STRING
        objDict[APIModelName.CodingKeys.info.rawValue] = self.info.convertToJSONString()
        return objDict
    }
}
