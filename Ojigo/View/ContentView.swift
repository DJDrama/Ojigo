//
//  ContentView.swift
//  Ojigo
//
//  Created by dj on 2021/10/19.
//

import SwiftUI

struct ContentView: View {
    let url: String
    
    init(url: String){
        self.url = url
    }
    
    var body: some View {
        WebBrowserView(url: self.url)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(url: MAIN_URL)
    }
}
