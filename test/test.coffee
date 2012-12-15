expect = require 'expect.js'
compiler = require '../compiler.coffee'

describe 'Lexer', ->
  describe 'tokenizer', ->
    it 'should tokenize the string (+ apple banana)', ->
      code = '(+ apple banana)'
      tokens = compiler.LexicalAnalyzer.tokenizeLine code

      expect(tokens.length).to.be 5

      expect(tokens[0].token).to.be '('
      expect(tokens[0].column).to.be 0

      expect(tokens[1].token).to.be '+'
      expect(tokens[1].column).to.be 1

      expect(tokens[2].token).to.be 'apple'
      expect(tokens[2].column).to.be 3

      expect(tokens[3].token).to.be 'banana'
      expect(tokens[3].column).to.be 9

      expect(tokens[4].token).to.be ')'
      expect(tokens[4].column).to.be 15
    
    it 'should tokenize the string (+ "apple" "banana")', ->
      code = '(+ "apple" "banana")'
      tokens = compiler.LexicalAnalyzer.tokenizeLine code

      expect(tokens.length).to.be 5

      expect(tokens[0].token).to.be '('
      expect(tokens[0].column).to.be 0

      expect(tokens[1].token).to.be '+'
      expect(tokens[1].column).to.be 1

      expect(tokens[2].token).to.be '"apple"'
      expect(tokens[2].column).to.be 3

      expect(tokens[3].token).to.be '"banana"'
      expect(tokens[3].column).to.be 11

      expect(tokens[4].token).to.be ')'
      expect(tokens[4].column).to.be 19

    it 'should tokenize the code from a file.', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/test1.lisp", (err, tokens) ->      
        expect(tokens.length).to.be 5

        expect(tokens[0].token).to.be '('
        expect(tokens[0].column).to.be 0

        expect(tokens[1].token).to.be '+'
        expect(tokens[1].column).to.be 1

        expect(tokens[2].token).to.be 'a'
        expect(tokens[2].column).to.be 3

        expect(tokens[3].token).to.be 'b'
        expect(tokens[3].column).to.be 5
        
        done()

    it 'should be able to compile the code.', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/test1.lisp", (err, tokens) ->
        object = compiler.LexicalAnalyzer.compile tokens

        expect(object[0].length).to.be 3

        expect(object[0][0].token).to.be '+'
        expect(object[0][1].token).to.be 'a'
        expect(object[0][2].token).to.be 'b'
        done()

    xit 'should be able to compile code with nesting'
      #compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/test2.lisp", (err, tokens) ->
      #  object = comp

    xit 'should be able to compile the code across many lines.', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/if-else.lisp", (err, tokens) ->
        object = compiler.LexicalAnalyzer.compile tokens

        expect(object[0].length).to.be 3

        expect(object[0][0]).to.be.a 'string'
        expect(object[0][0].token).to.be 'if'

        expect(object[0][1]).to.be.an 'array'

        done()
