//******************************************************************************
// Snap arguments
//******************************************************************************
class SnapArgs
{
	loaddelay = 250			// Delay before image load
	swapdelay = 2000		// Delay before video swap
}


//******************************************************************************
// Snap
//******************************************************************************
class Snap
{
	args = null
	image = null; imagepath = null
	previousload = 0; previousswap = 0
	
	constructor(_args, rectangle)
	{
		args = _args
		
		image = PreserveImage("", rectangle.x, rectangle.y, rectangle.width, rectangle.height)
	}
	
	
	function init()
	{
		imagepath = fe.get_art("snap", 0, 0, 1) // 1:ImageOnly

		image.art.file_name = imagepath
		image.update()
		image.art.visible = true
	}	
	

	// Swap from image to video, if exists
	function swap(ttime)
	{
		if (previousload == -1)
		{
			if (previousswap != -1)
				if (ttime > previousswap + args.swapdelay)
				{
					local videopath = fe.get_art("snap") // Image or video
				
					if (videopath != imagepath)
					{
						image.art.file_name = videopath
						image.art.video_playing = true
						image.update()
					}
					
					previousswap = -1
				}
		}
		else if (ttime > previousload + args.loaddelay)
		{
			previousload = -1
			previousswap = ttime
			init()
		}
	}
	
	
	function reset(ttime)
	{
		if (image != null)
		{
			image.art.video_playing = false
			image.art.visible = false
		}
		
		previousload = ttime
	}
}