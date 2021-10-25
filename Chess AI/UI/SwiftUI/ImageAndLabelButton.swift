//
//  StaticButton.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/7/21.
//

import SwiftUI

struct ImageAndLabelButton: View {

    let image: Image?
    let title: String
    var action: () -> Void = {}

    var body: some View {

        Button(action: action) {
            
            VStack {

                image
                    .font(.system(.title))

                Text(title)
                    .fontWeight(.semibold)
                    .font(.system(.body))

            }

        }

    }

}
