Lazy = require 'lazy'
carrier = require 'carrier'
fs = require 'fs'
Token = require './Token.coffee'
TokenWithColumnNumber = require './TokenWithColumnNumber.coffee'
TokenWithLineNumber = require './TokenWithLineNumber.coffee'
TokensList = require './TokensList.coffee'
compilerRegExp = require './compilerRegExp.coffee'
AnonymousToken = require './AnonymousToken.coffee'
SyntaxError = require './SyntaxError.coffee'
Scope = require './Scope.coffee'

###
This is only to split a single line of code. **Don't use this on multi-line
strings**.

@param string code, can be anything without any multi-lines.

@throws an error whenever code contains a new line character.

@returns an instance of `TokensList`

@seealso `split`
@seealso `TokensList.coffee`
###
module.exports.splitLine = splitLine = (code) ->
  if /(\r|\r)/.test code
    throw new Error "There should not be any new line characters in the code."

  tokens = code.match compilerRegExp.spacesAndChars

  retVal = []

  unless tokens is null
    charCount = 0
    for token in tokens
      if token is ';'
        break
      if token isnt ' '
        retVal.push(
          new TokenWithColumnNumber new Token(token), charCount
        )
      charCount += token.length

  return new TokensList retVal

###
This will split an entire string into appropriate tokens.
###
module.exports.split = split = (code) ->
  lines = code.split /\r?\n/

  tokensList = new TokensList

  for line, i in lines
    tokens = splitLine line
    tokens.convert (token) ->
      return new TokenWithLineNumber token, i
    tokensList.concatenate tokens

  return tokensList

###
Analyzes a list of tokens, and returns the tokens into anonymous tokens.

@returns TokensList with all the tokens converted into AnonymousToken
###
module.exports.analyze = analyze = (tokens) ->
  tokens.convert (token) ->
    return new AnonymousToken token

  return tokens

module.exports.scope = scope = (tokens) ->


  parseScope = (tokens) ->
    scopes = []

    i = 0
    while i < tokens.length
      token = tokens[i]

      if token.type is AnonymousToken.types.CLOSING
        return [scopes, i]
      else if token.type is AnonymousToken.types.OPENING
        [scope, j] = parseScope tokens.slice i + 1
        i += j
        scopes.push scope
      else
        scopes.push token

      i++

    throw new SyntaxError tokens[i - 1], "unexpected end of code."

  scopes = []

  i = 0
  while i < tokens._tokens.length
    token = tokens._tokens[i]
    if token.type isnt AnonymousToken.types.OPENING
      throw new SyntaxError token, "unexpected #{AnonymousToken.getOriginal token}. Expecting '('."

    [scope, j] = parseScope tokens._tokens.slice i + 1
    i += j + 1
    scopes.push scope

    i++

  return scopes

###
Compiles a list of tokens into object code.
###
module.exports.compile = compile = (tokens) ->
  thow new Error "Not yet implemented."
