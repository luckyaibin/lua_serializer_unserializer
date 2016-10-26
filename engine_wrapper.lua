--local print_tmp = print;
--print = function(...) print_tmp( os.date(),...) end;

--调试xxsg的逻辑
---disable-load-framework -workdir C:/quick-cocos2d-x-master/player/welcome/xxsg -startfile main.lua

--调试quick原来的逻辑
-- -disable-load-framework -workdir C:/quick-cocos2d-x-master/player/welcome -startfile scripts/main.lua

--调试选项
-- C:\quick-cocos2d-x-master\player\proj.win32\Debug\player.exe
-- -disable-load-framework -workdir C:/quick-cocos2d-x-master/player/welcome/xxsg -startfile main.lua
-- C:\quick-cocos2d-x-master\player\welcome\xxsg
--先打开c++里预定于的zlib
local zlib = package.preload.zlib();
require('src/lua_iostream')

function get_img(v,img_url)
	--print('img-', img_url)
	
	local is_exist = pack.fexists(SOURCE_PACK,img_url);
	local _name = cstr.hash_str(CONFIG.img_path..img_url);
	imgs_ = imgs_ or {};
	--imgs_保存的是图片句柄
	local img = imgs_[_name];
	--print(' wd load ', _name)
	
	--本地文件不存在，需要从http下载
	if not is_exist then
		img = picx.load_from_http(CONFIG.img_path..img_url, SOURCE_PACK);
		imgs_[_name]= img;
		lock_imgs[_name] = 1;
		if v then
			v.loadImgSize = v.loadImgSize + 1;
		end
	else--本地文件存在，但是句柄可能不存在
		if img == nil then
			local picx_ = {};
		picx_.loaded=function() return picx_.isloaded end;
		local CImage = CCImage:new();
		local img_data = CImage:initWithImageFile(SOURCE_PACK .. '/' .. img_url);
		picx_.img = CImage;
		picx_.filename = SOURCE_PACK ..'/'.. img_url
		picx_.isloaded = true;
		imgs_[_name]= picx_;
		
		img = picx_;
	else
		
	end
	-- 锁定图片
	if v and not v.nowuseimg[_name] then
		local lock_num = lock_imgs[_name] ;
		if lock_num then
			lock_num = lock_num + 1;
		else
			lock_num = 1;
		end;
		lock_imgs[_name] = lock_num;
	end
end



	if v and v.use_img_url and not v.nowuseimg[_name] then
		table.insert(v.use_img_url,_name)
		v.nowuseimg[_name] = true;
	else
		
	end;

	return img;
end;

function get_img(wnd,img_url)
	--print('img-', img_url)
	local _name = cstr.hash_str(CONFIG.img_path..img_url);
	local file_name = string.gsub(CONFIG.img_path..img_url,CONFIG.img_path,"");
	_name = string.gsub(file_name,"/","_");
	local is_exist = pack.fexists(SOURCE_PACK,_name);
	imgs_ = imgs_ or {};
	--imgs_保存的是图片句柄
	local img = imgs_[_name];
	--print(' wd load ', _name)
	
	--本地文件不存在，需要从http下载
	if not is_exist then
		img = picx.load_from_http(CONFIG.img_path..img_url, SOURCE_PACK);
		imgs_[_name]= img;
		lock_imgs[_name] = 1;
		if wnd then
			wnd.loadImgSize = wnd.loadImgSize + 1;
		end
	else--本地文件存在，但是句柄可能不存在
		--if img == nil then
			local picx_ = {};
			picx_.loaded=function() return picx_.isloaded end;
			local imgsp = CCImageNameToSprite(SOURCE_PACK .. '/' .. _name);
			picx_.img = imgsp;
			picx_.filename = SOURCE_PACK ..'/'.. _name
			picx_.isloaded = true;
			imgs_[_name]= picx_;
			img = picx_;
		--else
			
		--end
		-- 锁定图片
		if wnd and not wnd.nowuseimg[_name] then
			local lock_num = lock_imgs[_name] ;
			if lock_num then
				lock_num = lock_num + 1;
			else
				lock_num = 1;
			end;
			lock_imgs[_name] = lock_num;
		end
	end



	if wnd and wnd.use_img_url and not wnd.nowuseimg[_name] then
		table.insert(wnd.use_img_url,_name)
		wnd.nowuseimg[_name] = true;
	else
	
	end;

	return img;
end;

function to_unix_path(path)
	path = string.gsub(path,'\\','/');
	return path;
end


--from c:\abc\def\ghi.java
-- or         def\ghi.java
--get ghi.java
function get_file_name_from_path(path_name)
	path_name = to_unix_path(path_name)
	
	local _,_,file_name = string.find(path_name,'.*[/](.-)$')
	if not file_name then
		file_name = path_name;
	end
	return file_name;
end

function print_tree(root)
	local print = print
	local tconcat = table.concat
	local tinsert = table.insert
	local srep = string.rep
	local type = type
	local pairs = pairs
	local tostring = tostring
	local next = next
	if not print_r then
		print_r = function(root)
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
		print_r(root);
	end
end


--hex color 是 ARGB形式的32位整数
function hexcolor_to_int_argb(hex_color)
	local a = math.floor(hex_color / 0x01000000);
	hex_color = hex_color - a * 0x01000000;
	
	local r = math.floor(hex_color / 0x00010000);
	hex_color = hex_color - r * 0x00010000;
	
	local g = math.floor(hex_color / 0x00000100);
	hex_color = hex_color - g * 0x00000100;
	
	local b = math.floor(hex_color / 0x00000001);
	
	return a,r,g,b;
end

--hex color 是 ARGB形式的32位整数,a r g b ∈[0,1]
function hexcolor_to_float_argb(hex_color)
	local a = math.floor(hex_color / 0x01000000);
	hex_color = hex_color - a * 0x01000000;
	
	local r = math.floor(hex_color / 0x00010000);
	hex_color = hex_color - r * 0x00010000;
	
	local g = math.floor(hex_color / 0x00000100);
	hex_color = hex_color - g * 0x00000100;
	
	local b = math.floor(hex_color / 0x00000001);
	
	return a/255,r/255,g/255,b/255;
end

function int_color_to_float_color(color)
	return color/255;
end


function int_argb_to_hexcolor(a,r,g,b)
	local c = a * 0x01000000 + r * 0x00010000 + g * 0x00000100 + b;
	return c;
end
--Date
--此文件由[BabeLua]插件自动生成
function clone(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for key, value in pairs(object) do
			new_table[_copy(key)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

--Create an class.
function class(classname, super)
	local superType = type(super)
	local cls
	
	if superType ~= "function" and superType ~= "table" then
		superType = nil
		super = nil
	end
	
	if superType == "function" or (super and super.__ctype == 1) then
		-- inherited from native C++ Object
		cls = {}
		
		if superType == "table" then
			-- copy fields from super
			for k,v in pairs(super) do cls[k] = v end
			cls.__create = super.__create
			cls.super    = super
		else
			cls.__create = super
		end
		
	cls.ctor    = function() end
	cls.__cname = classname
	cls.__ctype = 1
	
	function cls.new(...)
		local instance = cls.__create(...)
		-- copy fields from class to native object
		for k,v in pairs(cls) do instance[k] = v end
		instance.class = cls
		instance:ctor(...)
		return instance
	end
	
else
	-- inherited from Lua Object
	if super then
		cls = clone(super)
		cls.super = super
	else
		cls = {ctor = function() end}
	end
	
	cls.__cname = classname
	cls.__ctype = 2 -- lua
	cls.__index = cls
	
	function cls.new(...)
		local instance = setmetatable({}, cls)
		instance.class = cls
		instance:ctor(...)
		return instance
	end
end

return cls
end

function getSuperMethod(table, methodName)
	local mt = getmetatable(table)
	local method = nil
	while mt and not method do
		method = mt[methodName]
		if not method then
			local index = mt.__index
			if index and type(index) == "function" then
				method = index(mt, methodName)
			elseif index and type(index) == "table" then
				method = index[methodName]
			end
		end
		mt = getmetatable(mt)
	end
	return method
end



function super(o,...)
	--if (o and o.super and o.super.ctor) then
	o.super.ctor(o,...)
	--end
end


function schedule(node, callback, delay)
	local delay = CCDelayTime:create(delay)
	local callfunc = CCCallFunc:create(callback)
	local sequence = CCSequence:createWithTwoActions(delay, callfunc)
	local action = CCRepeatForever:create(sequence)
	node:runAction(action)
	return action
end

function performWithDelay(node, callback, delay)
	local delay = CCDelayTime:create(delay)
	local callfunc = CCCallFunc:create(callback)
	local sequence = CCSequence:createWithTwoActions(delay, callfunc)
	node:runAction(sequence)
	return sequence
end



function S_dollar_sign(key)
	return false;
end

function L(str_to_wide_str)
	return str_to_wide_str
end

file=class("file");
file.file_status = false;


long={}
function long.new(num)
	return num;
end


inst = class('inst');


function inst.read_configure(config_name)
	inst_config = inst_config or {};
	inst_config['game_w'] = 640;
	inst_config['game_h'] = 960;
	
	inst_config['textNum'] = 5;
	print('get config:',config_name,inst_config[config_name]);
	return inst_config[config_name];
end

function inst.save_configure(key,value)
	inst_config = inst_config or {};
	inst_config[key] = value;
end

function inst.game_w()
	return inst.read_configure('game_w');
end

function inst.game_h()
	return inst.read_configure('game_h');
end

function inst.get_systeminf(systeminfo_key)
	return inst_config[systeminfo_key];
end

function inst.version()
	return '1.1.1'
end

function inst.ms()
	require('socket')
	local cc_timeval = device.gettime()
	
	--cc_timeval.tv_sec  seconds
	--cc_timeval.tv_usec microSeconds
	
	
	--print(cc_timeval.tv_sec,cc_timeval.tv_usec);
	return cc_timeval.tv_sec * 1000 + cc_timeval.tv_usec;
end

function inst.now()
	local v = inst.ms();
	return v;
end

function inst.checknetworkisvalid()
	return true;
end

function inst.set_fps(fps)
	print('set fps',fps);
end


time = class('time',inst);
time.__index = time;



g_curr_schedule_function = g_curr_schedule_function or nil;

function schedule_driver()
	if g_curr_schedule_function then
		g_curr_schedule_function();
		--g_curr_schedule_function = nil;
	end
end
CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(schedule_driver, 0, false);
function inst.set_on_tick(func)
	
	-- CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(func, 0, false)
	g_curr_schedule_function = func;
end


--[[inst.set_on_tick(

function ()
	ui_canvas:fillrect(0, 0, math.random(100,900), math.random(100,900), 
	int_argb_to_hexcolor( 
	math.random(100,255),
	math.random(100,255),
	math.random(100,255),
	math.random(100,255)),math.random(100,255))
end

);--]]

function inst.vibrate_start()
	
end

canvas = class("canvas");
canvas.__index = canvas;

function canvas:ctor()
	self.layer = CCLayer:create();
	local screenSize = CCDirector:sharedDirector():getWinSize();
	print(screenSize.width, screenSize.height)
	self.layer:setContentSize(CCSizeMake(screenSize.width, screenSize.height));
	
	self.clippingNode = CCDrawNode:create();--cc.ClippingNode:create()
	self.drawNode = display.newDrawNode();
	if self.layer and self.clippingNode then
		local stencil = CCDrawNode:create();
		print(self.layer:getContentSize().width,self.layer:getContentSize().height)
		--画一个多边形 这画一个屏幕宽高的矩形作为模板
		local color1 = ccc4f(1,0,0,0.5);
		local color2 = ccc4f(0,1,0,1);
		
		local params = {};
		params.fillColor = cc.c4f(1,0,0,0.5);
		params.borderWidth = 0;
		params.borderColor = cc.c4f(0,1,0,1);
		
		
		stencil:drawRect( {x=0,y=0,w=self.layer:getContentSize().width,h=self.layer:getContentSize().height},params ) --rectangle[0],rectangle[1],rectangle[2],rectangle[3],color1,0.5,color2);
		--self.clippingNode:setStencil(stencil);
		--self.clippingNode:setInverted(false)
		self.layer:addChild(self.clippingNode);
		--self.clippingNode:setContentSize(CCSizeMake(screenSize.width, screenSize.height));
		self.drawNode:setContentSize(CCSizeMake(screenSize.width, screenSize.height));
		self.clippingNode:addChild(self.drawNode);
		self.stencil = stencil;
	end
end

--左上角为锚点
function setAnchorPoint01(ccnode)
	ccnode:setAnchorPoint(ccp(0,1));
end

function setPosition(ccnode,x,y)
	print( tolua.type(ccnode));
	--print( tolua.takeownership(ccnode));
	-- print( tolua.releaseownership(ccnode));
	-- print( tolua.isnull(ccnode));
	-- print(tolua.inherit(ccnode));
	setAnchorPoint01(ccnode);
	ccnode:setPosition(x,y);
end



function onEdit(event, editbox)
    if event == "began" then
        -- 开始输入
		printf("editBox1 event began : text = %s", editbox:getText())
    elseif event == "changed" then
        -- 输入框内容发生变化
		printf("editBox1 event changed : text = %s", editbox:getText())
    elseif event == "ended" then
        -- 输入结束
		printf("editBox1 event ended : text = %s", editbox:getText())
    elseif event == "return" then
        -- 从输入框返回
		printf("editBox1 event return : text = %s", editbox:getText())
    end
end

textbox = class("textbox");
textbox.__index = textbox;
function textbox.create(text,maxlen,is_password,is_mutiline,ime,x,y,w,h)
	local editBox = ui.newEditBox({
        image = "res/EditBoxBg.png",
        size = CCSize(w, h),
        x = x,
        y = y,
        listener = onEdit});
		
			-----------------------------
			
			--设置CCEditBox控件中的文本
			  editBox:setPlaceHolder("Input here");
			
			  --设置文本字体和文本大小
			 -- editBox:setFont("Arial", 10);
			
			  --设置字体
			 -- editBox:setFontName("Arial");
			
			  --设置CCEditBox控件中显示的文本的大小
			  editBox:setFontSize(20);
			
			  --设置CCEditBox控件中显示的字体的颜色
			  --editBox:setFontColor(ccc3(255, 0, 0));
			
			  --设置CCEditBox控件的颜色
			  --editBox:setColor(ccc3(0, 255, 0));
			
			  --设置最多可以输入的字符的个数
			  editBox:setMaxLength(100);
			
			  --设置软键盘中回车按钮的样子
			  editBox:setReturnType(kKeyboardReturnTypeGo);
			
			  --设置输入模式
			  --kEditBoxInputModeAny表示可以输入任何数据
			  --editBox:setInputMode(kEditBoxInputModeAny);
			print('kEditBoxInputModeAny:',kEditBoxInputModeAny)
			print('cc.kEditBoxInputModeAny',cc.kEditBoxInputModeAny);
			
			---------------------------
			
   --editBox:setPlaceHolder("1234567890")
   -- editBox:setFontName(options.fontName)
   --- editBox:setFontSize(options.fontSize or 20)
    editBox:setText(1234567890)
    --editBox:setAnchorPoint(cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))
    if is_password then
    	editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	end
	if maxlen then
		editBox:setMaxLength(maxlen)
	end

	editBox:setPosition(x, y)
	

	
	return editBox	
end
function textbox.create(text,maxlen,is_password,is_mutiline,ime,x,y,w,h)
	 

    label = CCTextFieldTTF:textFieldWithPlaceHolder( text or '点我输入',CONFIG.font_name,CONFIG.font_size);
 
	label:setPosition(x,y);
	label:setContentSize(CCSizeMake(w, h))
	--label:setDimensions(CCSizeMake(50, 0));
	return label
end

function textbox.release(text_box)
	if text_box then
		text_box:setVisible(false);
		ui_canvas.drawNode:removeChild(text_box,true);
	end
end


function canvas:drawimage(picx_,x,y,alpha)
	local drawNode = self.drawNode;
	if not picx_ then
		print('not correct picx_...');
		return
	end
	alpha = alpha or 255;
	if not picx_.img then
		print('stop................',picx_.filename);
		return
	end
	local texture = CCTextureCache:sharedTextureCache():textureForKey(picx_.filename);
	if texture then
		print('existing...');
	elseif not texture then
		texture = CCTextureCache:sharedTextureCache():addUIImage(picx_.img, picx_.filename);
	end
	local sp = CCSprite:createWithTexture(texture);
	sp:ignoreAnchorPointForPosition(false);
	sp:setAnchorPoint(ccp(0,1));
	sp:setPosition(x,y);
	--sp:setAnchorPoint(ccp(0,0));
	drawNode:addChild(sp);
end

function canvas:drawimage(picx_,x,y,alpha)
	--do return end
	local drawNode = self.drawNode;
	if not picx_ then
		print('not correct picx_...');
		return
	end
	-- print(picx_.img,getmetatable(picx_.img));
	-- picx_.img:setPosition(x, y);
	alpha = alpha or 255;
	
	if not picx_.img then
		print('stop................',picx_.filename);
		return
	end
	
	local sp = picx_.img
	--sp:ignoreAnchorPointForPosition(false);
	if not sp.setAnchorPoint then
		local mt = getmetatable(sp);
		sysprint_table(mt);
		print('no setAnchorPoint function.....');
	end
	sp:setAnchorPoint(ccp(0,1));
	sp:setPosition(x,y);
	drawNode:addChild(sp);
end

function canvas:drawline(x1, y1, x2, y2, hex_color, alpha)
	--local drawNode = self.drawNode;
	local drawNode = self.drawNode;
	if drawNode then
		--cliplayer:addChild(drawNode);
		local a,r,g,b = hexcolor_to_float_argb(hex_color);
		a = int_color_to_float_color(alpha);
		
		local color = ccc4f(r,g,b,a);
		drawNode:drawSegment(CCPoint(x1, y1), CCPoint( x2, y2), 1, color);
	end
	
end



function canvas:drawtextbox(text_box)
	local drawNode = self.drawNode;
	--local cliplayer = self.clippingNode;
	
	--local ap = cliplayer:getAnchorPoint()
	--print('cliplayer position:',cliplayer:getPositionX(),cliplayer:getPositionY(),ap.x,ap.y);


	local ap = drawNode:getAnchorPoint()
	print('drawNode position:',drawNode:getPositionX(),drawNode:getPositionY(),ap.x,ap.y);
	
	if drawNode then
		drawNode:addChild(text_box)
	end
end

function canvas:drawtext( text,x,y,hex_color)
	local drawNode = self.drawNode;
	print(text, CONFIG.font_name, CONFIG.font_size);
	
	local a,r,g,b = hexcolor_to_int_argb(hex_color);
	
	local params = {
	text = text,
	font = CONFIG.font_name,
	size = CONFIG.font_size,
	color = ccc3(r,g,b),
	
	}
	local label = ui.newTTFLabel(params)
	drawNode:addChild(label);
	label:setPosition(x,y);
	
end

function canvas:create_drawnode()
	local drawNode = display.newDrawNode();
	return drawNode;
end
function canvas:release_drawnode(drawnode)
	print("release drawnode");
	drawnode:hide();
	local drawNode = self.drawNode
	drawNode:removeChild(drawnode,true);
end

function canvas:drawrect(x,y,w,h,hex_color, alpha,otherDrawNode)
	--local cliplayer = self.clippingNode;
	local drawNode = self.drawNode;
	if otherDrawNode then
		drawNode:addChild(otherDrawNode);
		--drawNode:setAnchorPoint(ccp(0.5,0.5));
		-- drawNode:drawDot(CCPoint(0,0), 20, ccc4f(1,1,1,1));
		
		 
		otherDrawNode:setContentSize(CCSizeMake(w, h));
		otherDrawNode:setPosition(x,y);
		--do return end
		--(CCPoint *verts, unsigned int count, const ccColor4F &fillColor, float borderWidth, const ccColor4F &borderColor)
		
		
		local a,r,g,b = hexcolor_to_float_argb(hex_color);
		a = int_color_to_float_color(alpha);
		local points ={
		{0,0},
		{w,0},
		{w,h},
		{0,h},
		};
		local params = {};
		params.fillColor = cc.c4f(r,g,b,0)
		params.borderWidth = 0;
		params.borderColor = cc.c4f(r,g,b,1);
		otherDrawNode:drawPolygon(points, params)
	else
	print('no drawNode');
	end
end

function canvas:fillrect(x,y,w,h,  hex_color, alpha,otherDrawNode)
	--do return end
	--local drawNode = self.drawNode;
	
	local cm = {
	0x00aa0000;
	0x0000aa00;
	0x000000aa;
	}
	--local rd = math.random(1,3);
	--hex_color = cm[rd]
	--hex_color = 0x00aa0000;
	--alpha = 150;
	--local cliplayer = self.clippingNode;
	local drawNode = self.drawNode;
	if otherDrawNode then
		drawNode:addChild(otherDrawNode);
		--local w = bottom_right_x - topleft_x;
		--local h = bottom_right_y - topleft_y;
		otherDrawNode:setContentSize(CCSizeMake(w, h));
		otherDrawNode:setPosition(x,y);
		local a,r,g,b = hexcolor_to_float_argb(hex_color);
		print(a,r,g,b)
		a = int_color_to_float_color(alpha);
		
		--a,r,g,b = 1,1,0,0
		local points ={
		{0,0},
		{w,0},
		{w,h},
		{0,h},
		};
		local params = {};
		params.fillColor = cc.c4f(r,g,b,a)
		params.borderWidth = 0;
		params.borderColor = cc.c4f(r,g,b,0);
		
		otherDrawNode:drawPolygon(points, params)
	else
		drawNode = self.drawNode;
	end
end





function canvas:measure_text(L_text)
	local len = string.len(L_text);
	return len;
end

function canvas:set_clip(x, y, w, h)
	do return end
	--print('CLIPPPPPPPPPPPPPPPPPPPPPP',x, y, w, h);
	local cliplayer = self.clippingNode;
	--do return end
	--删掉之前的stencil，设置新的裁剪范围
	if self.stencil then
		cliplayer:removeChild(self.stencil,true)
	end
	--cliplayer:setContentSize(CCSizeMake(100,50));

	local stencil = CCDrawNode:create();

	--画一个多边形 这画一个屏幕宽高的矩形作为模板
	local color1 = ccc4f(1,0,0,0.5);
	local color2 = ccc4f(0,1,0,1);

	local points ={
	{x,y},
	{x + w,y},
	{x + w,y+h},
	{x,y + h},
	};
	local params = {};
	params.fillColor = cc.c4f(1,0,0,0.5);
	params.borderWidth = 0;
	params.borderColor = cc.c4f(0,1,0,1);
	stencil:drawPolygon(points, params)

	self.clippingNode:setStencil(stencil);
	self.clippingNode:setInverted(false)
	self.stencil = stencil;
end

function canvas:cls_clip()
	do return end
	local cliplayer = self.clippingNode;
	--删掉之前的stencil，设置新的裁剪范围
	local res = cliplayer:removeChild(self.stencil,true)

	--self.clippingNode:setStencil(0);
	self.stencil = nil;
	--self:set_clip(0,0,960,640)
end

function canvas:releasetextobject(textobj)
	--local cliplayer = self.clippingNode;
	local drawNode = self.drawNode
	drawNode:removeChild(textobj,true);
end

function canvas:createtextobject(text,pos,len,font_size,eheadx,ismultiline,linew,linepadding,isprocessenter)
	--[[
	print(
	'text:',text,
	'pos:',pos,
	'len:',len,
	--'font_name:',font_name,
	'font_size:',font_size,'eheadx:',
	eheadx,
	'ismultiline:',ismultiline,
	'linew:',linew,
	'linepadding:',linepadding,
	'isprocessenter:',isprocessenter)
	--]]
	--text = 'chinese，我是中文';
	--local ttf = CCLabelTTF:create(text,'Courier New' or fontName, font_size);
	--local ccFontDefinition = ttf:getTextDefinition();
	--ttf:retain();
	--return ttf;	
	local params = {
	text = text,
	font = font_name or CONFIG.font_name,
	size = font_size or CONFIG.font_size,
	--color = ccc3(r,g,b),
	align = ui.TEXT_ALIGN_LEFT, --左对齐
	dimensions = CCSize(len, 0)
	}
	local label = ui.newTTFLabel(params)
	label:retain();
	if string.find(text,'.*23.*')then
		print('stop...');
		g_label = g_label or label;
	end
	print('xxxxxxxxxxxxx',label)
	return label;
end

function canvas:drawtextobject(ttf,x,y,hex_color,alpha)
	local a,r,g,b = hexcolor_to_int_argb(hex_color);
	-- local alighment = ttf:getHorizontalAlignment();
	local ccFontDefinition = ttf:getTextDefinition();
	ccFontDefinition.m_fontFillColor.r = r;
	ccFontDefinition.m_fontFillColor.g = g;
	ccFontDefinition.m_fontFillColor.b = b;
	
	
	--local cliplayer = self.clippingNode;
	local drawNode = self.drawNode
	if g_label == ttf then
		local t = ttf:getString();
		--print('draw glable',ttf,t)
		--local sx,sy = ttf:getScaleX(),ttf:getScaleY();
		--print(sx,sy)
	end
	ttf:setPosition(x,y)
	--print('xxxxxxxxxx:',ttf:description());
	drawNode:addChild(ttf);
	--这个要注释掉，要不然会现实太多的 CCLOGERROR("Currently only supported on iOS and Android!");
	--ttf:setTextDefinitionValue(ccFontDefinition);
end
function canvas:maincanvas()
	-- canvas.singleton_maincanvas =  canvas.singleton_maincanvas ;
	print('singleton_maincanvas:::',singleton_maincanvas)
	if not singleton_maincanvas then
		singleton_maincanvas = maincanvas.new()
		return  singleton_maincanvas;
	else
		return singleton_maincanvas
	end
end


--maincanvas同样有一个cclayer，只不过在调用构造函数时，调用基类的构造函数获得一个CCLayer，然后添加到自己独有的CCScene上去
maincanvas=class('maincanvas',canvas);
function maincanvas:ctor()
	if not self.has_instance then
		super(self,canvas);
		self.has_instance = true;
		self.scene = CCScene:create()
		
		self.layer:ignoreAnchorPointForPosition(false);
		self.layer:setAnchorPoint(ccp(0,1));
		self.layer:setPosition(0,0);
		self.scene:addChild(  self.layer);
		
		--启用触摸
		
		self.layer:setTouchEnabled(true);
		self.layer:registerScriptTouchHandler(touchHandlerDispatcher);
		CCDirector:sharedDirector():runWithScene(self.scene);
	else
		error('having an existing main canvas...');
	end
end





wstr = class('wstr');
function wstr.toint(v)
	return math.floor(tonumber(v));
end

function wstr.len(v)
	return string.len(v);
end

function wstr.cat(...)
	local res = '';
	local arg = { ... }
	for i,v in ipairs(arg) do
		res = res .. v;
	end
	return res;
end

function wstr.cstr(str)
	return str;
end

function wstr.sub(str,from,to)
	local sub = string.sub(str,from,to);
	return sub
end


cstr = class('cstr')
function cstr.wstr(str)
	return str;
end



function cstr.hash_str(str)
	return crypto.md5(str)
	--return 'hashed:' .. str;
end

function loadUserInfo(UINFO_PACK,UINFO_FNAME)
	return nil;
end

local url ="www.baidu.com"



local t1={};
local t2={1,2,3};

print(tostring(t1),tostring(t2));



http_request = class("http_request");
http_request.__index = http_request;

function http_request:newrequest()
	local req = http_request:new();
	--req.cc_request = network.createbareHTTPRequest();
	--req.cc_request:retain();
	return req;
end

function http_request:setdefaultattr(is_enable)
	--error('no such function');
	print('xxxxxx');
end

function http_request:seturl(url)
	self.__url = url;
	--self.__url = 'http://d.lanrentuku.com/down/png/1210/ikonos-png/warning-32.png';
	--self.cc_request:setUrl(url);
end

function http_request:geturl()
	return self.__url;
end

function http_request:setmethod(method)
	self.__method = method or 'GET';
	--self.cc_request:setRequestType(method_)
end

function http_request:setbodydata(buf_data)
	self.__buf_data = buf_data;
	--self.cc_request:setRequestData(buf_data,string.len(buf_data));
end

function http_request:set_onresponseend(callFun)
	self.__callFun = callFun;
	--self.cc_request:setResponseScriptCallback(callFun);
end

function http_request:setattr(key_str, vaule_str)
	self.__headers = self.__headers or {};
	self.__headers[key_str] = vaule_str;
	--设置http的自定义头
end

function http_request:set_attach(attach)
	self.__tag = attach;
end


--跟踪条公用
http = { };
http.request_id = 0;
http.id_request_map = {};
--[[参数：
list					要对应的list或listview，不是单独的lib，而要是button，因为trackbar内部要使用它创建定时器
c_track_bar				trackbar
c_indicator 			trackbar的指示
init_track_percengate 	初始时候的trackbar指示器所在的比例位置，取值为0~1。比如0.25 表示指示器在距离开头1/4的位置处
direction 				滑动方向，DIRECTION.vertical为垂直方向滑动，DIRECTION.horizontal为水平方向。默认为垂直方向
]]--


function http.on_request_back_dispatcher_not_use(CCHttpRequest_, isSucceed,body,header,status,errorBuffer)
	print(CCHttpRequest_,CCHttpRequest_:getTag(), isSucceed,string.sub(body,1,100),header,status,errorBuffer);
	
	local send_tag = CCHttpRequest_:getTag();
	--前4位置http附加tag，后面是请求附加tag
	local http_tag = string.sub(send_tag,1,4);
	local req_tag = string.sub(send_tag,5,string.len(send_tag));
	if req_tag then --修改成请求之前的tag
		CCHttpRequest_:setTag(req_tag);
	end
	
	
	local request = http.id_request_map[http_tag];
	
	if not (request and request.__callFun ) then
		print('invalid http request..');
	else
		local url = request:geturl();
		local code = -1;
		if isSucceed then
			code = 0;
		end
		--先解压
		local inflate = zlib.inflate()
		local inflated, eof, bytes_in, bytes_out = inflate(body,'full')
		--print(inflated, eof, bytes_in, bytes_out);
		--放入缓冲
		local buff_data = bufx.new();
		buff_data:set_raw_data(inflated);
		local data_len = buff_data:get_len();
		--local I = unserialize(inflated);
		--print_tree(I);
		request.__callFun(buff_data,data_len,url,tonumber(status),tonumber(req_tag),code,request);
		request = nil;
		http.id_request_map[http_tag] = nil;--
	end
end

function http.on_request_back_dispatcher2(event)
	
	local CCHTTPRequest = event.request	
	local send_tag = CCHTTPRequest:getTag();
	--前4位置http附加tag，后面是请求附加tag
	local http_tag = string.sub(send_tag,1,4);

	printf("event.name = %s",  event.name)
	local code = -1;
	local isSucceed;
	local status;
	local errorCode;
	local errorBuffer;
	if event.name == "completed" then
		status = CCHTTPRequest:getResponseStatusCode();
		isSucceed = true;
		code = 0;
		
		local request = http.id_request_map[http_tag];
		local url = request:geturl();
		local req_tag = string.sub(send_tag,5,string.len(send_tag));
		if req_tag then --修改成请求之前的tag
			CCHTTPRequest:setTag(req_tag);
		end
		local body = CCHTTPRequest:getResponseData();
		local header = CCHTTPRequest:getResponseHeadersString();
		print('header:::',header)
		local headers_parsed = http._parse_http_header(header);
		local buff_data = bufx.new();
		local data_len = 0;
		--先解压
		if headers_parsed['CE'] then
			local inflate = zlib.inflate()
			print('body:',string.sub(body,1,200));
			local inflated, eof, bytes_in, bytes_out = inflate(body,'full')
			print('gzip::::',inflated, eof, bytes_in, bytes_out);
			--放入缓冲
			buff_data:set_raw_data(inflated);
			data_len = buff_data:get_len();
		else
			--放入缓冲
			buff_data:set_raw_data(body);
			data_len = buff_data:get_len();
		end
		
		request.__callFun(buff_data,data_len,url,tonumber(status),tonumber(req_tag),code,request);
		request = nil;
		http.id_request_map[http_tag] = nil;
	elseif event.name == 'cancelled' then
		http.id_request_map[http_tag] = nil;
	elseif event.name == 'failed' then
		errorBuffer,errorCode = event.request:getErrorMessage() ,event.request:getErrorCode();
		print('http request event.name',event.name,errorBuffer,errorCode,'error here');
		---assert(tonumber(errorCode)==0)
		http.id_request_map[http_tag] = nil;
		--return;
	end	
end



function http:newrequest()
	local req = http_request:newrequest();
	return req;
end

function http.request(req)
	--sysprint_table(req)
	req.cc_request = network.createHTTPRequest(http.on_request_back_dispatcher2, req.__url, req.__method)
	local cc_request = req.cc_request;
	
	print(' cc_request:setRequestType:',req.__method);
	--自定义http头
	if req.__headers then
		for k,v in pairs(req.__headers) do
			cc_request:addRequestHeader(k .. ':' .. tostring(v));
		end
	end
	
	if req.__buf_data then
		--local buf_str = req.__buf_data:read_biox();
		--local len = req.__buf_data:get_len();
		--cc_request:setPOSTData(buf_str,len);
		local Len = string.len(req.__buf_data)
		cc_request:setPOSTData(req.__buf_data,Len);
	end
	http.request_id = http.request_id + 1;
	if http.request_id > 9999 then
		http.request_id = 0;
	end
	
	--保持4位数字的tag长度
	local http_tag = string.format("%04d", http.request_id);
	local send_tag = http_tag;
	if req.__tag then
		send_tag = send_tag .. req.__tag;
		print('http tag:',req.__tag)
	end
	cc_request:setTag(send_tag);
	
	--
	if req.__callFun then
		http.id_request_map[http_tag] = req;-- req.__callFun;
		--cc_request:setResponseScriptCallback(http.on_request_back_dispatcher);
	else
		error('no call back function.');
	end
	--CCHttpClient:getInstance():send(cc_request) ;
	cc_request:start();
end

function http.terminate(current_request)
	local cc_request = current_request.cc_request;
	cc_request:cancel();
	Url.current_request = nil;
end

function http._parse_http_header(header)
	--[[HTTP/1.1 200 OK
	Server: bfe/1.0.8.9
	Date: Wed, 09 Dec 2015 06:32:57 GMT
	Content-Type: image/png
	Content-Length: 3706
	Connection: keep-alive
	ETag: "2084273104"
	Last-Modified: Thu, 08 Oct 2015 08:46:10 GMT
	Expires: Wed, 06 Apr 2016 10:44:22 GMT
	Age: 4911988
	Cache-Control: max-age=15552000
	Accept-Ranges: bytes
	Access-Control-Allow-Origin: https://www.baidu.com
	--]]
	local HEADER_MAP = {
	['Content-Type']= 'Content%-Type%: (.-)\n';
	['Content-Length'] = 'Content%-Length%: (.-)\n';
	
	['CE'] = 'CE%: (.-)\n';
	}
	local parsed_header = {};
	local reg=HEADER_MAP['Content-Type'];
	print('reg',reg);
	_,_,parsed_header['Content-Type'] = string.find(header,reg);
	
	local reg=HEADER_MAP['Content-Length'];
	_,_,parsed_header['Content-Length'] = string.find(header,reg);
	
	local reg=HEADER_MAP['CE'];
	_,_,parsed_header['CE'] = string.find(header,reg);
	
	return parsed_header;
end


pack=class('pack',function() return CCFileUtils:sharedFileUtils() end);
pack.__index = pack;

function pack.read(pack_name,fname)
	local fileutil = CCFileUtils:sharedFileUtils();
	--local filedata,filesize = fileutil:getFileDataStdString(pack_name..'/' .. fname,'rb',0);
	local filedata = fileutil:getFileData(pack_name..'/' .. fname);
	local filesize = 0;
	if filedata then
		filesize = string.len(filedata);
	end
	return filedata,filesize;
end

function pack.save(pack_name,fname,buf,len)
	len = len or 0;
	-- local fileutil = CCFileUtils:sharedFileUtils();
	-- local writable_path = fileutil:getWritablePath();
	-- print('writable_path:::',writable_path);
	local file = io.open(pack_name..'/' .. fname,'wb+');
	if file then
		if len > 0 then
			file:write(string.sub(buf,1,len));
		else
			file:write(buf);
		end
		file:close();
		return true;
	else
		return nil;
	end
end

function pack.fexists(pack_name,fname)
	local fileutil = CCFileUtils:sharedFileUtils();
	local isexist,filename = fileutil:isFileExist(pack_name..'/' .. fname);
	print(isexist,filename)
	return isexist,filename
end

function pack.exists(name)
	local fileutil = CCFileUtils:sharedFileUtils();
	local isexist,filename = fileutil:isFileExist(name);
	print(isexist,filename)
	return isexist,filename
end


local test = {};
test.fn = function(CCHttpRequest_, isSucceed,body,header,status,errorBuffer)
	print(CCHttpRequest_,CCHttpRequest_:getTag(), isSucceed,header,status);
	if status ~= 200 then
		print("error:",errorBuffer);
	end
	
	print('body')
	print(string.sub(body,1,100));
	-- local myxml = CCFileUtils:sharedFileUtils():getStringFromFile("res/config/map_walk.xml");
end

--http_manager.request_url('https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png',test.fn);

--http_manager.request_url('www.163.com',test.fn);

picx=class('picx');
function picx.load_from_http(img_path, pack_name)
	print('load_from_http',img_path, pack_name,"http get img canceld..");
	--do return end
	local name = get_file_name_from_path(img_path);
	local picx_ = {};
	picx_.loaded=function() 
		return picx_.isloaded
	end;

	local pic_http_down_loaded = function(event)
		if event.name == "completed" then
			--调用回调
			--on_load_img(img, err)
			if loading.init_ok then
				loading:loadimg()
			end
			local status = event.request:getResponseStatusCode()
			if status ~= 200 then
				print("file not exists!!!!!!!!!!!!!!!")
				picx_.isloaded = save_ok;
				return
			end
			local buff_data = event.request:getResponseData();
			local data_len = string.len(buff_data);

			--local file_name = crypto.md5(event.request:getRequestUrl())
			--local file_name = cstr.hash_str(event.request:getRequestUrl());
			local file_name = string.gsub(event.request:getRequestUrl(),CONFIG.img_path,"");
			file_name = string.gsub(file_name,"/","_");
			print("down img_path=",event.request:getRequestUrl(),file_name)
			local save_ok = pack.save(pack_name,file_name,buff_data,data_len);
			
			local img = CCImage:new();
			local img_data = img:initWithImageFile(pack_name ..'/'.. file_name);
			
			local sp = __CCImageToSprite(img,pack_name ..'/'.. file_name);
			picx_.img = sp;
			picx_.filename = pack_name ..'/'.. file_name
			picx_.isloaded = save_ok;
		else
			errorBuffer,errorCode = event.request:getErrorMessage() ,event.request:getErrorCode();
			print('http request event.name',event.name,errorBuffer,errorCode,'error here');
			return;
		end
	end
	
	print('img_path:::',img_path);
	local httpreq = network.createHTTPRequest(pic_http_down_loaded, img_path, kCCHTTPRequestMethodGET)
	httpreq:start();
	return picx_
end

function picx.set_callback(on_load_img)
	
end


function __CCImageToSprite(image,name)
	local texture = CCTextureCache:sharedTextureCache():textureForKey(name);
	if texture then
		print('existing...');
	elseif not texture then
		texture = CCTextureCache:sharedTextureCache():addUIImage(image, name);
	end
	local sp = CCSprite:createWithTexture(texture);
	sp:retain();
	return sp;
end

function CCImageDataToSprite(img_data,name)
	local img = CCImage:new();
	print('kFmtPng:',CCImage.kFmtPng,kFmtPng)
	local ok = img:initWithImageDataString(img_data,string.len(img_data),kFmtPng,0,0,8);
	
	local sp;
	if ok then
		sp = __CCImageToSprite(img,name or '');
		--img.release();
	end
	return sp;
end


function CCImageNameToSprite(image_name)
	local image = CCImage:new();
	local img_data = image:initWithImageFile(image_name);
	local sp = __CCImageToSprite(image,image_name)
	return sp;
end

function picx.release(img_lib)
	
	--do return end
	img_lib.img:setVisible(false);
	local canv = canvas.maincanvas();
	canv.clippingNode:removeChild(img_lib.img,true);
	img_lib.img:release();
end

function picx.load_from_data(img_data)
	local img = CCImage:new();
	print('kFmtPng:',CCImage.kFmtPng)
	local ok = img:initWithImageDataString(img_data,string.len(img_data),CCImage.kFmtPng,0,0,8);
	------------
	--local texture = CCTextureCache:sharedTextureCache():addUIImage(img,'');
	--local sp = CCSprite:createWithTexture(texture);
	-- sp:ignoreAnchorPointForPosition(false);
	-- sp:setAnchorPoint(ccp(0,1));
	return img
	----------
end

function picx.load_from_data(img_data)
	return CCImageDataToSprite(img_data);
	----------
end

util = {};
function util.gzip_decompress(compressed_str,length)
	local compressed
	print(string.len(compressed_str))
	--[[if length then
		compressed = string.sub(compressed_str,length);
	else
		compressed = compressed_str;
	end--]]
	
	local inflate = zlib.inflate()
	local inflated, eof, bytes_in, bytes_out = inflate(compressed_str,'full')
	print(inflated, eof, bytes_in, bytes_out);
	return inflated,bytes_out;
end


LUAX_TTABLE = 'table';
LUAX_TWSTR = 'wide_string';
LUAX_TCSTR = 'ansi_string';
LUAX_TNUMBER = 'number';
LUAX_TBUFX = 'buffer';
function util.type(x)
	if type(x) == 'table' then
		if getmetatable(x) == bufx then
			return LUAX_TBUFX;
		else
			return LUAX_TTABLE;
		end
	elseif type(x) == 'string' then
		for i=1,string.len(x) do
			local c = string.byte(x,i);
			if c >= 255 then --有一个超限的就是宽字符
				return LUAX_TWSTR;
			end
		end
		return LUAX_TCSTR;--全都是ansi字符
	elseif type(x) == 'number' then
		return LUAX_TNUMBER;
	else
		
		print('xxxxxxxxxxxxx wrong type????????????????')
	end
end

function util.pos_in_rect(x, y, start_x,start_y,width,height)
	if x >= start_x and x<=start_x + width and y >=start_y and y <= start_y + height then
		return true;
	end
end


bufx = class("bufx");
bufx.__index = bufx;

function bufx:get_len()
	return string.len(self.buf_string);
end

function bufx:ctor(size,t)
	self.buf_string = string.rep('\0',size or 0);
end

function bufx:set_raw_data(raw_data)
	self.buf_string = raw_data;
end

function bufx:get_raw_data()
	return self.buf_string ;
end

function bufx:write_biox(data)
	self.buf_string = serialize(data);
	--error("not implemented");
end

function bufx:read_biox()
	local ls = LuaInputStream.new();
	ls:put_raw_data(self.buf_string);
	local ret,err = unserialize_helper(ls);
	ls = nil;
	return ret,err;
end

function bufx.free(buf)
	if type(buf) == 'string' then
		print('bufx.free can not free string ...');
		return
	end
	buf.buf_string = nil;
end





------------------------------------------

function touchHandlerDispatcher(eventType,x,y,z,w,n,m,o,p)
	--log("eventType = "..tostring(eventType))
	local touch_xy_set = { };
	table.insert(touch_xy_set,{x=x,y=y});
	print('touched at :',eventType,"x:",x,"y:",y,z,w,n,m,o,p);
	if eventType == "began" then
		--需要返回true
		return btnTouchBegin(touch_xy_set, event)
	elseif eventType == "moved" then
		btnTouchMove(touch_xy_set, event)
	elseif eventType == "ended" then
		btnTouchEnd(touch_xy_set, event)
	end
end


function btnTouchBegin(touch_xy_set)
	CCLuaLog("btnTouchBegin");
	--  local v = e[1];
	--  local pointMove = v:locationInView(v:view());
	-- pointMove = CCDirector:sharedDirector():convertToGL(pointMove);
	--   spriteForWorld:setPosition(CCPoint(pointMove.x,pointMove.y));
	
	--spriteForWorld:setPosition(CCPoint(touch_xy.x,touch_xy.y));
	local res = touch.callback_on_touches_begin(touch_xy_set);
	
	return true;
end


function btnTouchMove(touch_xy_set)
	CCLuaLog("btnTouchMove");
	-- local v = e[1];
	-- local pointMove = v:locationInView(v:view());
	-- pointMove = CCDirector:sharedDirector():convertToGL(pointMove);
	--spriteForWorld:setPosition(CCPoint(pointMove.x,pointMove.y));
	--spriteForWorld:setPosition(CCPoint(touch_xy.x,touch_xy.y));
	touch.callback_on_touches_moved(touch_xy_set);
end

function btnTouchEnd(touch_xy_set)
	CCLuaLog("btnCouchEnd");
	touch.callback_on_touches_ended(touch_xy_set);
end

touch = {};


function touch.set_on_touches_began(on_touches_begin)
	touch.callback_on_touches_begin = on_touches_begin;
end

function touch.set_on_touches_moved(on_touches_moved)
	touch.callback_on_touches_moved = on_touches_moved;
end

function touch.set_on_touches_ended(on_touches_ended)
	touch.callback_on_touches_ended = on_touches_ended;
end


function test_gzip()
	local body = 'hello zip';
	local inflate = zlib.inflate()
	local inflated, eof, bytes_in, bytes_out = inflate(body,'full')
	
	print(inflated, eof, bytes_in, bytes_out);
	
	local deflate = zlib.deflate()
	local deflated, eof, bytes_in, bytes_out = deflate(inflated, "full")
	print(inflated, eof, bytes_in, bytes_out)
end

function test_stats()
	local string = ("one"):rep(20)
	local deflated, eof, bin, bout = zlib.deflate()(string, 'finish')
	print(deflated, eof, bin, bout);
	assert(eof == true, "eof is true (" .. tostring(eof) .. ")");
	assert(bin > bout, "bytes in is greater than bytes out?")
	assert(#deflated == bout, "bytes out is the same size as deflated string length")
	assert(#string == bin, "bytes in is the same size as the input string length")
end

function test_zip_unzip()
	local string = ("asdf_"):rep(200)
	local deflated, eof, bin, bout = zlib.deflate()(string, 'finish')
	print(deflated, eof, bin, bout);
	
	local inflate = zlib.inflate()
	local inflated, eof, bytes_in, bytes_out = inflate(deflated,'full')
	
	print(inflated, eof, bytes_in, bytes_out);
	
end

--print(pcall(test_zip_unzip));

print_tree(t2);


luax = class('luax');
function luax.load_data(buffer,start,len,name2)
	
	--[[--pack.save('.','binary.data',buffer,len)
	local XIS_header = string.sub(buffer,1,3);
	local version = string.byte(buffer,4);
	local content_type1 = string.byte(buffer,5);
	local content_type2 = string.byte(buffer,6);
	
	local encrypt_type = string.byte(buffer,7);
	local compress_type = string.byte(buffer,8);
	
	local raw_len1 = string.byte(buffer,9);
	local raw_len2 = string.byte(buffer,10);
	local raw_len3 = string.byte(buffer,11);
	local raw_len4 = string.byte(buffer,12);
	--print(raw_len1,raw_len2,raw_len3,raw_len4);
	
	local real_len = raw_len1 * 0x00000001 + raw_len2 * 0x00000100 + raw_len3 * 0x00010000 + raw_len4 * 0x01000000;
	--print(real_len);
	
	local md5 = string.sub(buffer,13,13+15);
	for i=1,16 do
		print( string.format("%0x",string.byte(md5,i)));
	end
	
	local data = string.sub(buffer,29,29 + real_len - 1);--]]
	--print(data);
	local ret,err = pcall(loadstring,buffer)
	--ret() --这里会直接崩溃掉，不清楚原因，但是存到文件然后load就没问题，非常奇怪
	--print('111helpInfos::',helpInfos);
	--load_lua('src/ios640-help.1448450005586');
	--print('222helpInfos::',helpInfos);
	
	--pack.save('.',name2,data,real_len)
	return true;
end


--http://127.0.0.1:8080/sanguo_ios_inland/resource?c=MainSvc&m=getMain&p1=0
--http://127.0.0.1:8080/sanguo_ios_inland/imgs/ov/ov2.png

--endregion

--创建文本对象
function createTextObject(text,pos,len,fontsize,headx,ismultiline,linew,linepaddimg,isprocessenter)
    return canvas.maincanvas():createtextobject(text or '',pos,len,fontsize,headx,ismultiline,linew,linepaddimg,isprocessenter);
end




