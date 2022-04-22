@resultBuilder
public enum TextBuilder {
    public typealias Element = Writable
    public typealias Component = [Writable]
    public typealias Result = Writable

    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }

    public static func buildFinalResult(_ component: Component) -> Result {
        CompositeWritable(elements: component, endLines: false)
    }

    public static func buildExpression(_ expression: String) -> Component {
        [Line(text: expression)]
    }

    public static func buildExpression(_ expression: Writable) -> Component {
        [expression]
    }

    public static func buildEither(first component: TextBuilder.Component) -> TextBuilder.Component
    {
        return component
    }

    public static func buildEither(second component: TextBuilder.Component) -> TextBuilder.Component
    {
        return component
    }
    
    public static func buildOptional(_ component: TextBuilder.Component?) -> TextBuilder.Component {
        return component ?? []
    }

    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }
}
