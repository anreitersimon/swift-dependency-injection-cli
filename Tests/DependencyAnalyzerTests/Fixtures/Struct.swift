import Foundation

struct TestStruct: Injectable {}

struct TestStruct2: Injectable {
    @Inject var name: TestStruct
}

struct TestStruct3: Injectable {
    @Inject var name: TestStruct2
}
