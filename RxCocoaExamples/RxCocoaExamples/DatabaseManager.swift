//
//  Database.swift
//  RxCocoaExamples
//
//  Created by Federico Ojeda on 10/11/17.
//  Copyright © 2017 Federico Ojeda. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseDatabase

class DatabaseManager {
    
    let reference = Database.database().reference()
    
    func getData() -> Observable<[String]> {
        let dataRef = reference.child("data")
        return Observable.create { subscriber in
            dataRef.observe(DataEventType.value) { snapshot in
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                let values = postDict.keys.map { key -> String in
                    guard let dictValue = postDict[key], let value = dictValue["value"] as? String else {
                        return ""
                    }
                    return value
                }
                subscriber.onNext(values)
            }
            
            return Disposables.create()
        }
    }
}
