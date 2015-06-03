{View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class TipView extends View
  @content: ->
    @div class: 'fekit-prompt-panel', =>
      @div class: 'block padded', =>
        @label outlet:'inputLabel'
        @subview 'input', new TextEditorView(mini:true)
      @div class: 'text-center padded', =>
        @button outlet: 'okBtn', class: 'btn btn-primary', '确定'
        @button outlet: 'cancelBtn', class: 'btn', '取消'

  setLabel: (label) ->
    @inputLabel.text label
    @

  setValue: (text) ->
    @input.setText text
    @

  getValue: ->
    @input.getText()

  focus: ->
    @input.focus()
    @input.getModel().selectAll()
    @

  bindCancel: (action) ->
    @cancelBtn.on 'click', action
    @

  bindOk: (action) ->
    @okBtn.on 'click', () =>
      action?(@getValue())
    @input.on 'keyup', (event) =>
      if event.keyCode is 13
        action?(@getValue())
    @
