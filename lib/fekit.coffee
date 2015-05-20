TipView = require './views/tip-view'
LoadingView = require './views/loading-view'
ErrorView = require './views/error-view'
PromptView = require './views/prompt-view'
{CompositeDisposable} = require 'atom'
tools = require './tools'
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
		@subscriptions.add atom.commands.add 'atom-workspace', 'fekit:sync': => @sync()
		@subscriptions.add atom.commands.add 'atom-workspace', 'fekit:initproj': => @initProj()

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
				@tipPanel.hide()
			, duration

	showError: (msg, log, stderr) ->
		detail = log + if stderr then "\n<pre class='text-error'>#{stderr}</pre>" else ''
		@errorView.rebuild(msg, detail)
		@errorPanel.show()

	showPrompt: (label, defaultText, onOk, onCancel)->
		view = new PromptView()
		view.setLabel(label)
		.setValue(defaultText)
		.bindCancelBtn ->
			onCancel?(view.getValue())
			panel.destroy()
		.bindOkBtn ->
			onOk?(view.getValue())
			panel.destroy()
		panel = atom.workspace.addModalPanel(item: view.getElement(), visible: true)

	deactivate: ->
		@tipPanel.destroy()
		@loadingPanel.destroy()
		@subscriptions.dispose()
		@fekitView.destroy()

	serialize: ->
		# fekitViewState: @fekitView.serialize()

	initProj: ->
		rootPath = tools.getProjectPath()
		{spawn} = require 'child_process'
		envPath = tools.getEnvPath()
		initer = spawn 'fekit', ['init'], {cwd: rootPath, env:{PATH:envPath}}
		initer.stdout.on 'data', (data) =>
			output = data.toString().replace /\[\d+m/g, ''
			if /^prompt:/.test(output)
				label = output.replace /prompt:\s/, ''
				text = label.match(/\((.+)\)$/)?[1] || ''
				@showPrompt label, text
				, (value) ->
					initer.stdin.write(value+'\n')
				, ->
					initer.kill()
			else
				showTip(output)

	pack: ->
		cmds.pack
			init: (msg) => @showLoading(msg)
			succ: (msg) => @showTip(msg, 'success')
			warn: (msg) => @showTip(msg, 'warn')
			err: (msg, log, stderr) => @showError(msg, log, stderr)
			finish: => @loadingPanel.hide()

	sync: ->
		cmds.sync
			init: (msg) => @showLoading(msg)
			succ: (msg) => @showTip(msg, 'success')
			warn: (msg) => @showTip(msg, 'warn')
			err: (msg, log, stderr) => @showError(msg, log, stderr)
			finish: => @loadingPanel.hide()
