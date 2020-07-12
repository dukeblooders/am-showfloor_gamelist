//******************************************************************************
// Snap arguments
//******************************************************************************
class SnapArgs
{
	loaddelay = 5		// Delay before image/video load
	swapdelay = 200		// Delay before image/video swap (100 = ~1 second)
}


//******************************************************************************
// Snap
//******************************************************************************
class Snap
{
	args = null; rectangle = null
	image = null; imagepath = null
	currentloaddelay = 0; currentswapdelay = 0
	
	constructor(_args, _rectangle)
	{
		args = _args
		rectangle = _rectangle
	}
	
	
	function init()
	{
		imagepath = fe.get_art("snap", 0, 0, 1) // 1:ImageOnly

		image = PreserveImage(imagepath, rectangle.x, rectangle.y, rectangle.width, rectangle.height)
		image.update()
	}	
	
	
	// Delayed load
	function initswap()
	{
		if (currentloaddelay > args.loaddelay)
			swap()
		else if (currentloaddelay < args.loaddelay)
			currentloaddelay++
		else
		{
			init()
			currentloaddelay++
		}
	}


	// Swap from image to video, if exists
	function swap()
	{
		if (image == null)
			return
			
		if (currentswapdelay < args.swapdelay)
			currentswapdelay++
		else if (currentswapdelay == args.swapdelay)
		{
			local videopath = fe.get_art("snap") // Image or video
		
			if (videopath != imagepath)
			{
				clear()

				image = PreserveImage(videopath, rectangle.x, rectangle.y, rectangle.width, rectangle.height)
				image.update()
			}
			
			currentswapdelay++
		}
	}
	
	
	function clear()
	{		
		image.art.video_playing = false
		image.art.visible = false
		image.art = null
	
		image.surface.visible = false
		image.surface = null
		
		image = null
		imagepath = null
	}
	
	
	function reset()
	{
		if (image != null)
			clear()
		
		currentloaddelay = 0
		currentswapdelay = 0
	}
}