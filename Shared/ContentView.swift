//
//  ContentView.swift
//  Bubbles
//  Shared
//
//  Created by Dan on 20.10.2021.
//  for 130 Ltd.
//


import SwiftUI
import AVFoundation           //for short sound sound playing



// added 30.11.2021 2319 - get screen dim from any apple device (watchOS, iOS, macOS)
class SGConvenience{
    #if os(watchOS)
    static var deviceWidth:CGFloat  = WKInterfaceDevice.current().screenBounds.size.width
    static var deviceHeight:CGFloat = WKInterfaceDevice.current().screenBounds.size.height
    #elseif os(iOS)
    static var deviceWidth:CGFloat  = UIScreen.main.bounds.size.width
    static var deviceHeight:CGFloat = UIScreen.main.bounds.size.height
    #elseif os(macOS)
    static var deviceWidth:CGFloat  = (NSScreen.main?.frame.width)!
    static var deviceHeight:CGFloat = (NSScreen.main?.frame.height)!
    #endif
}




let widthBound:  CGFloat                = SGConvenience.deviceWidth  // use the display dims in app
let heightBound: CGFloat                = SGConvenience.deviceHeight

var bubbleContainer: [BubbleToDelegate] = []
var pocetBublinNaPlose:    Int          = 0
var ddx:                   Double       = 0.5 //zrychleni
var ddy:                   Double       = 0.1
let timerAccelerationModify             = 50
var timerAccelerationModifyCounter      = 50  //every 20 cycles change of dx and dy
var lifeAddition:          Double       = 0   //pridano k veku pri tahnuti
var startDate                           = NSDate()
var existujeOznacenaBublina             = 0
var smazatVsechnyOznacene: Int          = 0
var statusMessage                       = "Start"
//var bubbleList: [bubbledata] = []


func playAudio() {
    
    if let soundURL = Bundle.main.url(forResource: "pop", withExtension: "wav") {       // Load "pop.wav"
                      var mySound: SystemSoundID = 0
                      AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
                      AudioServicesPlaySystemSound(mySound); // Play
    }
    return
}



func playAsyncAudio() {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
        playAudio()
    })
}



func randomPlaceX()         -> CGFloat{
    let bubblexX: CGFloat   = CGFloat.random(in: 0...widthBound)
    return bubblexX
}



func randomPlaceY()         -> CGFloat {
    let bubbleyY: CGFloat   = CGFloat.random(in: 0...heightBound)
    return bubbleyY
}



func randomOffsetX()        -> CGFloat{
    let bubblexX: CGFloat   = CGFloat.random(in: -widthBound/2...widthBound)
    return bubblexX
}



func randomOffsetY()        -> CGFloat {
    let bubbleyY: CGFloat   = CGFloat.random(in: -heightBound/2...heightBound/2)
    return bubbleyY
}



func randomPlacedX()        -> CGFloat{
    let bubblexX: CGFloat   = CGFloat.random(in: -2.0...2.0)
    return bubblexX
}



func randomPlacedY()        -> CGFloat {
    let bubbleyY: CGFloat   = CGFloat.random(in: -2.0...2.0)
    return bubbleyY
}



func randomPlaceDdX()       -> CGFloat{
    let bubblexX: CGFloat   = CGFloat.random(in: -0.2...0.2)
    return bubblexX
}



func randomPlaceDdY()       -> CGFloat {
    let bubbleyY: CGFloat   = CGFloat.random(in: -0.2...0.2)
    return bubbleyY
}



func randomRotation()       -> CGFloat {
    let bubbleyY: CGFloat   = CGFloat.random(in: -359...359)
    return bubbleyY
}



func randomBubbleType()     -> Int {
    let bubletypeInt: Int   = Int.random (in: 1...15)
    return bubletypeInt
}



func randomLoopTimeInterval() -> CGFloat {
    let bubleLoopInt: CGFloat = CGFloat.random (in: 1...20)
    return bubleLoopInt
}



struct ContentView: View {
    
    @State var xPos5: CGFloat           = 270
    @State var yPos5: CGFloat           = 150
    @State var offset2: CGSize          = .zero
    @State var currentValue             = 0
    @State var shouldReset: Bool        = false
    @State var stringArray: [String]    = ["bublina cislo", "co se s ni stalo"]
    @State var jsonSettings: String     = ""
    @State var smazVsechnyOznacene: Int = 0
    @State var bubbleList: [bubbledata] = []
    @StateObject var settings           = GameSettings()

    
    
    func smazBubbleListItem (bublinaDokoncena: bubbledata) -> Bool {
        if settings.BubbleF.contains(String(bublinaDokoncena.arrayId) + "-") {
            return true
        }
        return false
    }
    
    
    
    func obsahujeVicBublin (vstupniId: Int) -> Int {
        // takove bubliny nezobrazime
        let idParentView: String =  String(vstupniId)
        if settings.OznaceneId.contains(idParentView + "+,") {
            settings.OznaceneId = settings.OznaceneId.replacingOccurrences(of: "+", with: "")
            //vybranoStatus = 1
            return 0
        }
        if settings.OznaceneId.contains(idParentView + ",") {
            //vybranoStatus = 2 //nezobrazuj
            return 1
        }
        return 0
    }
    
    
    
    var body: some View
    {

        ZStack
        {
            Color.black
                .edgesIgnoringSafeArea(.all)
              
            if true {  // nastaveni viditelnosti pro settings screen
                ZStack
            {
                //zobrazeni bublin
                ForEach(bubbleList, id: \.self) {bubbledata in
                    //if true //obsahujeVicBublin(vstupniId: bubbledata.arrayId)==0
                    // string obsahuje bubbledata.arrayId-, pak nezakladej Bubble3SubView//!settings.OznaceneId.contains( String(bubbledata.arrayId) + "," )
                    if !settings.BubbleF.contains(String(bubbledata.arrayId) + "-")
                    {
                        Bubble3SubView(
                           bubblePosX: bubbledata.x,
                           bubblePosY: bubbledata.y,
                           IdFromParent: bubbledata.arrayId,
                           shouldReset: $shouldReset,
                           stringArray: $stringArray,
                           smazVsechnyOznacene: $smazVsechnyOznacene
                       )
                    }
                }
                
                ZStack {}.onAppear {

                    smazVsechnyOznacene = 0
                    settings.score = 0
                }
                
            }
            .onAppear
            { // Prefer, Life cycle method
   
                // --- Start of game ---
                startDate               = NSDate()
                statusMessage           = "Start"
                var b: bubbledata       = bubbledata (subviewVisibility: true, x: 0, y: 0, dx: 20.0, dy: 20.0,
                                                      rotation: 20.0, loopTime: randomLoopTimeInterval(),
                                                      lifeTime: 10000, type:16, arrayId: 200
                                                      )
                for _ in 0...1
                {
                    b.x                 = randomPlaceX()//CGFloat( n * 15)
                    b.y                 = randomPlaceY() //CGFloat(n * 30)
                    b.type              = randomBubbleType()
                    b.dx                = randomPlacedX()
                    b.dy                = randomPlacedY()
                    b.rotation          = randomRotation()
                    b.arrayId           = bubbleList.count
                    settings.BubbleF    = settings.BubbleF + String(b.arrayId) + ","
                    bubbleList.append(b)
                    pocetBublinNaPlose  = 2
                }
            }
            
            
            if shouldReset          == true { //vyvolej prekresleni hlavniho ContentView
                 ZStack {
                  }.onAppear(perform: {
                     shouldReset        = false
                      
                  })
             }
            
            VStack {
                if settings.viditelnaObrazovkaNastaveni {
                    ZStack {
                        Color.gray
                        ZStack {
                            GameSettingsView ().environmentObject(settings)
                        }
                    }.opacity(0.98).clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding().zIndex(1)
                        .onAppear(perform: {
                            
                        })
                    
                       
                }
                else {
                    HStack {
                        Text ("*").foregroundColor(.yellow).font(.system(size:30, weight:.bold)).onTapGesture {
                            // kliknuto na *, ktera znaci zmenu do vychoziho rezimu
                            settings.viditelnaObrazovkaNastaveni    = true
                            settings.minDistanceForSingleClick      = 100.0 // disable single click on main screen when settings form is on
                        }
                        Spacer()
                        Text(settings.horniNapis.replacingOccurrences(of: "[znakyKVyhledani]", with: settings.znakyKVyhledani[0])).foregroundColor(.yellow)
                        Spacer()
                    }
                }
                Spacer()
                HStack {
                    Text(settings.SpodniLevelNapis)
                    .foregroundColor(.orange).font(.system(size:20, weight:.bold))
                    
                        
                    HStack {
                        
                        Text("score:")
                                                .foregroundColor(.orange).font(.system(size:20, weight:.bold))
                        
                        Text("\(settings.score)")
                                                .foregroundColor(.orange).font(.system(size:30, weight:.bold))

                    }.padding()
                    Spacer()
                    Text(settings.ukazVpravodoleZnaky)
                        .foregroundColor(.orange).font(.system(size:30, weight:.bold))
                }
            }
        }
        }
        .environmentObject(settings)

          .gesture(
            DragGesture(minimumDistance:10)
                .onChanged({value in
                    if true && settings.dragGestureMultiple {
                        let cursorX         = value.location.x
                        let cursorY         = value.location.y
                        
                        bubbleList.removeAll {  smazBubbleListItem(  bublinaDokoncena: $0) } // 30.11.2021 2352 memory get free from long strings
                        settings.BubbleF   = settings.BubbleF.replacingOccurrences(of: "\\d+-,", with: "", options: .regularExpression) // odstranime BubbleF polozky dokoncene
                        
                        var b: bubbledata = bubbledata (subviewVisibility: true,
                                                        x: 0, y: 0, dx: 20.0, dy: 30.0,
                                                        rotation: 20.0,
                                                        loopTime: randomLoopTimeInterval(),
                                                        lifeTime: 10000,
                                                            type: randomBubbleType(),
                                                         arrayId: bubbleList.count)
                        b.x  = cursorX
                        b.y  = cursorY
                        b.dx = randomPlacedX()
                        b.dy = randomPlacedY()

                        if true {// pocetBublinNaPlose <= bubbleNumMax && prekreslit
                        
                            self.xPos5      = cursorX
                            self.yPos5      = cursorY
                            b.arrayId       = bubbleList.count
                            bubbleList.append(b)
                            pocetBublinNaPlose += 1
                            settings.BubbleF    = settings.BubbleF + String(b.arrayId) + ","
                        }
                    }
                })
        )
        .gesture(
            DragGesture(minimumDistance: settings.minDistanceForSingleClick) // for single click = 0
                .onEnded(
                    {
                        value in
                        //test call for learning GameSettingsIO
                        //print("result write + \(GameSettingsIO.writeStringToDisc(inputString:"abc"))")
                        if true {
                            let cursorX     = value.location.x
                            let cursorY     = value.location.y
                            
                            // 30.11.2021 2352 memory get free from long strings
                            // odstranime nadbytecne polozky
                            bubbleList.removeAll {  smazBubbleListItem(  bublinaDokoncena: $0) }
                            // odstranime BubbleF polozky dokoncene
                            settings.BubbleF   = settings.BubbleF.replacingOccurrences(of: "\\d+-,", with: "", options: .regularExpression)
                            
                            
                        
                            var b: bubbledata   = bubbledata (subviewVisibility: true,
                                                              x: 0, y: 0, dx: 20.0, dy: 30.0,
                                                              rotation: 20.0,
                                                              loopTime: randomLoopTimeInterval(),
                                                              lifeTime: 100000,
                                                                  type: randomBubbleType(),
                                                               arrayId: bubbleList.count)
                            b.x  = cursorX
                            b.y  = cursorY
                            b.dx = randomPlacedX()
                            b.dy = randomPlacedY()
                            //debug if pocetBublinNaPlose <= bubbleNumMax && prekreslit
                            if true {
                           
                                self.xPos5       = cursorX
                                self.yPos5       = cursorY
                                b.arrayId        = bubbleList.count
                                settings.BubbleF = settings.BubbleF + String(b.arrayId) + ","
                               
                                bubbleList.append(b)
                                pocetBublinNaPlose  += 1
                            }
                        }
                    }
                )
            )
    }
    
    func reset() {
        self.shouldReset = true
    }

}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
