@isTest
private class BarTests {
    @isTest
    static void getBarTests() {
        Bar b = new Bar();
        System.assertEquals('bar', Bar.getBar());
    }
}
