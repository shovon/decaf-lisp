SyntaxError = require './SyntaxError.coffee'
Token = require './Token.coffee'
compilerRegExp = require './compilerRegExp.coffee'
decafLisp = require './decaf-lisp.coffee'
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
    'KEYWORD'
  ]

  @types: {}
  @_typesNum: {}

  for type in types
    @types[type] = type

  @getTypeName: (type) ->
    if type is AnonymousToken.types.OPENING
      return 'opening brace'
    else if type is AnonymousToken.types.CLOSING
      return 'closing brace'
    else if type is AnonymousToken.types.BOOL_TRUE or
    type is AnonymousToken.types.BOOL_FALSE
      return 'boolean'
    
    return type.toLowerCase()

  @getOriginal: (token) ->
    if not token instanceof AnonymousToken
      throw new Error "token must be an instance of AnonymousToken"

    if not @types[token.type]?
      throw new Error "Invalid token type."

    if token.type is @types.STRING or token.type is @types.NUMBER
      return token.value
    else if token.type is @types.IDENTIFIER or token.type is @types.KEYWORD
      return token.name
    else if token.type is @types.OPENING
      return '('
    else if token.type is @types.CLOSING
      return ')'
    else if token.type is @types.BOOL_TRUE
      return 'true'
    else if token.type is @types.BOOL_FALSE
      return 'false'

    assert false

  @isConstant: (token) ->
    return (token.type is AnonymousToken.types.STRING or
      token.type is AnonymousToken.types.NUMBER or
      token.type is AnonymousToken.types.BOOL_FALSE or
      token.type is AnonymousToken.types.BOOL_TRUE)


  constructor: (token) ->
    @lineNum = token.lineNum
    @columnNum = token.columnNum

    if not token.name?
      throw new Error "Fatal error: token does not have a name."

    identifierRegExp = new RegExp "^#{compilerRegExp.identifierStr}+$"
    stringRegExp = new RegExp "^#{compilerRegExp.stringStr}$"
    numberRegExp = /^[0-9]/

    if decafLisp.keywords[token.name]?
      @type = AnonymousToken.types.KEYWORD
      @name = token.name
    else if token.name is 'true'
      @type = AnonymousToken.types.BOOL_TRUE
    else if token.name is 'false'
      @type = AnonymousToken.types.BOOL_FALSE
    else if numberRegExp.test token.name
      @type = AnonymousToken.types.NUMBER
      @value = token.name
    else if identifierRegExp.test token.name
      @type = AnonymousToken.types.IDENTIFIER
      @name = token.name
    else if stringRegExp.test token.name
      @type = AnonymousToken.types.STRING
      @value = token.name
    else if token.name is '('
      @type = AnonymousToken.types.OPENING
    else if token.name is ')'
      @type = AnonymousToken.types.CLOSING
    else
      throw new SyntaxError token, "unknown token #{token.name}"

    assert AnonymousToken.types[@type]?
