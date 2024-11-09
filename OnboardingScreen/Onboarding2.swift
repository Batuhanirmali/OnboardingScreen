//
//  Onboarding2.swift
//  OnboardingScreen
//
//  Created by Talha Batuhan Irmalı on 6.11.2024.
//

import SwiftUI
import StoreKit
import ConfettiSwiftUI
import Lottie

struct OnboardingView1: View {
    @State private var currentPage: Int = 0
    @State private var selectedGender: String? = nil
    @State private var selectedDate: Date = Date()
    @State private var selectedHeightFeet: Int = 5
    @State private var selectedHeightInches: Int = 6
    @State private var selectedHeightCm: Int = 167
    @State private var selectedWeight: Int = 120
    @State private var isMetric: Bool = false
    @State private var selectedGoal: String? = nil
    @State private var isNextButtonEnabled: Bool = false
    @State private var notificationPermissionGranted: Bool = false
    @State private var wasNextButtonEnabled: Bool = false
    @State private var confettiCounter: Int = 0
    @State private var showFreeTrialShop: Bool = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    generateHapticFeedback()
                    if currentPage > 0 {
                        currentPage -= 1
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "arrow.backward.circle.fill")
                        .resizable()
                        .foregroundStyle(Color(UIColor.darkGray))
                        .frame(width: 32, height: 32)
                        .foregroundColor(.black)
                        .padding()
                }
                
                Spacer()
                
                ProgressBar(currentPage: $currentPage, totalPages: 9)
                    .frame(height: 3)
                    .padding(.trailing)
            }
            
            // Content
            if currentPage == 0 {
                GenderSelectionView(selectedGender: $selectedGender, generateHapticFeedback: generateHapticFeedback)
            } else if currentPage == 1 {
                ImageExampleView()
            } else if currentPage == 2 {
                BirthDateSelectionView(selectedDate: $selectedDate)
            } else if currentPage == 3 {
                HeightWeightSelectionView(selectedHeightFeet: $selectedHeightFeet, selectedHeightInches: $selectedHeightInches, selectedHeightCm: $selectedHeightCm, selectedWeight: $selectedWeight, isMetric: $isMetric)
            } else if currentPage == 4 {
                GoalSelectionView(selectedGoal: $selectedGoal, generateHapticFeedback: generateHapticFeedback)
            } else if currentPage == 5 {
                NotificationPermissionView(isNextButtonEnabled: $notificationPermissionGranted)
            } else if currentPage == 6 {
                ReviewRequestView(isNextButtonEnabled: $isNextButtonEnabled)
                    .onAppear {
                        if !UserDefaults.standard.bool(forKey: "hasRequestedReview") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                    SKStoreReviewController.requestReview(in: scene)
                                    UserDefaults.standard.set(true, forKey: "hasRequestedReview")
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                isNextButtonEnabled = true
                            }
                        } else {
                            isNextButtonEnabled = true
                        }
                    }
            } else if currentPage == 7 {
                ThankYouView(confettiCounter: $confettiCounter, isNextButtonEnabled: $isNextButtonEnabled)
                    .onAppear {
                        confettiCounter += 1
                        isNextButtonEnabled = true
                    }
            } else if currentPage == 8 {
                LoadingView(isNextButtonEnabled: $isNextButtonEnabled)
                    .onAppear {
                        isNextButtonEnabled = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            isNextButtonEnabled = true
                        }
                    }
            } else if currentPage == 9 {
                SummaryView()
                    .onAppear {
                        isNextButtonEnabled = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isNextButtonEnabled = true
                        }
                    }
            }

            Spacer()
            Divider()

            // Footer with Next Button
            VStack {
                Button(action: {
                    generateHapticFeedback()
                    if currentPage == 9 {
                        showFreeTrialShop = true // Show FreeTrialShopView as a full-screen cover
                    } else if isNextButtonCurrentlyEnabled() {
                        currentPage += 1
                    }
                }) {
                    Text("Next")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(isNextButtonCurrentlyEnabled() ? Color.black : Color.gray.opacity(0.4))
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                .disabled(!isNextButtonCurrentlyEnabled())
                .onChange(of: isNextButtonCurrentlyEnabled()) { newValue in
                    if newValue && !wasNextButtonEnabled {
                        generateHapticFeedback()
                    }
                    wasNextButtonEnabled = newValue
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showFreeTrialShop) {
            FreeTrialShopView()
        }
    }

    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func isValidBirthDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year ?? 0 >= 4
    }

    private func isNextButtonCurrentlyEnabled() -> Bool {
        return (currentPage == 1) ||
        (currentPage == 0 && selectedGender != nil) ||
        (currentPage == 2 && isValidBirthDate(selectedDate)) ||
        (currentPage == 3) ||
        (currentPage == 4 && selectedGoal != nil) ||
        (currentPage == 5 && notificationPermissionGranted) ||
        (currentPage == 6 && isNextButtonEnabled) ||
        (currentPage == 7 && isNextButtonEnabled) ||
        (currentPage == 8 && isNextButtonEnabled) ||
        (currentPage == 9 && isNextButtonEnabled)
    }
}

struct FreeTrialShopView: View {
    @State private var currentIndex: Int = 0 // Controls content within FreeTrialShopView

    var body: some View {
        VStack {
            if currentIndex == 0 {
                FreeTrialContentView(currentIndex: $currentIndex)
            } else if currentIndex == 1 {
                FreeTrialReminderView(currentIndex: $currentIndex) // Pass currentIndex as a binding
            } else if currentIndex == 2 {
                OnboardingFreeTrialShopView(currentIndex: $currentIndex) // Navigate to the new view
            }
        }
    }
}


import SwiftUI
import AVKit

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

struct FreeTrialContentView: View {
    @Binding var currentIndex: Int

    // Create an AVPlayer instance with the video URL
    private let player = AVPlayer(url: URL(string: "https://videos.pexels.com/video-files/3946211/3946211-uhd_1440_2732_25fps.mp4")!)

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    Text("We want you to try CalAI for free.")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)

                    // Replace the Image with CustomVideoPlayer
                    CustomVideoPlayer(player: player)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 300)
                        .cornerRadius(20)
                        .onAppear {
                            player.play() // Automatically start playback
                        }
                        .onDisappear {
                            player.pause() // Pause when view disappears
                        }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }

            VStack(spacing: 10) {
                Text("✓ No Payment Due Now")
                    .font(.headline)

                Button(action: {
                    currentIndex = 1 // Navigate to FreeTrialReminderView
                }) {
                    Text("Try for $0.00")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.black)
                        .cornerRadius(15)
                }
                .padding(.horizontal)

                Text("No commitment, cancel anytime.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .padding(.vertical)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct FreeTrialReminderView: View {
    @Binding var currentIndex: Int // Bind to currentIndex in parent view to go back
    @State private var isAnimationPlaying = true

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 30) {
                // Back Button at the top left
                HStack {
                    Button(action: {
                        currentIndex = 0 // Go back to FreeTrialShopView
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }

                
                // Title Text
                Text("We'll send you a reminder before your free trial ends")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 100)

                
                // Notification Bell Icon
                HStack {
                    LottieView(name: "bell", loopMode: .loop, isPlaying: $isAnimationPlaying)
                }
                .padding(.top, 25)
                .shadow(radius: 5)
                .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.5)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            
            // Bottom Overlay with Continue Button
            VStack(spacing: 10) {
                Text("✓ No Payment Due Now")
                    .font(.headline)
                
                Button(action: {
                    currentIndex = 2 // Navigate to OnboardingFreeTrailShopView
                }) {
                    Text("Continue for FREE")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.black)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                
                Text("No commitment, cancel anytime.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .padding(.vertical)

        }
        .ignoresSafeArea(edges: .bottom) // Ignore safe areas at the bottom
    }
}

struct OnboardingFreeTrialShopView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var currentIndex: Int // To navigate back to previous view
    @State private var showOverlay = false // State to control overlay visibility
    @State private var showOpacity = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 20) {
                // Top bar with Back and Close buttons
                HStack {
                    Button(action: {
                        currentIndex = 1 // Go back to FreeTrialReminderView
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showOverlay = true // Show the overlay with faster animation
                            showOpacity = true
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding([.leading, .trailing, .top])
                .padding(.bottom, 20)

                // Main title
                Text("Start your 3-day FREE trial to continue.")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Timeline of features with VerticalStepperView and text
                HStack(alignment: .top, spacing: 5) {
                    VerticalStepperView() // Custom stepper view
                    
                    VStack(alignment: .leading, spacing: 17.5) { // Text for each step
                        TimelineTextView(
                            title: "Today",
                            description: "Unlock all the app's features like AI calorie scanning and more."
                        )
                        TimelineTextView(
                            title: "In 2 Days - Reminder",
                            description: "We'll send you a reminder that your trial is ending soon."
                        )
                        TimelineTextView(
                            title: "In 3 Days - Billing Starts",
                            description: "You'll be charged on 11 Nov 2024 unless you cancel anytime before."
                        )
                    }
                }
                .frame(height: 300)
                .padding(.horizontal)

                Spacer()
            }
            .background(Color.white)
            .opacity(showOpacity ? 0.5 : 1) // Darken background when overlay is shown

            // Bottom overlay with Start Free Trial Button
            VStack(spacing: 10) {
                Text("✓ No Payment Due Now")
                    .font(.headline)
                
                Button(action: {
                    // Action to start free trial
                }) {
                    Text("Start Free Trial")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.black)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                
                Text("3 days free, then ₺999,99 per year (₺83,33/mo)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .padding(.vertical)
            
            
            // Overlay
            if showOverlay {
                Color.black.opacity(0.5) // Background dimming effect
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showOverlay = false // Close overlay with faster animation
                            showOpacity = false
                        }
                    }

                VStack {
                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                            Text("Not down for a year? We get it.")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                presentationMode.wrappedValue.dismiss() // Close the view
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                        }
                        HStack {
                            Text("₺999,99 per year")
                                .font(.title3)
                                .foregroundColor(.black)
                                .strikethrough(true)
                            Text("₺399,99 per month")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.red)
                                .strikethrough(false)
                        }
                        
                        VStack {
                            Text("Special Offer")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .background(Color.red)
                                .cornerRadius(20)
                        }
                        .frame(height: 30)
                        .background(.red)
                        .cornerRadius(20)
                        
                        Spacer()
                        VStack(spacing: 10) {
                            Text("✓ No commitment, cancel anytime")
                                .font(.headline)
                            
                            Button(action: {
                                // Action to start free trial
                            }) {
                                Text("Accept Offer")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(20)
                                    .background(Color.black)
                                    .cornerRadius(15)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .ignoresSafeArea() // Ignore safe areas at the bottom
                        .padding(.vertical)
                    }
                    .padding()
                    .frame(height: UIScreen.main.bounds.height / 3) // One-third screen height
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(radius: 10)
                    
                }
                .transition(.move(edge: .bottom)) // Slide up and down effect
                .animation(.easeInOut(duration: 0.25)) // Faster animation effect
            }
        }
        .ignoresSafeArea(edges: .bottom) // Ignore safe areas at the bottom
    }
}

struct VerticalStepperView: View {
    var body: some View {
        ZStack {
            // Vertical line split into two parts
            VStack(spacing: 0) {
                // Orange part (top 2/3 of the original length, adjusted)
                Rectangle()
                    .fill(Color.orange.opacity(0.5))
                    .frame(width: 15, height: 167) // Çizgi genişliği ve yüksekliği ayarlandı
                
                // Dark Gray part (bottom 1/3 of the original length, adjusted)
                Rectangle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 15, height: 83)
                    .cornerRadius(100)
            }
            .frame(width: 55, height: 250) // Total height set to 250
            
            VStack(spacing: 45) { // Adjusted spacing for new height
                // Lock Icon
                Circle()
                    .fill(Color.orange)
                    .frame(width: 35, height: 35)
                    .overlay(
                        Image(systemName: "lock.open")
                            .foregroundColor(.white)
                            .font(.system(size: 21))
                    )
                
                // Bell Icon
                Circle()
                    .fill(Color.orange)
                    .frame(width: 35, height: 35)
                    .overlay(
                        Image(systemName: "bell")
                            .foregroundColor(.white)
                            .font(.system(size: 21))
                    )
                
                // Crown Icon
                Circle()
                    .fill(Color.black)
                    .frame(width: 35, height: 35)
                    .overlay(
                        Image(systemName: "crown")
                            .foregroundColor(.white)
                            .font(.system(size: 21))
                    )
            }
            .padding(.top, -70) // Adjusted to align with the new line height
        }
    }
}



// Custom view for each step's text content
struct TimelineTextView: View {
    var title: String
    var description: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.callout)
                .foregroundColor(.gray)
        }
    }
}



struct GenderSelectionView: View {
    @Binding var selectedGender: String?
    let generateHapticFeedback: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose your Gender")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("This will be used to calibrate your custom plan.")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()

            VStack(spacing: 20) {
                GenderButton(title: "Male", selectedGender: $selectedGender)
                GenderButton(title: "Female", selectedGender: $selectedGender)
                GenderButton(title: "Other", selectedGender: $selectedGender)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}


struct GenderButton: View {
    let title: String
    @Binding var selectedGender: String?

    var body: some View {
        Button(action: {
            selectedGender = title
        }) {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(selectedGender == title ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedGender == title ? Color.black : Color.gray.opacity(0.1))
                .cornerRadius(15)
        }
    }
}

struct ImageExampleView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cal AI creates long-term results")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            Image("exampleImage2") // Replace with your actual image name
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .padding()

            Text("80% of Fashion AI users maintain their weight loss even 6 months later")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.horizontal)
    }
}

struct BirthDateSelectionView: View {
    @Binding var selectedDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("When were you born?")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("This will be used to calibrate your custom plan.")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()

            DatePicker("Select your birthdate", selection: $selectedDate, in: ...Date(), displayedComponents: [.date])
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()

            Spacer()
        }
        .padding(.horizontal)
    }
}

struct HeightWeightSelectionView: View {
    @Binding var selectedHeightFeet: Int
    @Binding var selectedHeightInches: Int
    @Binding var selectedHeightCm: Int
    @Binding var selectedWeight: Int
    @Binding var isMetric: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Height & weight")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("This will be used to calibrate your custom plan.")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()

            HStack {
                Spacer()
                Text("Imperial")
                    .fontWeight(isMetric ? .bold : .bold)
                    .foregroundColor(isMetric ? .gray : .black)
                Toggle("", isOn: $isMetric)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .labelsHidden()
                Text("Metric")
                    .fontWeight(isMetric ? .bold : .bold)
                    .foregroundColor(isMetric ? .black : .gray)
                Spacer()
            }
            .padding()

            if isMetric {
                // Metric Picker for Height and Weight
                HStack {
                    VStack {
                        Text("Height")
                            .fontWeight(.semibold)
                        Picker("Height", selection: $selectedHeightCm) {
                            ForEach(100...250, id: \.self) { height in
                                Text("\(height) cm")
                                    .font(.system(size: 16, weight: .regular))
                                    .tag(height)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                    }

                    VStack {
                        Text("Weight")
                            .fontWeight(.semibold)
                        Picker("Weight", selection: $selectedWeight) {
                            ForEach(30...200, id: \.self) { weight in
                                Text("\(weight) kg")
                                    .font(.system(size: 16, weight: .regular))
                                    .tag(weight)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                // Imperial Picker for Height (Feet and Inches) and Weight
                HStack {
                    VStack {
                        Text("Height (ft)")
                            .fontWeight(.semibold)
                        Picker("HeightFeet", selection: $selectedHeightFeet) {
                            ForEach(1...8, id: \.self) { feet in
                                Text("\(feet) ft")
                                    .font(.system(size: 16, weight: .regular))
                                    .tag(feet)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                    }

                    VStack {
                        Text("Height (in)")
                            .fontWeight(.semibold)
                        Picker("HeightInches", selection: $selectedHeightInches) {
                            ForEach(0...11, id: \.self) { inches in
                                Text("\(inches) in")
                                    .font(.system(size: 16, weight: .regular))
                                    .tag(inches)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                    }

                    VStack {
                        Text("Weight")
                            .fontWeight(.semibold)
                        Picker("Weight", selection: $selectedWeight) {
                            ForEach(50...700, id: \.self) { weight in
                                Text("\(weight) lb")
                                    .font(.system(size: 16, weight: .regular))
                                    .tag(weight)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

struct GoalSelectionView: View {
    @Binding var selectedGoal: String?
    let generateHapticFeedback: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What would you like to accomplish?")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("This will help us tailor your plan.")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()

            VStack(spacing: 20) {
                GoalButton(title: "Eat and live healthier", imageName: "applelogo", selectedGoal: $selectedGoal)
                GoalButton(title: "Boost my energy and mood", imageName: "sun.max.fill", selectedGoal: $selectedGoal)
                GoalButton(title: "Stay motivated and consistent", imageName: "bolt.fill", selectedGoal: $selectedGoal)
                GoalButton(title: "Feel better about my body", imageName: "figure.walk", selectedGoal: $selectedGoal)
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}

struct GoalButton: View {
    let title: String
    let imageName: String
    @Binding var selectedGoal: String?

    var body: some View {
        Button(action: {
            selectedGoal = title
        }) {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(selectedGoal == title ? .white : .black)
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(selectedGoal == title ? .white : .black)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(selectedGoal == title ? Color.black : Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

struct NotificationPermissionView: View {
    @Binding var isNextButtonEnabled: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            Text("Reach your goals with notifications")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 50)

            VStack {
                Text("Fashion AI would like to send you Notifications")
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding()
                HStack {
                    Text("Don't Allow")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .foregroundColor(.black)

                    Button(action: {
                        requestNotificationPermission()
                    }) {
                        Text("Allow")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                    }
                }
            }
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)

            HStack {
                Spacer()
                Text("👆")
                    .font(.system(size: 35))
                    .padding(.trailing, 75)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                isNextButtonEnabled = true
            }
        }
    }
}

struct ReviewRequestView: View {
    @Binding var isNextButtonEnabled: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Give us rating")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack(spacing: 10) {

                    Text("⭐️ ⭐️ ⭐️ ⭐️ ⭐️")
                        .font(.title)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)

                Text("Cal AI was made for people like you")
                    .font(.headline)

                HStack {
                    Image("exampleUser1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                    Image("exampleUser2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                    Image("exampleUser3")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                }
                Text("+ 1000 Fashion AI people")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 15) {
                    ReviewView(userName: "Marley Bryle", userImage: "exampleUser1", review: "I lost 15 lbs in 2 months! I was about to go on Ozempic but decided to give this app a shot and it worked :)")
                    ReviewView(userName: "Benny Marcs", userImage: "exampleUser3", review: "The time I have saved by just taking care of my calorie intake with Fashion AI is incredible!")
                    ReviewView(userName: "Alex Smith", userImage: "exampleUser2", review: "Fashion AI has been an absolute game changer for my health journey. Highly recommended!")
                    ReviewView(userName: "Jessica Lee", userImage: "exampleUser3", review: "The simplicity of this app is what makes it so effective. I love it!")
                    ReviewView(userName: "Chris Doe", userImage: "exampleUser2", review: "Amazing app, easy to use and very motivating.")
                }
                .padding()
            }
            .padding()
        }
    }
}

struct ReviewView: View {
    var userName: String
    var userImage: String
    var review: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(userImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                Text(userName)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer()
                HStack(spacing: 2) {
                    Text("⭐️⭐️⭐️⭐️⭐️")
                        .font(.title3)
                }
                
            }
            Text(review)
                .font(.body)
                .foregroundStyle(.white)
        }
        .padding()
        .background(Color.gray.opacity(0.95))
        .cornerRadius(20)
    }
}

struct ThankYouView: View {
    @State private var isCompleted: Bool = false
    @Binding var confettiCounter: Int
    @Binding var isNextButtonEnabled: Bool

    var body: some View {
        VStack {
            Spacer()
            
            // All Done Message with confetti effect
            VStack(alignment: .center, spacing: 16) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("All done!")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Text("Thank you for trusting us")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("We promise to always keep your personal information private and secure.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
        .confettiCannon(counter: $confettiCounter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
        .navigationBarBackButtonHidden(true)
    }
}

struct ProgressBar: View {
    @Binding var currentPage: Int
    let totalPages: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Foreground bar with conditional color and full width on the last page
                Rectangle()
                    .fill(currentPage == totalPages ? Color(red: 0.0, green: 0.5, blue: 0.0) : Color.black)
                    .frame(
                        width: currentPage == totalPages ? geometry.size.width : (CGFloat(currentPage) / CGFloat(totalPages)) * geometry.size.width,
                        height: geometry.size.height
                    )
            }
            .cornerRadius(2)
        }
    }
}


struct LoadingView: View {
    @Binding var isNextButtonEnabled: Bool
    @State private var currentTextIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var isAnimating = false
    @State private var isSetupComplete = false  // New state to track setup completion

    let loadingTexts: [String] = [
        "Applying BMR formula...",
        "Customizing your plan...",
        "Fetching personalized insights...",
        "Analyzing your health data...",
        "Finalizing details..."
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(isSetupComplete ? "Everything's all set" : "We're setting everything up for you")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        isNextButtonEnabled = true
                        isSetupComplete = true  // Update text after 10 seconds
                        stopLoadingAnimation()
                    }
                }
            
            if !isNextButtonEnabled {
                Text(loadingTexts[currentTextIndex])
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .onAppear {
                        startTextRotation()
                    }
                    .onDisappear {
                        stopTextRotation()
                    }
                
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Circle()
                            .frame(width: 12, height: 12)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(0.2 * Double(index)),
                                value: isAnimating
                            )
                    }
                }
                .onAppear {
                    isAnimating = true
                }
            }
            
            Spacer()
        }
        
    }
    
    private func startTextRotation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            if currentTextIndex < loadingTexts.count - 1 {
                currentTextIndex += 1
            } else {
                stopTextRotation()
            }
        }
    }
    
    private func stopTextRotation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func stopLoadingAnimation() {
        isAnimating = false
    }
}


struct SummaryView: View {
    
    let calories: Double = 1815
    let carbs: Double = 221
    let protein: Double = 119
    let fats: Double = 50
    let healthScore: Int = 7
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with a checkmark icon and congratulatory text
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.black)
                    
                    Text("Congratulations")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("your custom plan is ready!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Weight gain target
                VStack(spacing: 8) {
                    Text("You should gain:")
                        .font(.headline)
                    
                    Text("10 lbs by April 11, 2025")
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Daily recommendation section

                VStack(alignment: .leading, spacing: 20) {
                    
                    // Başlık Kısmı
                    VStack(alignment: .leading, spacing: 4) { // Leading alignment for left alignment
                        Text("Daily recommendation")
                            .font(.headline)
                        
                        Text("You can edit this anytime")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Circular Progress Views
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            FlexibleCircularProgressContainer(title: "Calories", value: calories, maxValue: 3000, color:
                                    .black)

                            FlexibleCircularProgressContainer(title: "Carbs", value: carbs, maxValue: 300, color: .orange)

                        }
                        
                        HStack(spacing: 20) {
                            FlexibleCircularProgressContainer(title: "Protein", value: protein, maxValue: 150, color: .red)
                            FlexibleCircularProgressContainer(title: "Fats", value: fats, maxValue: 100, color: .blue)

                        }
                    }.frame(height: UIScreen.main.bounds.height * 0.35)
                    
                    // Health Score Bölümü
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Health Score")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text("\(healthScore)/10")
                                    .font(.headline)
                            }
                            
                            // Health Score Progress Bar
                            ProgressView(value: Double(healthScore), total: 10)
                                .tint(.green)
                                .frame(height: 10)
                        }
                        
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 4)
                    
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(15)
                .padding()
//                LottieView(animation: .named("Animation - 1731095147563"))
//                    .playing(loopMode: .loop)
                
                Spacer()
                
            }
            .padding(.horizontal)
            .padding(.bottom, 40) // Extra padding for scroll space
        }
    }
}

struct NutrientCard: View {
    let title: String
    let amount: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
            
            Text(amount)
                .font(.title3)
                .fontWeight(.bold)
            
            Circle()
                .trim(from: 0, to: 0.7) // Adjust trim for each nutrient
                .stroke(color, lineWidth: 6)
                .frame(width: 40, height: 40)
        }
        .frame(width: 100, height: 100)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}




struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        FreeTrialReminderView(currentIndex: .constant(1))
    }
}

extension Color {
    static let darkGray = Color(UIColor.darkGray)
    static let lightGray = Color(UIColor.lightGray)
}


// Flexible Progress Container for better alignment
struct FlexibleCircularProgressContainer: View {
var title: String
var value: Double
var maxValue: Double
var color: Color

var body: some View {
    GeometryReader { geometry in
        VStack {
            FlexibleCircularProgressView(title: title, value: value, maxValue: maxValue, color: color)
                .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 4)
        
        
    }
}
}

// Circular Progress View Yapısı
struct FlexibleCircularProgressView: View {
var title: String
var value: Double
var maxValue: Double
var color: Color

var progress: Double {
    value / maxValue
}

var body: some View {
    VStack(spacing: 10) {
        Text(title)
            .font(.subheadline)
        
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .opacity(0.2)
                .foregroundColor(color)
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text(String(format: "%.0f", value))
                .font(.title3)
        }
    }
}
}
