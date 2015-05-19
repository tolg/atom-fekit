fs = require 'fs'
path = require 'path'

module.exports =

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
