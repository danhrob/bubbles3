//
//  BubbleDefinitions.swift
//  storyboard3
//
//  Created by Dan on 01.11.2021.
//

import SwiftUI

struct bubbledata: Identifiable, Hashable {
    
    var subviewVisibility: Bool 
    var id                          = UUID()
    var x: CGFloat
    var y: CGFloat
    var dx: CGFloat
    var dy: CGFloat
    var rotation: Double
    var loopTime: Double
    var lifeTime: Double
    var type: Int
    var arrayId: Int
  
}

let bubbleNumMax: Int               = 50

var score                           = 0

class BubbleToDelegate: ObservableObject {
    
    var x: CGFloat                  = 50
    var y: CGFloat                  = 50
    var lifetime: Double            = 10000
    @Published var status: Int      = 0 //0 OK, -1 remove from list
    
    init() {
        
    }
    
    func updateData() {
        
    }
}

struct element
{
    var zobrazit: String            = ""
    var kliknuto: Int               = 0
}

var symbolyProZobrazeniInit: [String]       = []
let levelName: String                       = "Level 1 - A" //A odpovida Data pro zobrazeni

//var dataProZobrazeni: [String]              = dataProZobrazeniInit
var symbolyProZobrazeni: [String]           = symbolyProZobrazeniInit


func zobrazNahodnySymbol()                 -> String {
    var nahodnySymbol                      = ""
    //pole, ze ktereho budeme brat pismeno    
    let symbolyProZobrazeni = GameSettings().znakyKZobrazeni
    let indexProZobrazeni                   = Int.random(in: 0...symbolyProZobrazeni.count-1)
    if symbolyProZobrazeni[indexProZobrazeni]  ==  "" {
        for i in indexProZobrazeni...symbolyProZobrazeni.count-1 {
            if !(symbolyProZobrazeni[i]        == "") {
                nahodnySymbol              = symbolyProZobrazeni[i]
                return nahodnySymbol
            }
        }
        for i in 0...symbolyProZobrazeni.count-1 {
            if !(symbolyProZobrazeni[i]        == "") {
                nahodnySymbol              = symbolyProZobrazeni[i]
                return nahodnySymbol
            }
        }
    } else {
        nahodnySymbol                      = symbolyProZobrazeni[indexProZobrazeni]
    }
    //je-li zde nahodne pismeno "", nejsou jiz v poli zadna pismena, je hotovo
    return nahodnySymbol
}
