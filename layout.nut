//******************************************************************************
// Modules
//******************************************************************************

fe.load_module("file");

fe.do_nut("tools.nut")
fe.do_nut("preserve.nut")
fe.do_nut("listbox.nut")
fe.do_nut("gallery.nut")
fe.do_nut("snap.nut")
fe.do_nut("controls.nut")


//******************************************************************************
// Layout
//******************************************************************************
local flw = fe.layout.width
local flh = fe.layout.height

fe.layout.font = "OpenSans-Bold.ttf"
fe.layout.page_size = 22

function resize(size)
{
	return size * flw / 1920 // Calculated from HD screen
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
listbox.rows = fe.layout.page_size
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
local lang1 = PreserveImage("", flw * 0.731, flh * 0.851, flw * 0.027, flh * 0.041)
local lang2 = PreserveImage("", flw * 0.731, flh * 0.796, flw * 0.027, flh * 0.041)

function updateLanguage(var)
{
	local info = fe.game_info(Info.Language, var)
	local languages = split(info, "/")
		
	if (languages.len() == 1)
	{
		lang1.file_name = "backgrounds/" + strip(languages[0]) + ".png"
		lang1.update()
		
		lang2.visible = false
	}
	else if (languages.len() == 2)
	{
		lang1.file_name = "backgrounds/" + strip(languages[1]) + ".png"
		lang1.update()
		
		lang2.file_name = "backgrounds/" + strip(languages[0]) + ".png"
		lang2.visible = true
		lang2.update()
	}
}


//*****************************************************************************
// Year
//******************************************************************************
text = fe.add_text("[Year]", flw * 0.95, flh * 0.949, flw * 0.03, flh * 0.025)
text.align = Align.Right
text.charsize = resize(20)
text.margin = 0


//******************************************************************************
// Game Gallery
//******************************************************************************
local galleryargs = GalleryArgs()
galleryargs.basepath = "../Roms/%s/media"
galleryargs.controlargs.charsizegroup = resize(28)
galleryargs.controlargs.charsize = resize(18)
galleryargs.controlargs.controlfolder = "controls"
galleryargs.controlargs.ellipsissize = resize(24)
galleryargs.controlargs.imagepath = "../buttons/%s.png"
galleryargs.controlargs.imagesize = resize(48)
galleryargs.controlargs.imagespace = resize(4)
galleryargs.controlargs.rowspace = resize(8)
galleryargs.imagefolder = "box"
galleryargs.wheelfolder = "wheel"
galleryargs.overview_charsize = resize(19)

local wheelrect = Rectangle(flw * 0.325, flh * 0.021, flw * 0.613, flh * 0.205)
local galleryrect = Rectangle(flw * 0.766 flh * 0.296, flw * 0.216, flh * 0.595)
local gallery = Gallery(galleryargs, wheelrect, galleryrect)


//******************************************************************************
// Game Gallery - Info
//******************************************************************************
local galleryinfoCurrent = fe.add_text("", flw * 0.819, flh * 0.949, flw * 0.05, flh * 0.025)
galleryinfoCurrent.align = Align.Right
galleryinfoCurrent.charsize = resize(20)
galleryinfoCurrent.margin = 0

local galleryinfo = fe.add_text("/", flw * 0.825, flh * 0.949, flw * 0.1, flh * 0.025)
galleryinfo.charsize = resize(20)
galleryinfo.margin = 0

local galleryinfoTotal = fe.add_text("", flw * 0.88, flh * 0.949, flw * 0.05 flh * 0.025)
galleryinfoTotal.align = Align.Left
galleryinfoTotal.charsize = resize(20)
galleryinfoTotal.margin = 0

function updateGalleryInfo()
{
	galleryinfoCurrent.msg = gallery.currentindex + 1
	galleryinfoTotal.msg = gallery.objlist.len()
}


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
	if (gallery.scroll(ttime)) updateGalleryInfo()
	snap.swap(ttime)
}

function transition_callback(ttype, var, ttime) 
{
	switch(ttype) 
	{
		case Transition.ToNewSelection:
			listbox.change(var)
			gallery.reset(var, false)
			updateGalleryInfo()
			snap.reset(current_ttime)
			updateLanguage(var)
			break
	
		case Transition.ToNewList:		
			updatePlatform()
			updateGameCount()
			listbox.change(var)
			gallery.reset(var, true)
			updateGalleryInfo()
			snap.reset(current_ttime)
			updateLanguage(var)
			break
			
		case Transition.FromGame:
			fe.signal("reload")
			break
	}
}

fe.add_ticks_callback("ticks_callback");
fe.add_transition_callback("transition_callback")