class Slowmotion:
	var obj
	var active = false
	var func_update
	var func_finish
	var duration = 1.0
	var time_step = 1.0
	var time_start = 0.0
	var time_scale_from = 0.1
	var time_scale_to = 1.0

	func start(time_scale_from, time_scale_to, duration, obj = null, func_update = "", func_finish = ""):
		self.obj = obj
		self.func_update = func_update
		self.func_finish = func_finish
		self.duration = duration
		time_step = 1.0 / duration
		time_start = OS.get_ticks_msec()
		self.time_scale_from = clamp(time_scale_from, 0.0, 1.0)
		self.time_scale_to = clamp(time_scale_to, 0.0, 1.0)
		Engine.time_scale = self.time_scale_from
		active = true
		
	func update(delta):
		if active:
			var elapsed = float(OS.get_ticks_msec() - time_start) / 1000
			var backward = time_scale_from > time_scale_to
			
			if elapsed > duration:
				active = false
				
				if obj and func_finish:
					obj.call_deferred(func_finish)
				
				Engine.time_scale = 1.0
			else:
				var t = clamp(elapsed * time_step, 0.0, 1.0)
				
				if backward:	
					t = 1 - t
					
				if obj and func_update:
					obj.callv(func_update, [t])
					
				Engine.time_scale = lerp(time_scale_from, time_scale_to, t)
