AnonymousToken = require './AnonymousToken.coffee'

module.exports = class SyntaxError extends Error
  constructor: (token, message = '') ->
    if not token instanceof AnonymousToken
      return new Error "unknown error"
    err = Error.call this, "Error on line #{token.lineNum + 1}, column #{token.columnNum + 1}: #{message}"
    err.name = "SyntaxError"
    return err
