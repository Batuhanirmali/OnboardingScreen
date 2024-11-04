//
//  ContentView.swift
//  OnboardingScreen
//
//  Created by Talha Batuhan Irmalı on 4.11.2024.
//
import SwiftUI
import AVKit

struct OnboardingView: View {
    @State private var isPlaying = false
    @State private var players: [AVPlayer] = []
    @State private var selectedOption: String = "Monthly"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                TabView {
                    ForEach(players.indices, id: \.self) { index in
                        VideoPlayer(player: players[index])
                            .scaledToFill() // Videoyu dolduracak şekilde ölçeklendir
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.5) // Ekranın tamamını kapla
                            .ignoresSafeArea(edges: .all) // Tüm kenarları ihlal et
                            .onAppear {
                                players[index].play()
                                isPlaying = true
                            }
                            .onDisappear {
                                players[index].pause()
                                isPlaying = false
                            }
                    }
                }
                .tabViewStyle(PageTabViewStyle())

                // Subscription Options
                VStack(spacing: 16) {
                    Text("Unlimited access to")
                        .font(.title2)
                        .bold()
                    Text("🍎 Cal AI")
                        .font(.largeTitle)
                        .bold()
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            selectedOption = "Monthly"
                        }) {
                            VStack {
                                HStack {
                                    Text("Monthly")
                                        .bold()
                                    Spacer()
                                }
                                .padding(.bottom, 4)
                                
                                Text("₺ 399,99 /mo")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(selectedOption == "Monthly" ? .black : .gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedOption == "Monthly" ? Color(.systemGray6) : Color.clear)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedOption == "Monthly" ? Color.black : Color.gray, lineWidth: 2)
                            )
                        }
                        
                        Button(action: {
                            selectedOption = "Yearly"
                        }) {
                            VStack {
                                HStack {
                                    Text("Yearly")
                                        .bold()
                                    Spacer()
                                    Text("Save 60%")
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                        .bold()
                                }
                                .padding(.bottom, 4)
                                
                                Text("₺ 166,66 /mo")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(selectedOption == "Yearly" ? .black : .gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedOption == "Yearly" ? Color(.systemGray6) : Color.clear)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedOption == "Yearly" ? Color.black : Color.gray, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        // Add continue button action here
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Text("Already purchased?")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding(.top, 8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15, corners: [.topLeft, .topRight])
                .frame(width: geometry.size.width)
                .padding(.bottom, 0) // Butonun altındaki boşluk daha iyi görünsün
            }
        }
        .onAppear {
            loadVideos()
        }
    }
    
    private func loadVideos() {
        let videoURLs = ["https://videos.pexels.com/video-files/4057322/4057322-sd_506_960_25fps.mp4", "https://videos.pexels.com/video-files/4536566/4536566-sd_360_640_30fps.mp4", "https://videos.pexels.com/video-files/3943967/3943967-sd_506_960_25fps.mp4"]
        players = videoURLs.compactMap { urlString in
            guard let url = URL(string: urlString) else { return nil }
            return AVPlayer(url: url)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}


