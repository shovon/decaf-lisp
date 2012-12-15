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

    interpretDefine = (tokens) ->
      throw new Error "Not yet implemented."

    interpretCall = (tokens) ->
      retVal = []

      i = 0
      while i < tokens.length
        token = tokens[i]
        if token.token is ')'
          retVal.type = 'instructions'
          return [retVal, i + 1]

        else if token.token is '('
          #console.log i
          #console.log tokens.slice i + 1
          [newTokens, i] = interpretCall tokens.slice i + 1
          #console.log i
          #console.log tokens.slice i + 1
          #console.log newTokens
          #throw new Error
          retVal.push newTokens

        else
          retVal.push token

        i++

      # The for loop should not have ended. This means that there was a missing
      # closing parenthesis.
      throw new Error "Unexpected end of code."

    i = 0
    while i < tokens.length
      token = tokens[i]

      if token.token isnt '('
        throw new Error "Error on line #{token.line}, column #{token.column}: Unexpected '#{token.token}'"

      if token[i + 1] is 'define'
        [newTokens, i] = interpretDefinition tokens.slice i + 2
      else
        [newTokens, i] = interpretCall tokens.slice i + 1
      compiledTokens.push newTokens
      
      i++

    return compiledTokens
