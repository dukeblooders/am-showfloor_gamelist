//******************************************************************************
// Modules
//******************************************************************************
fe.do_nut("tools.nut")
fe.do_nut("preserve.nut")
fe.do_nut("listbox.nut")
fe.do_nut("overview.nut")
fe.do_nut("snap.nut")


//******************************************************************************
// Layout
//******************************************************************************
local flw = fe.layout.width
local flh = fe.layout.height

fe.layout.font = "OpenSans-Bold.ttf"
fe.layout.page_size = 20

function resize(charsize)
{
	return charsize * flw / 1920 // Calculated from HD screen
}


//******************************************************************************
// Background
//******************************************************************************
fe.add_image("backgrounds/main.png", 0, 0, flw, flh)


//******************************************************************************
// Platform logo
//******************************************************************************
local platform = null
function updatePlatform()
{
	if (platform != null) platform.visible = false
	local name = "../showfloor/platforms/" + fe.list.name + ".png"
	platform = PreserveImage(name, flw * 0.009, flh * 0.033, flw * 0.239, flh * 0.17).update()
}


//******************************************************************************
// Listbox
//******************************************************************************
local listbox = ListBox(Rectangle(flw * 0.018, flh * 0.232, flw * 0.218, flh * 0.662))
listbox.rows = 22
listbox.charsize = resize(22)
listbox.sel_color = Color(255, 255, 255, 255)
listbox.sel_bgcolor = Color(0, 100, 220, 150)
listbox.init(0)


//******************************************************************************
// Game count
//******************************************************************************
local gamecount = fe.add_text("", flw * 0.018, flh * 0.94, flw * 0.219, flh * 0.04)
gamecount.charsize = resize(25)
gamecount.red = 0
gamecount.blue = 0
gamecount.green = 0

function updateGameCount()
{
	gamecount.msg = fe.list.size + " JEUX DISPONIBLES"
}


//******************************************************************************
// Game logo
//******************************************************************************
PreserveArt("wheel", flw * 0.325, flh * 0.021, flw * 0.613, flh * 0.205).update()


//*****************************************************************************
// Developper
//******************************************************************************
local text = fe.add_text("[Manufacturer]", flw * 0.284, flh * 0.949, flw * 0.207, flh * 0.025)
text.align = Align.Left
text.charsize = resize(20)
text.margin = 0


//*****************************************************************************
// Genre
//******************************************************************************
text = fe.add_text("[Category]", flw * 0.359, flh * 0.949, flw * 0.36, flh * 0.025)
text.align = Align.Right
text.charsize = resize(20)
text.margin = 0


//*****************************************************************************
// Players
//******************************************************************************
text = fe.add_text("[Players]", flw * 0.79, flh * 0.949, flw * 0.1, flh * 0.025)
text.align = Align.Left
text.charsize = resize(20)
text.margin = 0


//*****************************************************************************
// Languages
//******************************************************************************
text = fe.add_text("[Language]", flw * 0.825, flh * 0.949, flw * 0.1, flh * 0.025)
text.charsize = resize(20)
text.margin = 0


//*****************************************************************************
// Year
//******************************************************************************
text = fe.add_text("[Year]", flw * 0.95, flh * 0.949, flw * 0.03, flh * 0.025)
text.align = Align.Right
text.charsize = resize(20)
text.margin = 0


//******************************************************************************
// Game Overview
//******************************************************************************
local overviewargs = OverviewArgs()
overviewargs.charsize = resize(19)
overviewargs.controlpath = "../../../Roms/%s/media/controls/%s.png"

local overviewrect = Rectangle(flw * 0.767, flh * 0.296, flw * 0.216, flh * 0.595)
local overview = Overview(overviewargs, overviewrect)


//*****************************************************************************
// Snap (image + video)
//******************************************************************************
local snapargs = SnapArgs()
local snaprect = Rectangle(flw * 0.28, flh * 0.295, flw * 0.442, flh * 0.588)
local snap = Snap(snapargs, snaprect)


//******************************************************************************
// Callbacks
//******************************************************************************

local current_ttime = 0
function ticks_callback(ttime)
{
	current_ttime = ttime

	listbox.scroll()
	overview.scroll(ttime)
	snap.swap(ttime)
}

function transition_callback(ttype, var, ttime) 
{
	switch(ttype) 
	{
		case Transition.ToNewSelection:
			listbox.change(var)
			overview.reset(var)
			snap.reset(current_ttime)
			break
	
		case Transition.ToNewList:		
			updatePlatform()
			updateGameCount()
			listbox.change(var)
			overview.reset(var)
			snap.reset(current_ttime)
			break
			
		case Transition.FromGame:
			fe.signal("reload")
			break
	}
}

fe.add_ticks_callback("ticks_callback");
fe.add_transition_callback("transition_callback")