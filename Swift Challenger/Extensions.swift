//
//  Extensions.swift
//  Swift Challenger
//
//  Created by 64005831 on 2/12/24.
//

import Foundation
import RealityKit
import SwiftUI

extension simd_float4x4 {
    var translation: SIMD3<Float> {
        get {
            return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
        }
        set (newValue) {
            columns.3.x = newValue.x
            columns.3.y = newValue.y
            columns.3.z = newValue.z
        }
    }
}

