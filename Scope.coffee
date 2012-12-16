module.exports = class Scope
  scopes: []

  push: (element) ->
    @scopes.push element