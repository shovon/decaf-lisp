module.exports.stringStr = stringStr = "(" +
  "'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'" +
  '|"[^"\\\\]*(?:\\\\.[^"\\\\]*)*"' +
")"

module.exports.identifierStr = identifierStr = "[a-zA-Z0-9\\+><\\-_]"

module.exports.spacesAndChars = spaceAndCarsRegExp = new RegExp(
  "\\s+" +
  "|\\(" +
  "|\\)" +
  "|;" +
  "|(" +
    identifierStr +
    "|" + stringStr +
  ")+" +
  "|."
, "g")
