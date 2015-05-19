TipView = require './views/tip-view'
LoadingView = require './views/loading-view'
ErrorView = require './views/error-view'
{CompositeDisposable} = require 'atom'
cmds = require './commands'

tipTimeoutId = null

module.exports = Fekit =
	fekitView: null
	modalPanel: null
	subscriptions: null

	activate: (state) ->
		@tipView = new TipView(state.tipViewState)
		@tipPanel = atom.workspace.addModalPanel(item: @tipView.getElement(), visible: false)

		@loadingView = new LoadingView(state.loadingViewState)
		@loadingPanel = atom.workspace.addModalPanel(item: @loadingView.getElement(), visible: false)

		@errorView = new ErrorView state.errorViewState
		@errorPanel = atom.workspace.addModalPanel(item: @errorView.getElement(), visible: false)
		@errorView.bindCloseBtn =>
			@errorPanel.hide()

		# Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
		@subscriptions = new CompositeDisposable

		# Register command that toggles this view
		@subscriptions.add atom.commands.add 'atom-workspace', 'fekit:pack': => @pack()

	showTip: (text, type, duration)->
		clearTimeout tipTimeoutId if tipTimeoutId
		@tipView.setText(text) if text?
		@tipView[type||'plain']?()
		@tipPanel.show()
		if !duration? then duration = 3000
		if duration > 0
			tipTimeoutId = setTimeout =>
				@tipPanel.hide()
			, duration

	showError: (msg, detail) ->
		@errorView.rebuild(msg, detail)
		@errorPanel.show()

	deactivate: ->
		@tipPanel.destroy()
		@loadingPanel.destroy()
		@subscriptions.dispose()
		@fekitView.destroy()

	serialize: ->
		# fekitViewState: @fekitView.serialize()

	pack: ->
		@loadingView.setText '正在执行 fekit pack...'
		@loadingPanel.show()
		cmds.pack
			succ: (msg) => @showTip(msg, 'success')
			warn: (msg) => @showTip(msg, 'warn')
			err: (msg, detail) => @showError(msg, detail)
			finish: => @loadingPanel.hide()
