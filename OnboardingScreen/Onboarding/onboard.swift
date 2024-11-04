//
//  Untitled.swift
//  OnboardingScreen
//
//  Created by Talha Batuhan Irmalı on 4.11.2024.
//

import SwiftUI
import AVKit

struct Onboarding: View {
    @State private var isPlaying = false
    @State private var players: [AVPlayer] = []
    @State private var selectedOption: String = "Monthly"
    @State private var currentTabIndex: Int = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TabView(selection: $currentTabIndex) {
                    ForEach(players.indices, id: \.self) { index in
                        CustomVideoPlayer(player: players[index])
                            .frame(width: geometry.size.width, height: geometry.size.height * 1.5)
                            .ignoresSafeArea(edges: .top)
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
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .onReceive(timer) { _ in
                    withAnimation {
                        currentTabIndex = (currentTabIndex + 1) % players.count
                    }
                }
                Spacer()
                VStack(){
                    
                }.frame(width: geometry.size.width, height: geometry.size.height * 0.42)

            }
            .edgesIgnoringSafeArea(.top)
            .overlay(
                SubscriptionOptionsView(selectedOption: $selectedOption)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.45)
                    .background(Color.white)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(1.6), radius: 20, x: 0, y: 0)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 1.21)

            )
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            loadVideos()
        }
    }

    private func loadVideos() {
        let videoURLs = [
            "https://videos.pexels.com/video-files/4057322/4057322-sd_506_960_25fps.mp4",
            "https://videos.pexels.com/video-files/4536566/4536566-sd_360_640_30fps.mp4",
            "https://videos.pexels.com/video-files/3943967/3943967-sd_506_960_25fps.mp4"
        ]
        players = videoURLs.compactMap { urlString in
            guard let url = URL(string: urlString) else { return nil }
            return AVPlayer(url: url)
        }
    }
}

struct SubscriptionOptionsView: View {
    @Binding var selectedOption: String

    var body: some View {
        VStack(spacing: 16) {
            Text("Unlimited access to")
                .font(.title2)
                .bold()
            Text("🍎 Cal AI")
                .font(.largeTitle)
                .bold()

            HStack(spacing: 16) {
                SubscriptionButton(title: "Monthly", price: "₺399,99 /mo", isSelected: selectedOption == "Monthly") {
                    selectedOption = "Monthly"
                }

                SubscriptionButton(title: "Yearly", price: "₺166,66 /mo", isSelected: selectedOption == "Yearly") {
                    selectedOption = "Yearly"
                }
                .overlay(
                    Text("Save 60%")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .bold()
                        .padding(6)
                        .background(Color.black)
                        .cornerRadius(10)
                        .offset(y: -15),
                    alignment: .top
                )
            }
            .padding(.horizontal)

            Button(action: {
                // Add continue button action here
            }) {
                Text("Continue")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 35)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .padding(.horizontal)

            Button(action: {
                // Add action for already purchased here
            }) {
                Text("Already purchased?")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.top, 8)
            }
        }
        .padding()
    }
}

struct SubscriptionButton: View {
    let title: String
    let price: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack {
                    HStack {
                        Text(title)
                            .foregroundStyle(.black)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
                    Text(price)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(isSelected ? .black : .gray)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                } else {
                    Image(systemName: "circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 85)
            .background(isSelected ? Color(.systemGray6) : Color.clear)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.black : Color.gray, lineWidth: 3)
            )
        }
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}

struct CustomVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update code if necessary
    }
}



extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
