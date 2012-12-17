TokenWithColumnNumber = require './TokenWithColumnNumber.coffee'

module.exports = class TokenWithLineNumber extends TokenWithColumnNumber
  constructor: (token, @lineNum) ->
    super(token, token.columnNum)