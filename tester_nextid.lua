module("tester", package.seeall)

local m_ID = wx.wxID_HIGHEST
function tester.nextID()
	m_ID = m_ID+1
	return m_ID
end