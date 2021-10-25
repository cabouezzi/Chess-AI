//
//  Chess_MLApp.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/2/21.
//

import SwiftUI

@main
struct Chess_AIApp: App {
    
    @State var showLeftBar: Bool = false
    @State var showRightBar: Bool = false
    
    @State var currentScheme: BoardColorScheme = .standard
    
    let Game = GameView()
    
    var body: some Scene {
        
        WindowGroup {
            
            ZStack {
            
                HStack {
                    
                    BlurView()
                        .frame(maxWidth: showLeftBar ? .infinity : 0, alignment: .leading)
                    
                    Game
                        .padding(.top, 50)
                        .padding(.horizontal, 50)
                    
                    List {
                        
                        ImageAndLabelButton(image: Image(systemName: "arrowshape.turn.up.right.fill"), title: "Pink") {
                            currentScheme = .pink
                            Game.Manager.boardUI.changeScheme(currentScheme)
                        }
                        .buttonStyle(TabButtonStyle())
                        
                        ImageAndLabelButton(image: Image(systemName: "arrowshape.turn.up.right.fill"), title: "Blue") {
                            currentScheme = .blue
                            Game.Manager.boardUI.changeScheme(currentScheme)
                        }
                        .buttonStyle(TabButtonStyle())
                        
                        ImageAndLabelButton(image: Image(systemName: "arrowshape.turn.up.right.fill"), title: "Green") {
                            currentScheme = .green
                            Game.Manager.boardUI.changeScheme(currentScheme)
                        }
                        .buttonStyle(TabButtonStyle())
                        
                        ImageAndLabelButton(image: Image(systemName: "arrowshape.turn.up.right.fill"), title: "Blue 2") {
                            currentScheme = .secondBlue
                            Game.Manager.boardUI.changeScheme(currentScheme)
                        }
                        .buttonStyle(TabButtonStyle())
                        
                    }
                    .frame(maxWidth: showRightBar ? .infinity : 0, alignment: .trailing)
                    .background(BlurView())
                    
                }
                
                VStack {
                    
                    HStack {
                        
                        Toggle(isOn: $showLeftBar, label: { Image(systemName: "sidebar.leading") })
                            .toggleStyle(TabToggleStyle())
                            .font(.system(size: 15))
                            .padding(.horizontal, 10)
                            .onTapGesture {
                                showLeftBar.toggle()
                            }
                        
                        Spacer()
                        
                        Toggle(isOn: $showRightBar, label: { Image(systemName: "sidebar.trailing") })
                            .toggleStyle(TabToggleStyle())
                            .font(.system(size: 15, weight: .light))
                            .padding(.horizontal, 10)
                            .onTapGesture {
                                showRightBar.toggle()
                            }
                    }
                    .padding(.vertical, 30)
                    
                    Spacer()
                    
                }
                
            }
            .ignoresSafeArea(.all)
            
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
    }
    
}
