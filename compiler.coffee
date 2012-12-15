Lazy = require 'lazy'
carrier = require 'carrier'
fs = require 'fs'

LexicalAnalyzer = class module.exports.LexicalAnalyzer
  @tokenizeLine: (line) ->
    spacesAndChars = line.match ///
        # Match all spaces
        \s+
        # Match all opening braces
      | \(
        # Match all closing braces
      | \)
        # Match all semi-colons
      | ;
      | (
            [a-zA-Z0-9\+><\-_]
          | (
                '[^'\\]*(?:\\.[^'\\]*)*'
              | "[^"\\]*(?:\\.[^"\\]*)*"
            )
        )+
      | \.
      ///g

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
          console.log "Hmm..."
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
          token.type = 'token'
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
    finalStr = ''

    parseCall = (call) ->
      console.log call
      if call.type is 'token'
        finalStr = finalStr + "func['#{call.token}']("
      else if call.type is 'instructions'
        for c in call.tokens
          parseCall c

      finalStr += ')'
      
      return finalStr

    for call in objectCode
      if call.type is 'instructions'
        parseCall call

    return finalStr
