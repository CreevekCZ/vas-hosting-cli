import XCTest
@testable import VashKit
import Foundation

final class OutputFormatterTests: XCTestCase {

    func testPrintTableFormatsCorrectly() {
        // Capture stdout
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        OutputFormatter.printTable(
            headers: ["NAME", "VALUE"],
            rows: [["hello", "world"], ["foo", "bar"]]
        )

        fflush(stdout)
        dup2(original, STDOUT_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertTrue(output.contains("NAME"))
        XCTAssertTrue(output.contains("VALUE"))
        XCTAssertTrue(output.contains("hello"))
        XCTAssertTrue(output.contains("world"))
        XCTAssertTrue(output.contains("foo"))
        XCTAssertTrue(output.contains("bar"))
    }

    func testPrintTableWithEmptyRowsShowsNoResults() {
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        OutputFormatter.printTable(headers: ["A", "B"], rows: [])

        fflush(stdout)
        dup2(original, STDOUT_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(output.contains("No results"))
    }

    func testPrintJSONEncodesCorrectly() {
        struct TestModel: Encodable {
            let name: String
            let value: Int
        }

        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        OutputFormatter.printJSON(TestModel(name: "test", value: 42))

        fflush(stdout)
        dup2(original, STDOUT_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertTrue(output.contains("\"name\""))
        XCTAssertTrue(output.contains("\"test\""))
        XCTAssertTrue(output.contains("42"))
    }

    func testPrintSuccessTableFormat() {
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        OutputFormatter.printSuccess("Operation completed.", format: .table)

        fflush(stdout)
        dup2(original, STDOUT_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(output.contains("Operation completed."))
    }

    func testPrintSuccessJSONFormat() {
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        OutputFormatter.printSuccess("Ignored.", format: .json)

        fflush(stdout)
        dup2(original, STDOUT_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(output.contains("success"))
    }

    func testPrintErrorTableFormatWritesPlainTextToStderr() {
        let pipe = Pipe()
        let original = dup(STDERR_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

        let error = VashError.apiError("something went wrong")
        OutputFormatter.printError(error, format: .table)

        fflush(stderr)
        dup2(original, STDERR_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(output.contains("Error:"))
        XCTAssertTrue(output.contains("something went wrong"))
    }

    func testPrintErrorJSONFormatWritesJSONToStderr() {
        let pipe = Pipe()
        let original = dup(STDERR_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

        let error = VashError.unauthorized("Bad API key")
        OutputFormatter.printError(error, format: .json)

        fflush(stderr)
        dup2(original, STDERR_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(output.contains("\"error\""))
        XCTAssertTrue(output.contains("Bad API key"))
        XCTAssertTrue(output.contains("\"code\""))
        XCTAssertTrue(output.contains("unauthorized"))
    }

    func testPrintErrorJSONEscapesQuotes() {
        let pipe = Pipe()
        let original = dup(STDERR_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

        let error = VashError.apiError("message with \"quotes\"")
        OutputFormatter.printError(error, format: .json)

        fflush(stderr)
        dup2(original, STDERR_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        XCTAssertFalse(output.contains("\"message with \"quotes\"\""))
        XCTAssertTrue(output.contains("\\\"quotes\\\""))
    }
}
