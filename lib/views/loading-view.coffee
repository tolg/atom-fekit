{$} = require 'atom-space-pen-views'

module.exports =
class LadingView
  constructor: (serializedState) ->
    # Create root element
    @element$ = $('<div>').addClass 'text-center'
    $("<span class='loading loading-spinner-tiny inline-block'>").appendTo @element$
    # Create message element
    @message$ = $('<span class="text-color-subtle">').appendTo @element$

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element$.remove()

  getElement: ->
    @element$[0]

  setText: (text) ->
    @message$.html text
