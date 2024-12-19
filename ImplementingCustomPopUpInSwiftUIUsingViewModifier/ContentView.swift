//
//  ContentView.swift
//  ImplementingCustomPopUpInSwiftUIUsingViewModifier
//
//  Created by admin on 12/19/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isPresented: Bool = false
    
    var body: some View {
        VStack {
            Text("SwiftUI")
                .font(.largeTitle)
            
            Spacer()
            
            Button("Show dialog") {
                withAnimation(.bouncy) {
                    isPresented.toggle()
                }
            }
            
            Spacer()
        }
        .popView(isPresented: $isPresented) {
            CustomDialogView(image: Image(systemName: "swift"), title: "SwiftUI", subtitle: "Best programming language", closeButtonText: "OK!")
        }
    }
}

struct ViewModifierExamples: View {
    @State private var isActive: Bool = false
    
    var body: some View {
        VStack {
            Text("Custom modifier")
            //.modifier(RoundedBackgroundModifier())
                .roundedBackground(backgroundColor: .orange, cornerRadius: 10)
            
            Text("Custom modifier")
                .roundedBackground(backgroundColor: .mint, cornerRadius: 20)
            
            Button(action: { isActive.toggle() }) {
                HStack {
                    Text("Completed")
                        .textCase(.uppercase)
                        .bold()
                    Image(systemName: "bell.fill")
                }
                .foregroundStyle(.white)
                .padding(10)
                .background(.red, in: RoundedRectangle(cornerRadius: 5))
            }
            .conditionalStyle(isActive: isActive)
        }
    }
}

struct PopupViewModifier<ModelContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let modelContent: ModelContent
    @State private var isAnimated: Bool = false
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                if isAnimated {
                    modelContent
                        .transition(.move(edge: .top).combined(with: .scale))
                } else {
                    ZStack {
                        
                    }
                    .presentationBackground(.clear)
                }
            }
            .transaction { transaction in
                if isAnimated == false {
                    transaction.disablesAnimations = true
                }
            }
            .onChange(of: isPresented) { oldValue, newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation(.bouncy) {
                        isAnimated = newValue
                    }
                }
            }
    }
}

extension View {
    func popView<ModelContent: View>(isPresented: Binding<Bool>, content: @escaping () -> ModelContent) -> some View {
        self.modifier(PopupViewModifier(isPresented: isPresented, modelContent: content()))
    }
}

struct CustomDialogView: View {
    @Environment(\.dismiss) var dismiss
    var image: Image
    var title: String
    var subtitle: String
    var closeButtonText: String
    
    var body: some View {
        VStack {
            VStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.green, in: Circle())
                
                Text(title)
                    .font(.largeTitle)
                    .bold()
                
                Text(subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            Spacer()
            
            Button(closeButtonText) {
                dismiss()
            }
            .padding()
        }
        .containerRelativeFrame(.vertical) { height, _ in height / 3 }
        .containerRelativeFrame(.horizontal) { width, _ in width / 1.2 }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .presentationBackground(.clear)
    }
}

struct RoundedBackgroundModifier: ViewModifier {
    var backgroundColor: Color
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    func roundedBackground(backgroundColor: Color, cornerRadius: CGFloat) -> some View {
        self.modifier(RoundedBackgroundModifier(backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }
}

struct ConditionalModifier: ViewModifier {
    var isActive: Bool
    
    func body(content: Content) -> some View {
        HStack {
            content
            Image(systemName: "checkmark")
                .padding(10)
                .background(.red, in: RoundedRectangle(cornerRadius: 5))
                .offset(x: isActive ? -15 : -50)
                .opacity(isActive ? 1 : 0)
                .animation(.easeInOut, value: isActive)
        }
    }
}

extension View {
    func conditionalStyle(isActive: Bool) -> some View {
        self.modifier(ConditionalModifier(isActive: isActive))
    }
}

#Preview {
    ContentView()
}
