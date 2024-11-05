//
//  ContentView.swift
//  OnboardingScreen
//
//  Created by Talha Batuhan Irmalı on 4.11.2024.
//
import SwiftUI

struct OnboardingView: View {
    @State private var currentIndex: Int = 0
    let images = ["meal_image", "nutrition_analysis_image", "weight_goal_image"]
    let titles = ["Meal Plan", "Nutrition Analysis", "Weight Goal"]
    let descriptions = [
        "Just snap a quick photo of your meal and we'll do the rest",
        "Analyze your daily nutrition intake.",
        "Set and achieve your weight goals."
    ]
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(images[currentIndex])
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.top)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: currentIndex)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                
                VStack {
                    Spacer()
                    
                    VStack {
                        TabView(selection: $currentIndex) {
                            ForEach(0..<images.count, id: \.self) { index in
                                VStack(spacing: 16) {
                                    Text(titles[index])
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 20)
                                    Text(descriptions[index])
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                        .padding(.top, 10)
                                    Spacer()

                                }
                                .tag(index)
                            }
                            
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        HStack(spacing: 8) {
                            ForEach(0..<images.count, id: \.self) { index in
                                Circle()
                                    .fill(currentIndex == index ? Color.black : Color(UIColor.systemGray6))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        .padding(.bottom, 10)
                        
                    }
                    .background(Color.white)
                    .frame(width: UIScreen.main.bounds.width ,height: 300)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    Divider()
                    
                    VStack {
                        Button(action: {
                            // Handle next action
                        }) {
                            Text("Next")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, maxHeight: 30)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.black)
                                .cornerRadius(30)
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: geometry.size.width)
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
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

