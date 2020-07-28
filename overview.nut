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
	input_swap = "custom3"
}


//******************************************************************************
// Overview / Controls image
//******************************************************************************
class Overview
{
	args = null
	line = null; overview = null; image = null
	swapmode = false
	previoustick = 0


	constructor(_args, rectangle)
	{
		args = _args
	
		overview = fe.add_text("[Overview]", rectangle.x, rectangle.y, rectangle.width, rectangle.height)
		overview.word_wrap = true
		overview.align = args.align
		overview.charsize = args.charsize
		overview.margin = args.margin
			
		image = PreserveImage("", rectangle.x, rectangle.y, rectangle.width, rectangle.height)
			
		reset(0)
	}
	

	function reset(var)
	{
		if (swapmode)
		{
			local flyerpath = fe.get_art("flyer", var)
			
			setImagePath(flyerpath == "" ? "backgrounds/noimage.png" : flyerpath)
			
			overview.visible = false
		}
		else
		{
			local controlpath = format(args.controlpath, fe.game_info(Info.Buttons, var), fe.game_info(Info.Name, var))
		
			setImagePath(controlpath)
		
			overview.visible = true
		}
	}
	
	
	function setImagePath(path)
	{
		image.art.file_name = path
		image.update()
	}
	
	
	function resetOverview()
	{
		line = args.scroll_startline
		overview.first_line_hint = line
	}
	

	function scroll(ttime)
	{
		if (fe.get_input_state(args.input_swap))
		{
			if (ttime > previoustick + 400)
			{
				swapmode = !swapmode
				reset(0)
				
				previoustick = ttime
				return
			}
		}
		else 
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
}