// swift-tools-version: 5.9
import PackageDescription

// sukashi デザインシステムの SwiftUI 版。
// Web 版(sukashi.css)と同じ憲法・トークンを SwiftUI ネイティブへ転写したもの。
// 他プロジェクトからは `import Sukashi` で利用する。
let package = Package(
    name: "Sukashi",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "Sukashi", targets: ["Sukashi"])
    ],
    targets: [
        .target(name: "Sukashi")
    ]
)
