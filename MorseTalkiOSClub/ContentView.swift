//
//  ContentView.swift
//  MorseTalkiOSClub
//
//  Created by Rahul Narayanan on 10/10/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CameraFeedView() // This is a custom view made to show the camera.
            .cornerRadius(8.0)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
