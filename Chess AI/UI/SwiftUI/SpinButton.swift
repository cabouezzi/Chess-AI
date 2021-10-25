//
//  CustomButton.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 8/1/21.
//

import SwiftUI

struct SpinButton: View {

    let image: Image?
    let title: String
    var action: () -> Void = {}
    
    var angularShift: Angle = .degrees(360)
    @State private var angle: Angle = .zero

    var body: some View {

        Button(action: {
            
            action()
            withAnimation (.easeInOut) {
                angle += angularShift
            }
            angle.degrees = angle.degrees.truncatingRemainder(dividingBy: 360)
            
        }, label: {
            
            VStack {

                image
                    .font(.system(.title))
                    .rotationEffect(angle)

                Text(title)
                    .fontWeight(.semibold)
                    .font(.system(.body))

            }

        })

    }

}
