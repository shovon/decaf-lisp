expect = require 'expect.js'
compiler = require '../compiler.coffee'
fs = require 'fs'
AnonymousToken = require '../AnonymousToken.coffee'

describe 'Splitter', ->
  describe 'splitLine', ->
    it 'should split "(+ a b)"', ->
      tokens = compiler.splitLine '(+ a b)'
      expect(tokens._tokens).to.eql [
        { columnNum: 0, name: '(' }
        { columnNum: 1, name: '+' }
        { columnNum: 3, name: 'a' }
        { columnNum: 5, name: 'b' }
        { columnNum: 6, name: ')' }
      ]

    it 'should split "(+ \"apple\" \"banana\")"', ->
      tokens = compiler.splitLine '(+ "apple" "banana")'
      expect(tokens._tokens).to.eql [
        { columnNum: 0, name: '(' }
        { columnNum: 1, name: '+' }
        { columnNum: 3, name: '"apple"' }
        { columnNum: 11, name: '"banana"' }
        { columnNum: 19, name: ')' }
      ]

    it 'should split "(+ , *)"', ->
      tokens = compiler.splitLine '(+ , *)'
      
      expect(tokens._tokens).to.eql [
        { columnNum: 0, name: '(' }
        { columnNum: 1, name: '+' }
        { columnNum: 3, name: ',' }
        { columnNum: 5, name: '*' }
        { columnNum: 6, name: ')' }
      ]

    it 'should split "(+ (a) (b))"', ->
      tokens = compiler.splitLine '(+ (a) (b))'

      expect(tokens._tokens).to.eql [
        { columnNum: 0, name: '(' }
        { columnNum: 1, name: '+' }
        { columnNum: 3, name: '(' }
        { columnNum: 4, name: 'a' }
        { columnNum: 5, name: ')' }
        { columnNum: 7, name: '(' }
        { columnNum: 8, name: 'b' }
        { columnNum: 9, name: ')' }
        { columnNum: 10, name: ')' }
      ]

  describe 'split', ->
    it 'should split a string with multiple lines', ->
      tokens = compiler.split fs.readFileSync "#{__dirname}/testfiles/variable.lisp", 'utf8'

      expect(tokens._tokens).to.eql [
        { columnNum: 0, lineNum: 0, name: '(' }
        { columnNum: 1, lineNum: 0, name: 'defun' }
        { columnNum: 7, lineNum: 0, name: 'some-var' }
        { columnNum: 16, lineNum: 0, name: '(' }
        { columnNum: 17, lineNum: 0, name: ')' }
        { columnNum: 19, lineNum: 0, name: '1' }
        { columnNum: 20, lineNum: 0, name: ')' }
        { columnNum: 0, lineNum: 2, name: '(' }
        { columnNum: 1, lineNum: 2, name: 'console-log' }
        { columnNum: 13, lineNum: 2, name: 'some-var' }
        { columnNum: 21, lineNum: 2, name: ')' }
      ]

describe 'Analyzer', ->
  it 'should successfully analyze any string that contain nothing but valid code.', ->
    tokens = compiler.split fs.readFileSync "#{__dirname}/testfiles/hello-world.lisp", "utf8"
    tokens = compiler.analyze tokens

    expect(tokens._tokens).to.eql [
      { columnNum: 0, lineNum: 0, type: AnonymousToken.types.OPENING }
      { columnNum: 1, lineNum: 0, type: AnonymousToken.types.IDENTIFIER, name: 'console-log' }
      { columnNum: 13, lineNum: 0, type: AnonymousToken.types.STRING, value: '"Hello, World!"' }
      { columnNum: 28, lineNum: 0, type: AnonymousToken.types.CLOSING }
    ]
