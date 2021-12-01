//
//  GameSettingsView.swift
//  Bubbles3
//
//  Created by Dan on 22.11.2021.
//

import SwiftUI


extension Encodable {
    var convertToString: String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

extension Color {
    // get Color from String field RGB
    static func getColorFromRgbStrings (StringField: [String]) -> Color {
        return Color(red: Double(StringField[0])!, green: Double(StringField[1])!, blue: Double(StringField[2])!)
    }
}

struct User: Codable {
     var id:        Int
     var name:      String
}

struct JsonSettings: Codable {
    var score:      Int
    var SpodniLevelNapis             = "level #2"
    var horniNapis                   = "find and click A-A"
    var ukazVpravodoleZnaky          = "A-A"
    var znakyKZobrazeni              = ["A","circle","triangle","A","square","B"]
    var animationDuration            = 8.0
    var lifeDuration                 = 8.0
    var rozptylLifeDuration          = 4.0
    var casoveUkonceniZivotaBubl     = true
    var znakyKVyhledani              = ["A"]
    var barvaRgb                     = ["255", "165", "0"] //Color.orange
}


class GameSettings:                 ObservableObject
{
    @Published var score                        = 0
    @Published var oznaceno                     = 0
    @Published var barvaRgb                     = ["255", "165", "0"]
    @Published var barva                        = Color.orange
    @Published var casoveUkonceniZivotaBubl     = true //false
    @Published var animationDuration            = 8.0
    @Published var lifeDuration                 = 8.0
    @Published var rozptylLifeDuration          = 4.0
    @Published var viditelnaObrazovkaSbublinami = true
    @Published var viditelnaObrazovkaUvodPopis  = false
    @Published var viditelnaObrazovkaNastaveni  = false
    @Published var viditelneScore               = false
    @Published var viditelneLevel               = true
    @Published var SpodniLevelNapis             = "level #2"
    @Published var horniNapis                   = "find and click A-A"
    @Published var ukazVpravodoleZnaky          = "A-A"
    @Published var znakyKZobrazeni              = ["A","circle","triangle","A","square","B"]
    @Published var znakyKVyhledani              = ["A"]
    @Published var OznaceneId                   = ","    //"1,2,30," kvuli kliku s oznacenou bublinou se sem zapisou id oznacenych, aby se nezobrazovaly z hlavniho ContentView
    @Published var zobrazitAppIdBubliny         = false
    @Published var dragGestureMultiple          = true  //muze se pouzivat generovani tahem
    @Published var zobrazovatObrazkyBublin      = true
    @Published var BubbleF: String              = "," //zde vsechny bubliny +..zalozeny k..kliknuty -..kOdstraneni
    //kazda bublina se musi zajimat, zda se muze zobrazit
}





struct GameSettingsView : View {
    @EnvironmentObject var settings:        GameSettings //zde jsou vsechna nastaveni
    @State var viditelnaObrazovkaNastaveni: Bool = false     //settings.viditelnaObrazovkaNastaveni
    
    func cancelSettingsScreen () {
        viditelnaObrazovkaNastaveni             = false
        settings.viditelnaObrazovkaNastaveni    = false
    }
    
    init () {
        
    }
    
    var body: some View {
        
        
        //Text("Score:\(settings.score)").foregroundColor(.yellow)
        VStack {
        Form {
            Text("Settings").font(.largeTitle)
            Section {
                Toggle(isOn: $settings.casoveUkonceniZivotaBubl){
                    Text("Life timing of the bubble")}
                Stepper(onIncrement:{}, onDecrement: {}){Text("Speed")}
                ColorPicker("Set the bubble text color", selection: $settings.barva)
                Button("Default settings") {print("button Default settings")}
                
            }.padding()
            Section {
                Button("Save and continue") {
                    cancelSettingsScreen()
                    print("button Save and continue")}
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded(
                            {
                                _ in settings.viditelnaObrazovkaNastaveni = false}))
                    //$settings.viditelnaObrazovkaNastaveni
                
                Button("Exit") {
                    print("Exit")
                    exit(0)
                }
            }.padding()
        }.onAppear(){
            print("Form onAppear")
            //json test
            let user = User(id: 1, name: "name")
            print(user.convertToString!)
            let jsonSettings = JsonSettings(score:40)
            print(jsonSettings.convertToString!)
        }
        
    }
    }
  
    
}

struct GameSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GameSettings())
    }
}




