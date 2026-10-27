// Generated from Design/assets/*.svg by Tools/generate_vectors.py.
// Edit the SVG masters, then regenerate. No raster art or WebView is used.
import SwiftUI

enum VectorRole { case body, tail, face, eyes }
struct VectorPart {
    let name: String
    let path: Path
    let white: Bool
    let stroke: CGFloat
    let role: VectorRole
}
enum CatPose: String {
    case idle, focus, rest, icon
    var parts: [VectorPart] {
        switch self {
        case .idle: MiloVectors.idle
        case .focus: MiloVectors.focus
        case .rest: MiloVectors.rest
        case .icon: MiloVectors.icon
        }
    }
    var tailAnchor: CGPoint {
        switch self {
        case .idle: .init(x: 330, y: 315)
        case .focus: .init(x: 340, y: 340)
        case .rest: .init(x: 370, y: 390)
        case .icon: .zero
        }
    }
}
enum MiloVectors {
    static let idle: [VectorPart] = [
        VectorPart(name: "tail", path: Path { p in
            p.move(to: .init(x: 325.320, y: 293.480))
            p.addCurve(to: .init(x: 430.180, y: 352.280), control1: .init(x: 377.750, y: 283.190), control2: .init(x: 414.010, y: 314.550))
            p.addCurve(to: .init(x: 395.390, y: 458.610), control1: .init(x: 447.820, y: 393.440), control2: .init(x: 433.120, y: 437.540))
            p.addCurve(to: .init(x: 261.130, y: 473.800), control1: .init(x: 363.050, y: 477.720), control2: .init(x: 310.620, y: 482.620))
            p.addCurve(to: .init(x: 226.830, y: 442.930), control1: .init(x: 235.160, y: 472.330), control2: .init(x: 218.010, y: 464.980))
            p.addCurve(to: .init(x: 277.300, y: 424.310), control1: .init(x: 235.160, y: 422.350), control2: .init(x: 251.820, y: 420.880))
            p.addCurve(to: .init(x: 376.280, y: 408.140), control1: .init(x: 318.460, y: 429.700), control2: .init(x: 353.250, y: 423.330))
            p.addCurve(to: .init(x: 360.110, y: 341.500), control1: .init(x: 404.210, y: 389.520), control2: .init(x: 393.920, y: 355.220))
            p.addLine(to: .init(x: 332.670, y: 333.660))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .tail),
        VectorPart(name: "body", path: Path { p in
            p.move(to: .init(x: 167.540, y: 277.800))
            p.addCurve(to: .init(x: 287.590, y: 268.490), control1: .init(x: 193.020, y: 258.690), control2: .init(x: 250.350, y: 260.160))
            p.addCurve(to: .init(x: 349.820, y: 325.820), control1: .init(x: 320.420, y: 275.350), control2: .init(x: 344.430, y: 294.460))
            p.addCurve(to: .init(x: 282.200, y: 401.280), control1: .init(x: 351.780, y: 361.100), control2: .init(x: 322.870, y: 393.930))
            p.addLine(to: .init(x: 255.740, y: 404.220))
            p.addCurve(to: .init(x: 210.660, y: 418.920), control1: .init(x: 247.900, y: 421.370), control2: .init(x: 226.340, y: 430.190))
            p.addCurve(to: .init(x: 203.310, y: 384.130), control1: .init(x: 198.410, y: 410.100), control2: .init(x: 199.880, y: 398.340))
            p.addCurve(to: .init(x: 152.840, y: 383.640), control1: .init(x: 187.140, y: 395.890), control2: .init(x: 167.050, y: 391.480))
            p.addCurve(to: .init(x: 137.650, y: 344.930), control1: .init(x: 137.160, y: 374.820), control2: .init(x: 130.790, y: 360.120))
            p.addCurve(to: .init(x: 154.800, y: 303.280), control1: .init(x: 145.000, y: 329.250), control2: .init(x: 156.270, y: 323.370))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .body),
        VectorPart(name: "head", path: Path { p in
            p.move(to: .init(x: 82.770, y: 199.890))
            p.addCurve(to: .init(x: 181.750, y: 45.540), control1: .init(x: 90.610, y: 139.130), control2: .init(x: 130.300, y: 82.780))
            p.addCurve(to: .init(x: 233.690, y: 28.390), control1: .init(x: 201.350, y: 31.820), control2: .init(x: 220.950, y: 22.020))
            p.addCurve(to: .init(x: 254.760, y: 74.450), control1: .init(x: 247.900, y: 35.740), control2: .init(x: 252.310, y: 54.850))
            p.addCurve(to: .init(x: 311.600, y: 104.340), control1: .init(x: 276.810, y: 79.350), control2: .init(x: 294.450, y: 93.560))
            p.addCurve(to: .init(x: 409.110, y: 133.250), control1: .init(x: 353.250, y: 103.850), control2: .init(x: 393.920, y: 111.690))
            p.addCurve(to: .init(x: 391.960, y: 208.220), control1: .init(x: 424.300, y: 151.870), control2: .init(x: 408.620, y: 184.210))
            p.addCurve(to: .init(x: 317.970, y: 276.820), control1: .init(x: 371.870, y: 237.620), control2: .init(x: 343.450, y: 259.180))
            p.addCurve(to: .init(x: 198.410, y: 312.590), control1: .init(x: 285.630, y: 299.850), control2: .init(x: 241.530, y: 315.040))
            p.addCurve(to: .init(x: 90.120, y: 249.870), control1: .init(x: 145.490, y: 309.650), control2: .init(x: 107.270, y: 282.700))
            p.addCurve(to: .init(x: 82.770, y: 199.890), control1: .init(x: 82.770, y: 236.150), control2: .init(x: 78.850, y: 217.040))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .face),
        VectorPart(name: "ear-inner", path: Path { p in
            p.move(to: .init(x: 353.250, y: 175.880))
            p.addCurve(to: .init(x: 407.150, y: 156.280), control1: .init(x: 372.360, y: 164.120), control2: .init(x: 392.450, y: 157.750))
            p.addCurve(to: .init(x: 347.370, y: 240.560), control1: .init(x: 406.660, y: 185.680), control2: .init(x: 376.280, y: 219.980))
            p.addCurve(to: .init(x: 353.250, y: 175.880), control1: .init(x: 350.310, y: 216.550), control2: .init(x: 353.250, y: 197.930))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .face),
        VectorPart(name: "eye-left", path: Path { p in
            p.move(to: .init(x: 182.611, y: 199.792))
            p.addCurve(to: .init(x: 121.312, y: 270.453), control1: .init(x: 175.753, y: 243.093), control2: .init(x: 148.308, y: 274.728))
            p.addCurve(to: .init(x: 84.849, y: 184.308), control1: .init(x: 94.316, y: 266.177), control2: .init(x: 77.991, y: 227.609))
            p.addCurve(to: .init(x: 146.148, y: 113.647), control1: .init(x: 91.707, y: 141.007), control2: .init(x: 119.152, y: 109.372))
            p.addCurve(to: .init(x: 182.611, y: 199.792), control1: .init(x: 173.144, y: 117.923), control2: .init(x: 189.469, y: 156.491))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .eyes),
        VectorPart(name: "eye-right", path: Path { p in
            p.move(to: .init(x: 324.028, y: 214.195))
            p.addCurve(to: .init(x: 271.924, y: 301.825), control1: .init(x: 330.801, y: 256.961), control2: .init(x: 307.474, y: 296.194))
            p.addCurve(to: .init(x: 195.292, y: 234.585), control1: .init(x: 236.375, y: 307.455), control2: .init(x: 202.066, y: 277.351))
            p.addCurve(to: .init(x: 247.396, y: 146.955), control1: .init(x: 188.519, y: 191.819), control2: .init(x: 211.846, y: 152.586))
            p.addCurve(to: .init(x: 324.028, y: 214.195), control1: .init(x: 282.945, y: 141.325), control2: .init(x: 317.254, y: 171.429))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .eyes),
        VectorPart(name: "pupil-left", path: Path { p in
            p.move(to: .init(x: 169.108, y: 195.562))
            p.addCurve(to: .init(x: 129.755, y: 240.429), control1: .init(x: 164.747, y: 223.093), control2: .init(x: 147.128, y: 243.180))
            p.addCurve(to: .init(x: 106.192, y: 185.598), control1: .init(x: 112.381, y: 237.677), control2: .init(x: 101.832, y: 213.128))
            p.addCurve(to: .init(x: 145.545, y: 140.731), control1: .init(x: 110.553, y: 158.067), control2: .init(x: 128.172, y: 137.980))
            p.addCurve(to: .init(x: 169.108, y: 195.562), control1: .init(x: 162.919, y: 143.483), control2: .init(x: 173.468, y: 168.032))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .eyes),
        VectorPart(name: "pupil-right", path: Path { p in
            p.move(to: .init(x: 304.227, y: 217.385))
            p.addCurve(to: .init(x: 271.445, y: 276.652), control1: .init(x: 308.842, y: 246.519), control2: .init(x: 294.165, y: 273.054))
            p.addCurve(to: .init(x: 221.953, y: 230.415), control1: .init(x: 248.726, y: 280.251), control2: .init(x: 226.567, y: 259.550))
            p.addCurve(to: .init(x: 254.735, y: 171.148), control1: .init(x: 217.338, y: 201.281), control2: .init(x: 232.015, y: 174.746))
            p.addCurve(to: .init(x: 304.227, y: 217.385), control1: .init(x: 277.454, y: 167.549), control2: .init(x: 299.613, y: 188.250))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .eyes)
    ]
    static let focus: [VectorPart] = [
        VectorPart(name: "tail", path: Path { p in
            p.move(to: .init(x: 332.640, y: 322.300))
            p.addCurve(to: .init(x: 453.860, y: 380.300), control1: .init(x: 389.480, y: 305.480), control2: .init(x: 435.880, y: 342.020))
            p.addCurve(to: .init(x: 449.800, y: 447.580), control1: .init(x: 466.620, y: 406.400), control2: .init(x: 463.140, y: 441.780))
            p.addCurve(to: .init(x: 411.520, y: 422.060), control1: .init(x: 432.400, y: 455.700), control2: .init(x: 412.680, y: 442.360))
            p.addCurve(to: .init(x: 368.600, y: 380.880), control1: .init(x: 409.780, y: 393.640), control2: .init(x: 394.120, y: 383.780))
            p.addLine(to: .init(x: 344.240, y: 386.100))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .tail),
        VectorPart(name: "body", path: Path { p in
            p.move(to: .init(x: 160.960, y: 300.840))
            p.addCurve(to: .init(x: 305.960, y: 297.360), control1: .init(x: 196.340, y: 280.540), control2: .init(x: 264.780, y: 283.440))
            p.addCurve(to: .init(x: 362.800, y: 373.340), control1: .init(x: 345.400, y: 310.120), control2: .init(x: 362.220, y: 341.440))
            p.addCurve(to: .init(x: 292.620, y: 438.300), control1: .init(x: 362.800, y: 408.720), control2: .init(x: 334.960, y: 430.180))
            p.addLine(to: .init(x: 256.660, y: 441.200))
            p.addCurve(to: .init(x: 206.200, y: 460.920), control1: .init(x: 247.960, y: 459.760), control2: .init(x: 224.760, y: 471.360))
            p.addCurve(to: .init(x: 188.220, y: 422.060), control1: .init(x: 190.540, y: 453.380), control2: .init(x: 185.900, y: 438.300))
            p.addCurve(to: .init(x: 139.500, y: 420.320), control1: .init(x: 171.980, y: 431.340), control2: .init(x: 153.420, y: 429.020))
            p.addCurve(to: .init(x: 132.540, y: 380.300), control1: .init(x: 125.580, y: 411.620), control2: .init(x: 124.420, y: 395.960))
            p.addCurve(to: .init(x: 144.720, y: 336.220), control1: .init(x: 142.980, y: 362.900), control2: .init(x: 145.880, y: 358.260))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .body),
        VectorPart(name: "head", path: Path { p in
            p.move(to: .init(x: 73.380, y: 213.260))
            p.addCurve(to: .init(x: 182.420, y: 52.600), control1: .init(x: 79.760, y: 152.360), control2: .init(x: 122.680, y: 94.360))
            p.addCurve(to: .init(x: 242.160, y: 38.680), control1: .init(x: 207.360, y: 35.200), control2: .init(x: 229.400, y: 26.500))
            p.addCurve(to: .init(x: 260.140, y: 85.080), control1: .init(x: 253.180, y: 49.700), control2: .init(x: 257.240, y: 65.360))
            p.addCurve(to: .init(x: 325.680, y: 112.920), control1: .init(x: 287.980, y: 87.400), control2: .init(x: 307.120, y: 100.740))
            p.addCurve(to: .init(x: 429.500, y: 142.500), control1: .init(x: 366.860, y: 112.920), control2: .init(x: 412.680, y: 118.720))
            p.addCurve(to: .init(x: 407.460, y: 222.540), control1: .init(x: 444.580, y: 163.380), control2: .init(x: 428.920, y: 194.700))
            p.addCurve(to: .init(x: 317.560, y: 298.520), control1: .init(x: 384.840, y: 254.440), control2: .init(x: 348.880, y: 279.380))
            p.addCurve(to: .init(x: 196.920, y: 337.380), control1: .init(x: 281.600, y: 321.140), control2: .init(x: 239.840, y: 339.120))
            p.addCurve(to: .init(x: 85.560, y: 282.280), control1: .init(x: 145.300, y: 335.640), control2: .init(x: 104.700, y: 314.180))
            p.addCurve(to: .init(x: 73.380, y: 213.260), control1: .init(x: 72.800, y: 260.820), control2: .init(x: 69.320, y: 236.460))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .face),
        VectorPart(name: "ear-inner", path: Path { p in
            p.move(to: .init(x: 368.020, y: 198.180))
            p.addCurve(to: .init(x: 427.760, y: 173.240), control1: .init(x: 388.900, y: 182.520), control2: .init(x: 409.200, y: 174.980))
            p.addCurve(to: .init(x: 362.800, y: 268.940), control1: .init(x: 426.020, y: 205.140), control2: .init(x: 395.280, y: 243.420))
            p.addCurve(to: .init(x: 368.020, y: 198.180), control1: .init(x: 367.440, y: 241.680), control2: .init(x: 369.180, y: 217.900))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .face),
        VectorPart(name: "eye-left", path: Path { p in
            p.move(to: .init(x: 90.200, y: 166.860))
            p.addCurve(to: .init(x: 78.020, y: 232.400), control1: .init(x: 81.500, y: 183.680), control2: .init(x: 75.700, y: 207.460))
            p.addCurve(to: .init(x: 119.200, y: 295.040), control1: .init(x: 79.180, y: 264.300), control2: .init(x: 95.420, y: 292.140))
            p.addCurve(to: .init(x: 174.300, y: 253.280), control1: .init(x: 141.820, y: 297.940), control2: .init(x: 162.120, y: 277.060))
            p.addLine(to: .init(x: 158.640, y: 239.940))
            p.addCurve(to: .init(x: 118.040, y: 260.820), control1: .init(x: 147.040, y: 261.400), control2: .init(x: 133.120, y: 270.100))
            p.addCurve(to: .init(x: 96.580, y: 207.460), control1: .init(x: 101.220, y: 250.380), control2: .init(x: 96.000, y: 228.920))
            p.addCurve(to: .init(x: 104.700, y: 177.880), control1: .init(x: 96.580, y: 197.020), control2: .init(x: 99.480, y: 186.000))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .eyes),
        VectorPart(name: "eye-right", path: Path { p in
            p.move(to: .init(x: 195.760, y: 265.460))
            p.addLine(to: .init(x: 224.180, y: 257.920))
            p.addCurve(to: .init(x: 257.820, y: 301.420), control1: .init(x: 227.660, y: 287.500), control2: .init(x: 238.680, y: 301.420))
            p.addCurve(to: .init(x: 312.920, y: 252.120), control1: .init(x: 286.820, y: 302.580), control2: .init(x: 306.540, y: 278.220))
            p.addCurve(to: .init(x: 312.920, y: 216.160), control1: .init(x: 316.400, y: 237.620), control2: .init(x: 315.240, y: 226.600))
            p.addCurve(to: .init(x: 334.380, y: 282.280), control1: .init(x: 330.900, y: 232.980), control2: .init(x: 338.440, y: 258.500))
            p.addCurve(to: .init(x: 277.540, y: 333.320), control1: .init(x: 328.000, y: 315.340), control2: .init(x: 305.960, y: 331.580))
            p.addCurve(to: .init(x: 195.760, y: 265.460), control1: .init(x: 234.620, y: 335.640), control2: .init(x: 206.200, y: 311.860))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .eyes)
    ]
    static let rest: [VectorPart] = [
        VectorPart(name: "tail", path: Path { p in
            p.move(to: .init(x: 365.150, y: 377.250))
            p.addCurve(to: .init(x: 456.950, y: 464.800), control1: .init(x: 406.800, y: 393.400), control2: .init(x: 434.850, y: 424.000))
            p.addCurve(to: .init(x: 495.200, y: 513.250), control1: .init(x: 468.000, y: 486.050), control2: .init(x: 479.900, y: 516.650))
            p.addCurve(to: .init(x: 487.550, y: 440.150), control1: .init(x: 517.300, y: 507.300), control2: .init(x: 503.700, y: 469.050))
            p.addCurve(to: .init(x: 405.950, y: 353.450), control1: .init(x: 466.300, y: 402.750), control2: .init(x: 434.850, y: 368.750))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .tail),
        VectorPart(name: "body", path: Path { p in
            p.move(to: .init(x: 214.700, y: 206.400))
            p.addCurve(to: .init(x: 349.850, y: 238.700), control1: .init(x: 258.900, y: 190.250), control2: .init(x: 312.450, y: 217.450))
            p.addCurve(to: .init(x: 429.750, y: 280.350), control1: .init(x: 381.300, y: 257.400), control2: .init(x: 410.200, y: 274.400))
            p.addCurve(to: .init(x: 485.850, y: 249.750), control1: .init(x: 445.900, y: 251.450), control2: .init(x: 465.450, y: 238.700))
            p.addCurve(to: .init(x: 485.000, y: 312.650), control1: .init(x: 508.800, y: 262.500), control2: .init(x: 502.000, y: 290.550))
            p.addLine(to: .init(x: 438.250, y: 367.050))
            p.addCurve(to: .init(x: 380.450, y: 394.250), control1: .init(x: 423.800, y: 384.050), control2: .init(x: 405.950, y: 394.250))
            p.addCurve(to: .init(x: 319.250, y: 430.800), control1: .init(x: 366.850, y: 427.400), control2: .init(x: 341.350, y: 444.400))
            p.addCurve(to: .init(x: 288.650, y: 390.850), control1: .init(x: 302.250, y: 420.600), control2: .init(x: 298.000, y: 403.600))
            p.addCurve(to: .init(x: 223.200, y: 309.250), control1: .init(x: 258.900, y: 367.900), control2: .init(x: 236.800, y: 333.050))
            p.addCurve(to: .init(x: 166.250, y: 304.150), control1: .init(x: 199.400, y: 322.000), control2: .init(x: 177.300, y: 317.750))
            p.addCurve(to: .init(x: 195.150, y: 258.250), control1: .init(x: 153.500, y: 287.150), control2: .init(x: 171.350, y: 265.900))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .body),
        VectorPart(name: "head", path: Path { p in
            p.move(to: .init(x: 57.450, y: 207.250))
            p.addCurve(to: .init(x: 150.950, y: 84.850), control1: .init(x: 66.800, y: 153.700), control2: .init(x: 104.200, y: 101.850))
            p.addCurve(to: .init(x: 279.300, y: 107.800), control1: .init(x: 195.150, y: 67.850), control2: .init(x: 247.850, y: 78.050))
            p.addCurve(to: .init(x: 307.350, y: 166.450), control1: .init(x: 296.300, y: 123.950), control2: .init(x: 304.800, y: 145.200))
            p.addCurve(to: .init(x: 339.650, y: 174.100), control1: .init(x: 321.800, y: 156.250), control2: .init(x: 335.400, y: 161.350))
            p.addCurve(to: .init(x: 330.300, y: 214.050), control1: .init(x: 345.600, y: 189.400), control2: .init(x: 336.250, y: 204.700))
            p.addCurve(to: .init(x: 327.750, y: 273.550), control1: .init(x: 345.600, y: 237.850), control2: .init(x: 347.300, y: 257.400))
            p.addCurve(to: .init(x: 228.300, y: 293.100), control1: .init(x: 301.400, y: 293.950), control2: .init(x: 264.000, y: 290.550))
            p.addLine(to: .init(x: 114.400, y: 316.050))
            p.addCurve(to: .init(x: 76.150, y: 297.350), control1: .init(x: 93.150, y: 320.300), control2: .init(x: 75.300, y: 311.800))
            p.addCurve(to: .init(x: 105.900, y: 274.400), control1: .init(x: 77.850, y: 282.900), control2: .init(x: 93.150, y: 276.950))
            p.addCurve(to: .init(x: 54.050, y: 282.050), control1: .init(x: 85.500, y: 283.750), control2: .init(x: 65.100, y: 290.550))
            p.addCurve(to: .init(x: 57.450, y: 237.850), control1: .init(x: 43.850, y: 274.400), control2: .init(x: 51.500, y: 252.300))
            p.addLine(to: .init(x: 49.800, y: 235.300))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .face),
        VectorPart(name: "ear-inner", path: Path { p in
            p.move(to: .init(x: 52.350, y: 259.950))
            p.addCurve(to: .init(x: 86.350, y: 258.250), control1: .init(x: 63.400, y: 251.450), control2: .init(x: 74.450, y: 252.300))
            p.addLine(to: .init(x: 104.200, y: 272.700))
            p.addCurve(to: .init(x: 54.900, y: 282.050), control1: .init(x: 82.950, y: 282.050), control2: .init(x: 66.800, y: 288.000))
            p.addCurve(to: .init(x: 52.350, y: 259.950), control1: .init(x: 49.800, y: 278.650), control2: .init(x: 48.950, y: 269.300))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .face),
        VectorPart(name: "eye-left", path: Path { p in
            p.move(to: .init(x: 165.682, y: 191.919))
            p.addCurve(to: .init(x: 100.241, y: 226.053), control1: .init(x: 152.698, y: 221.081), control2: .init(x: 123.399, y: 236.364))
            p.addCurve(to: .init(x: 81.818, y: 154.581), control1: .init(x: 77.082, y: 215.742), control2: .init(x: 68.834, y: 183.743))
            p.addCurve(to: .init(x: 147.259, y: 120.447), control1: .init(x: 94.802, y: 125.419), control2: .init(x: 124.101, y: 110.136))
            p.addCurve(to: .init(x: 165.682, y: 191.919), control1: .init(x: 170.418, y: 130.758), control2: .init(x: 178.666, y: 162.757))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .eyes),
        VectorPart(name: "eye-right", path: Path { p in
            p.move(to: .init(x: 277.575, y: 151.128))
            p.addCurve(to: .init(x: 208.379, y: 156.000), control1: .init(x: 265.635, y: 170.238), control2: .init(x: 234.655, y: 172.419))
            p.addCurve(to: .init(x: 182.425, y: 91.672), control1: .init(x: 182.104, y: 139.582), control2: .init(x: 170.484, y: 110.781))
            p.addCurve(to: .init(x: 251.621, y: 86.800), control1: .init(x: 194.365, y: 72.562), control2: .init(x: 225.345, y: 70.381))
            p.addCurve(to: .init(x: 277.575, y: 151.128), control1: .init(x: 277.896, y: 103.218), control2: .init(x: 289.516, y: 132.019))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .eyes),
        VectorPart(name: "pupil-left", path: Path { p in
            p.move(to: .init(x: 159.984, y: 185.883))
            p.addCurve(to: .init(x: 112.759, y: 210.449), control1: .init(x: 150.628, y: 206.897), control2: .init(x: 129.485, y: 217.896))
            p.addCurve(to: .init(x: 99.416, y: 158.917), control1: .init(x: 96.034, y: 203.003), control2: .init(x: 90.060, y: 179.931))
            p.addCurve(to: .init(x: 146.641, y: 134.351), control1: .init(x: 108.772, y: 137.903), control2: .init(x: 129.915, y: 126.904))
            p.addCurve(to: .init(x: 159.984, y: 185.883), control1: .init(x: 163.366, y: 141.797), control2: .init(x: 169.340, y: 164.869))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .eyes),
        VectorPart(name: "pupil-right", path: Path { p in
            p.move(to: .init(x: 267.409, y: 142.970))
            p.addCurve(to: .init(x: 218.935, y: 146.759), control1: .init(x: 258.951, y: 156.506), control2: .init(x: 237.248, y: 158.202))
            p.addCurve(to: .init(x: 201.091, y: 101.530), control1: .init(x: 200.622, y: 135.315), control2: .init(x: 192.633, y: 115.066))
            p.addCurve(to: .init(x: 249.565, y: 97.741), control1: .init(x: 209.549, y: 87.994), control2: .init(x: 231.252, y: 86.298))
            p.addCurve(to: .init(x: 267.409, y: 142.970), control1: .init(x: 267.878, y: 109.185), control2: .init(x: 275.867, y: 129.434))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .eyes),
        VectorPart(name: "mouth", path: Path { p in
            p.move(to: .init(x: 217.250, y: 205.550))
            p.addQuadCurve(to: .init(x: 226.600, y: 196.200), control: .init(x: 220.650, y: 198.750))
        }, white: true, stroke: 4.250, role: .face)
    ]
    static let icon: [VectorPart] = [
        VectorPart(name: "head", path: Path { p in
            p.move(to: .init(x: 124.000, y: 213.440))
            p.addCurve(to: .init(x: 90.560, y: 263.600), control1: .init(x: 118.720, y: 231.040), control2: .init(x: 102.000, y: 244.240))
            p.addCurve(to: .init(x: 110.800, y: 396.480), control1: .init(x: 63.280, y: 307.600), control2: .init(x: 74.720, y: 360.400))
            p.addCurve(to: .init(x: 208.480, y: 432.560), control1: .init(x: 135.440, y: 421.120), control2: .init(x: 163.600, y: 432.560))
            p.addLine(to: .init(x: 339.600, y: 432.560))
            p.addCurve(to: .init(x: 442.560, y: 385.040), control1: .init(x: 390.640, y: 432.560), control2: .init(x: 424.080, y: 415.840))
            p.addCurve(to: .init(x: 449.600, y: 281.200), control1: .init(x: 463.680, y: 351.600), control2: .init(x: 459.280, y: 312.880))
            p.addLine(to: .init(x: 470.720, y: 144.800))
            p.addCurve(to: .init(x: 436.400, y: 120.160), control1: .init(x: 475.120, y: 119.280), control2: .init(x: 455.760, y: 106.080))
            p.addLine(to: .init(x: 340.480, y: 188.800))
            p.addCurve(to: .init(x: 321.120, y: 194.960), control1: .init(x: 335.200, y: 193.200), control2: .init(x: 329.920, y: 194.960))
            p.addLine(to: .init(x: 292.960, y: 194.960))
            p.addCurve(to: .init(x: 267.440, y: 183.520), control1: .init(x: 280.640, y: 194.960), control2: .init(x: 274.480, y: 192.320))
            p.addLine(to: .init(x: 161.840, y: 59.440))
            p.addCurve(to: .init(x: 123.120, y: 62.080), control1: .init(x: 150.400, y: 45.360), control2: .init(x: 128.400, y: 41.840))
            p.addLine(to: .init(x: 120.480, y: 114.000))
            p.addCurve(to: .init(x: 136.320, y: 139.520), control1: .init(x: 118.720, y: 126.320), control2: .init(x: 122.240, y: 132.480))
            p.addCurve(to: .init(x: 126.640, y: 152.720), control1: .init(x: 143.360, y: 144.800), control2: .init(x: 134.560, y: 149.200))
            p.addCurve(to: .init(x: 127.520, y: 172.080), control1: .init(x: 116.080, y: 158.880), control2: .init(x: 116.080, y: 166.800))
            p.addCurve(to: .init(x: 126.640, y: 186.160), control1: .init(x: 135.440, y: 175.600), control2: .init(x: 134.560, y: 181.760))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .face),
        VectorPart(name: "body", path: Path { p in
            p.move(to: .init(x: 56.240, y: 353.360))
            p.addLine(to: .init(x: 42.160, y: 358.640))
            p.move(to: .init(x: 64.160, y: 385.920))
            p.addLine(to: .init(x: 32.480, y: 405.280))
            p.move(to: .init(x: 473.360, y: 353.360))
            p.addLine(to: .init(x: 486.560, y: 359.520))
            p.move(to: .init(x: 459.280, y: 387.680))
            p.addLine(to: .init(x: 492.720, y: 409.680))
        }, white: false, stroke: 17.600, role: .body),
        VectorPart(name: "eye-left", path: Path { p in
            p.move(to: .init(x: 241.920, y: 303.200))
            p.addCurve(to: .init(x: 174.160, y: 379.760), control1: .init(x: 241.920, y: 345.483), control2: .init(x: 211.583, y: 379.760))
            p.addCurve(to: .init(x: 106.400, y: 303.200), control1: .init(x: 136.737, y: 379.760), control2: .init(x: 106.400, y: 345.483))
            p.addCurve(to: .init(x: 174.160, y: 226.640), control1: .init(x: 106.400, y: 260.917), control2: .init(x: 136.737, y: 226.640))
            p.addCurve(to: .init(x: 241.920, y: 303.200), control1: .init(x: 211.583, y: 226.640), control2: .init(x: 241.920, y: 260.917))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .eyes),
        VectorPart(name: "eye-right", path: Path { p in
            p.move(to: .init(x: 427.600, y: 304.960))
            p.addCurve(to: .init(x: 359.840, y: 381.520), control1: .init(x: 427.600, y: 347.243), control2: .init(x: 397.263, y: 381.520))
            p.addCurve(to: .init(x: 292.080, y: 304.960), control1: .init(x: 322.417, y: 381.520), control2: .init(x: 292.080, y: 347.243))
            p.addCurve(to: .init(x: 359.840, y: 228.400), control1: .init(x: 292.080, y: 262.677), control2: .init(x: 322.417, y: 228.400))
            p.addCurve(to: .init(x: 427.600, y: 304.960), control1: .init(x: 397.263, y: 228.400), control2: .init(x: 427.600, y: 262.677))
            p.closeSubpath()
        }, white: true, stroke: 0.000, role: .eyes),
        VectorPart(name: "pupil-left", path: Path { p in
            p.move(to: .init(x: 220.800, y: 305.840))
            p.addCurve(to: .init(x: 194.400, y: 348.960), control1: .init(x: 220.800, y: 329.655), control2: .init(x: 208.980, y: 348.960))
            p.addCurve(to: .init(x: 168.000, y: 305.840), control1: .init(x: 179.820, y: 348.960), control2: .init(x: 168.000, y: 329.655))
            p.addCurve(to: .init(x: 194.400, y: 262.720), control1: .init(x: 168.000, y: 282.025), control2: .init(x: 179.820, y: 262.720))
            p.addCurve(to: .init(x: 220.800, y: 305.840), control1: .init(x: 208.980, y: 262.720), control2: .init(x: 220.800, y: 282.025))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .eyes),
        VectorPart(name: "pupil-right", path: Path { p in
            p.move(to: .init(x: 364.240, y: 306.720))
            p.addCurve(to: .init(x: 337.840, y: 349.840), control1: .init(x: 364.240, y: 330.535), control2: .init(x: 352.420, y: 349.840))
            p.addCurve(to: .init(x: 311.440, y: 306.720), control1: .init(x: 323.260, y: 349.840), control2: .init(x: 311.440, y: 330.535))
            p.addCurve(to: .init(x: 337.840, y: 263.600), control1: .init(x: 311.440, y: 282.905), control2: .init(x: 323.260, y: 263.600))
            p.addCurve(to: .init(x: 364.240, y: 306.720), control1: .init(x: 352.420, y: 263.600), control2: .init(x: 364.240, y: 282.905))
            p.closeSubpath()
        }, white: false, stroke: 0.000, role: .eyes)
    ]
}
