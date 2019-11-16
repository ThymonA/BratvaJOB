-- Don't edit, code for formating money
function comma_value(amount)
	local formatted = amount
	while true do  
	  formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	  if (k==0) then
		break
	  end
	end
	return formatted
  end
  
  ---============================================================
  -- rounds a number to the nearest decimal places
  --
  function round(val, decimal)
	if (decimal) then
	  return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
	  return math.floor(val+0.5)
	end
  end
  
  --===================================================================
  -- given a numeric value formats output with comma to separate thousands
  -- and rounded to given decimal places
  --
  --
  function format_num(amount, decimal, prefix, neg_prefix)
	local str_amount,  formatted, famount, remain
  
	decimal = decimal or 2  -- default 2 decimal places
	neg_prefix = neg_prefix or "-" -- default negative sign
  
	famount = math.abs(round(amount,decimal))
	famount = math.floor(famount)
  
	remain = round(math.abs(amount) - famount, decimal)
  
		  -- comma to separate the thousands
	formatted = comma_value(famount)
  
		  -- attach the decimal portion
	if (decimal > 0) then
	  remain = string.sub(tostring(remain),3)
	  formatted = formatted .. "#" .. remain ..
				  string.rep("0", decimal - string.len(remain))
	end
  
		  -- attach prefix string e.g '$' 
	formatted = (prefix or "") .. formatted 
  
		  -- if value is negative then format accordingly
	if (amount<0) then
	  if (neg_prefix=="()") then
		formatted = "("..formatted ..")"
	  else
		formatted = neg_prefix .. formatted 
	  end
	end
  
	formatted = string.gsub(formatted, ',', '.')

	return string.gsub(formatted, '#', ',')
  end

  function round(num)
	return tonumber(string.format("%.0f", num))
  end

function LogToDiscord(webhooks, name, message, color, footer)
	for i = 1, #webhooks, 1 do
		local webhook = webhooks[i]
		SendToDiscord(webhook, name, message, color, footer)
	end
end

function SendToDiscord(webhook, name, message, color, footer)
	local DiscordWebHook = webhook
	local date_table = os.date("*t")
	local hour, minute, second = date_table.hour, date_table.min, date_table.sec
	local year, month, day = date_table.year, date_table.month, date_table.wday
	local result = string.format("%d-%d-%d %d:%d:%d", day, month, year, hour, minute, second)

  	local embeds = {
		{
			["title"] = message,
		  	["type"] = "rich",
		  	["color"] = color,
		  	["footer" ]=  {
				["text"] = footer .. ' @ ' .. result,
		 	},
		}
  	}

	if message == nil or message == '' then return FALSE end
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
  end