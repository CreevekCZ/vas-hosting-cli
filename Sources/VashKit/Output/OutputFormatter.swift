import Foundation
import ArgumentParser

public enum OutputFormat: String, CaseIterable, ExpressibleByArgument {
    case table
    case json
}

public enum OutputFormatter {
    public static func printTable(headers: [String], rows: [[String]]) {
        if rows.isEmpty {
            Swift.print("No results.")
            return
        }
        var widths = headers.map { $0.count }
        for row in rows {
            for (i, cell) in row.enumerated() where i < widths.count {
                widths[i] = max(widths[i], cell.count)
            }
        }
        let separator = widths.map { String(repeating: "-", count: $0 + 2) }.joined(separator: "+")
        let headerLine = headers.enumerated().map { i, h in
            " " + h.padding(toLength: widths[i], withPad: " ", startingAt: 0) + " "
        }.joined(separator: "|")

        Swift.print(separator)
        Swift.print(headerLine)
        Swift.print(separator)
        for row in rows {
            let line = row.enumerated().map { i, cell in
                let w = i < widths.count ? widths[i] : cell.count
                return " " + cell.padding(toLength: w, withPad: " ", startingAt: 0) + " "
            }.joined(separator: "|")
            Swift.print(line)
        }
        Swift.print(separator)
    }

    public static func printJSON<T: Encodable>(_ value: T, encoder: JSONEncoder? = nil) {
        let enc = encoder ?? {
            let e = JSONEncoder()
            e.outputFormatting = [.prettyPrinted, .sortedKeys]
            return e
        }()
        if let data = try? enc.encode(value),
           let str = String(data: data, encoding: .utf8) {
            Swift.print(str)
        }
    }

    public static func printSuccess(_ message: String = "Done.", format: OutputFormat) {
        switch format {
        case .table:
            Swift.print(message)
        case .json:
            Swift.print(#"{"status":"success"}"#)
        }
    }

    public static func printError(_ message: String) {
        fputs("Error: \(message)\n", stderr)
    }

    public static func printError(_ error: Error, format: OutputFormat) {
        switch format {
        case .table:
            fputs("Error: \(error.localizedDescription)\n", stderr)
        case .json:
            let message = error.localizedDescription
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            let code: String
            if let vashError = error as? VashError {
                code = vashError.errorCode
            } else {
                code = "unknown"
            }
            fputs("{\"error\":\"\(message)\",\"code\":\"\(code)\"}\n", stderr)
        }
    }
}
