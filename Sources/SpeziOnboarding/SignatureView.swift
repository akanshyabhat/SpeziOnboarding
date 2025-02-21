//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PencilKit
import SpeziViews
import SwiftUI


/// Input freeform signatures using a finger or the Apple Pencil.
///
/// Use SwiftUI `Bindings` to obtain information like the content of the signature and if the user is currently signing:
/// ```swift
/// @State var signature = PKDrawing()
/// @State var isSigning = false
/// 
///
/// SignatureView(
///     signature: $signature,
///     isSigning: $isSigning,
///     name: name
/// )
/// ```
public struct SignatureView: View {
    @Environment(\.undoManager) private var undoManager
    @Binding private var signature: PKDrawing
    @Binding private var isSigning: Bool
    @Binding private var canvasSize: CGSize
    @State private var canUndo = false
    private let name: PersonNameComponents
    private let lineOffset: CGFloat
    
    
    public var body: some View {
        VStack {
            ZStack(alignment: .bottomLeading) {
                SignatureViewBackground(name: name, lineOffset: lineOffset)

                CanvasView(drawing: $signature, isDrawing: $isSigning, showToolPicker: .constant(false))
                    .accessibilityLabel(Text("SIGNATURE_FIELD", bundle: .module))
                    .accessibilityAddTraits(.allowsDirectInteraction)
                    .onPreferenceChange(CanvasView.CanvasSizePreferenceKey.self) { size in
                        // for some reason, the preference won't update on visionOS if placed in a parent view
                        self.canvasSize = size
                    }
            }
                .frame(height: 120)
            Button(
                action: {
                    undoManager?.undo()
                    canUndo = undoManager?.canUndo ?? false
                },
                label: {
                    Text("SIGNATURE_VIEW_UNDO", bundle: .module)
                }
            )
                .disabled(!canUndo)
        }
            .onChange(of: isSigning) {
                Task { @MainActor in
                    canUndo = undoManager?.canUndo ?? false
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: canUndo)
    }
    
    
    /// Creates a new instance of an ``SignatureView``.
    /// - Parameters:
    ///   - signature: A `Binding` containing the current signature as an `PKDrawing`.
    ///   - isSigning: A `Binding` indicating if the user is currently signing.
    ///   - canvasSize: The size of the canvas as a Binding.
    ///   - name: The name that is displayed under the signature line.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    init(
        signature: Binding<PKDrawing> = .constant(PKDrawing()),
        isSigning: Binding<Bool> = .constant(false),
        canvasSize: Binding<CGSize> = .constant(.zero),
        name: PersonNameComponents = PersonNameComponents(),
        lineOffset: CGFloat = 30
    ) {
        self._signature = signature
        self._isSigning = isSigning
        self._canvasSize = canvasSize
        self.name = name
        self.lineOffset = lineOffset
    }
}


#if DEBUG
struct SignatureView_Previews: PreviewProvider {
    static var previews: some View {
        SignatureView()

        SignatureView(name: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))
    }
}
#endif
