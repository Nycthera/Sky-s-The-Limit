import Foundation
import Appwrite
import UIKit
import AppwriteModels
import JSONCodable

// --- Global Constants & Variables ---
let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
let databaseID = "69114f5e001d9116992a"
let tableID = "constellation"

// This array will store the unique ID(s) of the user's document(s).
var userTableIDs: [String] = []


/// Creates a brand new document for a first-time user.
func post_to_database(equations: [String], name: String) async {
    print("User has no document. Creating a new one...")
    do {
        let document = try await appwrite.table.createRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: ID.unique(),
            data: [
                "userid": deviceID,
                "equations": equations,
                "isShared": false,
                "name": name
            ],
            permissions: [
                Permission.read(Role.any()),
                Permission.update(Role.any()),
                Permission.delete(Role.any())
            ]
        )
        print("Document created successfully: \(document.id)")
        // After creating, we should update our list of known IDs.
        userTableIDs.append(document.id)
    } catch {
        print("Error creating document: \(error.localizedDescription)")
    }
}


/// Fetches and stores the document IDs for the current user.
func list_document_for_user() async {
    print("Checking for existing documents for user: \(deviceID)...")
    do {
        let rowList = try await appwrite.table.listRows(
            databaseId: databaseID,
            tableId: tableID,
            queries: [
                Query.equal("userid", value: deviceID)
            ]
        )
        // Get all document IDs associated with this user.
        userTableIDs = rowList.rows.map { $0.id }
        
        if userTableIDs.isEmpty {
            print("No documents found for this user.")
        } else {
            print("Fetched row IDs: \(userTableIDs)")
        }
    } catch {
        print("Error listing documents: \(error.localizedDescription)")
    }
}


/// Updates a document with a new list of equations and name, using a specific row/document ID.
/// If the document doesn't exist, it creates a new one.
func update_document(rowId: String, equations: [String], name: String) async {
    print("Updating document with ID: \(rowId)...")
    do {
        _ = try await appwrite.table.updateRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: rowId,
            data: [
                "equations": equations,
                "name": name
            ],
            permissions: [Permission.read(Role.any())]
        )
        print("Document updated successfully.")
    } catch {
        print("Error updating document: \(error.localizedDescription)")
    }
}

// MARK: - Delete (DELETE)
func delete_document(rowId: String) async {
    do {
        try await appwrite.table.deleteRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: rowId
        )
        print("Document deleted: \(rowId)")
    } catch {
        print("Error deleting document: \(error.localizedDescription)")
    }
}

// MARK: - Share / Unshare
func toggle_share(rowId: String, share: Bool) async {
    do {
        let updated = try await appwrite.table.updateRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: rowId,
            data: [
                "isShared": share
            ]
        )
        print(share ? " Constellation shared: \(updated.id)" : "Constellation unshared: \(updated.id)")
    } catch {
        print("Error toggling share state: \(error.localizedDescription)")
    }
}

// MARK: - Check shared document (public access)
func get_shared_document(rowId: String) async {
    do {
        let document = try await appwrite.table.getRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: rowId
        )
        print("Shared document fetched: \(document)")
    } catch {
        print("Error fetching shared document: \(error.localizedDescription)")
    }
}

/// Fetches the first document belonging to the current user
/// and prints/returns its contents.
struct Constellation: Identifiable {
    let id: String
    let userId: String
    let name: String
    let equations: [String]
    let isShared: Bool
}


func get_document_for_user(rowId: String) async -> Constellation? {
    do {
        let document = try await appwrite.table.getRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: rowId
        )
        
        let userId = (document.data["userid"] as? AnyCodable)?.value as? String ?? "unknown"
        let isShared = (document.data["isShared"] as? AnyCodable)?.value as? Bool ?? false
        let name = (document.data["name"] as? AnyCodable)?.value as? String ?? "Untitled"
        print(name) // "Why" or "Untitled" if nil

        
        var equations: [String] = []
        if let anyEquations = document.data["equations"] as? AnyCodable {
            if let arr = anyEquations.value as? [String] {
                equations = arr
            } else if let single = anyEquations.value as? String {
                equations = [single]
            }
        }
        
        return Constellation(
            id: document.id,
            userId: userId,
            name: name,
            equations: equations,
            isShared: isShared
        )

    } catch {
        print("Error fetching document: \(error.localizedDescription)")
        return nil
    }
}




func checkIfUserHasDocument() async -> Bool {
    await list_document_for_user()   // updates userTableIDs
    
    print("Response from checkIfUserHasDocument(): \(userTableIDs)")
    
    // Return true if NO documents, false if documents exist
    return userTableIDs.isEmpty
}
