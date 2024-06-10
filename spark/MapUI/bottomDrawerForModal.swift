////
////  bottomDrawerForModal.swift
////  spark
////
////  Created by Kabir Borle on 6/4/24.
////
//
//import Foundation
//import SwiftUI
//
//struct CustomCorners: Shape {
//    var corners: UIRectCorner
//    var radius: CGFloat
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
//struct BottomDrawerView<Content: View, DrawerContent: View, PullUpView: View>: View {
//    var content: () -> Content
//    var drawerContent: () -> DrawerContent
//    var pullUpView: (_ shouldGoUp: Bool) -> PullUpView
//    var bottomDrawerHeight: CGFloat = 100
//    var drawerTopCornerRadius: CGFloat = 32
//    var ignoreTopSafeAreas: Bool = false
//    
//    @State var lastOffset: CGFloat = 0
//    @State var offset: CGFloat = 0
//    @GestureState var gestureOffset: CGFloat = 0
//    
//    init(
//        content: @escaping () -> Content,
//        drawerContent: @escaping () -> DrawerContent,
//        pullUpView: @escaping (_ shouldGoUp: Bool) -> PullUpView,
//        bottomDrawerHeight: CGFloat = 100,
//        drawerTopCornerRadius: CGFloat = 32,
//        ignoreTopSafeAreas: Bool = false
//    ) {
//        self.content = content
//        self.drawerContent = drawerContent
//        self.pullUpView = pullUpView
//        self.bottomDrawerHeight = bottomDrawerHeight
//        self.drawerTopCornerRadius = drawerTopCornerRadius
//        self.ignoreTopSafeAreas = ignoreTopSafeAreas
//    }
//    
//    var body: some View {
//        ZStack {
//            content()
//            GeometryReader { proxy -> AnyView in
//                let height = proxy.frame(in: .global).height
//                let maxHeight = height * 0.75 // Limit the maximum height to 3/4 of the screen
//                return AnyView(
//                    ZStack {
//                        Color.black
//                            .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: self.drawerTopCornerRadius))
//                        VStack(spacing: 0) {
//                            self.pullUpView(-offset > (maxHeight - self.bottomDrawerHeight))
//                                .frame(height: self.bottomDrawerHeight)
//                                .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: self.drawerTopCornerRadius))
//                            drawerContent()
//                        }
//                        .frame(maxHeight: .infinity, alignment: .top)
//                    }
//                    .offset(y: height - self.bottomDrawerHeight)
//                    .offset(y: -offset > 0 ? min(offset, maxHeight - self.bottomDrawerHeight) : 0)
//                    .gesture(
//                        DragGesture()
//                            .updating(self.$gestureOffset, body: { value, out, _ in
//                                out = value.translation.height
//                                DispatchQueue.main.async {
//                                    self.offset = min(gestureOffset + lastOffset, maxHeight - self.bottomDrawerHeight)
//                                }
//                            })
//                            .onEnded({ value in
//                                withAnimation {
//                                    if -offset > (maxHeight - self.bottomDrawerHeight) / 2 {
//                                        offset = -(maxHeight - self.bottomDrawerHeight)
//                                    } else {
//                                        offset = 0
//                                    }
//                                }
//                                self.lastOffset = offset
//                            })
//                    )
//                )
//            }
//            .ignoresSafeArea(.all, edges: self.ignoreTopSafeAreas ? [.top, .bottom] : [.bottom])
//        }
//    }
//}
//
//struct BottomDrawerModifier<DrawerContent: View, PullUpView: View>: ViewModifier {
//    var bottomDrawerHeight: CGFloat = 100
//    var drawerTopCornerRadius: CGFloat = 32
//    var ignoreTopSafeAreas: Bool = false
//    var drawerContent: () -> DrawerContent
//    var pullUpView: (_ shouldGoUp: Bool) -> PullUpView
//    
//    func body(content: Content) -> some View {
//        BottomDrawerView(
//            content: { content },
//            drawerContent: drawerContent,
//            pullUpView: pullUpView,
//            bottomDrawerHeight: self.bottomDrawerHeight,
//            drawerTopCornerRadius: self.drawerTopCornerRadius,
//            ignoreTopSafeAreas: self.ignoreTopSafeAreas
//        )
//    }
//}
//
//extension View {
//    func bottomDrawerView<DrawerContent: View, PullUpView: View>(
//        bottomDrawerHeight: CGFloat = 100,
//        drawerTopCornerRadius: CGFloat = 32,
//        ignoreTopSafeAreas: Bool = false,
//        @ViewBuilder drawerContent: @escaping () -> DrawerContent,
//        @ViewBuilder pullUpView: @escaping (_ shouldGoUp: Bool) -> PullUpView
//    ) -> some View {
//        self.modifier(BottomDrawerModifier(
//            bottomDrawerHeight: bottomDrawerHeight,
//            drawerTopCornerRadius: drawerTopCornerRadius,
//            ignoreTopSafeAreas: ignoreTopSafeAreas,
//            drawerContent: drawerContent,
//            pullUpView: pullUpView
//        ))
//    }
//}

import SwiftUI

struct CustomCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct BottomDrawerView<Content: View, DrawerContent: View, PullUpView: View>: View {
    var content: () -> Content
    var drawerContent: () -> DrawerContent
    var pullUpView: (_ shouldGoUp: Bool) -> PullUpView
    var bottomDrawerHeight: CGFloat = 100
    var drawerTopCornerRadius: CGFloat = 32
    var ignoreTopSafeAreas: Bool = false
    
    @State var lastOffset: CGFloat = 0
    @State var offset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    init(
        content: @escaping () -> Content,
        drawerContent: @escaping () -> DrawerContent,
        pullUpView: @escaping (_ shouldGoUp: Bool) -> PullUpView,
        bottomDrawerHeight: CGFloat = 100,
        drawerTopCornerRadius: CGFloat = 32,
        ignoreTopSafeAreas: Bool = false
    ) {
        self.content = content
        self.drawerContent = drawerContent
        self.pullUpView = pullUpView
        self.bottomDrawerHeight = bottomDrawerHeight
        self.drawerTopCornerRadius = drawerTopCornerRadius
        self.ignoreTopSafeAreas = ignoreTopSafeAreas
    }
    
    var body: some View {
        ZStack {
            content()
            GeometryReader { proxy -> AnyView in
                let height = proxy.frame(in: .global).height
                let maxHeight = height * 0.75 // Limit the maximum height to 3/4 of the screen
                let shouldHidePullUpView = -offset > (maxHeight - self.bottomDrawerHeight)
                
                return AnyView(
                    ZStack {
                        Color.black
                            .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: self.drawerTopCornerRadius))
                        VStack(spacing: 0) {
                            if !shouldHidePullUpView {
                                self.pullUpView(shouldHidePullUpView)
                                    .frame(height: self.bottomDrawerHeight)
                                    .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: self.drawerTopCornerRadius))
                            }
                            drawerContent()
                                .frame(maxHeight: shouldHidePullUpView ? .infinity : .none, alignment: .top)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .offset(y: height - self.bottomDrawerHeight)
                    .offset(y: -offset > 0 ? min(offset, maxHeight - self.bottomDrawerHeight) : 0)
                    .gesture(
                        DragGesture()
                            .updating(self.$gestureOffset, body: { value, out, _ in
                                out = value.translation.height
                                DispatchQueue.main.async {
                                    self.offset = min(gestureOffset + lastOffset, maxHeight - self.bottomDrawerHeight)
                                }
                            })
                            .onEnded({ value in
                                withAnimation {
                                    if -offset > (maxHeight - self.bottomDrawerHeight) / 2 {
                                        offset = -(maxHeight - self.bottomDrawerHeight)
                                    } else {
                                        offset = 0
                                    }
                                }
                                self.lastOffset = offset
                            })
                    )
                )
            }
            .ignoresSafeArea(.all, edges: self.ignoreTopSafeAreas ? [.top, .bottom] : [.bottom])
        }
    }
}

struct BottomDrawerModifier<DrawerContent: View, PullUpView: View>: ViewModifier {
    var bottomDrawerHeight: CGFloat = 100
    var drawerTopCornerRadius: CGFloat = 32
    var ignoreTopSafeAreas: Bool = false
    var drawerContent: () -> DrawerContent
    var pullUpView: (_ shouldGoUp: Bool) -> PullUpView
    
    func body(content: Content) -> some View {
        BottomDrawerView(
            content: { content },
            drawerContent: drawerContent,
            pullUpView: pullUpView,
            bottomDrawerHeight: self.bottomDrawerHeight,
            drawerTopCornerRadius: self.drawerTopCornerRadius,
            ignoreTopSafeAreas: self.ignoreTopSafeAreas
        )
    }
}

extension View {
    func bottomDrawerView<DrawerContent: View, PullUpView: View>(
        bottomDrawerHeight: CGFloat = 100,
        drawerTopCornerRadius: CGFloat = 32,
        ignoreTopSafeAreas: Bool = false,
        @ViewBuilder drawerContent: @escaping () -> DrawerContent,
        @ViewBuilder pullUpView: @escaping (_ shouldGoUp: Bool) -> PullUpView
    ) -> some View {
        self.modifier(BottomDrawerModifier(
            bottomDrawerHeight: bottomDrawerHeight,
            drawerTopCornerRadius: drawerTopCornerRadius,
            ignoreTopSafeAreas: ignoreTopSafeAreas,
            drawerContent: drawerContent,
            pullUpView: pullUpView
        ))
    }
}
