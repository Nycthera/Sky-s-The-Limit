//
//  AppwriteService.swift
//  Skys The Limit
//
//  Created by Chris  on 10/11/25.
//
import Foundation
import Appwrite
import JSONCodable

class Appwrite {
    var client: Client
    var account: Account
    var database: Databases
    var table: TablesDB
    
    public init() {
        self.client = Client()
            .setEndpoint("https://sgp.cloud.appwrite.io/v1")
            .setProject("690d951a00110f06cd0f")
        
        self.account = Account(client)
        self.database = Databases(client)
        self.table = TablesDB(client)
    }
}

let appwrite = Appwrite()
