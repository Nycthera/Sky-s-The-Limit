import Foundation
import Appwrite
import UIKit
import AppwriteModels
import JSONCodable

let deviceID = UIDevice.current.identifierForVendor?.uuidString
var userTableIDs: [String] = [] // store fetched row IDs
let databaseID = "69114f5e001d9116992a"
let tableID = "constellation"

func post_to_database() async {
    let userid = deviceID ?? ""
    
    do {
        let document = try await appwrite.table.createRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: ID.unique(),
            data: [
                "userid": userid,
                "equations": ["1", "1"]
            ],
            permissions: [Permission.read(Role.any())]
        )
        print("Document created: \(document)")
    } catch {
        print("Error creating document: \(error.localizedDescription)")
    }
}

func list_document_for_user() async {
    let userid = deviceID ?? ""
    
    do {
        let rowList = try await appwrite.table.listRows(
            databaseId: databaseID,
            tableId: tableID,
            queries: [
                Query.equal("userid", value: userid)
            ]
        )
        
        // Extract IDs
        userTableIDs = rowList.rows.compactMap { row in
            row.data["$id"]?.value as? String
        }
        
        print("Fetched row IDs: \(userTableIDs)")
        print("Full rowList: \(rowList)")
        
    } catch {
        print("Error fetching rows: \(error.localizedDescription)")
    }
}

func get_documents_for_user() async {
    for rowId in userTableIDs {
        do {
            let response = try await appwrite.table.getRow(
                databaseId: databaseID,
                tableId: tableID,
                rowId: rowId
            )
            print("Fetched row: \(response)")
        } catch {
            print("Error fetching row \(rowId): \(error.localizedDescription)")
        }
    }
}
