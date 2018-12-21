@isTest
private class FooTests {
    @isTest
    static void getFooTest() {
        System.assertEquals('foo', Foo.getFoo());
    }

    @isTest
    static void getBarTest() {
        System.assertEquals('foo', Foo.getBar());
    }
}
