require("muhkuh_cli_init")
require("wx")
require("nxoeditor")

-- Create the main Frame.
m_tMainFrame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "netX Tag List Editor/NXO Builder @PROJECT_VERSION@", wx.wxDefaultPosition, wx.wxSize(640,480), wx.wxDEFAULT_FRAME_STYLE)
m_tPanel = wx.wxPanel(m_tMainFrame, wx.wxID_ANY)
-- show the frame window
m_tMainFrame:Show(true)

_G.__MUHKUH_PANEL = m_tPanel


nxoeditor.run()

wx.wxGetApp():MainLoop()
