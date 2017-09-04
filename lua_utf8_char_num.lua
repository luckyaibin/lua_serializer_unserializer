
function mt.print_tree(root)
	local print = print
	local tconcat = table.concat
	local tinsert = table.insert
	local srep = string.rep
	local type = type
	local pairs = pairs
	local tostring = tostring
	local next = next
	if not mt.print_r then
		mt.print_r = function(root)
			local cache = {  [root] = "." }
			local function _dump(t,space,name)
				local temp = {}
				for k,v in pairs(t) do
					local key = tostring(k)
					if cache[v] then
						tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
					elseif type(v) == "table" then
						local new_key = name .. "." .. key
						cache[v] = new_key
						tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
					else
						tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
					end
				end
				return tconcat(temp,"\n"..space)
			end
			print(_dump(root, "",""))
		end
	end
	if root == nil then
		print('value is nil')
	else
		mt.print_r(root);
	end
end

--[[
UTF-8采用如下所示的二进制方式来表示31位UCS-4，X表示有效位：
1字节 0XXXXXXX
2字节 110XXXXX 10XXXXXX
3字节 1110XXXX 10XXXXXX 10XXXXXX
4字节 11110XXX 10XXXXXX 10XXXXXX 10XXXXXX
5字节 111110XX 10XXXXXX 10XXXXXX 10XXXXXX 10XXXXXX
6字节 1111110X 10XXXXXX 10XXXXXX 10XXXXXX 10XXXXXX 10XXXXXX
从上可以看得出，如果处在第一字节的引导字节最高位为0，则是一字节。否则看前导1的个数，来确定是几个字节长。前导1与有效位之间有0相隔，也可以通过首字节的值范围来确定字节数。
1字节 0  ~127
2字节 192~223
3字节 224~239
4字节 240~247
5字节 248~251
6字节 252~253
随后的字节每个都以10为前导位，取值范围则在128~191之间。可以立即得知一个字节是否为后续字节，因为引导字节的引导位不是00、01就是11，不会是10。
]]--
--获取utf8编码字符串里面字符（中文韩文英文等所有utf8编码的单个有效字符）的个数,而不是字节的长度
function mt.get_utf8_chrctr_num(str)
	local character_num = 0;
	local start_index = 1;
	while true do
		local char = string.sub(str,start_index,start_index);
		if char and start_index <= string.len(str) then
			local c = string.byte(char);
			local len = 1;
			if 0 <= c and c <= 127 then
				len = 1;
			elseif 192 <= c and c <= 223 then
				len = 2;
			elseif 224 <= c and c <= 239 then
				len = 3;
			elseif 240 <= c and c <= 247 then
				len = 4;
			elseif 248 <= c and c <= 251 then
				len = 5;
			elseif 252 <= c and c <= 253 then
				len = 6;
			else
				print(c,'error');
			end
			--print(start_index,len,c,char);
			--print('长度',len)
			start_index = start_index + len;
			character_num = character_num + 1;
		else
			break;
		end
	end
	--print('character_num::::',character_num);
	return character_num;
end

--迭代每个有效的utf8字符
function mt.utf8_each_charactor_iterator(str,iterator_fn)
	local character_num = 0;
	local start_index = 1;
	while true do
		local char = string.sub(str,start_index,start_index);
		if char and start_index <= string.len(str) then
			local c = string.byte(char);
			local len = 1;
			if 0 <= c and c <= 127 then
				len = 1;
			elseif 192 <= c and c <= 223 then
				len = 2;
			elseif 224 <= c and c <= 239 then
				len = 3;
			elseif 240 <= c and c <= 247 then
				len = 4;
			elseif 248 <= c and c <= 251 then
				len = 5;
			elseif 252 <= c and c <= 253 then
				len = 6;
			else
				print(c,'error');
			end
			iterator_fn(start_index,len);
			--print(start_index,len,c,char);
			--print('长度',len)
			start_index = start_index + len;
			character_num = character_num + 1;
		else
			break;
		end
	end
	--print('character_num::::',character_num);
	return character_num;
end

--截取utf8编码的str的前char_num个字符
function mt.get_utf8_substr(str,char_num)
	local substr;
	local character_num = 0;
	local start_index = 1;
	while true do
		local char = string.sub(str,start_index,start_index);
		if char and start_index <= string.len(str) then
			local c = string.byte(char);
			local len = 1;
			if 0 <= c and c <= 127 then
				len = 1;
			elseif 192 <= c and c <= 223 then
				len = 2;
			elseif 224 <= c and c <= 239 then
				len = 3;
			elseif 240 <= c and c <= 247 then
				len = 4;
			elseif 248 <= c and c <= 251 then
				len = 5;
			elseif 252 <= c and c <= 253 then
				len = 6;
			else
				print(c,'error');
			end
			--print(start_index,len,c,char);
			--print('长度',len)
			start_index = start_index + len;
			character_num = character_num + 1;
			if character_num >= char_num then
				substr = string.sub(str,1,start_index-1);
				break;
			end
		else
			break;
		end
	end
	return substr;
end

--满足策划的需求：名字里英文个数为E，汉字或韩文或其他个数为C，E*1 + C*2 <= 12
function mt.get_utf8_name_len(str)
	local name_len = 0;
	local start_index = 1;
	while true do
		local char = string.sub(str,start_index,start_index);
		if char and start_index <= string.len(str) then
			local c = string.byte(char);
			local len = 1;
			if 0 <= c and c <= 127 then
				len = 1;
			elseif 192 <= c and c <= 223 then
				len = 2;
			elseif 224 <= c and c <= 239 then
				len = 3;
			elseif 240 <= c and c <= 247 then
				len = 4;
			elseif 248 <= c and c <= 251 then
				len = 5;
			elseif 252 <= c and c <= 253 then
				len = 6;
			else
				print(c,'error');
			end
			--print(start_index,len,c,char,sfont_util.utf8_to_gbk(char));
			--print('curr len..',name_len,len,sfont_util.utf8_to_gbk(string.sub(str,start_index,start_index+len-1) ));
			start_index = start_index + len;
			if len == 1 then
				name_len = name_len + 1;
			else
				name_len = name_len + 2;
			end
		else
			break;
		end
	end
	print('name len::::',name_len);
	return name_len;
end

--把utf8字符串截取成小于等于(less equal -> le ) --byte_num字节的正确字符串（不能直接用string.sub，它会把有效字符从中间阶段，导致最后被截断的字符显示乱码）
--比如QQ昵称很长的时候暴力截断，有时会导致名字显示不出来
function mt.cut_utf8_chrctr_le_byte(str,byte_num)
	local start_index = 1;
	local sub_str = '';
	while true do
		local char = string.sub(str,start_index,start_index);
		if char and start_index <= string.len(str) then
			local c = string.byte(char);
			local len = 1;
			if 0 <= c and c <= 127 then
				len = 1;
			elseif 192 <= c and c <= 223 then
				len = 2;
			elseif 224 <= c and c <= 239 then
				len = 3;
			elseif 240 <= c and c <= 247 then
				len = 4;
			elseif 248 <= c and c <= 251 then
				len = 5;
			elseif 252 <= c and c <= 253 then
				len = 6;
			else
				print(c,'error');
			end
			
			if start_index + len - 1 <= byte_num then
				start_index = start_index + len;
			else
				break;--超过长度，结束
			end
		else
			break;
		end
	end
	
	if start_index > 1 then
		start_index = start_index - 1;
	end
	if start_index > string.len(str) then
		start_index = string.len(str);
	end
	
	sub_str = string.sub(str,1,start_index);
	
	--[[print('utf8 str',sub_str);
	local gbk_str = sfont_util.utf8_to_gbk(sub_str);
	print('gbk str',gbk_str,string.len(gbk_str));--]]
	
	return sub_str;
end
