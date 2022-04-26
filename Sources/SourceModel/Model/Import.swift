public struct Import: Codable, Hashable {
    public let modifers: [String]
    public let attributes: [String]
    public let kind: TypeDeclaration.Kind?
    public let path: String

}
