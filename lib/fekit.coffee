{$} = require 'atom-space-pen-views'
TipView = require './views/tip-view'
LoadingView = require './views/loading-view'
ErrorView = require './views/error-view'
PromptView = require './views/prompt-view'
ServerView = require './views/server-view'
{CompositeDisposable} = require 'atom'
cmds = require './commands'

serverUri = 'atom://fekit-server'

tipTimeoutId = null

module.exports = Fekit =
	fekitView: null
	modalPanel: null
	subscriptions: null

	activate: (state) ->
		atom.workspace.addOpener (uri) ->
			if uri.startsWith(serverUri)
				new ServerView({uri})
		@wsview = $ atom.views.getView(atom.workspace)
		@tipView = new TipView(state.tipViewState)
		@tipPanel = atom.workspace.addModalPanel(item: @tipView.getElement(), visible: false)

		@loadingView = new LoadingView(state.loadingViewState)
		@loadingPanel = atom.workspace.addModalPanel(item: @loadingView.getElement(), visible: false)

		@errorView = new ErrorView state.errorViewState
		@errorPanel = atom.workspace.addModalPanel(item: @errorView.getElement(), visible: false)
		@errorView.bindCloseBtn =>
			@hideError()

		# Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
		@subscriptions = new CompositeDisposable

		# Register command that toggles this view
		@subscriptions.add atom.commands.add 'atom-workspace', 'fekit:pack': => @pack()
		@subscriptions.add atom.commands.add 'atom-workspace', 'fekit:min': => @min()
		@subscriptions.add atom.commands.add 'atom-workspace', 'fekit:sync': => @sync()
		@subscriptions.add atom.commands.add 'atom-workspace', 'fekit:initproj': => @initProj()
		@subscriptions.add atom.commands.add 'atom-workspace', 'fekit:server': => @server()

	showLoading: (text) ->
		@loadingView.setText text
		@loadingPanel.show()

	showTip: (text, type, duration)->
		clearTimeout tipTimeoutId if tipTimeoutId
		@tipView.setText(text) if text?
		@tipView[type||'plain']?()
		@tipPanel.show()
		if !duration? then duration = 3000
		if duration > 0
			tipTimeoutId = setTimeout =>
				@hideTip()
			, duration
		@wsview.on 'keyup.fekittip', ({keyCode})=>
			@hideTip() if keyCode is 27

	hideTip: ->
		clearTimeout tipTimeoutId
		@wsview.off('keyup.fekittip')
		@tipPanel.hide()

	showError: (msg, log, stderr) ->
		detail = log + if stderr then "\n<pre class='text-error'>#{stderr}</pre>" else ''
		@errorView.rebuild msg, detail
		@errorPanel.show()
		@wsview.on 'keyup.fekiterror', ({keyCode}) =>
			@hideError() if keyCode is 27

	hideError: ->
		@wsview.off 'keyup.fekiterror'
		@errorPanel.hide()

	showPrompt: (label, defaultText, onOk, onCancel)->
		view = new PromptView()
		view.setLabel(label)
		.setValue(defaultText)
		.bindCancel ->
			onCancel?()
			panel.destroy()
		.bindOk (value) ->
			onOk?(value)
			panel.destroy()
		panel = atom.workspace.addModalPanel(item: view, visible: true)
		view.focus()

	deactivate: ->
		@tipPanel.destroy()
		@loadingPanel.destroy()
		@subscriptions.dispose()
		@fekitView.destroy()

	serialize: ->
		# fekitViewState: @fekitView.serialize()

	execSimpleCmd: (cmd) ->
		cmds[cmd]
			init: (msg) => @showLoading(msg)
			succ: (msg) => @showTip(msg, 'success')
			warn: (msg) => @showTip(msg, 'warn')
			err: (msg, log, stderr) => @showError(msg, log, stderr)
			finish: => @loadingPanel.hide()

	initProj: ->
		cmds.initProj
			info: => @showTip.apply(@, arguments)
			prompt: @showPrompt

	pack: -> @execSimpleCmd 'pack'

	min: -> @execSimpleCmd 'min'

	sync: -> @execSimpleCmd 'sync'

	server: ->
		atom.workspace.open(serverUri)
