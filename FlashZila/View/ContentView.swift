//
//  ContentView.swift
//  FlashZila
//
//  Created by dominator on 07/04/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

struct ContentView: View {
    
    enum Preference: String, CaseIterable{
        case reInsert = "re-insert"
        case none = "none"
    }
    
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @State private var isActive = true
    @State private var cards = [Card]()
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @State private var timeRemaining = 20
    @State private var showingEditScreen = false
    @State private var showingPrefrence = false
    @State private var preference: Preference = .none
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                if getStoredCardCount() > 0 {
                    Text("Time: \(timeRemaining)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.black)
                                .opacity(0.75)
                    )
                }
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        return CardView(card: self.cards[index]) { _ in
                            withAnimation {
                                self.removeCard(at: index)
                            }
                        }
                        .stacked(at: index, in: self.cards.count)
                        .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                if timeRemaining == 0 {
                    VStack(spacing: 20){
                        Text("GAME OVER")
                            .font(.largeTitle)
                            .onAppear(perform: removeAllCards)
                        Button("Start Again", action: resetCards)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())}
                }
                if cards.isEmpty && timeRemaining > 0{
                    if getStoredCardCount() > 0 {
                        VStack(spacing: 20) {
                            Text(getText())
                                .font(.largeTitle)
                            Button("Start Again", action: resetCards)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .clipShape(Capsule())
                        }
                    }else{
                        VStack{
                            Text("You don't have any card yet add some to play")
                                .font(.largeTitle)
                            Button(action: {
                                self.showingEditScreen = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle")
                                    Text("Add Cards")
                                }
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Capsule())
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .padding()
                            }
                        }
                    }
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingPrefrence = true
                    }) {
                        Image(systemName: "gear")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    Button(action: {
                        self.showingEditScreen = true
                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            if differentiateWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as being correct."))
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard self.isActive, self.getStoredCardCount() > 0 else { return }
            if self.timeRemaining > 0{
                self.timeRemaining -= 1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCards()
        }
        .onAppear(perform: resetCards)
        .actionSheet(isPresented: $showingPrefrence) {
            ActionSheet(title: Text("Preference"), message: Text("Select what to do with wrong cards."), buttons: Preference.allCases.map({ prefrence in
                ActionSheet.Button.default(Text(prefrence.rawValue), action: { self.preference =  prefrence})
            }) + [.cancel()]
            )
        }
    }
    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        cards.remove(at: index)
        if cards.isEmpty {
            isActive = false
        }
    }
    func resetCards() {
        timeRemaining = 20
        isActive = true
        loadData()
    }
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
    func removeAllCards() {
        cards.removeAll()
    }
    func getStoredCardCount() -> Int{
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                return decoded.count
            }
        }
        return 0
    }
    
    func getLeastTime()->Int{
        if let time = UserDefaults.standard.value(forKey: "time") as? Int{
            return time
        }
        return 0
    }
    
    func setTime(time: Int){
        UserDefaults.standard.set(time, forKey: "time")
        UserDefaults.standard.synchronize()
    }
    
    func getText()->String{
        if getLeastTime() == 0{
            return "You have score the first least time \(timeRemaining)"
        }else if getLeastTime() > timeRemaining{
            setTime(time: timeRemaining)
            return "You have broke the record by \(getLeastTime() - timeRemaining) seconds"
        }else if getLeastTime() < timeRemaining{
            return "You have missed the record by \(timeRemaining - getLeastTime())"
        }else{
            return "You have completed in record time"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewLayout(.fixed(width: 568, height: 320))
    }
}
