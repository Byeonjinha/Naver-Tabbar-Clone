import SwiftUI
import CoreGraphics

struct ContentView: View {
    @State var isCircleView: Bool = false
    let buttonImages:[String] = ["heart", "star", "square", "triangle", "circle", "rectangle"]
    
    var body: some View {
        
        ZStack{
            VStack{
                Spacer()
                Circle()
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        if isCircleView == false {
                            self.isCircleView = true
                        } else {
                            self.isCircleView = false
                        }
                    }
                    .padding()
            }
            if isCircleView {
                CircleMenuView(isCircleView: $isCircleView,  buttonImages: buttonImages)
            }
        }
    }
    
}
