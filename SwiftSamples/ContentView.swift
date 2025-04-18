//
//  ContentView.swift
//  SwiftSamples
//
//  Created by Roi Jacob on 4/18/25.
//

import SwiftUI

struct TeamSeven: Identifiable, Hashable {
    let id = NSUUID().uuidString
    let name: String
}

struct ContentView: View {
    let members: [TeamSeven] = [
        .init(name: "Naruto"),
        .init(name: "Sasuke"),
        .init(name: "Sakura")
    ]
    
    var body: some View {
        NavigationStack(root: {
            VStack(content: {
                ForEach(members, content: { member in
                    /// 1. Attach a custom NavigationLink view as the label
                    NavigationLink(value: member, label: {
                        ZStack(content: {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 300, height: 200)
                            Text(member.name)
                                .foregroundStyle(.white)
                        })
                    })
                })
            })
            .navigationDestination(for: TeamSeven.self, destination: { member in
                GreetingView(inputMember: member)
            })
        })
    }
}

struct GreetingView: View {
    let inputMember: TeamSeven
    
    var body: some View {
        Text("Hello \(inputMember.name)!")
    }
}

#Preview {
    ContentView()
}
