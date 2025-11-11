import Foundation
import Appwrite
import UIKit
import AppwriteModels
import JSONCodable

let deviceID = UIDevice.current.identifierForVendor?.uuidString
var userTableIDs: [String] = []
let databaseID = "69114f5e001d9116992a"
let tableID = "constellation"

// ... (your other functions like post_to_database, list_document_for_user can stay the same) ...

func list_document_for_user() async {
    let userid = deviceID ?? ""
    do {
        let rowList = try await appwrite.table.listRows(
            databaseId: databaseID,
            tableId: tableID,
            queries: [Query.equal("userid", value: userid)]
        )
        userTableIDs = rowList.rows.map { $0.id }
        print("Fetched row IDs: \(userTableIDs)")
    } catch {
        print("Error fetching rows: \(error.localizedDescription)")
    }
}

// MODIFIED FUNCTION
func update_document_for_user(equations: [String]) async {
    guard let docIdToUpdate = userTableIDs.first else {
        print("Cannot update: No document ID found for the user.")
        // You could call post_to_database() here to create a new document if none exist
        return
    }
    
    let userid = deviceID ?? ""
    
    do {
        let row = try await appwrite.table.updateRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: docIdToUpdate,
            data: ["userid": userid, "equations": equations],
            permissions: [Permission.read(Role.any())]
        )
        print("Document updated: \(row)")
    } catch {
        print("Error updating document: \(error.localizedDescription)")
    }
}
