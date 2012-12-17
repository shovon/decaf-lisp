assert = require 'assert'

# TODO: rename this to `Expression`
module.exports = class Scope
  types = [
    "FUNCTION_DEFINITION"
    "LAMBDA_EXPRESSION"
    "EXPRESSION"
  ]

  @types: {}

  for type in types
    @types[type] = type

  constructor: (@type, options) ->
    if not @type?
      throw new Error "A type must be defined."

    if not Scope.types[@type]?
      throw new Error "Unkown type #{@type}."

    if @type is Scope.types.FUNCTION_DEFINITION or
    @type is Scope.types.LAMBDA_EXPRESSION
      if not options?
        throw new Error "Options must be provided"

      if not options.parameters?
        throw new Error "A list of parameters must be provided."

      if @type is Scope.types.FUNCTION_DEFINITION
        if not options.functionName?
          throw new Error "A function name must be specified."

        @functionName = options.functionName

      @parameters = options.parameters

  push: (element) ->
    unless @scopes?
      @scopes = []

    @scopes.push element
