{$} = require 'atom' #引入jQuery

module.exports =
class TipView
    constructor: (serializedState) ->
        # Create root element
        @element$ = $('<div class="fekit-prompt-panel">')

        @ctn$ = $('<div class="block padded">').appendTo @element$
        @label$ = $('<label">').appendTo @ctn$
        @input$ = $('<atom-text-editor mini>').appendTo @ctn$

        btnCtn$ = $('<div class="text-center padded">').appendTo @element$
        @okBtn$ = $('<button class="btn btn-primary">确定</button>').appendTo btnCtn$
        @cancelBtn$ = $('<button class="btn" style="margin-left:20px;">取消</button>')
        .appendTo btnCtn$
    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
        @element$.remove()

    getElement: ->
        @element$[0]

    setLabel: (label) ->
        @label$.text label
        @

    setValue: (text) ->
        @input$.text text
        @

    getValue: ->
        @input$.text()

    bindCancel: (action) ->
        @cancelBtn$.on 'click', action
        @

    bindOk: (action) ->
        @okBtn$.on 'click', () =>
          action?(@getValue())
        @input$.on 'keyup', (event) =>
          if event.keyCode is 13
            action?(@getValue())
        @
