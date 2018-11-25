@isTest
private class FooTests {
    @isTest
    static void getFooTest() {
        System.assertEquals('foo', Foo.getFoo());
    }
}
