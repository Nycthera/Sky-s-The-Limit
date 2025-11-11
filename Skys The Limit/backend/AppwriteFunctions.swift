import Foundation
import Appwrite
import UIKit
import AppwriteModels

// --- Global Constants & Variables ---
let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
let databaseID = "69114f5e001d9116992a"
let tableID = "constellation"
let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"

// This array will store the unique ID(s) of the user's document(s).
var userTableIDs: [String] = []


/// Creates a brand new document for a first-time user.
func post_to_database(equations: [String]) async {
    print("User has no document. Creating a new one...")
    do {
        let document = try await appwrite.table.createRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: ID.unique(),
            data: [
                "userid": deviceID,
                "equations": equations
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


/// Updates the user's first document with a new list of equations.
/// If no document exists, it calls `post_to_database` to create one.
func update_document_for_user(equations: [String]) async {
    // Ensure we have a document ID to update.
    guard let docIdToUpdate = userTableIDs.first else {
        print("Update failed: No document ID found for the user. Attempting to create one.")
        // If no document exists, we should create one instead.
        await post_to_database(equations: equations)
        return
    }
    
    print("Updating document: \(docIdToUpdate)...")
    do {
        _ = try await appwrite.table.updateRow(
            databaseId: databaseID,
            tableId: tableID,
            rowId: docIdToUpdate,
            data: [
                "userid": deviceID,
                "equations": equations
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
