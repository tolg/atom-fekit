tools = require './tools'
path = require 'path'

detactFekitProject = (onError) ->
	targetPath = tools.getActiveFilePath() || tools.getProjectPath()
	fekitPath = tools.findFileUpward targetPath, 'fekit.config'
	if !fekitPath
		console.warn 'not a fekit project!'
		onError?('没有找到fekit项目。')
		false
	else
		fekitPath

getEnvPath = ->
	envPath = process.env.PATH
	# mac os下atom的node环境变量PATH中不包含/usr/local/bin(fekit指令连接在此)
	if process.platform is "darwin" and !(/\/usr\/local\/bin/.test envPath)
		envPath += ':/usr/local/bin'
	envPath

runFekitCmd = (cmd, fekitPath, cb) ->
	{exec} = require 'child_process'
	envPath = getEnvPath()
	exec 'fekit '+cmd, {cwd: fekitPath, env:{PATH:envPath}}, cb

getFekitConfig = (projectPath, cb) ->
	sep = path.sep
	filePath = projectPath.replace(new RegExp('\\'+sep), '') + sep + 'fekit.config'
	require('fs').readFile 'filePath', (err, data) ->
		obj = null
		if !err
			obj = evel '(' + data.toString() + ')'
		cb(err, obj)

getProjectName = (projectPath, cb) ->
	getFekitConfig projectPath, (err, config) ->
		projectName = if err || !config.name
			path.basename(projectPath)
		else
			config.name
		cb?(null, projectName)


module.exports = commands =

	pack: (actions) ->
		fekitPath = actions.fekitPath || detactFekitProject (msg) ->
			actions['warn'||'warning']?(msg)
			actions.finish?()
		if fekitPath
			getProjectName fekitPath, (_, projectName) ->
				runFekitCmd 'pack', fekitPath, (err, stdout, stderr) =>
					if err
						actions['err'||'error']?("项目 <i>#{projectName}</i> 执行 fekit pack 失败", stdout, err)
					else
						actions['succ'||'success']?("项目 <i>#{projectName}</i> 执行 fekit pack 成功")
					actions.finish?()

	sync: (actions) ->
		fekitPath = actions.fekitPath || detactFekitProject (msg) ->
			actions['warn'||'warning']?(msg)
			actions.finish?()
		if fekitPath
			runFekitCmd 'sync', fekitPath,  (err, stdout, stderr) =>
				if err
					actions['err'||'error']?('fekit sync 执行失败', stdout, err)
				else
					actions['succ'||'success']?('fekit sync 执行成功')
				actions.finish?()
