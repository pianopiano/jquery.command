if !window.Command&&!window.Animate&&!window.Prop&&!window.Func&&!window.Wait&&!window.Trace&&!window.Serial&&!window.Parallel
	window.Command = {}
	
((w) ->
	$elms = []
	$params = []
	w.Command = ->
		@.delegate
	
	w.Command.prototype = 
		execute: ->
		onComplete: ->
			if @.delegate
				@.delegate()	
	
	# Prop
	w.Prop = ($elm, params) ->
		$elms.push $elm
		$params.push params
		@.propFunction = ->
			$elm.css params
		@
		
	w.Prop.prototype = new w.Command()
	w.Prop.prototype.execute = ->
		@.propFunction()
		@.onComplete()
	
	# Func
	w.Func = (func) ->
		@.targetFunction = func
		@
		
	w.Func.prototype = new w.Command()
	w.Func.prototype.execute = ->
		@.targetFunction()
		@.onComplete()
		
	# Wait
	w.Wait = (delay) ->
		@.delay = delay
		@.timer
		@
		
	w.Wait.prototype = new w.Command()
	w.Wait.prototype.execute = ->
		self = @
		@.timer = setTimeout ->
			self.onComplete()
		, @.delay
	
	
	# Trace
	w.Trace = (log) ->
		@.consoleLog = ->
			console.log '[info] - ' + log.toString()
		@
		
	w.Trace.prototype = new w.Command()
	w.Trace.prototype.execute = ->
		@.consoleLog()
		@.onComplete()
	
	# Animate
	w.Animate = ($elm, params1, params2) ->
		$elms.push $elm
		$params.push params1
		options2 = $.extend
			duration: 0
			easing: 'linear'
			complete: ->
		, params2
	
		@.animateFunc = ->
			$elm.animate params1, params2
			
		@.delay = options2.duration
		@.timer
		@
	
	w.Animate.prototype = new w.Command()
	w.Animate.prototype.execute = ->
		@.animateFunc();
		self = @;
		@.timer = setTimeout ->
			self.onComplete()
		, @.delay
		
	# Parallel
	w.Parallel = (coms) ->
		if coms
			@.commands = coms
		else
			@.commands = []
			
		@.count
		@
		
	w.Parallel.prototype = new w.Command()
	w.Parallel.prototype.execute = ->
		if @.commands.length is 0
			@.commands = []
			@.onComplete()
		else
			@.count = 0
			i = 0
			len = @.commands.length
			command = null
			self = @
			for i in [0..len-1]
				command = @.commands[i]
				command.delegate = ->
					self.commandComplete()
				command.execute()
				
	w.Parallel.prototype.add = (com) ->
		@.commands.push com
		
	w.Parallel.prototype.commandComplete = ->
		@.count++
		if @.count is @.commands.length
			@.onComplete()
			
	w.Parallel.prototype.remove = ->
		remove(@)
		
	w.Parallel.prototype.skip = ->
		skip(@)
	
	# Serial
	w.Serial = (coms) ->
		if coms
			@.commands = coms
		else
			@.commands = []
			
		@.currentCommand
		return @
		
	w.Serial.prototype = new w.Command()
	w.Serial.prototype.execute = ->
		if @.commands.length is 0
			@.onComplete()
		else
			@.currentCommand = @.commands.shift()
			self = @
			@.currentCommand.delegate = ->
				self.commandComplete()
			@.currentCommand.execute()
			
	w.Serial.prototype.add = (com) ->
		@.commands.push com
		
	w.Serial.prototype.commandComplete = ->
		@.currentCommand = null
		@.execute()
		
	w.Serial.prototype.remove = ->
		remove(@)
		
	w.Serial.prototype.skip = ->
		skip(@)
	
	skip = (_this) ->
		_this.commands = []
		_this.currentCommand = null
		_this.execute()
		n = 0
		$elms.forEach (elm) ->
			elm.stop().css($params[n])
			n++
		$elms = []
		$params = []
		
	remove = (_this) ->
		_this.commands = []
		_this.currentCommand = null
		_this.execute()
		$elms.forEach (elm) ->
			elm.stop()
		$elms = []
		
	@
)(window)
