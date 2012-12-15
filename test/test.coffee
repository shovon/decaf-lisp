expect = require 'expect.js'
compiler = require '../compiler.coffee'

describe 'Lexer', ->
  describe 'tokenizer', ->
    it 'should tokenize the string (+ apple banana)', ->
      code = '(+ apple banana)'
      tokens = compiler.LexicalAnalyzer.tokenizeLine code

      expect(tokens.length).to.be 5

      expect(tokens).to.eql [
        {token: '(', column: 0}
        {token: '+', column: 1}
        {token: 'apple', column: 3}
        {token: 'banana', column: 9}
        {token: ')', column: 15}
      ]
    
    it 'should tokenize the string (+ "apple" "banana")', ->
      code = '(+ "apple" "banana")'
      tokens = compiler.LexicalAnalyzer.tokenizeLine code

      expect(tokens).to.eql [
        {token: '(', column: 0}
        {token: '+', column: 1}
        {token: '"apple"', column: 3}
        {token: '"banana"', column: 11}
        {token: ')', column: 19}
      ]

    it 'should tokenize the code from a file.', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/test1.lisp", (err, tokens) ->      
        expect(tokens.length).to.be 5

        expect(tokens).to.eql [
          {token: '(', line: 1, column: 0}
          {token: '+', line: 1, column: 1}
          {token: 'a', line: 1, column: 3}
          {token: 'b', line: 1, column: 5}
          {token: ')', line: 1, column: 6}
        ]
        
        done()

    it 'should be able to compile the code.', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/test1.lisp", (err, tokens) ->
        object = compiler.LexicalAnalyzer.compile tokens

        expect(object[0].type).to.be 'instructions'
        expect(object[0].tokens[0].token).to.be '+'
        expect(object[0].tokens[1].token).to.be 'a'
        expect(object[0].tokens[2].token).to.be 'b'

        done()

    it 'should be able to compile code with nesting', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/test2.lisp", (err, tokens) ->
        object = compiler.LexicalAnalyzer.compile tokens

        expect(object[0].tokens.length).to.be 3

        expect(object[0].tokens[0].token).to.be '+'
        expect(object[0].tokens[1].tokens[0].token).to.be 'a'
        expect(object[0].tokens[2].tokens[0].token).to.be 'b' 

        done()

    it 'should be able to compile the code across many lines.', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/if-else.lisp", (err, tokens) ->
        object = compiler.LexicalAnalyzer.compile tokens

        expect(object[0].tokens.length).to.be 4

        expect(object[0].tokens[0]).to.have.property 'token'
        expect(object[0].tokens[0].token).to.be 'if'

        expect(object[0].tokens[1].tokens).to.be.an 'array'
        expect(object[0].tokens[1].tokens.length).to.be 3

        expect(object[0].tokens[1].tokens[0]).to.have.property 'token'
        expect(object[0].tokens[1].tokens[0].token).to.be '<'

        expect(object[0].tokens[1].tokens[1].tokens).to.be.an 'array'
        expect(object[0].tokens[1].tokens[1].tokens.length).to.be 2

        expect(object[0].tokens[1].tokens[1].tokens[0]).to.have.property 'token'
        expect(object[0].tokens[1].tokens[1].tokens[0].token).to.be 'args'

        expect(object[0].tokens[1].tokens[1].tokens[1]).to.have.property 'token'
        expect(object[0].tokens[1].tokens[1].tokens[1].token).to.be '0'

        expect(object[0].tokens[1].tokens[2].tokens).to.be.an 'array'
        expect(object[0].tokens[1].tokens[2].tokens.length).to.be 2

        expect(object[0].tokens[1].tokens[2].tokens[0]).to.have.property 'token'
        expect(object[0].tokens[1].tokens[2].tokens[0].token).to.be 'args'

        expect(object[0].tokens[1].tokens[2].tokens[1]).to.have.property 'token'
        expect(object[0].tokens[1].tokens[2].tokens[1].token).to.be '1'

        expect(object[0].tokens[2].tokens).to.be.an 'array'
        expect(object[0].tokens[2].tokens.length).to.be 2

        expect(object[0].tokens[2].tokens[0]).to.have.property 'token'
        expect(object[0].tokens[2].tokens[0].token).to.be 'log'

        expect(object[0].tokens[2].tokens[1]).to.have.property 'token'
        expect(object[0].tokens[2].tokens[1].token).to.be '"First is greater."'

        expect(object[0].tokens[3].tokens).to.be.an 'array'
        expect(object[0].tokens[3].tokens.length).to.be 2

        expect(object[0].tokens[3].tokens[0]).to.have.property 'token'
        expect(object[0].tokens[3].tokens[0].token).to.be 'log'

        expect(object[0].tokens[3].tokens[1]).to.have.property 'token'
        expect(object[0].tokens[3].tokens[1].token).to.be '"Second is greater."'

        done()

    it 'should be able to compile function calls', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/define.lisp", (err, tokens) ->
        object = compiler.LexicalAnalyzer.compile tokens

        expect(object[0].type).to.be 'function'
        expect(object[0].name).to.be 'display-something'
        expect(object[0].params).to.eql ['val1', 'val2']

        expect(object[1].type).to.be 'instructions'

        done()

    it 'should be able to compile functions with no parameters', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/variable.lisp", (err, tokens) ->
        object = compiler.LexicalAnalyzer.compile tokens

        expect(object[0].type).to.be 'function'
        expect(object[0].name).to.be 'some-var'
        expect(object[0].params).to.eql []

        expect(object[1].type).to.be 'instructions'

        done()

    it 'should be able to link code', (done) ->
      compiler.LexicalAnalyzer.analyze "#{__dirname}/testfiles/hello-world.lisp", (err, tokens) ->
        object = compiler.LexicalAnalyzer.compile tokens
        output = compiler.LexicalAnalyzer.link object

        console.log output

        done()