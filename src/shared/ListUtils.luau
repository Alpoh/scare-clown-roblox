local ListUtils = {}

function ListUtils.pickRandom(list)
	if #list == 0 then
		return nil
	end
	return list[math.random(1, #list)]
end

return ListUtils
