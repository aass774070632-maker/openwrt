local pcall, dofile, _G = pcall, dofile, _G

module "luci.version"

if pcall(dofile, "/etc/openwrt_release") and _G.DISTRIB_DESCRIPTION then
	distname    = ""
	distversion = _G.DISTRIB_DESCRIPTION
	if _G.DISTRIB_REVISION then
		distrevision = _G.DISTRIB_REVISION
		if not distversion:find(distrevision,1,true) then
			distversion = distversion .. " " .. distrevision
		end
	end
else
	distname    = "OpenWrt"
	distversion = "Development Snapshot"
end

luciname    = "LuCI (HEAD detached from 75e41cba) branch"
luciversion = "25.292.66247~75e41cb"
