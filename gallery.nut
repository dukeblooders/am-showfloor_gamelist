//******************************************************************************
// Gallery arguments
//******************************************************************************
class GalleryArgs
{
	object_order = ["overview", "controls", "image", "wheel"]
	basepath = ""			// Use %s for current list
	controlargs = null
	imagefolder = ""
	wheelfolder = ""
	overview_align = Align.TopLeft
	overview_charsize = 20
	overview_margin = 0
	scroll_startline = 25				
	scroll_mindelay = 100
	input_up = "custom1"
	input_down = "custom2"
	input_swap = "custom3"
	
	constructor()
	{
		controlargs = ControlsArgs()
	}
}

//******************************************************************************
// Gallery platform 
//******************************************************************************
class GalleryPlatform
{
	platform = null
	imagefiles = null
	wheelfiles = null
}


//******************************************************************************
// Gallery object 
//******************************************************************************
class GalleryObject
{
	orderindex = null
	path = null
	pathindex = null
	
	constructor(_orderindex, _path)
	{
		orderindex = _orderindex
		path = _path
	}
}


//******************************************************************************
// Gallery (overview, image, controls, ...)
//******************************************************************************
class Gallery
{
	args = null
	line = null; wheel = null; image = null; overview = null; controls = null;
	platforms = null
	previoustick = 0

	currentindex = 0
	orderindex = 0
	wheels = null
	objlist = null


	constructor(_args, rectangleWheel, rectangleGallery)
	{		
		args = _args
	
		overview = fe.add_text("[Overview]", rectangleGallery.x, rectangleGallery.y, rectangleGallery.width, rectangleGallery.height)
		overview.word_wrap = true
		overview.align = args.overview_align
		overview.charsize = args.overview_charsize
		overview.margin = args.overview_margin
		
		wheel = PreserveImage("", rectangleWheel.x, rectangleWheel.y, rectangleWheel.width, rectangleWheel.height)		
		image = PreserveImage("", rectangleGallery.x, rectangleGallery.y, rectangleGallery.width, rectangleGallery.height)
		controls = Controls(args.controlargs, rectangleGallery)		
		
		reset(0, true)
	}
	
	
	//******************************************************************************
	// Reset
	//******************************************************************************

	function reset(var, reload_files)
	{
		wheels = []
		objlist = []
		
		if (reload_files) // Group files by platform for multi-plaforms lists
		{
			platforms = []
			readFiles();
		}
		
		local platform = fe.game_info(Info.Extra, var)
		local name = fe.game_info(Info.Name, var)
		local wheelorderindex = -1
		
		for (local i=0; i<args.object_order.len(); i++)
			switch (args.object_order[i])
			{
				case "overview":
					local overviewpath = "./scraper/" + fe.game_info(Info.Emulator, var) + "/overview/" + name + ".txt"
					if (doesFileExist(overviewpath))
						objlist.push(GalleryObject(i, null))
					break
					
				case "controls":
					local controlpath = format(args.basepath, platform) + "/" + args.controlargs.controlfolder + "/" + name + ".txt"
					if (doesFileExist(controlpath)) 
						objlist.push(GalleryObject(i, controlpath))
					else
						controls.clear()
					break
					
				case "image":
					getImages(i, platform, name, reload_files)				
					break
					
				case "wheel":
					wheelorderindex = i
					break
			}
					
		if (objlist.len() == 0)
			objlist.push(GalleryObject(0, null))	
			
		getWheels(wheelorderindex, platform, name, reload_files)
		
		updateCurrentIndex()
		load()
	}
	
	
	function doesFileExist(path)
	{
		try 
		{
			file(path, "r")
			return true
		}
		catch(e)
		{
			return false
		}
	}
	
	
	function updateCurrentIndex()
	{
		for (local i=0; i<objlist.len(); i++)
			if (objlist[i].orderindex == orderindex)
			{
				currentindex = i
				return
			}
		
		currentindex = 0
	}
	
	
		
	//******************************************************************************
	// Read files
	//******************************************************************************
	
	function readFiles()
	{
		local platform = null
		local path = null
		local files = null
		local platformobj
		
		for (local i=0; i<fe.list.size; i++)
		{
			platform = fe.game_info(Info.Extra, i)
			if (getPlatformObj(platform) != null)
				continue
			
			// New platform
			platformobj = GalleryPlatform()
			platformobj.platform = platform
			platformobj.imagefiles = []
			platformobj.wheelfiles = []
			platforms.push(platformobj)
			
			// Images - Files are grouped by letter to reduce load times
			path = "../../" + format(args.basepath, platform) + "/" + args.imagefolder
			files = DirectoryListing(path, false).results
			
			for (local i=0; i<255; i++)
				platformobj.imagefiles.push([])
			
			foreach	(file in files)
				platformobj.imagefiles[file[0]].push(file)
			
			// Wheels - Files are grouped by letter to reduce load times
			path = "../../" + format(args.basepath, platform) + "/" + args.wheelfolder
			files = DirectoryListing(path, false).results
			
			for (local i=0; i<255; i++)
				platformobj.wheelfiles.push([])
			
			foreach	(file in files)
				platformobj.wheelfiles[file[0]].push(file)
		}
	}
	
	
	function getPlatformObj(_platform)
	{
		foreach	(platform in platforms)
			if (platform.platform == _platform)
				return platform
			
		return null	
	}
		
	
	//******************************************************************************
	// Get current game files
	//******************************************************************************
		
	function getImages(index, platform, name, reload_files)
	{
		local path = format(args.basepath, platform) + "/" + args.imagefolder
		local imagefiles = getPlatformObj(platform).imagefiles

		for (local i=0; i<imagefiles[name[0]].len(); i++)
		{
			local r = regexp(name)
			local c = r.capture(imagefiles[name[0]][i])
			
			if (c != null)
			{
				local obj = getGalleryObject(index, path, name, imagefiles[name[0]][i])
				if (obj == null) continue
	
				objlist.push(obj)
			}
		}
	}


	function getWheels(index, platform, name, reload_files)
	{	
		local path = format(args.basepath, platform) + "/" + args.wheelfolder
		local wheelfiles = getPlatformObj(platform).wheelfiles
		
		for (local i=0; i<wheelfiles[name[0]].len(); i++)
		{
			local r = regexp(name)
			local c = r.capture(wheelfiles[name[0]][i])

			if (c != null)
			{
				local wheel = getGalleryObject(index, path, name, wheelfiles[name[0]][i])
				if (wheel == null) continue
			
				if (wheels.len() == 0) // Default wheel
					wheels.push(wheel)
				else
				{
					if (isMatchingWheel(index, wheel)) // Matching image-wheel
						wheels.push(wheel)
					else // Independant wheel
					{
						if (index != -1)
							objlist.push(wheel)
					}
				}
			}
		}
	}
	
	
	function isMatchingWheel(index, wheel)
	{
		foreach	(obj in objlist)
			if (obj.pathindex != null &&
				obj.orderindex != index &&
				obj.pathindex == wheel.pathindex) 
				return true
				
		return false
	}
		
	
	function getGalleryObject(index, path, name, filename)
	{
		local obj = GalleryObject(index, path + "/" + filename)

		if (filename == name + ".png") // Match name exactly
			return obj
	
		local length = name.len()
		if (filename[length] == 95) // Match name_? (95 = _ )
		{
			local index = filename.find(".", length + 1)
			local value = filename.slice(length + 1, index)
					
			try { obj.pathindex = value.tointeger() }
			catch (e) { }
			
			return obj
		}
		
		return null
	}
	

	//******************************************************************************
	// Load
	//******************************************************************************
	
	function load()
	{
		local obj = objlist[currentindex]
	
		loadObj(obj, true)
	}
	
	
	function loadObj(obj, setWheel)
	{	
		switch (args.object_order[obj.orderindex])
		{
			case "overview":
				if (setWheel) setWheelPath(wheels.len() == 0 ? "" : "../../" + wheels[0].path)
				image.visible = false
				overview.visible = true
				controls.clear()
				
				resetOverview()
				break
				
			case "controls":
				if (setWheel)
				{
					local index = getWheelIndex(obj)
					if (index != null) setWheelPath("../../" + index.path)
				}
				image.visible = false
				overview.visible = false
				controls.reset(obj.path)				
				break
				
			case "wheel":
				setWheelPath("../../" + obj.path) // Display wheel with first non-wheel object
				
				for (local i=0; i<objlist.len(); i++)
					if (objlist[i].orderindex != obj.orderindex)
					{
						loadObj(objlist[i], false)	// Display first object with independant wheel
						break
					}						
				break
			
			default:
				if (setWheel)
				{
					local index = getWheelIndex(obj)
					if (index != null) setWheelPath("../../" + index.path)
				}
				setImagePath("../../" + obj.path)
				image.visible = true
				overview.visible = false
				controls.clear()
				break
		}
	}
	
	
	function getWheelIndex(obj)
	{
		if (obj.pathindex != null)
			foreach (wheel in wheels)
				if (wheel.pathindex == obj.pathindex) // Matching wheel
					return wheel
					
		return wheels.len() == 0 ? null : wheels[0]  // Default wheel
	}
	
	
	function setWheelPath(path)
	{
		wheel.art.file_name = path
		wheel.update()
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


	//******************************************************************************
	// Callbacks
	//******************************************************************************

	function scroll(ttime)
	{
		if (fe.get_input_state(args.input_swap))
		{
			if (ttime > previoustick + 400)
			{
				currentindex++
				if (currentindex == objlist.len())
					currentindex = 0
	
				orderindex = objlist[currentindex].orderindex
			
				load()
				previoustick = ttime
				
				return true
			}
		}
		else 
		{
			if (ttime > previoustick + args.scroll_mindelay)
				if (fe.get_input_state(args.input_up))
				{
					if (overview.visible)
					{
						if (line > args.scroll_startline)
							overview.first_line_hint = --line
					}
					else if (controls.lines != null)
						controls.reload(-1)					
					
					previoustick = ttime
				}
				else if (fe.get_input_state(args.input_down))
				{
					if (overview.visible)
					{					
						overview.first_line_hint = ++line
						
						if (overview.msg_width == 0)
							resetOverview()
					}
					else if (controls.lines != null)			
						controls.reload(1)
				
					previoustick = ttime
				}
		}
		
		return false
	}
}