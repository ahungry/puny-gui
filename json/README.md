# JSON

A JSON module for janet. Encodes and Decodes JSON data and converts it
to and from Janet data structures. Strings are encoded as UTF-8, and UTF-16
escapes and surrogates as supported as per the JSON spec.

Json values are translated as follows:

- JSON array becomes Janet array
- JSON string becomes a Janet string.
- JSON Objects becomes a Janet table.
- JSON true and false become Janet booleans.
- JSON null becomes the keyword :null. This is because JSON supports null values in objects,
    while Janet does not support nil value or keys in tables.

## Building

To build the native module, use the `jpm tool`, which requires having janet installed.
Run

```
jpm build
```

To build the library.

## Testing

```
jpm test
```

## License

This module is licensed under the MIT/X11 License.
