//
//  Tbl_Name.swift


import Foundation
import CoreData

extension Tbl_Name {
    // batch insert
    internal static func insertData(dictData: [[String: Any]], context: NSManagedObjectContext) {
        CoreDataManager.sharedInstance.batchInsertData(entity: .Tbl_Name, dictData: dictData, context: context)
    }
    
    // batch update
    internal static func updateData(dictData: [String: Any], context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "id == %@", (dictData["id"] as? String ?? ""))
        CoreDataManager.sharedInstance.batchUpdateData(entity: .Tbl_Name, predicate: predicate, dictData: dictData, context: context)
    }
    
    internal static func updateData(objFolder: APIModelName, context: NSManagedObjectContext) {
        //Update
        guard let objUpdatedDict = objFolder.getBindDBData else {
            return
        }
        Tbl_Name.updateData(dictData: objUpdatedDict, context: context)
    }
    
    //Delete
    internal static func removeData(id: String, context: NSManagedObjectContext) {
        // fetch data
        let predicate1 = NSPredicate(format: "id == %@", id)
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = self.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1])
        
        CoreDataManager.sharedInstance.batchDeleteData(fetchRequest: fetchRequest, context: context)
    }
    
    internal static func getRecords(arrIds: [String], in context:NSManagedObjectContext) -> [Tbl_Name]? {
        let fetchRequest : NSFetchRequest<Tbl_Name>  = self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", arrIds)
        //Sorting
//        let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: "contact_id", ascending: true)
//        fetchRequest.sortDescriptors = [idDescriptor]
        
        do {
            let result = try context.fetch(fetchRequest)
            if (result.count > 0) {
                return result
            }
        } catch {
            fatalError("Failed to fetch records: \(error)")
        }
        return nil
    }
    
    internal static func getRecords(id: String, in context:NSManagedObjectContext) -> [Tbl_Name]? {
        let fetchRequest : NSFetchRequest<Tbl_Name>  = self.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let result = try context.fetch(fetchRequest)
            if (result.count > 0) {
                print(result.count)
                print(result)
                return result
            }
        } catch {
            fatalError("Failed to fetch records: \(error)")
        }
        return nil
    }

    
    internal static func getAllRecords(in context:NSManagedObjectContext) -> [Tbl_Name]? {
        let fetchRequest : NSFetchRequest<Tbl_Name>  = self.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            if (result.count > 0) {
                print(result.count)
                print(result)
                return result
            }
        } catch {
            fatalError("Failed to fetch records: \(error)")
        }
        return nil
    }
    
    
    //Check Record exist than update or insert
    internal static func checkRecordExistAndUpdateOrInsert(arrAPIModelName: [APIModelName], context: NSManagedObjectContext){
        context.performAndWait {
            let predicate = NSPredicate(format: "id IN %@", arrAPIModelName.map({ $0.id }))
            //Insert or update Tbl_Name
            if let entityStatus = CoreDataManager.sharedInstance.getRecordIfExistIn(predicate: predicate, entityName: entityNameEnum.Tbl_Name.rawValue, context: context){
                //Insert or update Tbl_Name
                var arrInsertData = [[String:Any]]()
                
                for objAPIModelName in arrAPIModelName {
                    if let arrFoundedRecords = entityStatus.Records as? [Tbl_Name], let _ = arrFoundedRecords.first(where: { $0.id == objAPIModelName.id }){
                        //Update
                        guard let objUpdatedDict = objAPIModelName.getBindDBData else {
                            return
                        }
                        Tbl_Name.updateData(dictData: objUpdatedDict, context: context)
                    }else{
                        //Insert
                        guard let objUpdatedDict = objAPIModelName.getBindDBData else {
                            return
                        }
                        arrInsertData.append(objUpdatedDict)
                    }
                }
                if arrInsertData.count > 0 {
                    // INSERT DATA
                    Tbl_Name.insertData(dictData: arrInsertData, context: context)
                }
            }
        }
    }
    
    //Remove old records which are now removed from server
    internal static func removeOldOtherThan(vaultId: String, arrIds: [String]?, context: NSManagedObjectContext) {
        context.performAndWait {
            let predicate1 = NSPredicate(format: "vaultId == %@", vaultId)
            let predicate2 = NSPredicate(format: "NOT id IN %@",arrIds ?? [])
            if let removeStatus = CoreDataManager.sharedInstance.getRecordIfExistIn(predicate: NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2]), entityName: entityNameEnum.Tbl_Name.rawValue, context: context) {
                if removeStatus.isRecordExist{
                    if let arrData = removeStatus.Records as? [Tbl_Name] {
                        for object in arrData{
                            //Remove
                            context.delete(object)
                        }
                        CoreDataManager.sharedInstance.saveContext()
                    }
                }
            }
        }
    }
}

extension Tbl_Name{
    func convertToAPIModel() -> APIModelName {
        let object = APIModelName(id: self.id, name: self.name, designation: self.designation, company_name: self.company_name, front_image: self.front_image, back_image: self.back_image, cardDetails: self.cardDetails?.convertToModel(), timeInMillis: self.timeInMillis)
        return object
    }
}



extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func printJson() {
        print(json)
    }
    
    mutating func changeKey(from: Key, to: Key) -> Dictionary{
        self[to] = self[from]
        self.removeValue(forKey: from)
        return self
    }
}


extension Encodable {
    func convertToJSONString() -> String?{
        do {
            let jsonData = try JSONEncoder().encode(self)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else{
                return nil
            }
//            print(jsonString)
            return jsonString == "null" ? nil : jsonString
        }catch {
            print(error)
            return nil
        }
    }
}

extension String {
    func convertToModel<T: Decodable>() -> T? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            print(error)
            return nil
        }
    }
}
