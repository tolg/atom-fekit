{$} = require 'atom' #引入jQuery

module.exports =
class TipView
    constructor: (serializedState) ->
        # Create root element
        @element$ = $('<div class="fekit-error-panel">')

        # Create message element
        @message$ = $('<h2 class="text-error padded">').appendTo @element$

        @detailCtn$ = $('<div class="padded detail-ctn">').hide().appendTo @element$
        @detail$ = $('<pre class="inset-panel padded">').appendTo @detailCtn$

        btnCtn$ = $('<div class="text-center padded">').appendTo @element$
        @detailBtn$ = $('<button class="btn btn-error inline-block-tight">查看详情</button>')
        .on 'click', (evt) =>
            btn$ = $(evt.target)
            if(btn$.text() is '查看详情')
                @detailCtn$.slideDown('fast')
                btn$.html('隐藏详情')
            else
                @detailCtn$.slideUp('fast')
                btn$.html('查看详情')
        .appendTo btnCtn$
        @closeBtn$ = $('<button class="btn margined" style="margin-left:20px;">关闭</button>')
        .appendTo btnCtn$
    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
        @element$.remove()

    getElement: ->
        @element$[0]

    setMsg: (text) ->
        @message$.html text
        @

    setDetail: (text) ->
        text = text.replace(/(\[LOG\])/gi, '<span class="text-info">$1</span>')
        .replace(/(\[ERROR\])/gi, '<span class="text-error">$1</span>')
        .replace(/(\[WARNING\])/gi, '<span class="text-warning">$1</span>')
        @detail$.html text
        @

    bindCloseBtn: (action) ->
        @closeBtn$.on 'click', action
        @

    rebuild: (msg, detail) ->
        @setMsg(msg)
        @setDetail(detail)
        @detailCtn$.hide()
        @detailBtn$.html('查看详情')
        @
