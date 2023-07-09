//
//  CircleMenuView.swift
//  NaverButton
//
//  Created by Byeon jinha on 2023/07/09.
//

import SwiftUI

struct CircleMenuView: View {
    
    @State private var radius: CGFloat = 40
    @State private var backCicleSize: CGFloat = 0.5
    @State private var rotationAngle: Double = 0.0
    
    @State private var timer: Timer? = nil
    @State private var moveCount: Int = 0
    
    @State private var isFirst: Bool = true
    
    @Binding var isCircleView: Bool
    
    let buttonImages: [String]
    @State var isButtons: [Bool]
    
    //애니메이션 중복발생을 막음.
    @State var isDisappear: Bool = true
    
    init(isCircleView: Binding<Bool>, buttonImages: [String]) {
        self.buttonImages = buttonImages
        isButtons = Array(repeating: false, count: buttonImages.count)
        _isCircleView = isCircleView
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: w * backCicleSize, height: h * backCicleSize)
                    Circle()
                        .fill(Color.blue)
                        .frame(width: w * 0.3 * backCicleSize, height: h * 0.3 * backCicleSize)
                        .onTapGesture {
                            if isDisappear {
                                isDisappear = false
                                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                    if moveCount < 2 {
                                        withAnimation(Animation.linear(duration: 0.1)) {
                                            rotationAngle = (rotationAngle - .pi / Double(buttonImages.count)).truncatingRemainder(dividingBy: 2 * .pi)
                                            moveCount += 1
                                            radius -= 40
                                            backCicleSize -= 0.15
                                        }
                                    } else if moveCount == 2{
                                        withAnimation(Animation.linear(duration: 0.1)) {
                                            rotationAngle = (rotationAngle + .pi / Double(buttonImages.count) * 0.2).truncatingRemainder(dividingBy: 2 * .pi)
                                            moveCount += 1
                                            backCicleSize += 0.1
                                        }
                                        moveCount = 0
                                        stopTimer()
                                        isCircleView = false
                                    }
                                }
                            }
                        }
                    
                    ForEach(0..<buttonImages.count) { index in
                        Circle()
                            .fill(Color.red)
                            .frame(width: 50, height: 50)
                            .overlay(
                                VStack{
                                    Image(systemName: buttonImages[index])
                                }
                            )
                            .position(
                                x: geometry.size.width * 0.5 + CGFloat(cos(angle(index: index) + rotationAngle)) * (radius),
                                y: geometry.size.height * 0.5 + CGFloat(sin(angle(index: index) + rotationAngle)) * (radius)
                            )
                            .navigationDestination(isPresented: $isButtons[index]) {
                                Image(systemName: buttonImages[index])
                           
                            }
                            .onTapGesture {
                                isButtons[index] = true
                                isFirst = false
                            }
                            .gesture(DragGesture()
                                .onChanged { value in
                                    let redPointAngle = angle(index: index)
                                    let dragAngle = atan2(Double(value.location.y - geometry.size.height * 0.5), Double(value.location.x - geometry.size.width * 0.5))
                                    rotationAngle = dragAngle - redPointAngle
                                }
                                .onEnded { value in
                                    endEvent(location: value.location, index: index, w: w, h: h)
                                }
                            )
                    }
                }
                .onAppear {
                    if isFirst {
                        appearEvent()
                    } else {
                        isCircleView = false
                    }
                }
            }
        }
    }
    
    // 각 원의 위치를 계산
    private func angle(index: Int) -> Double {
        let angleStep = 2 * .pi / Double(buttonImages.count)
        return angleStep * Double(index)
    }
    
    // 이벤트 종료
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // appearEvent
    private func appearEvent() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if moveCount < 2 {
                withAnimation(Animation.linear(duration: 0.1)) {
                    rotationAngle = (rotationAngle + .pi / Double(buttonImages.count)).truncatingRemainder(dividingBy: 2 * .pi)
                    moveCount += 1
                    radius += 40
                    backCicleSize += 0.15
                }
            } else if moveCount == 2{
                withAnimation(Animation.linear(duration: 0.1).repeatForever(autoreverses: true)) {
                    rotationAngle = (rotationAngle + .pi / Double(buttonImages.count) * 0.2).truncatingRemainder(dividingBy: 2 * .pi)
                    moveCount += 1
                    backCicleSize += 0.15
                }
            } else if moveCount == 3{
                withAnimation(Animation.linear(duration: 0.1)) {
                    rotationAngle = (rotationAngle - .pi / Double(buttonImages.count) * 0.2).truncatingRemainder(dividingBy: 2 * .pi)
                    moveCount += 1
                    backCicleSize -= 0.1
                }
                moveCount = 0
                stopTimer()
            }
        }
    }
    
    // endEvent
    private func endEvent( location: CGPoint, index: Int, w: CGFloat,h: CGFloat) {
        let angleStep = 2 * CGFloat.pi / CGFloat(buttonImages.count)
        let angleRange = stride(from: -Double.pi, through: Double.pi, by: angleStep)
        let anglesArray = Array(angleRange)

        let redPointAngle = angle(index: index)
        let dragAngle = atan2(Double(location.y - h * 0.5), Double(location.x - w * 0.5))

        var minAngle = 3.15
        var idx = 0
        for i in 0..<anglesArray.count {
            //절대값 비교후 절대값이 가장 작은 값 저장 후 적용.
            if abs(anglesArray[i] - dragAngle) < minAngle {
                minAngle = abs(anglesArray[i] - dragAngle)
                idx = i
            }
        }
        rotationAngle = anglesArray[idx] - redPointAngle
    }
}
