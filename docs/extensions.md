# Extension Functions

## DateExtension (on `DateTime`)

**Source:** `lib/extensions/date_extensions.dart`

### `toWeekDayDate`

```dart
String get toWeekDayDate
```

Formats the DateTime as `"E, dd MMM hh:mm aaa"` (e.g. "Mon, 15 Jan 02:30 PM").

```dart
DateTime.now().toWeekDayDate; // "Mon, 15 Jan 02:30 PM"
```

### `toAPIDate`

```dart
String get toAPIDate
```

Formats the DateTime as `"yyyy-MM-dd"` for API requests.

```dart
DateTime(2025, 3, 15).toAPIDate; // "2025-03-15"
```

### `toAPIDateTime`

```dart
String get toAPIDateTime
```

Formats the DateTime as `"yyyy-MM-ddTHH:mm"` for API requests that need time.

```dart
DateTime(2025, 3, 15, 14, 30).toAPIDateTime; // "2025-03-15T14:30"
```

### `toDateTimeFormat`

```dart
String toDateTimeFormat(String format)
```

Formats the DateTime using a custom `DateFormat` pattern.

```dart
DateTime(2025, 3, 15).toDateTimeFormat('MMM d, HH:mm'); // "Mar 15, 00:00"
```

### `toRelativeTime`

```dart
String get toRelativeTime
```

Returns a human-readable relative time string. Handles both past and future dates.

| Condition | Output |
|---|---|
| Future, < 1 minute | `"Soon"` |
| Future, < 1 hour | `"in Xm"` |
| Future, < 1 day | `"in Xh"` |
| Future, >= 1 day | `"MMM d, HH:mm"` format |
| Past, < 1 minute | `"Just now"` |
| Past, < 1 hour | `"Xm ago"` |
| Past, < 1 day | `"Xh ago"` |
| Past, < 7 days | `"Xd ago"` |
| Past, >= 7 days | `"MMM d, HH:mm"` format |

```dart
DateTime.now().subtract(Duration(minutes: 4)).toRelativeTime; // "4m ago"
DateTime.now().add(Duration(minutes: 15)).toRelativeTime;     // "in 15m"
```

---

## StringDateExt (on `String`)

**Source:** `lib/extensions/date_extensions.dart`

### `toDate`

```dart
DateTime? get toDate
```

Parses a `"yyyy-MM-dd"` date string into a `DateTime`. Also handles `"today"` and `"now"` (returns `DateTime.now()`). Returns `null` on parse failure.

```dart
"2025-03-15".toDate;  // DateTime(2025, 3, 15)
"today".toDate;       // DateTime.now()
"invalid".toDate;     // null
```

### `toRelativeDateTime`

```dart
DateTime? get toRelativeDateTime
```

Parses relative time strings back into a `DateTime`. Supports `"just now"`, `"soon"`, future (`"in Xm"`, `"in Xh"`, `"in Xd"`), and past (`"Xm ago"`, `"Xh ago"`, `"Xd ago"`). Returns `null` if the string cannot be parsed.

```dart
"4m ago".toRelativeDateTime;  // DateTime ~4 minutes in the past
"in 15m".toRelativeDateTime;  // DateTime ~15 minutes in the future
"just now".toRelativeDateTime; // DateTime.now()
```

---

## MyStringExt (on `String`)

**Source:** `lib/text_view/text_view_extensions.dart`

### `interpolate`

```dart
String interpolate(Map<String, dynamic> row, {String listSeparator = ", ", String? defaultValue})
```

Template interpolation using `@field#` syntax. Replaces `@fieldName#` placeholders in the string with values from the provided map. Supports nested access with dot notation (`@parent.child#`) and list indexing (`@list.0.field#`).

```dart
"Hello @name#!".interpolate({"name": "Alice"}); // "Hello Alice!"
"@user.email#".interpolate({"user": {"email": "a@b.com"}}); // "a@b.com"
```

### `slug`

```dart
String get slug
```

Converts the string to a URL-friendly slug using underscores as delimiters.

```dart
"Hello World".slug; // "hello_world"
```

### `md5Hash`

```dart
String get md5Hash
```

Returns the MD5 hash of the string.

```dart
"hello".md5Hash; // "5d41402abc4b2a76b9719d911017c592"
```

### `capitalize`

```dart
String get capitalize
```

Capitalizes the first letter of the string, lowercases the rest.

```dart
"hello WORLD".capitalize; // "Hello world"
```

### `titleCase`

```dart
String get titleCase
```

Replaces underscores with spaces and capitalizes the first letter.

```dart
"first_name".titleCase; // "First name"
```

### `capitalizeEachWord`

```dart
String get capitalizeEachWord
```

Applies `titleCase` then capitalizes the first letter of each word.

```dart
"first_name".capitalizeEachWord; // "First Name"
```

### `toUrlNoSlash`

```dart
String toUrlNoSlash()
```

Strips a trailing slash from the string if present.

```dart
"https://api.example.com/users/".toUrlNoSlash(); // "https://api.example.com/users"
"https://api.example.com/users".toUrlNoSlash();  // "https://api.example.com/users"
```

### `toUrlWithSlash`

```dart
String toUrlWithSlash()
```

Ensures the string ends with a trailing slash.

```dart
"https://api.example.com/users".toUrlWithSlash();  // "https://api.example.com/users/"
"https://api.example.com/users/".toUrlWithSlash(); // "https://api.example.com/users/"
```

### `idFromUpdateUrl`

```dart
int? get idFromUpdateUrl
```

Extracts a numeric ID from the last segment of a URL path. Returns `null` if the last segment is not a valid integer.

```dart
"https://api.example.com/users/42/".idFromUpdateUrl; // 42
"https://api.example.com/users/".idFromUpdateUrl;    // null
```

---

## IntExtension (on `int`)

**Source:** `lib/nfc/utils.dart`

### `toHexString`

```dart
String toHexString()
```

Converts the integer to a hexadecimal string prefixed with `0x`, zero-padded to at least 2 hex digits, uppercase.

```dart
255.toHexString(); // "0xFF"
10.toHexString();  // "0x0A"
```
