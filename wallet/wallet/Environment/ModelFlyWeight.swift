//
//  ModelFlyWeight.swift
//  ECC-Wallet
//
//  Created by Francisco Gindre on 6/30/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import Foundation

class ModelFlyWeight {
    static let shared = ModelFlyWeight()
    
    var models = [AnyHashable : AnyObject]()
    private init() {}
    
    func modelBy<O: ObservableObject>(defaultValue: O) -> O {
        let id = idFor(defaultValue)
        guard let model = models[id] as? O else {
            models[id] = defaultValue
            return defaultValue
        }
        return model
    }
    
    private func idFor<O: ObservableObject>(_ flyweight: O) -> String {
        String(describing: type(of: flyweight))
    }
    
    func dispose<O: ObservableObject>(flyweight: O) {
        let id = idFor(flyweight)
        models[id] = nil
    }
}
