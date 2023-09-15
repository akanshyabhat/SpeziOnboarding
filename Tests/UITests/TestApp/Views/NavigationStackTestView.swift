//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SpeziViews
import SwiftUI


struct NavigationStackTestView: View {
    @EnvironmentObject private var path: OnboardingNavigationPath

    @State var paths = NavigationPath()


    var body: some View {
        let stack = NavigationStack(path: $paths) {
            VStack(spacing: 12) {
                Text("NavigationStack Test View")

                Button {
                    path.nextStep()
                } label: {
                    Text("Next")
                }
            }
        }

        mirror(stack: stack)
        stack
    }

    func mirror<Stack: View>(stack: Stack) -> EmptyView {
        for (label, child) in Mirror(reflecting: stack).children {
            print("NS: \(label): \(child)")
        }
        return EmptyView()
    }
}


#if DEBUG
struct NavigationStackTestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStackTestView()
    }
}
#endif
