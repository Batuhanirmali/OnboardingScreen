//
//  Onboarding2.swift
//  OnboardingScreen
//
//  Created by Talha Batuhan Irmalı on 6.11.2024.
//

import SwiftUI
import StoreKit
import ConfettiSwiftUI

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
    @State private var wasNextButtonEnabled: Bool = false // Track previous state of the button
    @State private var confettiCounter: Int = 0

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // Header with Back Button and Progress Bar side by side
            HStack {
                Button(action: {
                    generateHapticFeedback() // Add haptic feedback
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
                
                ProgressBar(currentPage: $currentPage, totalPages: 8)
                    .frame(height: 4)
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
                ThankYouView(confettiCounter: $confettiCounter)
                    .onAppear {
                        confettiCounter += 1
                    }
            }else if currentPage == 8 {
                LoadingView() // Add the loading screen as the last page
            }
            
            

            Spacer()
            Divider()

            // Footer with Next Button
            VStack {
                Button(action: {
                    generateHapticFeedback() // Add haptic feedback
                    if (currentPage == 0 && selectedGender != nil) ||
                        currentPage == 1 ||
                        (currentPage == 2 && isValidBirthDate(selectedDate)) ||
                        (currentPage == 3) ||
                        (currentPage == 4 && selectedGoal != nil) ||
                        (currentPage == 5 && notificationPermissionGranted) ||
                        (currentPage == 6 && isNextButtonEnabled) ||
                        (currentPage == 7 && isNextButtonEnabled) {
                        currentPage += 1
                    }
                }) {
                    Text("Next")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isNextButtonCurrentlyEnabled() ? Color.black : Color.gray.opacity(0.4))
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                .disabled(!isNextButtonCurrentlyEnabled())
                .onChange(of: isNextButtonCurrentlyEnabled()) { newValue in
                    // Add haptic feedback if the button becomes enabled
                    if newValue && !wasNextButtonEnabled {
                        generateHapticFeedback()
                    }
                    wasNextButtonEnabled = newValue
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Hides the default back button
    }

    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func isValidBirthDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        if let age = ageComponents.year, age >= 4 {
            return true
        }
        return false
    }

    private func isNextButtonCurrentlyEnabled() -> Bool {
        return (currentPage == 1) ||
            (currentPage == 0 && selectedGender != nil) ||
            (currentPage == 2 && isValidBirthDate(selectedDate)) ||
            (currentPage == 3) ||
            (currentPage == 4 && selectedGoal != nil) ||
            (currentPage == 5 && notificationPermissionGranted) ||
            (currentPage == 6 && isNextButtonEnabled) ||
            (currentPage == 7 && isNextButtonEnabled)
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

            Button(action: {
                requestNotificationPermission()
            }) {
                VStack {
                    Text("Fashion AI would like to send you Notifications")
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding()
                    HStack {
                        Text("Don't Allow")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.4))
                            .foregroundColor(.black)
                        Text("Allow")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                    }
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.horizontal)
            }
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
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: geometry.size.width, height: geometry.size.height)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: (CGFloat(currentPage + 1) / CGFloat(totalPages)) * geometry.size.width, height: geometry.size.height)
            }
            .cornerRadius(2)
        }
    }
}

struct LoadingView: View {
    @State private var currentTextIndex: Int = 0
    @State private var timer: Timer? = nil
    @State private var isAnimating = false

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
            
            Text("We\'re setting everything up for you")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
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
            
            Spacer()
        }
    }
    
    private func startTextRotation() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            currentTextIndex = (currentTextIndex + 1) % loadingTexts.count
        }
    }
    
    private func stopTextRotation() {
        timer?.invalidate()
        timer = nil
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

extension Color {
    static let darkGray = Color(UIColor.darkGray)
    static let lightGray = Color(UIColor.lightGray)
}

