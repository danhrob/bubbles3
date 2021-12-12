//
//  GameSettingsView.swift
//  Bubbles3
//
//  Created by Dan on 22.11.2021.
//

import SwiftUI


extension Encodable {
    var convertToString: String? {
        let jsonEncoder              = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData             = try jsonEncoder.encode(self)
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
    var score: Int                   = 40
    var SpodniLevelNapis             = "level #2"
    var horniNapis                   = "find and click A-A"
    var ukazVpravodoleZnaky          = "A-A"
    var znakyKZobrazeni              = ["A","circle","triangle","A","square","\u{05d0}","\u{03a9}"]
    var animationDuration            = 16.0
    var lifeDuration                 = 16.0
    var rozptylLifeDuration          = 4.0
    var casoveUkonceniZivotaBubl     = true
    var znakyKVyhledani              = ["A"]
    var barvaRgb                     = ["255", "165", "0"] //Color.orange
}

//test class for testing write and read to disc
//path to app can be Bundle.main.path(forResource: "file1", ofType: "txt")  but is read only
class GameSettingsIO {
    
    static func getDocumentsDirectory() -> URL {
        let paths                   = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory      = paths[0]
        print("document's directory\(documentsDirectory)")
        return documentsDirectory
    }
    
    static func writeStringToDisc(inputString: String, inputFileName: String, inputExtension: String) -> String {
        let directoryURL    = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL         = URL(fileURLWithPath: inputFileName, relativeTo: directoryURL).appendingPathExtension(inputExtension)
        // Create data to be saved
        let myString        = inputString
        guard let data      = myString.data(using: .utf8) else {
            print("Unable to convert string to data")
            return ""
        }// Save the data
        do {
         try data.write(to: fileURL)
         print("File saved: \(fileURL.absoluteURL)")
        } catch {
         // Catch any errors
         print(error.localizedDescription)
        }
        return ""
    }
    
    static func writeConfigFile(jsonString: String) -> String {
        //it should be user documents directory with for possible access to write
        let result: String    = GameSettingsIO.writeStringToDisc(inputString: jsonString, inputFileName: "bubblesConfig", inputExtension: "txt")
        print("result write: \(result)")
        return result
    }
    
    static func getZnakyKZobrazeniJoin(inputStringF: [String]) -> String {
        let inputStringField = inputStringF.joined(separator:",")
        return inputStringField
    }
    
    static func prepareJsonSettingsString(jsonSettings: JsonSettings) -> String {
        let jsonSettingsConverted = jsonSettings.convertToString!
        print("jsonSettingsConverted:\(jsonSettingsConverted)")
        return jsonSettingsConverted
    }
    
    static func convertGameSettingsToJsonSettings(gameSettings: GameSettings) -> JsonSettings {
        var jsonSettings = JsonSettings()
        jsonSettings.score                      = gameSettings.score
        jsonSettings.SpodniLevelNapis           = gameSettings.SpodniLevelNapis
        jsonSettings.horniNapis                 = gameSettings.horniNapis
        jsonSettings.ukazVpravodoleZnaky        = gameSettings.ukazVpravodoleZnaky
        jsonSettings.znakyKZobrazeni            = gameSettings.znakyKZobrazeni
        jsonSettings.animationDuration          = gameSettings.animationDuration
        jsonSettings.lifeDuration               = gameSettings.lifeDuration
        jsonSettings.rozptylLifeDuration        = gameSettings.rozptylLifeDuration
        jsonSettings.casoveUkonceniZivotaBubl   = gameSettings.casoveUkonceniZivotaBubl
        jsonSettings.znakyKVyhledani            = gameSettings.znakyKVyhledani
        jsonSettings.barvaRgb                   = gameSettings.barvaRgb //Color.orange
        return jsonSettings
    }
    
}

class GameSettings:                 ObservableObject
{
    @Published var score: Int                        = 0
    @Published var oznaceno                     = 0
    @Published var barvaRgb                     = ["255", "165", "0"]
    @Published var barva                        = Color.orange
    @Published var casoveUkonceniZivotaBubl     = true //false
    @Published var animationDuration            = 26.0
    @Published var lifeDuration                 = 26.0
    @Published var rozptylLifeDuration          = 4.0
    @Published var viditelnaObrazovkaSbublinami = true
    @Published var viditelnaObrazovkaUvodPopis  = false
    @Published var viditelnaObrazovkaNastaveni  = false
    @Published var minDistanceForSingleClick    = 0.0
    @Published var viditelneScore               = false
    @Published var viditelneLevel               = true
    @Published var SpodniLevelNapis             = "level #2"
    @Published var horniNapis                   = "find and click [znakyKVyhledani]" //[znakyKVyhledani] = replaced variable in text znakyKVyhledani
    @Published var ukazVpravodoleZnaky          = "\u{03a9}-\u{03a9}"
    @Published var znakyKZobrazeni              = ["A","circle","triangle","A","square","\u{05d0}","\u{03a9}"]
    @Published var znakyKVyhledani              = ["\u{03a9}"]
    @Published var OznaceneId                   = ","    //"1,2,30," kvuli kliku s oznacenou bublinou se sem zapisou id oznacenych, aby se nezobrazovaly z hlavniho ContentView
    @Published var zobrazitAppIdBubliny         = false
    @Published var dragGestureMultiple          = true  //muze se pouzivat generovani tahem
    @Published var zobrazovatObrazkyBublin      = true
    @Published var BubbleF: String              = "," //zde vsechny bubliny +..zalozeny k..kliknuty -..kOdstraneni
    //kazda bublina se musi zajimat, zda se muze zobrazit
}





struct GameSettingsView : View {
    @EnvironmentObject var settings:        GameSettings //zde jsou vsechna nastaveni
    @State var viditelnaObrazovkaNastaveni:Bool = false     //settings.viditelnaObrazovkaNastaveni
    @State var lettersSettingsDialog: Bool      = false
    @State private var lettersToView: String    = "A,B,C,D"
    @State private var lettersToFind: String    = "A"
    @State var znakyKZobrazeni: [String]        = ["C","D","A"]
    @State var znakyKVyhledani: [String]        = ["C","D","A"]
    @State var horniNapis: String               = "find and click [znakyKVyhledani]"

    func getInputStringKZobrazeni() -> String {
        let znakyKZobrazeniF : [String] = settings.znakyKZobrazeni
        return znakyKZobrazeniF.joined(separator: ",")
    }
    
    func getInputStringKVyhledani() -> String {
        let znakyKVyhledaniF : [String] = settings.znakyKVyhledani
        return znakyKVyhledaniF.joined(separator: ",")
    }
    
    func cancelSettingsScreen () {
        viditelnaObrazovkaNastaveni             = false
        settings.viditelnaObrazovkaNastaveni    = false
        settings.minDistanceForSingleClick      = 0 // set it can react for single click(drag 0 points) on main layer
        // print("cancelSettingsScreen GameSettingsView settings.znakyKZobrazeni:\(settings.znakyKZobrazeni), znakyKZobrazeni:\(znakyKZobrazeni) ")
        print("cancelSettingsScreen GameSettingsView settings.znakyKVyhledani:\(settings.znakyKVyhledani), znakyKVyhledani:\(znakyKVyhledani) ")
    }
    
    init () {
        
    }
    
    var body: some View {

        VStack {
        Form {
            Text("Settings").font(.largeTitle)
            Section {
                Toggle(isOn: $settings.casoveUkonceniZivotaBubl){
                    Text("Life timing of the bubble")}
                Stepper(onIncrement:{}, onDecrement: {}){Text("Speed")}
                ColorPicker("Set the bubble text color", selection: $settings.barva)
                Button("Letters to find and click") {
                    lettersSettingsDialog = true
                    print("button Letter settings")}
                if lettersSettingsDialog {
                    VStack {
                        TextField("Enter letters to view", text: $lettersToView)
                           .onAppear(perform: {
                            lettersToView = getInputStringKZobrazeni()
                           })
                        TextField("Enter letter to find", text: $lettersToFind)
                           .onAppear(perform: {
                            lettersToFind = getInputStringKVyhledani()
                           })
                        Button("Save letters settings") {

                            lettersSettingsDialog = false
                            //lettersToView = getInputStringKZobrazeni()
                            settings.znakyKZobrazeni = lettersToView.components(separatedBy:",")
                            settings.znakyKVyhledani = lettersToFind.components(separatedBy:",")
                            // print("letters settings lettersToView:\(lettersToView)")
                            print("letters settings lettersToFind:\(lettersToFind)")
                        }
                    }
                }
                Button("Default settings") {print("button Default settings")}
                
                
            }.padding()
            Section {
                Button("Save and continue") {
                    lettersToView = getInputStringKZobrazeni()
                    settings.znakyKZobrazeni    = lettersToView.components(separatedBy:",")
                    lettersToFind = getInputStringKVyhledani()
                    settings.znakyKVyhledani    = lettersToFind.components(separatedBy: ",")
                    settings.ukazVpravodoleZnaky = settings.znakyKVyhledani[0] + "-" + settings.znakyKVyhledani[0]
                    settings.horniNapis         =  horniNapis.replacingOccurrences(of: "[znakyKVyhledani]", with: settings.znakyKVyhledani[0])
                    cancelSettingsScreen()
                    //write config to json file
                    _ = GameSettingsIO.writeConfigFile(jsonString: GameSettingsIO.prepareJsonSettingsString(jsonSettings: GameSettingsIO.convertGameSettingsToJsonSettings(gameSettings: settings)))
                    //print("button Save and continue")
                    //print("Save and continue lettersToView:\(lettersToView), znakyKZobrazeni:\(settings.znakyKZobrazeni)")
                    print("Save and continue lettersToFind:\(lettersToView), znakyKVyhledani:\(settings.znakyKVyhledani)")
                    
                }
                Button("Exit") {
                    //print("Exit")
                    exit(0)
                }
            }.padding()
        }.onAppear(){
            //print("Form onAppear")
            //json test
            //let user         = User(id: 1, name: "name")
            //print(user.convertToString!)
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




