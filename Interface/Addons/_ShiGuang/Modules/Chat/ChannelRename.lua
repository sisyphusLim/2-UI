﻿local _, ns = ...
local M, R, U, I = unpack(ns)
local module = M:GetModule("Chat")

local gsub, strfind = string.gsub, string.find
local INTERFACE_ACTION_BLOCKED = INTERFACE_ACTION_BLOCKED

function module:UpdateChannelNames(text, ...)
	if strfind(text, INTERFACE_ACTION_BLOCKED) and not I.isDeveloper then return end

	local r, g, b = ...
	if MaoRUIPerDB["Chat"]["WhisperColor"] and strfind(text, U["Tell"].." |H[BN]*player.+%]") then
		r, g, b = r*.7, g*.7, b*.7
	end
		if (GetLocale() == "zhCN") then
		text = gsub(text, "|h%[(%d+)%. 综合.-%]|h", "|h%[%1%.综合%]|h")
		text = gsub(text, "|h%[(%d+)%. 交易.-%]|h", "|h%[%1%.交易%]|h")
		text = gsub(text, "|h%[(%d+)%. 本地防务.-%]|h", "|h%[%1%.防务%]|h")
		text = gsub(text, "|h%[(%d+)%. 寻求组队.-%]|h", "|h%[%1%.组队%]|h")
    text = gsub(text, "|h%[(%d+)%. 世界防务.-%]|h", "|h%[%1%.世界防务%]|h")
		text = gsub(text, "|h%[(%d+)%. 公会招募.-%]|h", "|h%[%1%.招募%]|h")
		text = gsub(text, "|h%[(%d+)%. 大脚世界频道%]|h", "|h%[%1%.世界%]|h")
		elseif (GetLocale() == "zhTW") then
		text = gsub(text, "|h%[(%d+)%. 綜合.-%]|h", "|h%[%1%.綜合%]|h")
		text = gsub(text, "|h%[(%d+)%. 貿易.-%]|h", "|h%[%1%.貿易%]|h")
		text = gsub(text, "|h%[(%d+)%. 本地防務.-%]|h", "|h%[%1%.防務%]|h")
		text = gsub(text, "|h%[(%d+)%. 尋求組隊.-%]|h", "|h%[%1%.組隊%]|h")
    text = gsub(text, "|h%[(%d+)%. 世界防務.-%]|h", "|h%[%1%.世界防務%]|h")
		text = gsub(text, "|h%[(%d+)%. 公會招募.-%]|h", "|h%[%1%.招募%]|h")
		text = gsub(text, "|h%[(%d+)%. 大腳世界頻道%]|h", "|h%[%1%.世界%]|h")
		else
		text = gsub(text, "|h%[(%d+)%. General.-%]|h", "|h%[%1%.General%]|h")
		text = gsub(text, "|h%[(%d+)%. Trade.-%]|h", "|h%[%1%.Trade%]|h")
		text = gsub(text, "|h%[(%d+)%. LocalDefense.-%]|h", "|h%[%1%.Defense%]|h")
		text = gsub(text, "|h%[(%d+)%. LookingForGroup.-%]|h", "|h%[%1%.LFG%]|h")
    text = gsub(text, "|h%[(%d+)%. WorldDefense.-%]|h", "|h%[%1%.WorldDefense%]|h")
		text = gsub(text, "|h%[(%d+)%. GuildRecruitment.-%]|h", "|h%[%1%.Recruitment%]|h")
		end
		return self.oldAddMsg(self, text, r, g, b) --self.oldAddMsg(self, gsub(text, "|h%[(%d+)%..-%]|h", "|h[%1]|h"), r, g, b)
end

function module:ChannelRename()
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame"..i]
			chatFrame.oldAddMsg = chatFrame.AddMessage
			chatFrame.AddMessage = module.UpdateChannelNames
		end
	end
end