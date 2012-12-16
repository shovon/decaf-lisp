Token = require './Token.coffee'
SyntaxError = require './SyntaxError.coffee'
compilerRegExp = require './compilerRegExp.coffee'
assert = require 'assert'

module.exports = class AnonymousToken extends Token
  types = [
    'STRING'
    'NUMBER'
    'IDENTIFIER'
    'OPENING'
    'CLOSING'
    'BOOL_TRUE'
    'BOOL_FALSE'
  ]

  @types: {}
  @_typesNum: {}

  for type, i in types
    @types[type] = i
    @_typesNum[i] = type

  constructor: (token) ->
    @lineNum = token.lineNum
    @columnNum = token.columnNum


    if not token.name?
      throw new Error "Fatal error: token does not have a name."

    identifierRegExp = new RegExp "^#{compilerRegExp.identifierStr}+$"
    stringRegExp = new RegExp "^#{compilerRegExp.stringStr}$"
    numberRegExp = /^[0-9]/

    if identifierRegExp.test token.name
      @type = AnonymousToken.types.IDENTIFIER
      @name = token.name
    else if stringRegExp.test token.name
      @type = AnonymousToken.types.STRING
      @value = token.name
    else if numberRegExp.test token.name
      @type = AnonymousToken.types.NUMBER
      @value = token.name
    else if token.name is 'true'
      @type = AnonymousToken.types.BOOL_TRUE
    else if token.name is 'false'
      @type = AnonymousToken.types.BOOL_FALSE
    else if token.name is '('
      @type = AnonymousToken.types.OPENING
    else if token.name is ')'
      @type = AnonymousToken.types.CLOSING
    else
      throw new SyntaxError token, "unknown token #{token.name}"

    assert AnonymousToken._typesNum[@type]?
