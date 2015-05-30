{$} = require 'atom-space-pen-views'

module.exports =
class TipView
  constructor: (serializedState) ->
    # Create root element
    @element$ = $('<div>').addClass 'text-center'

    # Create message element
    @message$ = $('<h2>').appendTo @element$

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element$.remove()

  getElement: ->
    @element$[0]

  setText: (text) ->
    @message$.html text
    @

  warn: ->
    @setTextClass 'text-warning'
    @

  error: ->
    @setTextClass 'text-error'
    @

  success: ->
    @setTextClass 'text-success'
    @

  plain: ->
    @setTextClass ''
    @

  setTextClass: (className) ->
    @message$.removeClass().addClass(className)
    @
