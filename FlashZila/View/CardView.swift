//
//  CardView.swift
//  FlashZila
//
//  Created by dominator on 07/04/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import SwiftUI

struct CardView: View {
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @State private var isShowingAnswer = false
    @State private var offset: CGSize = .zero
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @State private var feedback = UINotificationFeedbackGenerator()
    let card: Card
    var removal: ((_ wasRight: Bool) -> Void)? = nil
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                    ? Color.white
                    : Color.white
                        .opacity(1 - Double(abs(offset.width / 50)))
            )
                .shadow(radius: 10)
                .background(
                    differentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(offset.width > 0 ? Color.green : Color.red)
            )
                
            VStack {
                if accessibilityEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)

                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .onTapGesture {
            self.isShowingAnswer.toggle()
        }
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 2, y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibility(addTraits: .isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                    self.feedback.prepare()
            }
                
            .onEnded { _ in
                if abs(self.offset.width) > 100 {
                    if self.offset.width > 0 {
                        self.feedback.notificationOccurred(.success)
                    } else {
                        self.feedback.notificationOccurred(.error)
                    }
                    self.removal?(self.offset.width > 0)
                } else {
                    self.offset = .zero
                }
            }
        )
        .animation(.spring())
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: .example)
    }
}
