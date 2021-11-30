//
//  Bubble3SubView.swift
//  bubbles3
//
//  Created by Dan on 03.11.2021.
//

import SwiftUI
import Foundation

struct Bubble3SubView: View {
    
    @Binding var shouldReset:               Bool
    @Binding var stringArray:               [String]
    @Binding var smazVsechnyOznacene:       Int
    @EnvironmentObject var settings:        GameSettings //zde jsou vsechna nastaveni

    @State var valueFromParent : Int        = 0 // projectedValue - jmeno (cislo), ktere dostane kazda bublina od rodice - aby se dala smazat v pripade potreby
    @State private var showMessage          = false
    @State private var offsetx: CGFloat     = 0
    @State private var offsety: CGFloat     = 0
    @State private var bubbleTypeNo: Int    = randomBubbleType()
    @State private var rotatex: Double      = 0
    @State private var opacityx: Double     = 1
    @State var positionx: Double        //  = 50
    @State var positiony: Double        //  = 50
    @State private var lifetimex: Double    = 10.0//Double.random(in: 10...20)
    @State private var shouldResetx: Bool   = false
    @State var napis: String                = zobrazNahodnySymbol()
    /* v pripade kliknuti na bublinu, ktera je oznacitelna, napr. "A",
     se informace prihraje do vybranoStatus - sem - pro zobrazeni a jako globalni informace pro ostatni "A"
     do informacniho pole
     */
    @State private var vybranoStatus: Int   = 0  //v pripade kliknuti na "A" se tato B. oznaci
    var indexPoleHodnot: Int                = 0
    
        
    init (bubblePosX: Double, bubblePosY: Double, IdFromParent: Int, shouldReset: Binding<Bool>, stringArray: Binding<[String]>, smazVsechnyOznacene: Binding<Int> )
    {
        positionx                           = bubblePosX
        positiony                           = bubblePosY
        valueFromParent                     = IdFromParent
        self._shouldReset                   = shouldReset
        self._stringArray                   = stringArray
        self._smazVsechnyOznacene           = smazVsechnyOznacene

    }
    
    func obsahujeVicBublin (vstupniId: Int) -> Int {
        // takove bubliny nezobrazime
        let idParentView: String    =  String(vstupniId)
        if settings.OznaceneId.contains("+") {
            settings.OznaceneId     = settings.OznaceneId.replacingOccurrences(of: "+", with: "")
            return 0
        }
        if settings.OznaceneId.contains(idParentView + ",") {
            //vybranoStatus = 2 //nezobrazuj
            return 1
        }
        return 0
    }
    
    func bublinaKZobrazeni (IdB: Int) -> Bool {
        // vysvetleni zobrazeni bubliny s id cislem: IdB
        // hlavni string settings.BubbleF obsahuje seznam bublin, ktery si bubliny samy aktualizuji,
        //   a ktery obsahuje tyto udaje:
        // 21-,2-, znamena, ze bubliny s id 21 a 2 jsou dokoncene, nebudou se jiz nikdy zobrazovat
        // 4, 5, bubliny jsou nekde na plose
        // 6+, bublina je oznacena kliknutim a obsahuje kolecko, pristi kliknuti na tento typ
        //      bubliny z ni udela bublinu dokoncenou
        let ids:  String =  settings.BubbleF
        let idBcontains_        = ids.contains(String(IdB) + "-")
        if idBcontains_ {
            return false
        }
        return true
    }
    
    var body: some View {
        
        ZStack {}
        //zakladni podminka pro vykreslovani kazde lokalni bubliny je v teto funkci
        if  bublinaKZobrazeni(IdB: valueFromParent) {
            ZStack() {
                if true {
                    Image("bubble\(bubbleTypeNo)")
                    .frame(minWidth: 20, idealWidth: 20, maxWidth: 20, minHeight: 20, idealHeight: 20, maxHeight: 20, alignment: Alignment.center).opacity(0.7)
                }
                if vybranoStatus == 1 {
                    Circle().strokeBorder(settings.barva,lineWidth: 3).frame(width: 50, height: 50)
                 }
                let nahodnySymbol = napis
                if nahodnySymbol.count > 2 {
                    Image(systemName: nahodnySymbol)
                        .font(.largeTitle.weight(.black))
                        .font(.system(size: 20))
                        .foregroundColor(settings.barva).padding(3.0)
                } else {
                    Text(nahodnySymbol).foregroundColor(settings.barva).font(.system(size:40, weight:.bold))
                }

               
            }
            .position(x: positionx,
                      y: positiony)
            .rotationEffect(Angle(degrees: rotatex))
            .offset(x: offsetx, y: offsety)
            .opacity(opacityx)
            .onAppear {
                withAnimation(.easeOut(duration: settings.animationDuration)) {
                        self.offsetx            = randomOffsetX()//100.0
                        self.offsety             = randomOffsetY() //200.0
                        self.rotatex             = randomRotation()
                    }
                //}
                playAudio()
                let zobrazit                = statusMessage.contains("Start")
                if !zobrazit {
                    lifetimex               = 0.1
                }
                
                // prasknuti bubliny
                if settings.casoveUkonceniZivotaBubl { // false pro vyvoj bez casovani
                    lifetimex = Double.random(in: settings.lifeDuration...settings.lifeDuration + settings.rozptylLifeDuration)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + lifetimex, execute: {
                    pocetBublinNaPlose      -= 1
                    if (pocetBublinNaPlose<1) {
                        pocetBublinNaPlose  = 0
                        statusMessage       = "You Won!" //konec hry
                        shouldReset             = true
                    }
 
                    //prasknuti neprehravame, kdyz uz tam bubliny nejsou
                    if statusMessage.contains("Start") {
                        playAudio()
                        
                    }

                    if settings.BubbleF.contains(String(valueFromParent) + ",") {

                        settings.BubbleF = settings.BubbleF.replacingOccurrences(of: (String(valueFromParent) + ","), with: (String(valueFromParent) + "-,"))
                    }
                    stringArray[0]          = String(valueFromParent)
                    stringArray[1]          = "praskla"
                    shouldReset             = true
                    
                })
                }
                
                
                
                
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                // kliknuto tlacitkem na bublinu = jeji konec + prehrani zvuku
                    .onEnded({
                        value in
                        pocetBublinNaPlose      -= 1
                        if (pocetBublinNaPlose<1) {
                            pocetBublinNaPlose  = 0
                            statusMessage       = "You Won!" //konec hry
                            shouldReset             = true
                        }

                        stringArray[0]          = String(valueFromParent)
                    
                        if statusMessage.contains("Start") {
                            playAudio()
                          }
                                               
                        
                        if napis == "A" { //kliknu na bubl. s A
                            //nebylo zatim na tuhle kliknuto, nyni je, bude se vykreslovat s krouzkem
                            //a ceka, az nekdo klikne na jinou
                            //tj. 1.krok
                            var lzeKliknout     = true
                            if settings.BubbleF.contains(String(valueFromParent) + ",")
                                && !settings.BubbleF.contains("x") {
                            settings.BubbleF    = settings.BubbleF.replacingOccurrences(of: (String(valueFromParent) + ","), with: (String(valueFromParent) + "x,"))
                                vybranoStatus   = 1 //kandidat na zmizeni status 1, x
                                lzeKliknout     = false
                            }
                            if settings.BubbleF.contains(String(valueFromParent) + ",")
                                && settings.BubbleF.contains("x") {
                                settings.BubbleF = settings.BubbleF.replacingOccurrences(of: ("x"), with: ("-"))
                                settings.BubbleF = settings.BubbleF.replacingOccurrences(of: (String(valueFromParent) + ","), with: (String(valueFromParent) + "-,"))
                                vybranoStatus   = 2
                                settings.score  += 1
                                if settings.score % 10 == 0 {
                                    //pokracuj ztizenim casu animace a prasknutim bubliny
                                    settings.score += 10
                                    if settings.animationDuration > 2    {
                                        settings.animationDuration-=2}
                                    if settings.lifeDuration > 2 {
                                        settings.lifeDuration -= 2
                                        if settings.rozptylLifeDuration > 0 {settings.rozptylLifeDuration -= 1}
                                    }
                                
                                }
                                lzeKliknout     = false
                            }
                            //pokud existuje kliknuta bublina, vsechny kliknute odstran:
                            if lzeKliknout && settings.BubbleF.contains(String(valueFromParent) + "x,") {
                                settings.BubbleF    = settings.BubbleF.replacingOccurrences(of: ("x"), with: (""))                                // vsechny kliknute nezobrazit

                            }
                             
                        }
                        else { // neni to kandidatska bublina, nastav zmizeni bez bodu
                            vybranoStatus           = 2
                            settings.BubbleF    = settings.BubbleF.replacingOccurrences(of: (String(valueFromParent) + ","), with: (String(valueFromParent) + "-,"))
                            stringArray[1]          = "odebranaNeklicova"
                        }
                        //odstranit pismeno z pole
                                               
                        shouldReset                     = true
                    })
            )
        }
        
    }
   
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GameSettings())
    }
}

