Lazy = require 'lazy'
carrier = require 'carrier'
fs = require 'fs'
Token = require './Token.coffee'
TokenWithColumnNumber = require './TokenWithColumnNumber.coffee'
TokenWithLineNumber = require './TokenWithLineNumber.coffee'
TokensList = require './TokensList.coffee'
compilerRegExp = require './compilerRegExp.coffee'
SyntaxError = require './SyntaxError.coffee'
AnonymousToken = require './AnonymousToken.coffee'
Scope = require './Scope.coffee'
_ = require 'underscore'
assert = require 'assert'

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
      if not /^\s+$/.test token
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
    retval = []

    i = 0
    while i < tokens.length
      token = tokens[i]
      if token.type is AnonymousToken.types.OPENING
        [scope, j] = parseScope tokens.slice i + 1
        i += j + 1
        retval.push scope
      else if token.type is AnonymousToken.types.CLOSING
        return [retval, i]
      else
        retval.push token

      i++

    throw new SyntaxError tokens[i - 1], "unexpected end of code."

  retval = []

  i = 0
  while i < tokens._tokens.length
    token = tokens._tokens[i]
    if token.type isnt AnonymousToken.types.OPENING
      throw new SyntaxError token, "unexpected token"

    [scope, j] = parseScope tokens._tokens.slice i + 1
    i += j + 1
    retval.push scope

    i++

  return retval

###
Compiles a list of tokens into object code.
###
module.exports.compile = compile = (scopes) ->
  #throw new Error "Not yet implemented."
  parseScope = (scope) ->
    newScope = null

    if scope[0] instanceof AnonymousToken and
    scope[0].type is AnonymousToken.types.KEYWORD and
    scope[0].name is 'defun' or scope[0].name is 'lambda'
      offset = if scope[0].name is 'defun' then 1 else 0
      functionName = null

      if scope[0].name is 'defun'
        if scope[1].type isnt AnonymousToken.types.IDENTIFIER
          throw new SyntaxError scope[0], "expected a function name"

        functionName = scope[1].name

      if not _.isArray scope[1 + offset]
        throw new SyntaxError scope[1 + offset], "unexpected token #{AnonymousToken.getOriginal scope[1 + offset]}. Expecting '('"
      if not _.isArray scope[2 + offset]
        throw new SyntaxError scope[2 + offset], "unexpected token #{AnonymousToken.getOriginal scope[2 + offset]}"

      parameters = []

      parameterRegExp = /^[^0-9\-\+\\\*\(\)\[\]\{\}\/\,\.'"\!@\#%\^\&\=\?;\s]([^\-\+\\\*\(\)\[\]\{\}\/\,\.'"\!@\#%\^\&\=\?;\s]+)?$/
      for element in scope[1 + offset]
        if element.type isnt AnonymousToken.types.IDENTIFIER
          throw new SyntaxError element, "unexpected token #{AnonymousToken.getTypeName element.type}, #{AnonymousToken.getOriginal element}"

        if not parameterRegExp.test element.name
          throw new SyntaxError element, "illegal character in parameter name."

        parameters.push element.name

      scopeType = ''
      scopeType = Scope.types.FUNCTION_DEFINITION if scope[0].name is 'defun'
      scopeType = Scope.types.LAMBDA_EXPRESSION if scope[0].name is 'lambda'
      
      options = { parameters: parameters }

      if scopeType is Scope.types.FUNCTION_DEFINITION
        assert functionName
        options.functionName = functionName

      newScope = new Scope scopeType, options

      scope = scope.slice 2 + offset
    else
      newScope = new Scope Scope.types.EXPRESSION

    if newScope == null
      throw new Error "Unknown error."

    for element in scope
      if _.isArray element
        newScope.push parseScope element

      # TODO: error out if there is a keyword.
      else if element instanceof AnonymousToken
        newScope.push element

      else
        throw new Error "unknown error."

    return newScope

  objCode = new Scope Scope.types.EXPRESSION

  for scope in scopes
    if not _.isArray scope
      throw new Error "The scope is not an array."

    objCode.push parseScope scope

  return objCode

module.exports.link = (objectCode) ->
  functionsDefined = false
  codeOutput = ''

  outptuFunctionCall = (token) ->
    if not token.name?
      throw new Error "Token's name is not defined."
    return "func['token.name']"

  outputExpressions = (scope) ->
    retval = ''
    if scope.type is Scope.types.EXPRESSION
      for expression in scope.scopes
        if _.isArray(expression.scopes)
          retval += outputExpression expression
          retval += '('
          retval += "#{outputExpression }"
        else
          if not expression.name?
            throw new Error "A name is not defined for the expression."
          retval += "func['#{expression.name}']("
          retval += "#{outputExpression expression}"
          retval += ")"
    return retval

  outputFunction = (scope) ->
    functionBody = "function (#{scope.parameters.join ', '}) {\n"
    debugger
    functionBody = "  return #{outputExpressions scope.scopes};\n"
    functionBody = "};\n\n"

  for scope in objectCode.scopes
    if scope.type is Scope.types.FUNCTION_DEFINITION
      functionsDefined = true
      codeOutput = codeOutput + "func['#{scope.functionName}']"
      codeOutput = codeOutput + " = #{outputFunction scope}"

  return codeOutput