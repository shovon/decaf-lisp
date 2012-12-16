class module.exports.SyntaxError extends Error
  constructor: (token, message = '') ->
    super "Error on line #{token.line}, column #{token.column + 1}: #{message}"
