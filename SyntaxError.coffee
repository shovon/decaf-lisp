module.exports = class SyntaxError extends Error
  constructor: (token, message = '') ->
    err = Error.call this, "Error on line #{token.lineNum + 1}, column #{token.columnNum + 1}: #{message}"
    err.name = "SyntaxError"
    return err
