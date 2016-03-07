---------------------------------------------------------------------------
-- SVN Keywords
--
-- $Date: 2009-11-12 17:39:41 +0100 (Thu, 12 Nov 2009) $
-- $Revision: 5770 $
-- $Author: slesch $
---------------------------------------------------------------------------

module("gui_stuff", package.seeall)
require("tester")
local nextID = tester.nextID

-------------------- set up GUI
-- get the maximum width of the elements in column iCol of a grid sizer
function getMaxWidth(grid, iCol)
	local nCol = grid:GetCols()
	local nRow = grid:GetRows()
	local iMaxWidth = 0
	for iRow = 1, nRow do
		local elem = grid:GetItem(nCol*iRow+iCol)
		if elem then
			local iWidth = elem:GetSize():GetWidth()
			if iWidth>iMaxWidth then iMaxWidth = iWidth end
		end
	end
	return iMaxWidth
end

-- set the width of all elements in column iCol of a grid sizer
function setColumnWidth(grid, iCol, iWidth)
	local nCol = grid:GetCols()
	local nRow = grid:GetRows()
	for iRow = 1, nRow do
		local elem = grid:GetItem(nCol*iRow+iCol)
		if elem then
			local size = elem:GetSize()
			size:SetWidth(iWidth)
			elem:SetMinSize(size)
		end
	end
end

-- set the width of all elements of column iCol of a number of grid sizers to the maximum
-- width found in that column
function setColumnMaxWidth(aGrids, iCol)
	local iMaxWidth = 0
	for _, grid in pairs(aGrids) do
		local iWidth = getMaxWidth(grid, iCol)
		if iWidth>iMaxWidth then iMaxWidth = iWidth end
	end
	for _, grid in pairs(aGrids) do
		setColumnWidth(grid, iCol, iMaxWidth)
	end
end

-- find out the maximum width of all elements in the list and set
-- each element's minimum size to this width.
function setMaxWidth(aItems)
	local iMaxWidth = 0
	for _, elem in pairs(aItems) do
		local iWidth = elem:GetSize():GetWidth()
		if iWidth>iMaxWidth then iMaxWidth = iWidth end
	end
	for _, elem in pairs(aItems) do
		local size = elem:GetSize()
		size:SetWidth(iMaxWidth)
		elem:SetMinSize(size)
	end
end


function confirmDialog(strCaption, strMessage)
	print(strCaption .. ": " .. strMessage)
	local dialog = wx.wxMessageDialog(__MUHKUH_PANEL, strMessage, strCaption,
		wx.wxYES_NO  + wx.wxICON_QUESTION + wx.wxSTAY_ON_TOP)
	local res = dialog:ShowModal()
	dialog:Destroy()
	return res==wx.wxID_YES
end

function messageDialog(strCaption, strMessage)
	print(strCaption .. ": " .. strMessage)
	local dialog = wx.wxMessageDialog(__MUHKUH_PANEL, strMessage, strCaption,
		wx.wxOK + wx.wxICON_INFORMATION + wx.wxSTAY_ON_TOP)
	dialog:ShowModal()
	dialog:Destroy()
end

function errorDialog(strCaption, strMessage)
	print(strCaption .. ": " .. strMessage)
	local dialog = wx.wxMessageDialog(__MUHKUH_PANEL, strMessage, strCaption, 
		wx.wxCANCEL + wx.wxICON_ERROR + wx.wxSTAY_ON_TOP)
	dialog:ShowModal()
	dialog:Destroy()
end

function internalErrorDialog(strMessage)
	errorDialog("Internal Error", 
	strMessage .."\n\n" ..
	"This error is caused by Muhkuh or the script, not by the hardware under test.\n" ..
	"Check if your installation of Muhkuh and the test script are complete and up to date.\n")
end


function createLabel(panel, strLabel)
	return wx.wxStaticText(panel, 0, strLabel)
end

local bmps = {} -- declaration

function createButton(parentPanel, strLabel, eventFunction)
	local id = nextID()
	local button = wx.wxButton(parentPanel, id, strLabel)
	parentPanel:Connect(id, wx.wxEVT_COMMAND_BUTTON_CLICKED, eventFunction)
	return button
end

function createToggleButton(parentPanel, strLabel, eventFunction)
	local id = nextID()
	local button = wx.wxToggleButton(parentPanel, id, strLabel)
	parentPanel:Connect(id, wx.wxEVT_COMMAND_BUTTON_CLICKED, eventFunction)
	return button
end

function createBitmapButton(parentPanel, iArtId, eventFunction)
	local xpm = xpms[iArtId]
	local bmp = wx.wxBitmap(xpm)
	local id = nextID()
	local button = wx.wxBitmapButton(parentPanel, id, bmp, wx.wxDefaultPosition, wx.wxDefaultSize, 
		wx.wxBU_RIGHT + wx.wxBU_EXACTFIT )
	parentPanel:Connect(id, wx.wxEVT_COMMAND_BUTTON_CLICKED, eventFunction)
	return button
end


function createBitmapButton2(parentPanel, iArtId, eventFunction)
	local bmp = wx.wxArtProvider.GetBitmap(iArtId, wx.wxART_BUTTON)
	local id = nextID()
	local button = wx.wxBitmapButton(parentPanel, id, bmp)
	parentPanel:Connect(id, wx.wxEVT_COMMAND_BUTTON_CLICKED, eventFunction)
	return button
end


function createToolbarButton(parentPanel, iArtId, strLabel, eventFunction)
	local bmp = bmps[iArtId]
	local toolbar = wx.wxToolBar(parentPanel, -1, wx.wxDefaultPosition, wx.wxDefaultSize, 
		wx.wxTB_HORIZONTAL + wx.wxTB_NODIVIDER + wx.wxTB_TEXT) --wx.wxTB_HORZ_TEXT)
	local id = nextID()
	toolbar:AddTool(id, strLabel, bmp)
	toolbar:Realize()
	parentPanel:Connect(id, wx.wxEVT_COMMAND_TOOL_CLICKED, eventFunction)
	return toolbar
end

function createRadioButton(parentPanel, strLabel, eventFunction, fBeginGroup)
	local id = tester.nextID()
	local style = fBeginGroup and wx.wxRB_GROUP or 0
	local button = wx.wxRadioButton(parentPanel, id, strLabel, wx.wxDefaultPosition, wx.wxDefaultSize, style)
	button:SetValue(false)
	parentPanel:Connect(id, wx.wxEVT_COMMAND_RADIOBUTTON_SELECTED, eventFunction)
	return button
end



local database_refresh_bmp = wx.wxBitmap({
--local database_refresh_xpm = {
--/* width height ncolors chars_per_pixel */
"16 16 150 2",
--/* colors */
"   c #B1B1B1",
" . c #AFAFAF",
" X c #75B16F",
" o c #B2DAAB",
" O c #ADADAD",
" + c #ABABAB",
" @ c #A9A9A9",
" # c #A7A7A7",
" $ c #367A31",
" % c #A5A5A5",
" & c #91CA87",
" * c #A3A3A3",
" = c #A1A1A1",
" - c #9F9F9F",
" ; c #D2D4D1",
" : c #2D6E28",
" > c #2A6A25",
" , c #999999",
" < c #83C479",
" 1 c #63955D",
" 2 c #959595",
" 3 c #5A9554",
" 4 c #919191",
" 5 c #387B32",
" 6 c #A7D59F",
" 7 c #33752D",
" 8 c #69B95E",
" 9 c #FEFEFE",
" 0 c #FCFCFC",
" q c #7BB973",
" w c #F8F8F8",
" e c #F6F6F6",
" r c #568852",
" t c #F4F4F4",
" y c #F2F2F2",
" u c #F0F0F0",
" i c #D7ECD4",
" p c #EEEEEE",
" a c #EAEAEA",
" s c #6AA962",
" d c #E8E8E8",
" f c #68A760",
" g c #E6E6E6",
" h c #63A15B",
" j c #E2E2E2",
" k c #E0E0E0",
" l c #DEDEDE",
" z c #5E9D56",
" x c #DCDCDC",
" c c #70A16B",
" v c #D8D8D8",
" b c #D6D6D6",
" n c #D4D4D4",
" m c #9FD099",
" M c #D2D2D2",
" N c #4E9746",
" B c #6FC063",
" V c #D0D0D0",
" C c #649B5F",
" Z c #B6CAB3",
" A c #CECECE",
" S c #82C279",
" D c #276623",
" F c #256421",
" G c #7EBE75",
" H c #7AC271",
" J c #C4C4C4",
" K c #C2C2C2",
" L c #C0C0C0",
" P c #BCBCBC",
" I c #BABABA",
" U c #B8B8B8",
" Y c #B7B8B7",
" T c #B6B6B6",
" R c #B4B4B4",
" E c #B2B2B2",
" W c #B0B0B0",
" Q c #AEAEAE",
" ! c #B1D9AA",
" ~ c #ACACAC",
" ^ c #AFD9A8",
" / c #59A650",
" ( c #97CD8D",
" ) c #94CB8A",
" _ c #8EC984",
" ` c #6AA064",
" ' c #2F712A",
" ] c #2E6F29",
" [ c #2B6B26",
" { c #969696",
" } c #909090",
" | c #8C8C8C",
".  c #67B75D",
".. c #64B35A",
".X c #61AF57",
".o c #3B8035",
".O c #5CA952",
".+ c #ADD8A5",
".@ c #AAD6A2",
".# c #8DC882",
".$ c #8CC881",
".% c #9CD294",
".& c #5D9B56",
".* c #5A9953",
".= c #589751",
".- c #4C9545",
".; c #6BBC60",
".: c #FFFFFF",
".> c #68B85D",
"., c #468D3F",
".< c #FDFDFD",
".1 c #236220",
".2 c #FBFBFB",
".3 c #205E1D",
".4 c #F9F9F9",
".5 c #41873A",
".6 c #F7F7F7",
".7 c #F5F5F5",
".8 c #74B46C",
".9 c #F3F3F3",
".0 c #EDEDED",
".q c #E7E7E7",
".w c #65A45D",
".e c #E1E1E1",
".r c #97CF8E",
".t c #DDDDDD",
".y c #DBDBDB",
".u c #599A51",
".i c #D9D9D9",
".p c #8FCD86",
".a c #D5D5D5",
".s c #CFCFCF",
".d c #4B9443",
".f c #296925",
".g c #83C37A",
".h c #CDCDCD",
".j c #246320",
".k c #458C3D",
".l c #215F1D",
".z c #78B76F",
".x c #BFBFBF",
".c c #BEBFBE",
".v c #74B36B",
".b c #72B569",
".n c #BBBBBB",
".m c #B9B9B9",
".M c #B7B7B7",
".N c #B5B5B5",
".B c #B3B3B3",
".V c None",
--/* pixels */
".V.V.V I U.M T R.B.V.V.V.V.V.V.V",
".V.n V d.9.< 0.0 k K O.V.V.V.V.V",
" I.e 9.:.:.:.:.:.:.2.s q.V.V.V.V",
".m w 9.:.:.:.:.:.:.2 a.b...V.V.V",
".M.6 V x d.4 i.p B.;.  S G /.V.V",
".N e j.h J Z <.% o ^.+.@ 6.8 N.V",
" R.7 p g j m.r !.g.X.O.z.v.-.V.V",
" E t a.e.t H.>.. X.x j.&.d.V.V.V",
" W.9.q.t.i k.y J Y.n.e 1.V.V.V.V",
" Q y j v.a x v L.B c k {.V.V.V.V",
" ~ u l n M.y ;.c C 3 l } 5 7 ] >",
" @ l.9.y M.y b ` s.w.o $.=.# h F",
".V % A.0 t.7.u f ( ) & _.$ f.j.V",
".V.V = - = + # r z.* ' [ D.1.V.V",
".V.V.V.V.V.V.V.V 7 ].V.V.V.V.V.V",
".V.V.V.V.V.V.V.V.V.f.V.V.V.V.V.V"
})

local folder_explore_bmp = wx.wxBitmap({
--local folder_explore_xpm = {
-- /* width height ncolors chars_per_pixel */
"16 16 147 2",
-- /* colors */
"   c #B68349",
" . c #F6E1AC",
" X c #E3C76B",
" o c #FAEDB3",
" O c #FFFDFA",
" + c #A8C2E0",
" @ c #FEFAEF",
" # c #9EBDE0",
" $ c #B87E44",
" % c #ABC6E6",
" & c #DFECF8",
" * c #FAECAC",
" = c #F3D88E",
" - c #FEFCF2",
" ; c #FDFAF1",
" : c #F9E9A1",
" > c #B17F4A",
" , c #CBE2F8",
" < c #F6E9C9",
" 1 c #F7E38B",
" 2 c #A7C4E5",
" 3 c #DCEAF8",
" 4 c #F9E9A4",
" 5 c #FCF2C8",
" 6 c #B2B3A7",
" 7 c #C7E0F7",
" 8 c #C5DEF5",
" 9 c #C4DCF4",
" 0 c #E2C35F",
" q c #DAAA36",
" w c #FEFBEE",
" e c #DA9A36",
" r c #C9DDF2",
" t c #BC8C54",
" y c #C1DAF4",
" u c #D3B89C",
" i c #B8D0EB",
" p c #CCE3F8",
" a c #9BBADF",
" s c #F6DE72",
" d c #A9C5E6",
" f c #BDD8F3",
" g c #FEFDF4",
" h c #D3E6F8",
" j c #B3D1F3",
" k c #D8872D",
" l c #F5E09F",
" z c #A36A27",
" x c #F8E48E",
" c c #FFFDF8",
" v c #A4C1E4",
" b c #DAAF35",
" n c #DAAB35",
" m c #F5DA63",
" M c #DEB992",
" N c #D4D4A9",
" B c #FEFCF0",
" V c #D8B22C",
" C c #CDE2F8",
" Z c #F2D581",
" A c #93B6E0",
" S c #AAC6E6",
" D c #FFFFFE",
" F c #F5DE91",
" G c #FEFCF3",
" H c #FDFAF2",
" J c #D8862C",
" K c #B5AFA8",
" L c #B4CDE9",
" P c #F5DE94",
" I c #F4DC93",
" U c #FEFCF6",
" Y c #DAAE34",
" T c #D6E4F3",
" R c #FBF7E9",
" E c #9AB6D9",
" W c #E2C360",
" Q c #EFD07A",
" ! c #BA8A50",
" ~ c #D98E33",
" ^ c #C99862",
" / c #F7E285",
" ( c #FEFBEF",
" ) c #DAA637",
" _ c #CEE3F8",
" ` c #FFFEFD",
" ' c #EECF72",
" ] c #EFD494",
" [ c #EFD280",
" { c #FFFDF6",
" } c #F7E181",
" | c #D9B132",
".  c #EDCA6A",
".. c #D3D2A3",
".X c #E4C76B",
".o c #F6DE76",
".O c #FBF6E8",
".+ c #A66C2B",
".@ c #E1C25E",
".# c #DAB336",
".$ c #DAAF36",
".% c #D6E5F5",
".& c #DAAB36",
".* c #E9C173",
".= c #DAA136",
".- c #C9DCF2",
".; c #FCF6D8",
".: c #D4A747",
".> c #FEFCF1",
"., c #CAE0F6",
".< c #EECE88",
".1 c #F8E695",
".2 c #FBEFB9",
".3 c #FFFFFF",
".4 c #99A3B2",
".5 c #A8C4E5",
".6 c #FFFCF5",
".7 c #D8882D",
".8 c #B3C6C8",
".9 c #F3D786",
".0 c #C6DEF5",
".q c #F4DB9E",
".w c #FAF0DC",
".e c #E6CD79",
".r c #FEFCF7",
".t c #D9B434",
".y c #F9E89C",
".u c #EFD385",
".i c #FBF7EA",
".p c #F8E591",
".a c #DA9435",
".s c #97A3B6",
".d c #F3DA96",
".f c #EACB6C",
".g c #D8B32C",
".h c #BACFE2",
".j c #DBB63C",
".k c #FFFEFE",
".l c #FEFEFD",
".z c #DBE7F5",
".x c #E5CA74",
".c c #9ABAE0",
".v c #F4DDA7",
".b c #C6DDF4",
".n c #EECF76",
".m c #C8955E",
".M c None",
-- /* pixels */
".M.M.M.M.M.M.M.M.M.M.M.M.M.M.M.M",
".t.@ W W W 0.j.M.M.M.M.M.M.M.M.M",
".#.l D.k ` D.i.X X X X.e.x.M.M.M",
" b.r x F l . ( g G.> ( w O.$.M.M",
" q ; P I Z. .f.u [ Q.n ' R Y.M.M",
" n.O ].<.* < - G - B ( w D.&.M.M",
" ) D c {.6 G.;.1 N.8 # 2.h.:.M.M",
".= U 5.2 *.y 1.. L.z & r i 6.M.M",
" e H o 4.1 /.o S T.,.0 8 h +.M.M",
".a @ :.p } s m # 3.b 9 f C v.M.M",
" ~.w.v.q.d =.9.5.% y f f p E.M.M",
".M.7 k.7.7.7.7 K.- _ 7 , j.4.M.M",
".M.M.M.M.M.M.M.M.M % d a.s u.m.M",
".M.M.M.M.M.M.M.M.M.M.M.M.M ^ M  ",
".M.M.M.M.M.M.M.M.M.M.M.M.M.M t !",
".M.M.M.M.M.M.M.M.M.M.M.M.M.M.M.M"
})

local textfield_bmp = wx.wxBitmap({
--/* width height ncolors chars_per_pixel */
"16 16 5 1",
--/* colors */
"  c #FCFCFC",
". c #E8E8E8",
"X c #FFFFFF",
"o c #C9C9C9",
"O c None",
--/* pixels */
"OOOOOOOOOOOOOOOO",
"OOOOOOOOOOOOOOOO",
"OOOOOOOOOOOOOOOO",
"OOOOOOOOOOOOOOOO",
"oooooooooooooooo",
"o              .",
"o o            .",
"o o            .",
"o o            .",
"o o            .",
"o              .",
"................",
"OOOOOOOOOOOOOOOO",
"OOOOOOOOOOOOOOOO",
"OOOOOOOOOOOOOOOO",
"OOOOOOOOOOOOOOOO"
})


bmps = {
[wx.wxART_LIST_VIEW]=database_refresh_bmp,
[wx.wxART_FILE_OPEN]=folder_explore_bmp,
text_copy=textfield_bmp}

