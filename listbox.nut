//******************************************************************************
// Color
//******************************************************************************
class Color
{
	r = null; g = null; b = null; a = null
	
	constructor(_r, _g, _b, _a)
	{
		r = _r
		g = _g
		b = _b
		a = _a
	}
}


//******************************************************************************
// Listbox item
//******************************************************************************
class ListboxItem
{
	listbox = null
	surface = null; text = null
	currentdelay = 0
	
	
	constructor(_listbox, y, itemheight, offset, var)
	{
		listbox = _listbox
		
		local name = fe.game_info(Info.Title, offset)
		
		if (offset == var)
		{
			local width = calculateSize(name)
		
			if (width < listbox.rectangle.width)
			{
				clearSurface()
				text = fe.add_text(name, listbox.rectangle.x, y, listbox.rectangle.width, itemheight)
			}
			else
			{
				surface = fe.add_surface(listbox.rectangle.width, itemheight)
				surface.x = listbox.rectangle.x
				surface.y = y
				
				text = surface.add_text(name, 0, 0, width + listbox.margin * 2, surface.height)
				listbox.scrollitem = this
			}
			
			configureTextSelection()
		}
		else
		{
			text = fe.add_text(name, listbox.rectangle.x, y, listbox.rectangle.width, itemheight)
					
			text.red = listbox.color.r
			text.blue = listbox.color.b
			text.green = listbox.color.g
			text.alpha = listbox.color.a
		}
		
		configureText()
	}
	
	
	function calculateSize(name)
	{
		local length = name.len()
		local multiplier = 0.5 	// Char size : half of width
		
		if (length > 35)
			multiplier = 0.58
		else if (length > 30)
			multiplier = 0.545
	
		return 	length * listbox.charsize * multiplier +  
				listbox.margin * 2 
	}

		
	function clearSurface()
	{
		if (surface == null)
			return
			
		listbox.scrollitem = null
			
		text.visible = false
		text = null
		surface.visible = false
		surface = null
	}
	
	
	function configureText()
	{
		text.align = listbox.align
		text.charsize = listbox.charsize
		text.margin = listbox.margin
	}
	
	
	function configureTextSelection()
	{
		text.red = listbox.sel_color.r
		text.blue = listbox.sel_color.b
		text.green = listbox.sel_color.g
		text.alpha = listbox.sel_color.a
		
		text.bg_red = listbox.sel_bgcolor.r
		text.bg_blue = listbox.sel_bgcolor.b
		text.bg_green = listbox.sel_bgcolor.g
		text.bg_alpha = listbox.sel_bgcolor.a
	}
	
	
	function scroll()
	{
		if (text.x + text.width <= surface.width)
		{
			if (currentdelay > 0)
				currentdelay--
			else
				text.x = 0
		}
		else
		{
			if (currentdelay < listbox.delay * 100)
				currentdelay++
			else
				text.x--
		}
	}
}


//******************************************************************************
// Listbox
//******************************************************************************
class ListBox
{
	rectangle = null
	texts = null
	scrollitem = null
	
	align = Align.Left
	rows = 10
	charsize = 20
	color = Color(0, 0, 0, 255) 
	sel_bgcolor = Color(200, 200, 200, 255)
	sel_color = Color(255, 255, 0, 255)
	margin = 10
	delay = 1
	

	constructor(_rectangle)
	{
		rectangle = _rectangle
	}
	
	
	function init(var)
	{
		local y = rectangle.y
		local itemheight = rectangle.height / rows
		local offset = getOffsetIndex(var)
		local maxitems = rows < fe.list.size ? rows : fe.list.size

		texts = []

		local item = null
		for (local i=0; i<maxitems; i++)
		{
			item = ListboxItem(this, y, itemheight, offset, var)
				
			texts.push(item.text)
			y += itemheight
			offset++
		}	
	}
		

	function initText(text)
	{
		text.align = align
		text.charsize = charsize
		text.margin = margin
	}
		
	
	function getOffsetIndex(var)
	{
		local index = fe.list.index + var
		local size = fe.list.size
		local middle = rows / 2
		
		if (index < 0) index += size
		else if (index >= size) index %= size
		
		if (index < middle || size < rows)
			return -index + var
		if (index > size - (rows - middle))
			return -rows + size - index + var
		
		return -middle + var
	}
	
	
	function change(var)
	{
		for (local i=0; i<texts.len(); i++)
			texts[i].visible = false
		
		init(var)
	}
		
	
	function scroll()
	{
		if (scrollitem == null)
			return

		scrollitem.scroll()	
	}
}