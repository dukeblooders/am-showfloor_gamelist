//******************************************************************************
// Controls arguments
//******************************************************************************
class ControlsArgs
{
	bgcolorgroup = Color(10, 10, 10, 200)
	bgcolor = Color(0, 0, 0, 100)
	charsizegroup = 28
	charsize = 18
	controlfolder = ""
	ellipsissize = 24
	imagepath = "" 				// Use %s for image name
	imagesize = 48
	imagespace = 4	
	rowspace = 8
	separator = ";"
}

//******************************************************************************
// Controls row
//******************************************************************************
class ControlsRow
{
	args = null
	rectangle = null
	rowindex = null
	
	text = null
	images = null
	
	
	constructor(_args, _rectangle, _rowindex)
	{
		args = _args
		rectangle = _rectangle
		rowindex = _rowindex
		images = []
		
		text = fe.add_text("", rectangle.x, rectangle.y, rectangle.width, rectangle.height)
		text.word_wrap = true
	}	
	
	
	function reset(line)
	{
		local values = split(line, args.separator)
		
		if (values.len() == 1)
		{
			setGroup(values[0])
		}
		else
		{
			local title = ""
			foreach	(value in values)
				if (value[0] == '$') break
				else title += strip(value) + "\n"
			
			setText(title)	
			setButtons(values)
		}
	}
	
		
	function setGroup(title)
	{
		text.msg = strip(title)
		text.align = Align.Centre
		text.charsize = args.charsizegroup
		text.bg_red = args.bgcolorgroup.r
		text.bg_blue = args.bgcolorgroup.b
		text.bg_green = args.bgcolorgroup.g
		text.bg_alpha = args.bgcolorgroup.a
	}
	
	
	function setText(title)
	{
		text.msg = strip(title)
		text.align = Align.Left
		text.charsize = args.charsize
		text.bg_red = args.bgcolor.r
		text.bg_blue = args.bgcolor.b
		text.bg_green = args.bgcolor.g
		text.bg_alpha = args.bgcolor.a
	}
	
	
	function setButtons(values)
	{
		local path = null
		local image = null	
		local x = args.imagespace + args.imagesize
		local imgindex = 0

		for (local i = values.len() - 1; i >= 0; i--)
			if (values[i][0] == '$')
			{
				path = format(args.imagepath, values[i].slice(1))
			
				if (images.len() <= imgindex)
					images.append(fe.add_image("", rectangle.x + rectangle.width - x, rectangle.y + args.imagespace, args.imagesize, args.imagesize))
				
				images[imgindex].file_name = path
				images[imgindex].visible = true
				
				x += args.imagesize + args.imagespace
				imgindex++
			}
	}
	
	
	function clear()
	{
		text.msg = ""
		text.bg_alpha = 0
		
		foreach	(image in images)
			image.visible = null
	}
}


//******************************************************************************
// Controls
//******************************************************************************
class Controls
{
	args = null
	
	lines = null
	rows = null
	ellipsis_up = null
	ellipsis_down = null
	currentindex = null
	maxrows = 0
	

	constructor(_args, rectangle)
	{
		args = _args
		rows = []
		
		local y = rectangle.y
		local itemheight = args.imagesize + args.imagespace * 2
		
		ellipsis_up = fe.add_text("...", rectangle.x, y, rectangle.width, args.ellipsissize)
		ellipsis_up.charsize = args.charsizegroup
		ellipsis_up.visible = false
		
		y += args.rowspace + args.ellipsissize
		while (y + itemheight + args.rowspace + args.ellipsissize < rectangle.y + rectangle.height)
		{
			rows.append(ControlsRow(args, Rectangle(rectangle.x, y, rectangle.width, itemheight), maxrows))
		
			y += itemheight + args.rowspace
			maxrows++
		}
		
		ellipsis_down = fe.add_text("...", rectangle.x, y, rectangle.width, args.ellipsissize)
		ellipsis_down.charsize = args.charsizegroup
		ellipsis_down.visible = false
	}	
	
	
	function reset(path)
	{
		local temp = []
        local f = ReadTextFile(path)
        while (!f.eos())
            temp.append(f.read_line())
	
		lines = temp.len() == 0 ? null : temp
		currentindex = 0
				
		reload(0)
	}
	

	function reload(indexchange)
	{
		switch (indexchange)
		{
			case -1:
				if (currentindex == 0) return
				else currentindex--
				break
				
			case 1:
				if (currentindex >= lines.len() - maxrows) return
				else currentindex++
				break
		}
	
		clear()
		
		if (lines != null)
		{			
			ellipsis_up.visible = currentindex > 0
			
			local index = null
			for (local i = 0; i < maxrows; i++)
			{
				index = i + currentindex
			
				if (lines[index] != "")
					rows[i].reset(lines[index])
			
				if (index == lines.len() - 1)
					return
			}
			
			ellipsis_down.visible = true
		}
	}
	
	
	function clear()
	{
		ellipsis_up.visible = false
		ellipsis_down.visible = false
	
		if (rows != null)
			foreach	(row in rows)
				row.clear()
	}
}