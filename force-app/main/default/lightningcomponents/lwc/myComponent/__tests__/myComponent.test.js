// createElement is what we'll use to create our component under test
import { createElement } from 'lwc';

// Import module under test by convention <namespace>/<moduleName>
import LwcMyComponent from 'c/myComponent';

describe('myComponent', () => {
    it('displays expected header text', () => {
        const expectedText = 'Hello, Lightning web components';

        // Create an instance of the component under test
        const element = createElement('c-myComponent', { is: LwcMyComponent });

        // Add component to DOM (jsdom) so it renders, goes through creation lifecycle
        document.body.appendChild(element);

        // Find the header element we want to inspect
        const header = element.shadowRoot.querySelector('h1');

        // Compare the found text with the expected value
        expect(header.textContent).toBe(expectedText);

        // Available "expect" APIs can be found here: 
        // https://facebook.github.io/jest/docs/en/expect.html
    });
});