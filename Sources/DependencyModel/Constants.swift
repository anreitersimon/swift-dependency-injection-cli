public enum Constants {
    public static let runtimeLibraryName = "DependencyInjection"

    public static let injectableProtocols: Set<String> = [
        "Injectable",
        "\(runtimeLibraryName).Injectable",
    ]

    public static let assistedAnnotations: Set<String> = [
        "@Assisted",
        "@\(runtimeLibraryName).Assisted",
        "@Assisted()",
        "@\(runtimeLibraryName).Assisted()",
    ]

    public static let injectAnnotations: Set<String> = [
        "@Inject",
        "@\(runtimeLibraryName).Inject",
        "@Inject()",
        "@\(runtimeLibraryName).Inject()",
    ]

    public static let allAnnotations =
        assistedAnnotations
        .union(injectAnnotations)
}
