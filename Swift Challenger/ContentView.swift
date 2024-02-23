//
//  ContentView.swift
//  Swift Challenger
//
//  Created by 64005831 on 2/12/24.
//

import SwiftUI
import RealityKit
import SceneKit
import ARKit
import Combine

/* idea:
 
 Vehicle playground
 Able to Increase Size and Shrink Size
 Customizable Avatars
 
 */


// 1. Load app on ipad
// 2. load block onto screen
// 3. load model car onto screen
// 4. move car forward
// 5. move car left / right

public var volume = 0
public var hasSound = true

struct GameState {
    var moveForward = false
    var moveBackward = false
    var moveRight = false
    var moveLeft = false
    var isAccelerating = false
    var big = false
    var small = false
    var speed: Float = 0
    
    var z: Float = 0
    var r: Float = 0
    var size: SIMD3<Float> = .one
    
}

struct StartContentView: View {
    
    @State var soundIcon = "speaker.wave.2.fill"
    
    var body: some View {
        ZStack() {
            Color(.black)
                .ignoresSafeArea()
            
          HStack(spacing: 0) {
            ZStack() { }
            .frame(width: 1209.98, height: 342.24)
          }
          .padding(
            EdgeInsets(top: 0, leading: 225.50, bottom: 0, trailing: 16.52)
          )
          .frame(height: 1388)
          .offset(x: 402, y: 334)
          Rectangle()
            .foregroundColor(.clear)
            .background(
             Image("building-background")
                .resizable()
                .frame(width: 500, height: 450)
            )
            .offset(x: -400, y: 300)
            
            
            //Play Button
            Button(action: {}, label: {
                ZStack{
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 489, height: 158)
                        .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                        .cornerRadius(37)
                    Text("Play")
                      .font(Font.custom("Julius Sans One", size: 100))
                      .foregroundColor(.black)
                }
            })
            .offset(x: -0.50, y: 72)
            
          Text("Kaiju car")
            .font(Font.custom("Julius Sans One", size: 100))
            .foregroundColor(.white)
            .offset(x: 0.50, y: -95.50)
        
            ZStack {
                Image("car-background")
                    .resizable()
                    .frame(width: 1000, height: 1000)
                    .offset(x: 475, y: 325)
                
                //sound
                Button(action: {
                    if (hasSound == true) {
                        hasSound = false
                        soundIcon = "speaker.slash.fill"
                        
                    } else {
                        hasSound = true
                        soundIcon = "speaker.save.2.fill"
                    }
                }, label: {
                    Image(systemName: soundIcon)
                        .foregroundColor(.black)
                        .font(.system(size: 75))
                })
                    .foregroundColor(.clear)
                    .frame(width: 125, height: 125)
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .cornerRadius(37)
                    .offset(x: 500, y: -325)
                
                //info
                Button(action: {}, label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.black)
                        .font(.system(size: 75))
                })
                    .foregroundColor(.clear)
                    .frame(width: 125, height: 125)
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .cornerRadius(37)
                    .offset(x: 320, y: -325)
            }
        }
        .frame(width: 1366, height: 1024)
        
    }
    
}

struct ARContentView : View {
    
    @State var gameState = GameState()
    @State var speedDisplay = "0.0"
   
    var body: some View {
        
        ZStack {
            // AR View
            //ARViewContainer(gameState).edgesIgnoringSafeArea(.all)
            Color(.black).ignoresSafeArea()
                
            //controls
            VStack {
                Label(speedDisplay, systemImage: "speedometer")
                    .foregroundColor(.white)
                    .font(.system(size: 75))
                    .offset(y: UIScreen.main.bounds.height/(-7.5))
                
                HStack {
                    
                    //directional controls
                    VStack {
                        
                        Button {} label: {
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: 75))
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ _ in
                                    gameState.moveForward = true
                                    gameState.moveBackward = false
                                    gameState.isAccelerating = true
                                    speedup()
                                })
                                .onEnded({ _ in
                                    gameState.isAccelerating = false
                                    slowdown()
                                    if (gameState.speed == 0) {
                                        gameState.moveForward = false
                                    }
                                }))
                        
                        HStack {
                            Button {} label: {
                                Image(systemName: "arrowtriangle.left.fill")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 75))
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged({ _ in
                                        gameState.moveLeft = true
                                        gameState.moveForward = false
                                        gameState.moveBackward = false
                                    })
                                    .onEnded({ _ in
                                        gameState.moveLeft = false
                                    }))
                            
                            Spacer()
                                .frame(width: 75, height: 80)
                            
                            Button {} label: {
                                Image(systemName: "arrowtriangle.right.fill")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 75))
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged({ _ in
                                        gameState.moveRight = true
                                        gameState.moveForward = false
                                        gameState.moveBackward = false
                                    })
                                    .onEnded({ _ in
                                        gameState.moveRight = false
                                    }))
                        }
                        
                        Button {} label: {
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: 75))
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ _ in
                                    gameState.moveBackward = true
                                    gameState.moveForward = false
                                    gameState.isAccelerating = true
                                    speedup()
                                })
                                .onEnded({ _ in
                                    gameState.isAccelerating = false
                                    slowdown()
                                    if (gameState.speed == 0) {
                                        gameState.moveBackward = false
                                    }
                                }))
                        
                        
                    }
                    Spacer()
                        
                    //size control
                    
                    HStack {
                        
                        Button {} label: {
                            Image(systemName: "minus.circle")
                        }
                        .foregroundStyle(.white)
                        .font(.system(size: 100))
                        .offset(x: UIScreen.main.bounds.height/(25))
                        .padding()
                        .offset(x: UIScreen.main.bounds.width/(-15))
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ _ in
                                    gameState.small = true
                                })
                                .onEnded({ _ in
                                    gameState.small = false
                            }))
                        
                        Button {} label: {
                            Image(systemName: "plus.circle")
                        }
                        .foregroundStyle(.white)
                        .font(.system(size: 100))
                        .offset(x: UIScreen.main.bounds.height/(25))
                        .padding()
                        .offset(x: UIScreen.main.bounds.width/(-15))
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ _ in
                                    gameState.big = true
                                })
                                .onEnded({ _ in
                                    gameState.big = false
                            }))
                    }
                    
                }
                .padding(50)
                .offset(y: UIScreen.main.bounds.height/(5))
            }
            
        }
        
    }
    
    //update speed display
    func updateSpeed() {
        if (gameState.speed > 5) {
            speedDisplay = "Max"
        } else {
            speedDisplay = String(round(10 * gameState.speed) / 10) + " "
        }
    }
    
    //accelerate when holding forward/backward
    func speedup() {
        gameState.isAccelerating = true
        if (gameState.speed < 5) {
            gameState.speed += 0.2
            updateSpeed()
        }
        print(gameState.speed)
    }
    
    //deccelerate on release
    func slowdown() {
        _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            if (gameState.isAccelerating) {
                timer.invalidate()
            } else {
                gameState.speed -= 0.1
                updateSpeed()
                
                if (gameState.speed <= 0.5) {
                    gameState.speed = 0
                    updateSpeed()
                    timer.invalidate()
                }
            }
            
        }
    }
               
}

struct ARViewContainer: UIViewRepresentable {

    var gameState: GameState

    public init(_ gameState: GameState) {
        self.gameState = gameState
    }

    func makeUIView(context: Context) -> GameView {
        let arView = GameView(frame: .zero)
        arView.setup()
        arView.gameState = gameState
        return arView
    }
    func updateUIView(_ view: GameView, context: Context) {
        view.gameState = gameState
    }
    
}


#Preview {
    //ARContentView()
    StartContentView()
}
