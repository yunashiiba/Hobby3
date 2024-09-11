//
//  Datas.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/04.
//
//data = [0"passwprd",1"user_id",2"age",3"country",4"color",5"id",6"hobby",7"hobby",8"hobby"]

import Foundation
import RealmSwift
import UIKit

class UserData: Object{
    @objc dynamic var passwprd: String = ""
    @objc dynamic var user_id: String = ""
    @objc dynamic var age: Int = 0
    @objc dynamic var country: Int = 0
    @objc dynamic var hobby1: String = ""
    @objc dynamic var hobby2: String = ""
    @objc dynamic var hobby3: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var todayencount: Int = 0
    @objc dynamic var screen: Int = 0
    @objc dynamic var lastcheck = Date()
    @objc dynamic var id: Int = 0
}

class Encount: Object{
    @objc dynamic var id: Int = 0
    @objc dynamic var hobby: String = ""
    @objc dynamic var encountDay = Date()
    @objc dynamic var x: Float = 0
    @objc dynamic var y: Float = 0
    @objc dynamic var color: String = ""
    @objc dynamic var country: Int = 0
    @objc dynamic var user: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class EncountHobby: Object{
    @objc dynamic var hobby: String = ""
    @objc dynamic var encount: Int = 0
    @objc dynamic var motherhobby: String = ""
}

func resetRealm(){
    let realm = try! Realm()
    try! realm.write {
        let UserData = realm.objects(UserData.self)
        realm.delete(UserData)
        let Encount = realm.objects(Encount.self)
        realm.delete(Encount)
        let EncountHobby = realm.objects(EncountHobby.self)
        realm.delete(EncountHobby)
    }
}


func toRealm(data: [String]){
    let realm = try! Realm()
    let userData: UserData? = realm.objects(UserData.self).first
    
    try! realm.write {
        if let user = userData {
            user.age = Int(data[2]) ?? 0
            user.country = Int(data[3]) ?? 0
            user.hobby1 = data[6]
            user.hobby2 = data[7]
            user.hobby3 = data[8]
            user.color = data[4]
            user.id = Int(data[5]) ?? 0
        } else {
            let newUser = UserData()
            newUser.passwprd = data[0]
            newUser.user_id = data[1]
            newUser.age = Int(data[2]) ?? 0
            newUser.country = Int(data[3]) ?? 0
            newUser.hobby1 = data[6]
            newUser.hobby2 = data[7]
            newUser.hobby3 = data[8]
            newUser.color = data[4]
            newUser.id = Int(data[5]) ?? 0

            realm.add(newUser)
        }
    }
}

func toData() -> [String]{
    var data : [String] = []
    let realm = try! Realm()
    let userData: UserData? = realm.objects(UserData.self).first
    
    if let userData = userData {
        data  += [userData.passwprd, userData.user_id, String(userData.age), String(userData.country), userData.color, String(userData.id), userData.hobby1, userData.hobby2, userData.hobby3]
    }
    
    return data
}
