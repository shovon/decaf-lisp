Lazy = require 'lazy'
carrier = require 'carrier'
fs = require 'fs'

stringRegExp = "(" +
  "'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'" +
  '|"[^"\\\\]*(?:\\\\.[^"\\\\]*)*"' +
")"

identifierRegExp = "[a-zA-Z0-9\\+><\\-_]"

class SyntaxError extends Error
  initialize: (token, message = '') ->
    super "Error on line #{token.line}, column #{token.column + 1}: #{message}"

LexicalAnalyzer = class module.exports.LexicalAnalyzer
  @tokenizeLine: (line) ->

    spacesAndChars = line.match new RegExp(
      "\\s+" +
      "|\\(" +
      "|\\)" +
      "|;" +
      "|(" +
        identifierRegExp +
        "|" + stringRegExp +
      ")+" +
      "|."
    , "g")

    tokens = []

    charCount = 0
    unless spacesAndChars == null
      for word in spacesAndChars
        if word[0] isnt ' '
          if word[0] is ';'
            break
          tokens.push
            token: word
            column: charCount

        charCount += word.length

    return tokens

  @analyze: (filename, callback) ->
    lineCount = 0

    retVal = []

    carryInfo = carrier.carry (fs.createReadStream filename), (line) ->
      lineCount++
      tokens = LexicalAnalyzer.tokenizeLine line
      for token in tokens
        token.line = lineCount
        retVal.push token

    carryInfo.on 'end', ->
      callback null, retVal

  @compile: (tokens) ->
    compiledTokens = []

    interpretParams = (tokens) ->
      retVal = []

      i = 0
      while i < tokens.length
        token = tokens[i]
        if token.token is ')'
          return [retVal, i]
        else if token.token is '('
          throw new Error "Error on line #{token.line}, column #{token.column + 1}: unexpected '('"
        else if /^[a-zA-Z]([a-zA-Z0-9]+)?/.test token.token
          retVal.push token.token
        else
          #console.log "Hmm..."
          throw new Error "Error on line #{token.line}, column #{token.column + 1}: unexpected '#{token.token}'"

        i++

      throw new Error "Unexpected end of code"

    interpretCall = (tokens) ->
      retVal = []

      i = 0
      while i < tokens.length
        token = tokens[i]
        if token.token is ')'
          return [{ tokens: retVal }, i + 1]

        else if token.token is '('
          [newTokens, j] = interpretCall tokens.slice i + 1
          i += j
          retVal.push newTokens
        else
          strReg = new RegExp "^#{stringRegExp}$"
          numberReg = /^[0-9]/
          identifierReg = new RegExp "^#{identifierRegExp}+$"

          if strReg.test(token.token) or numberReg.test(token.token)
            token.type = 'literal'
          else if identifierReg.test token.token
            token.type = 'identifier'
          retVal.push token

        i++

      # The for loop should not have ended. This means that there was a missing
      # closing parenthesis.
      throw new Error "Unexpected end of code."

    i = 0
    while i < tokens.length
      token = tokens[i]

      if token.token isnt '('
        throw new Error "Error on line #{token.line}, column #{token.column + 1}: unexpected '#{token.token}'"

      if tokens[i + 1].token is 'defun'
        params = []
        funcName = tokens[i + 2].token
        [params, j] = interpretParams tokens.slice i + 4

        i += j + 5

        [newTokens, j] = interpretCall tokens.slice i + 1

        newTokens.name = funcName
        newTokens.params = params
        newTokens.type = 'function'

        i += j
      else
        [newTokens, j] = interpretCall tokens.slice i + 1
        newTokens.type = 'instructions'
        i += j
      compiledTokens.push newTokens
      
      i++

    return compiledTokens

  @link: (objectCode) ->
    builtInFunctions =
      "console-log": "console.log"

    finalStr = ''

    parseCall = (call) ->
      getFunctionCall = (token) ->
        if builtInFunctions[token.token]?
          return "#{builtInFunctions[token.token]}("
        else
          return "func['#{token.token}']("

      outputParameter = (token) ->
        if token.type is 'literal'
          finalStr = finalStr + token.token
        else if token.type is 'identifier'
          finalStr = finalStr + "#{getFunctionCall token})"
        else if token.type is 'instructions'
          throw new Error "Not yet implemented."

      # Evaluate the first expression. This represents the function call.
      if call.tokens[0].type is 'literal'
        throw new SyntaxError call.tokens[0], "unexpected literal."
      
      if call.tokens[0].type is 'identifier'
        finalStr = finalStr + getFunctionCall call.tokens[0]

      if call.tokens.length >= 2
        for i in [1...call.tokens.length - 1]
          param = call.tokens[i]
          outputParameter param
          finalStr = finalStr + ','

        outputParameter call.tokens[call.tokens.length - 1]

      finalStr = finalStr + ')'

    for obj in objectCode
      if obj.type is 'instructions'
        parseCall obj
        finalStr = finalStr + ';\n'

    return finalStr
