public struct Import: Codable, Hashable, CustomStringConvertible {
    public let modifers: [String]
    public let attributes: [String]
    public let kind: TypeDeclaration.Kind?
    public let path: String

    
    public var description: String {
        var builder = ""
        
        for modifer in modifers {
            builder.append(modifer)
            builder.append(" ")
        }
        
        builder.append("import ")
        if let kind = kind {
            builder.append(kind.rawValue)
            builder.append(" ")
        }
        
        builder.append(path)
        
        return builder
    }
}
