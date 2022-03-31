/**
 * Allows you to define a tokenized string and pass an arbitrary number of arguments to replace the tokens.  Each
 * token must be unique, and must increment in the format {0}, {1}, etc.  Example usage:
 *
 *     const cls = 'my-class';
 *     const text = 'Some text';
 *     stringFormat('<div class="{0}">{1}</div>', cls, text); //'<div class="my-class">Some text</div>'
 *
 * @param {String} format The tokenized string to be formatted.
 * @param {...*} values The values to replace tokens `{0}`, `{1}`, etc in order.
 * @return {String} The formatted string.
 */
export function stringFormat(format, ...values) {
    return format.replace(/\{(\d+)\}/g, (match, g1) => {
        const sub = values[+g1];
        return sub === undefined ? match : sub;
    });
}