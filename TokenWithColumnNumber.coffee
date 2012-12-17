Token = require './Token.coffee'

module.exports = class TokenWithColumnNumber extends Token
  constructor: (token, @columnNum) ->
    super(token.name)