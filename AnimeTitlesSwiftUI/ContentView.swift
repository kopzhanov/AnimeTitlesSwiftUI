//
//  ContentView.swift
//  AnimeTitlesSwiftUI
//
//  Created by Alikhan Kopzhanov on 05.10.2023.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftyJSON

struct AnimeTitle:Identifiable{
    
    var id = UUID()
    var title = ""
    var englishTitle = ""
    var episodes = 0
    var score = 0.0
    var genres = ""
    var picture = ""
    
    init(json:JSON) {
        if let item = json["title"].string {
            title = item
        }
        if let item = json["englishTitle"].string {
            englishTitle = item
        }
        if let item = json["episodes"].int {
            episodes = item
        }
        if let item = json["score"].double {
            score = item
        }
        if let item = json["genres"].string {
            genres = item
        }
        if let item = json["picture"].string {
            picture = item
        }
    }
}

struct AnimeTitleRow:View {
    
    var animeTitle:AnimeTitle
    
    var body:some View{
        HStack(alignment: .top){
            WebImage(url: URL(string:animeTitle.picture))
                .resizable()
                .frame(width: 120,height: 160)
                .aspectRatio(contentMode: .fill)
                .clipped()
            VStack(alignment:.leading,spacing: 3){
                Text(animeTitle.title)
                    .font(.headline)
                Text(animeTitle.englishTitle)
                Text("Episodes: \(animeTitle.episodes)")
                    .foregroundStyle(.mint)
                Text("Score: \(animeTitle.score,specifier: "%.2f")")
                    .backgroundStyle(.gray)
                    .foregroundStyle(.orange)
                Text("Genres: \(animeTitle.genres)")
            }
        }
    }
    
}

struct ContentView: View {
    @ObservedObject var animeTitles = GetAnimeTitles()
    
    var body: some View {
        NavigationView{
            List(animeTitles.animeTitlesArray){animeTitle in
                AnimeTitleRow(animeTitle: animeTitle)
            }.refreshable {
                self.animeTitles.updateData()
            }.navigationTitle("Anime Titles")
        }
    }
}

#Preview {
    ContentView()
}

class GetAnimeTitles: ObservableObject {
    @Published var animeTitlesArray = [AnimeTitle]()
    
    init(){
        updateData()
    }
    
    func updateData(){
        let urlString = "https://demo1735147.mockable.io/getAnimeTitles"
        
        let url = URL(string: urlString)
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url!) {(data, _, error) in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            
            let json = try! JSON(data:data!)
            if let resultArray = json.array {
                for item in resultArray {
                    let animeTitle = AnimeTitle(json: item)
                    
                    DispatchQueue.main.async{
                        self.animeTitlesArray.append(animeTitle)
                    }
                }
            }
        }.resume()
    }
}
