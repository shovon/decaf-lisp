Token = require './Token.coffee'

module.exports = class TokensList
  constructor: (tokens) ->
    if tokens?
      @setAll tokens

  concatenate: (tokens) ->
    if @_tokens?
      @_tokens = @_tokens.concat tokens._tokens
    else
      @_tokens = tokens._tokens

  setAll: (tokens) ->
    tokens.forEach (token) ->
      if not token instanceof Token
        throw new Error "A token in the list is not an instance of Token."

    @_tokens = tokens

  convert: (cb) ->
    @_tokens = @_tokens.map (token) ->
      newToken = cb token
      if not newToken instanceof Token
        throw new Error "A token in the list is not an instance of Token."
      return newToken