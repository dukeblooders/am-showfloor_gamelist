//******************************************************************************
// Overview arguments
//******************************************************************************
class OverviewArgs
{
	align = Align.TopLeft
	charsize = 20
	margin = 0
	scroll_startline = 25				
	scroll_mindelay = 75
	controlpath = ""			// Use %s for current list
	input_up = "custom1"
	input_down = "custom2"
}


//******************************************************************************
// Overview / Controls image
//******************************************************************************
class Overview
{
	args = null
	rectangle = null

	line = null
	overview = null
	controls = null
	
	previoustick = 0


	constructor(_args, _rectangle,)
	{
		args = _args
		rectangle = _rectangle
	
		overview = fe.add_text("[Overview]", rectangle.x, rectangle.y, rectangle.width, rectangle.height)
		overview.word_wrap = true
		overview.align = args.align
		overview.charsize = args.charsize
		overview.margin = args.margin
			
		reset(0)
	}
	

	function reset(var)
	{
		if (controls != null)
		{
			controls.art.visible = false
			controls = null
		}
		
		if (overview.msg == "[Overview]") // Overview not found
		{	
			local path = format(args.controlpath, fe.game_info(Info.Buttons, var), fe.game_info(Info.Name, var))
			
			controls = PreserveImage(path, rectangle.x, rectangle.y, rectangle.width, rectangle.height)
			controls.update()
		}

		resetOverview()
	}
	
	
	function resetOverview()
	{
		line = args.scroll_startline
		overview.first_line_hint = line
	}
	

	function scroll(ttime)
	{
		if (ttime > previoustick + args.scroll_mindelay)
			if (fe.get_input_state(args.input_up))
			{
				overview.first_line_hint = line--
				previoustick = ttime
			}
			else if (fe.get_input_state(args.input_down))
			{
				overview.first_line_hint = line++
			
				if (overview.msg_width == 0)
				{
					if (overview.first_line_hint == 0)
						overview.first_line_hint = -1
				
					resetOverview()
				}
				
				previoustick = ttime
			}
	}
}