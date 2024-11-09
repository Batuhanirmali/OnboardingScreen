//import SwiftUI
//
//struct CustomPlanView: View {
//    let calories: Double = 1815
//    let carbs: Double = 221
//    let protein: Double = 119
//    let fats: Double = 50
//    let healthScore: Int = 7
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            
//            // Başlık Kısmı
//            VStack(alignment: .leading, spacing: 4) { // Leading alignment for left alignment
//                Text("Daily recommendation")
//                    .font(.headline)
//                
//                Text("You can edit this anytime")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            }
//            
//            // Circular Progress Views
//            VStack(spacing: 20) {
//                HStack(spacing: 20) {
//                    FlexibleCircularProgressContainer(title: "Calories", value: calories, maxValue: 3000, color:
//                            .black)
//
//                    FlexibleCircularProgressContainer(title: "Carbs", value: carbs, maxValue: 300, color: .orange)
//
//                }
//                
//                HStack(spacing: 20) {
//                    FlexibleCircularProgressContainer(title: "Protein", value: protein, maxValue: 150, color: .red)
//                    FlexibleCircularProgressContainer(title: "Fats", value: fats, maxValue: 100, color: .blue)
//
//                }
//            }.frame(height: UIScreen.main.bounds.height * 0.35)
//            
//            // Health Score Bölümü
//            HStack {
//                Image(systemName: "heart.fill")
//                    .foregroundColor(.pink)
//                    .padding(8)
//                    .background(Color.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .shadow(radius: 2)
//                
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text("Health Score")
//                            .font(.headline)
//                        
//                        Spacer()
//                        
//                        Text("\(healthScore)/10")
//                            .font(.headline)
//                    }
//                    
//                    // Health Score Progress Bar
//                    ProgressView(value: Double(healthScore), total: 10)
//                        .tint(.green)
//                        .frame(height: 10)
//                }
//                
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(15)
//            .shadow(radius: 4)
//            
//        }
//        .padding()
//        .background(Color(UIColor.systemGray6))
//        .cornerRadius(15)
//        .padding()
//        
//    }
//}
//
//// Flexible Progress Container for better alignment
//struct FlexibleCircularProgressContainer: View {
//    var title: String
//    var value: Double
//    var maxValue: Double
//    var color: Color
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack {
//                FlexibleCircularProgressView(title: title, value: value, maxValue: maxValue, color: color)
//                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.white)
//            .cornerRadius(10)
//            .shadow(radius: 4)
//            
//            
//        }
//    }
//}
//
//// Circular Progress View Yapısı
//struct FlexibleCircularProgressView: View {
//    var title: String
//    var value: Double
//    var maxValue: Double
//    var color: Color
//    
//    var progress: Double {
//        value / maxValue
//    }
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            Text(title)
//                .font(.subheadline)
//            
//            ZStack {
//                Circle()
//                    .stroke(lineWidth: 5)
//                    .opacity(0.2)
//                    .foregroundColor(color)
//                Circle()
//                    .trim(from: 0.0, to: progress)
//                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
//                    .foregroundColor(color)
//                    .rotationEffect(Angle(degrees: 270.0))
//                    .animation(.linear, value: progress)
//                
//                Text(String(format: "%.0f", value))
//                    .font(.title3)
//            }
//        }
//    }
//}
//
//struct CustomPlanView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomPlanView()
//    }
//}
//
//
//
