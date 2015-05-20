tools = require './tools'
path = require 'path'
fs = require 'fs'
cp = require 'child_process'

sep = path.sep

detactFekitProject = (onError) ->
	targetPath = tools.getActiveFilePath() || tools.getProjectPath()
	fekitPath = tools.findFileUpward targetPath, 'fekit.config'
	if !fekitPath
		console.warn 'not a fekit project!'
		onError?('没有找到fekit项目。')
		false
	else
		fekitPath

runFekitCmd = (cmd, fekitPath, cb) ->
	envPath = tools.getEnvPath()
	cp.exec 'fekit '+cmd, {cwd: fekitPath, env:{PATH:envPath}}, cb

getFekitConfig = (projectPath, cb) ->
	filePath = projectPath.replace(new RegExp('\\'+sep), '') + sep + 'fekit.config'
	fs.readFile filePath, (err, data) ->
		obj = null
		if !err
			try
				obj = JSON.parse(data.toString())
			catch e
				err = e
		cb(err, obj)

getProjectName = (projectPath, cb) ->
	getFekitConfig projectPath, (err, config) ->
		projectName = if err || !config.name
			path.basename(projectPath)
		else
			config.name
		cb?(null, projectName)

getDevInfo = (projectPath, cb) ->
	filePath = projectPath.replace(new RegExp('\\'+sep), '') + sep + '.dev'
	fs.readFile filePath, (err, data) ->
		obj = null
		if !err
			try
				obj = JSON.parse(data.toString())
			catch e
				err = e
		cb(err, obj)

module.exports = commands =

	initProj: (actions) ->
		rootPath = tools.getProjectPath()
		envPath = tools.getEnvPath()
		initer = cp.spawn 'fekit', ['init'], {cwd: rootPath, env:{PATH:envPath}}
		initer.stdout.on 'data', (data) =>
			output = data.toString().replace /\[\d+m/g, ''
			if /^prompt:/.test(output)
				label = output.replace /prompt:\s+/, ''
				text = label.match(/\((.+)\)\s*$/)?[1] || ''
				actions.prompt label, text, (value) ->
					initer.stdin.write(value+'\n')
				, ->
					initer.kill()
			else
				actions.info(tools.beautifyLog(output))


	pack: (actions) ->
		actions.init?('正在执行 fekit pack...')
		fekitPath = actions.fekitPath || detactFekitProject (msg) ->
			actions['warn'||'warning']?(msg)
			actions.finish?()
		if fekitPath
			getProjectName fekitPath, (_, projectName) ->
				runFekitCmd 'pack', fekitPath, (err, stdout, stderr) =>
					if err
						actions['err'||'error']?("项目 <i>#{projectName}</i> 执行 fekit pack 失败", stdout, stderr)
					else
						actions['succ'||'success']?("项目 <i>#{projectName}</i> 执行 fekit pack 成功")
					actions.finish?()

	sync: (actions) ->
		fekitPath = actions.fekitPath || detactFekitProject (msg) ->
			actions['warn'||'warning']?(msg)
			actions.finish?()
		if fekitPath
			getDevInfo fekitPath, (devErr, devObj) ->
				if devErr
					actions['warn'||'warning']?(msg)
				else
					getProjectName fekitPath, (_, projectName) ->
						targetHost = devObj.dev.host
						actions.init?('正在同步projectName到targetHost...')
						runFekitCmd 'sync', fekitPath,  (err, stdout, stderr) =>
							if err
								actions['err'||'error']?("项目<i>#{projectName}</i>同步失败", stdout, stderr)
							else
								actions['succ'||'success']?('<i>#{projectName}</i>同步到#{targetHost}成功')
							actions.finish?()
