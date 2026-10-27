import CoreGraphics
import XCTest
@testable import MiloCore

final class GenieGeometryTests: XCTestCase {
    func testExpandedPanelMatchesItsOriginalBounds() {
        let body = CGRect(x: 8, y: 0, width: 420, height: 224)
        let anchor = CGPoint(x: 310, y: 246)
        for row in 0...100 {
            let fraction = CGFloat(row) / 100
            let section = GenieGeometry.section(at: fraction, progress: 0, body: body, anchor: anchor)
            XCTAssertEqual(section.left, body.minX, accuracy: 0.0001)
            XCTAssertEqual(section.right, body.maxX, accuracy: 0.0001)
            XCTAssertEqual(section.y, body.height * fraction, accuracy: 0.0001)
        }
    }

    func testEveryRowConvergesOnAnOffCenterMenuIcon() {
        let body = CGRect(x: 8, y: 0, width: 352, height: 544)
        for anchorX: CGFloat in [30, 180, 340] {
            let anchor = CGPoint(x: anchorX, y: 566)
            for row in 0...100 {
                let section = GenieGeometry.section(at: CGFloat(row) / 100, progress: 1, body: body, anchor: anchor)
                XCTAssertEqual(section.left, anchor.x, accuracy: 0.0001)
                XCTAssertEqual(section.right, anchor.x, accuracy: 0.0001)
                XCTAssertEqual(section.y, anchor.y, accuracy: 0.0001)
            }
        }
    }

    func testSheetNeverFoldsOrEscapesTheWindowDuringEitherPanelSize() {
        for size in [CGSize(width: 420, height: 224), CGSize(width: 352, height: 594)] {
            let body = CGRect(origin: CGPoint(x: 8, y: 0), size: size)
            let anchor = CGPoint(x: size.width - 18, y: size.height + 22)
            for frame in 0...100 {
                let progress = CGFloat(frame) / 100
                var previousY: CGFloat = -1
                for row in 0...100 {
                    let section = GenieGeometry.section(at: CGFloat(row) / 100, progress: progress, body: body, anchor: anchor)
                    XCTAssertTrue(section.left.isFinite && section.right.isFinite && section.y.isFinite)
                    XCTAssertGreaterThanOrEqual(section.y + 0.0001, previousY)
                    XCTAssertGreaterThanOrEqual(section.left, body.minX - 0.0001)
                    XCTAssertLessThanOrEqual(section.right, body.maxX + 0.0001)
                    XCTAssertGreaterThanOrEqual(section.width, 0)
                    XCTAssertLessThanOrEqual(section.y, anchor.y + 0.0001)
                    previousY = section.y
                }
            }
        }
    }

    func testNearEdgeFormsANeckBeforeTheFarEdgeMoves() {
        let body = CGRect(x: 8, y: 0, width: 420, height: 224)
        let anchor = CGPoint(x: 218, y: 246)
        let top = GenieGeometry.section(at: 1, progress: 0.30, body: body, anchor: anchor)
        let bottom = GenieGeometry.section(at: 0, progress: 0.30, body: body, anchor: anchor)
        XCTAssertLessThan(top.width, bottom.width * 0.7)
        XCTAssertEqual(bottom.width, body.width)
        XCTAssertEqual(bottom.y, body.minY)
        XCTAssertGreaterThan(top.y, body.maxY)
    }
}
