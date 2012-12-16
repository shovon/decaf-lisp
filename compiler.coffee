Lazy = require 'lazy'
carrier = require 'carrier'
fs = require 'fs'
Token = require './Token.coffee'
TokenWithColumnNumber = require './TokenWithColumnNumber.coffee'
TokenWithLineNumber = require './TokenWithLineNumber.coffee'
TokensList = require './TokensList.coffee'
compilerRegExp = require './compilerRegExp.coffee'
AnonymousToken = require './AnonymousToken.coffee'

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
      unless token is ' '
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
