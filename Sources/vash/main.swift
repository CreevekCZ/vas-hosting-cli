import VashKit
import Foundation
import ArgumentParser

// Run the CLI asynchronously using a Task + DispatchSemaphore.
let sema = DispatchSemaphore(value: 0)
Task {
    do {
        var command = try VashCommand.parseAsRoot()
        if var asyncCommand = command as? any AsyncParsableCommand {
            try await asyncCommand.run()
        } else {
            try command.run()
        }
    } catch {
        // For --help, --version, and completion requests ArgumentParser uses a clean exit code.
        // Delegate those back to ArgumentParser so it can print the correct output.
        let exitCode = VashCommand.exitCode(for: error)
        if exitCode == .success {
            VashCommand.exit(withError: error)
        }

        // For real errors, detect --format json from raw argv and emit structured output.
        let args = CommandLine.arguments
        let isJSON = zip(args, args.dropFirst()).contains(where: { $0 == "--format" && $1 == "json" })
            || args.contains("--format=json")
        let format: OutputFormat = isJSON ? .json : .table
        OutputFormatter.printError(error, format: format)
        exit(exitCode.rawValue)
    }
    sema.signal()
}
sema.wait()
