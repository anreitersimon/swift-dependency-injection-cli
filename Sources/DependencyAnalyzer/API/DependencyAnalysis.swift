import SourceModel
import DependencyModel
import Foundation

public enum DependencyAnalysis {

    public static func extractDependencyGraph(
        file: URL,
        moduleName: String
    ) throws -> DependencyGraph {
        let sourceFile = try SourceFile.parse(module: moduleName, file: file)

        // TODO:
        
        return DependencyGraph()
    }
}
