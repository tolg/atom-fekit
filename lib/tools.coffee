fs = require 'fs'
path = require 'path'

module.exports = tools =

	# 从spath路径开始向上级寻找指定的文件，找到后返回文件所在路径
	findFileUpward: (spath, fileName) ->
		return false if !spath or !fs.existsSync spath
		sep = path.sep
		testPath = spath.replace(new RegExp('\\'+sep), '') + sep + fileName
		if fs.existsSync testPath
			spath
		else if path.dirname(spath) is spath
			false
		else
			arguments.callee(path.dirname(spath), fileName)

	getActiveFilePath: ->
		atom.workspace.getActiveEditor()?.getPath()

	getProjectPath: ->
		atom.project.getPath()

	removeComments: (source) ->
		source.replace(/\/\/.+\n/g, '')

	parseJSON: (source) ->
		code = tools.removeComments(source)
		JSON.parse(code)

	getEnvPath: ->
		envPath = process.env.PATH
		# mac os下atom的node环境变量PATH中不包含/usr/local/bin(fekit指令连接在此)
		if process.platform is "darwin" and !(/\/usr\/local\/bin/.test envPath)
			envPath += ':/usr/local/bin'
		envPath

	beautifyLog: (text) ->
		text.replace(/\[(log)\]/gi, "<span class='inline-block highlight-info'>Info</span>")
		.replace(/\[(error)\]/gi, "<span class='inline-block highlight-error'>Error</span>")
		.replace(/\[(warning)\]/gi, "<span class='inline-block highlight-warning'>Warning</span>")
