{$, $$, ScrollView, TextEditorView} = require 'atom-space-pen-views'
{Disposable} = require 'atom'
{BufferedProcess} = require 'atom'
{exec} = require 'child_process'
tools = require '../tools'
TipView = require './tip-view'

getRootPath = ->
	targetPath = tools.getActiveFilePath() || tools.getProjectPath()
	tools.findFileUpward(targetPath, 'fekit.config') || tools.getProjectPath() || ''

module.exports =
class ServerView extends ScrollView

	@content: ->
		@div class: 'fekit-server-view pane-item', =>
			@div outlet: 'configSide', class: 'config-side', =>
				@div class: 'line', =>
					@label '启动路径', for: 'path'
					@input outlet: 'rootPath', class: 'path-input', value: getRootPath(), name: 'path-input'
				@div class: 'line', 'data-arg': '-p', =>
					@label '端口号', for: 'port'
					@input value: '80', class:'ext-arg port-input', name: 'port-input'
				@div class: 'line', 'data-arg': '-c', =>
					@input class: 'enable-check', type: 'checkbox', name: 'combine'
					@label '合并文件', for: 'combine'
				@div class: 'line', 'data-arg': '-n', =>
					@input class: 'enable-check', type: 'checkbox', name: 'noexport'
					@label '无视exprot', for: 'noexport'
				@div class: 'line', 'data-arg': '-b', =>
					@input class: 'enable-check', type: 'checkbox', name: 'boost'
					@label '对编译结果缓存', for: 'boost'
				@div class: 'line', 'data-arg': '-s', =>
					@input outlet: 'checkSsl', class: 'enable-check', type: 'checkbox', name: 'ssl'
					@label '指定ssl证书', for: 'ssl'
					@input outlet: 'sslInput', type: 'file', class: 'ext-arg', name: 'ssl-input', disabled: true
				@div class: 'line', 'data-arg': '-m', =>
					@input outlet: 'checkMock', class: 'enable-check', type: 'checkbox', name: 'mock'
					@label 'mock', for: 'mock'
					@input outlet: 'mockInput', type: 'file', class: 'ext-arg', name: 'mock-input', disabled: true
				@div class: 'line', 'data-arg': '-l', =>
					@input class: 'enable-check', type: 'checkbox', name: 'livereload'
					@label 'livereload', for: 'live reload'
				@div class: 'line btn-line', =>
					@button outlet: 'launchBtn', class: 'btn btn-success', '启动服务'
					@button outlet: 'shutBtn', class: 'btn btn-error hidden', '停止服务'
					@button outlet: 'clearBtn', class: 'btn', '清除日志'
			@div class: 'terminal-side', =>
				@pre outlet: 'terminalText'
	initialize: ({@uri, activePanelName}={}) ->
		super
		@bindEvents()
		@tipView = new TipView()
		@tipPanel = atom.workspace.addModalPanel(item: @tipView.getElement(), visible: false)

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

	getTitle: ->
		"Fekit Server"

	bindEvents: ->
		@checkSsl.on 'change', (event) =>
			@sslInput.attr('disabled', !event.target.checked)
		@checkMock.on 'change', (event) =>
			@mockInput.attr('disabled', !event.target.checked)
		@clearBtn.on 'click', => @clearLog()
		@launchBtn.click => @startServer()
		@shutBtn.click => @stopServer()

	showLanuchBtn: ->
		@shutBtn.addClass 'hidden'
		@launchBtn.removeClass 'hidden'

	showShutBtn: ->
		@launchBtn.addClass 'hidden'
		@shutBtn.removeClass 'hidden'

	detached: ->
		@unsubscribe()

	onDidChangeTitle: -> new Disposable()
	onDidChangeModified: -> new Disposable()

	startServer: ->
		if cwd = @rootPath.val()
			args = ['fekit', 'server']
			@configSide.find('.line[data-arg]').each (i, item) =>
				enableCheck = $(item).find('.enable-check')
				if !enableCheck[0]? || enableCheck[0].checked
					args.push $(item).data('arg')
					if extArg = $(item).find('.ext-arg')[0]
						args.push extArg.value
			cmd = tools.getCompatibleCommand "sudo fekit server #{args.join(' ')}"

			@serverProcess = exec cmd,
				cwd: cwd
			, -> console.log arguments
			@serverProcess.stdout.on 'data', (data) =>
				@printLog data

			# @serverProcess = new BufferedProcess
			# 	command: 'sudo'
			# 	args: args
			# 	options: {cwd: cwd, env: {PATH: tools.getEnvPath()}}
			# 	stdout: (data) => @printLog(data)
			# 	stderr: (data) => @printLog(data)
			# 	exit: (code) =>
			# 		@showLanuchBtn()
			@showShutBtn()
		else
			@showTip '请输入服务启动路径!', 'warn'

	stopServer: ->
		@serverProcess?.kill()
		@showLanuchBtn()

	printLog: (log) ->
		console.log(log)
		@terminalText[0].innerHTML += log

	clearLog: ->
		@terminalText.empty()
