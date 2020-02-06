# unicodeCategory

Efficient [Unicode General Category](https://en.wikipedia.org/wiki/Template:General_Category_(Unicode)) validation.

## Usage

```as3
import org.unicode.utils.UnicodeCategory

const category = UnicodeCategory.fromString('👧')
trace('U+1F467 = So =', category === UnicodeCategory.OTHER_SYMBOL)

// Verify Letter category
trace(UnicodeCategory.isLetter(UnicodeCategory.fromString('Ë')))
```

## Credits

Copyright © 2017 @Hydroper