--   release name: Blunderous Bit-Blasting Bonanza
--           type: TIC-80
--   release date: 02.02.2025
--    party/compo: GERP 2025 / Wild
-- 
-- 
--   code: mrange
--    gfx: glimglam
--  music: Virgill
-- 
-- 
-- TIC-80 has this magical retro vibe, 
-- right? It feels like a vintage computer,
-- but—surprise—it’s not. It’s a fantasy 
-- machine, and I can’t get enough of it.
-- 
-- So when we decided to goto GERP 2025, 
-- it only made sense to create a demo that
-- would throw you straight into that 
-- nostalgic Atari-Amiga feel. Classic 
-- effects, pixel goodness, and a whole 
-- lot of retro love—all packed into one 
-- neat little package. 
--  
-- I hope it takes you back to the golden 
-- age of computing… or at least gets you 
-- feeling a bit nostalgic.
-- 
-- If the music sounds familiar, you’ve 
-- probably heard Virgill’s “Timeline 2” 
-- from another awesome TIC-80 demo. 
-- Big shoutout to Virgill for letting us 
-- use this amazing track.
-- 
-- The source code is up on GitHub for the 
-- curious folks out there.

-- script:  lua

cos 			= math.cos
sin 			= math.sin
exp 			= math.exp
rnd	 		= math.random
sqrt			= math.sqrt
floor		= math.floor
abs 		 = math.abs
min 		 = math.min
max 		 = math.max
pow				= math.pow
pi					= math.pi
tau				= 2*pi
tempo		= 150
spd  		= 8
bpm  		= 3*tempo/spd
balli		= 224

NaN     = 0./0.
shapes		= {}
layers  = {}
lineCol = {}
lineOff	= NaN
lineCol4 = {}
lineCol12 = {}
twistColmap = {}
standardPalette 		= {}
reflectionPalette = {}
musicStarted = false

introTexts = {
    "Glenzing up the Vectors",
    "Polishing the Blitter Objects (BOBs)",
    "Quantizing Quantum Copper Colors",
    "Voxelizing Vector Unicorns",
    "Rotating Rasters with Rainbow Tables",
    "Stabilizing Starfields with Dark Matter",
    "Polishing Parallax Prisms",
    "Making Rainbow Tables from Pixie Dust",
    "Salting the Hashes with Tears of Dragons",
    "Warping Waveforms with Wacky Math",
    "Crunching Coordinates with Cosmic Rays",
    "Flattening Fractals into Fairy Dust",
    "Multiplexing Magic for Maximum Mojo",
    "Debugging with Dolphins",
    "Plotting Polygons on Pirate Maps",
    "Refactoring Reality with Rainbows",
}

impulseTexts = {
	{"Impulse is droppin',back in the mix"	,31,11},
	{"With pixels so retro, it's like '86"	,33,11},
	{"We're second rate,"																		,33,11},
	{"yeah, we know what's up!"												,82,10},
	{"But human-placed pixels?"												,33,10},
	{"That's top-tier stuff!"														,93,10},
	{"We're not the elite,"																,33,9},
	{"we won't steal the show"													,83,9},
	{"But back in Stenungsund?"												,33,9},
	{"We're the pros, you know!"											,76,12},
}
specialKeys = {
	{465, 0},	-- 0
	{465, 1},
	{466, 0},
	{466, 1},
	{466, 2}, -- 4
	{466, 3},
	{467, 0},
	{467, 1},
	{467, 2}, -- 8
	{467, 3},
	{468, 0}, -- :
	{469, 0}, -- ;
	{469, 1}, -- <
	{469, 2}, -- =
	{469, 3}, -- >
	{470, 0}, -- ?
	{470, 2}, -- @
}
scrollTexts = {
		  ""
		.."?With love from?     "
		.."                    "
		.." 7                  "
		.." 1                  "
		.." 1207032037 7720070 "
		.." 11 1 11 11 111  1  "
		.." 11 1 16041 115036  "
		.." 11 9 11  1 11  11  "
		.." 99   99  504900490 "
		.."                    "
		.."                    "
		.."                    "
		, ""
		.."   Greetings goto   "
		.."   --------------   "
		.."                    "
		.."Brainless Institute "
		.."   Fisk Kompaniet   "
		.."       NewCore      "
		.."       NoCrew       "
		.."        ICE         "
		.."                    "
		.."      and XiA       "
		.."          ---       "
		.."                    "
	}

function isNaN(value)
    return value ~= value
end


function strict()
    local declared_globals = {}

    setmetatable(_G, {
        __newindex = function(_, name, value)
            if not declared_globals[name] then
                error("Attempt to create global variable '" .. name .. "'", 2)
            end
            rawset(_G, name, value)
        end,
        __index = function(_, name)
            if not declared_globals[name] then
                trace("Attempt to access undeclared global variable '" .. name .. "'", 2)
            end
            return nil
        end
    })

end

-- Function to explicitly declare globals
function declare_global(name, value)
    declared_globals[name] = true
    rawset(_G, name, value)
end

function btime(n)
	return n*60/bpm
end

function nrow(tm)
	return floor(4*bpm*tm/60)
end

function vec2(x,y)
	return {x,y}
end

function vec3(x,y,z)
	return {x,y,z}
end

vec3_0 		= vec3(0,0,0)
vec3_1 		= vec3(1,1,1)
vec3_127 = vec3(127,127,127)
vec3_255 = vec3(255,255,255)
sshapes = {
	{
		-- FlatFish
		r0   = 0.75,
		r1_0 = vec3(0.7	, 0.3	, 0.2),
		r1_1 = vec3(2 		, 1   , 1		),
		r2_0 = vec3(100	, 100 , 20	),
		r2_1 = vec3(2  	, 1	 	, 1		),
 },
	{
		-- Saucer
		r0   =	1.25,
		r1_0 =	vec3(0.2, 1.7, 1.7),
		r1_1 =	vec3(0.2, 1		, 1		),
		r2_0 =	vec3(0.5, 0.2, 0.2),
		r2_1 =	vec3(1		, 1		, 1		),
 },
	{
		-- Rose
		r0   =	1,
		r1_0 =	vec3(0.2, 1.7, 1.7),
		r1_1 =	vec3(7		, 1		, 1		),
		r2_0 =	vec3(0.2, 1.7, 1.7),
		r2_1 =	vec3(7		, 1		, 1		),
 },
	{
		-- Lantern
		r0   = 1.75,
		r1_0 = vec3(0.2	, 1.7	, 1.7),
		r1_1 = vec3(20		, 1   , 1		),
		r2_0 = vec3(0.5	, 0.2 , 0.2),
		r2_1 = vec3(6  	, 1	 	, 1		),
 },
	{
		-- HexBox
 	r0   =	0.75,
		r1_0 =	vec3(60 , 25 , 25 ),
		r1_1 =	vec3(6  , 1		, 1		),
		r2_0 =	vec3(250, 100, 100),
		r2_1 =	vec3(6		, 1		, 1		),
 },
	{
		-- Hedgehog
 	r0   =	0.75,
		r1_0 =	vec3(60 , 25 , 25 ),
		r1_1 =	vec3(100, 1		, 1		),
		r2_0 =	vec3(250, 100, 100),
		r2_1 =	vec3(40	, 1		, 1		),
 },
}


function round(a)
	return floor(a+0.5)
end

function fract(a)
	return a-floor(a)
end

function clamp(a,b,c)
	return min(max(a,b),c)
end

function step(a,b)
	if a < b then
		return 0
	else
		return 1
	end	
end

function smoothstep(a,b,c)
	local t = clamp((c-a)/(b-a),0,1)
 return t*t*(3-2*t)
end

function hash(co)
  return fract(sin(co*12.9898) * 13758.5453)
end

function snare(tm)
	local ftm = 1.-fract(0.75+tm*bpm/60*0.5)
	ftm = ftm*ftm*ftm*ftm
	return ftm
end

function snare2(tm)
	local ftm = 1.-fract(0.5+tm*bpm/60*0.5)
	ftm = ftm*ftm*ftm*ftm
	return ftm
end

function mix(a,b,x)
  return a+(b-a)*x
end

function srnd()
	return -1+2*rnd()
end

function sign(a)
	if a < 0 then
		return -1
	else
		return 1
	end
end

function vec4(x,y,z,w)
	return {x,y,z,w}
end

function srnd2()
		return vec2(srnd(), srnd())
end

function srnd3()
		return vec3(srnd(), srnd(), srnd())
end

function vxyz(a)
	return vec3(a[1],a[2],a[3])
end


function vyzx(a)
	return vec3(a[2],a[3],a[1])
end

function vzxy(a)
	return vec3(a[3],a[1],a[2])
end

function vbtime(a)
	local v = {}
	for i=1,#a do
		v[i] = btime(a[i])
	end
	return v
end

function vdot(a,b)
	local sum = 0
	for i=1,#a do
		sum = sum+a[i]*b[i]
	end
	return sum
end

function vcross3(a,b)
	return {
 	a[2] * b[3] - a[3] * b[2],
 	a[3] * b[1] - a[1] * b[3],
  a[1] * b[2] - a[2] * b[1],
	}
end

function vmul(a,b)
	local v = {}
	for i=1,#a do
		v[i] = a[i]*b[i]
	end
	return v
end

function vadd(a,b)
	local v = {}
	for i=1,#a do
		v[i] = a[i]+b[i]
	end
	return v
end

function vsub(a,b)
	local v = {}
	for i=1,#a do
		v[i] = a[i]-b[i]
	end
	return v
end

function vabs(a)
	local v = {}
	for i=1,#a do
		v[i] = abs(a[i])
	end
	return v
end

function vsqrt(a)
	local v = {}
	for i=1,#a do
		v[i] = sqrt(a[i])
	end
	return v
end

function vsign(a)
	local s
	local v = {}
	for i=1,#a do
		v[i] = sign(a[i])
	end
	return v
end

function vlength(a)
	return sqrt(vdot(a,a))
end

function vnormalize(a)
	local l,v
	l = vlength(a)
	v = {}
	for i=1,#a do
		v[i] = a[i]/l
	end
	return v
end

function vmix(a,b,x)
	local v = {}
	for i=1,#a do
		v[i] = mix(a[i],b[i],x)
	end
	return v
end

function vmax(a,b)
	local v = {}
	for i=1,#a do
		s = 1
		v[i] = max(a[i],b[i])
	end
	return v
end

function vmin(a,b)
	local v = {}
	for i=1,#a do
		s = 1
		v[i] = min(a[i],b[i])
	end
	return v
end

function vclamp(a,b,c)
	local v = {}
	for i=1,#a do
		v[i] = clamp(a[i],b[i],c[i])
	end
	return v
end

function vround(a)
	local v = {}
	for i=1,#a do
		v[i] = round(a[i])
	end
	return v
end

function palette(a)
	local r,g,b
	r = round(0.5*(sin(a)+1))
	g = round(0.5*(sin(a+1)+1))
	b = round(0.5*(sin(a+2)+1))
 return vround(vmul((vec3(r,g,b)),vec3_255))
end

function hsv2rgb_approx(h,s,v)
	local r,g,b,htau,ss,vv
	ss = clamp(s,0,1)
	vv = 0.5*v
	htau = h*tau
	r = vv*(cos(htau)*ss+2-ss)
 g = vv*(cos(htau+4)*ss+2-ss)
 b = vv*(cos(htau+2)*ss+2-ss)
 return vround(
 	vmul(vclamp(
  	vec3(r,g,b),vec3_0,vec3_1),
   vec3_255))
end

function r(th, n, q)
	return pow(pow(abs(1/q[2]*cos(q[1]*th*0.25)), n[2]) + pow(abs(1/q[2]*sin(q[1]*th*0.25)), n[2]), -1/n[1])
end

function supershape(p2, f, t, m)
	local p 			= vec2((p2[1]-0.5)*tau,(p2[2]-0.5)*pi)
 local r0  	= mix(f.r0, t.r0, m)
 local r1_0 = vmix(f.r1_0 , t.r1_0, m)
 local r1_1 = vmix(f.r1_1 , t.r1_1, m)
 local r2_0 = vmix(f.r2_0 , t.r2_0, m)
 local r2_1 = vmix(f.r2_1 , t.r2_1, m)

 local r1    = r(p[1], r1_0, r1_1);
 local r2    = r(p[2], r2_0, r2_1);

 return vec3(
     r0*r1*cos(p[1])*r2*cos(p[2])
   , r0*r1*sin(p[1])*r2*cos(p[2])
   , r0*r2*sin(p[2])
 )
end

function sphere(p,r)
	return vlength(p)-r
end

function ssphere4(p,r)
	local p2
	p2 = vmul(p,p)
	return pow(vdot(p2,p2),0.25)-r
end

function torus(p, t)
	 local q,px,py,pz,tx,ty
		px = p[1]
		py = p[2]
		pz = p[3]
		tx = t[1]
		ty = t[2]
  q  = vec2(vlength(vec2(px,pz))-tx,py)
  return vlength(q)-ty
end

function mirror(tm)
	local screen,from,to,ii
	screen = 0x0000
	for i=0,25 do
		ii = i/25
		local f = round((2-0.5*ii*ii)*i)
		from = 120*(110-f)
		from = round(from+5*sqrt(ii)*sin(3*ii+tm))
		to 		= 120*(i+110)
		
		memcpy(0x0000+to,0x0000+from,120)
	end
end

function starScroller(tm,yoff)
	local mz,px,py,pc,layer,p
	
	if not(yoff) then
		yoff = 0
	end
	
	-- Stars
	for i=#layers,1,-1 do
		mz = -2/(2+i)*tm*60
		layer = layers[i]
		for j=1,#layer do
			p = layer[j]
			px = p[1]
			py = p[2]
			pc = p[3]
			px = round(px+mz)%240
			pix(px,py+yoff,pc)
		end
	end

end

function snareEffect(s)
	local tmp,save
	tmp = round(16-4*s)
	if s > 0.25 then
--[[
		save = peek4(0x3FF0*2+12)
		poke4(0x3FF0*2+12,tmp)
		spr(344,25,12,5,3,0,0,8,4)
		poke4(0x3FF0*2+12,save)
]]
		print("Impulse!",0,44,tmp,0,5)
	end
end

function sky(fade)
	local ii,i,f,save
	for i=0,50 do
		ii = i/50		
		f = fract(10.*ii)
		lineCol4[i]  = hsv2rgb_approx(-0.5+ii,0.5+sqrt(f),mix(1.5,0,f*f*fade))
		lineCol12[i] = hsv2rgb_approx(0.58,0.2,mix(1.1,-0.2,ii+(i%2)*0.2)*fade)
	end
	lineCol4[51] = standardPalette[4]
	lineCol12[51] = standardPalette[12]
	
	for i=0,99 do
		ii = i/100		
		ii = smoothstep(0.5,1,ii)
		lineCol[i] = hsv2rgb_approx(0.68-0.3*ii,1.5-ii,(ii+0.15)*fade)
	end
	for i=100,136 do
		ii = (i-100)/50
		lineCol[i] = hsv2rgb_approx(0.68-0.05*ii,0.9,ii*fade)
	end
	fade = sqrt(fade)
	lineCol[99] = vmul(vec3(fade,fade,fade),vec3_255)
end

function appearPos(tm)	
	local a = tm
	return {
		sin(tm*0.707)*80+120,
		sin(tm)*52+52,
	}
end

function writer(tm,btm,sel)
	local flip = 32
	btm = btm
	local stm  = btm/flip
	local nstm = floor(stm)
	local cstm = stm-nstm
	local fos		= 0.9
	local fo			= max(cstm-0.95, 0)*20
	fo = fo*fo*2
	local scrollText = scrollTexts[sel]

	local bix=448
	if scrollText then
		local sl = string.len(scrollText)
		local atm= flip*nstm
		local tyani = round(fract(btm*0.5))+fo*138
		local save = peek4(0x3FF0*2+12)

		for y=0,11 do
			for x=0,19 do
				local ix = (x+y*20)%sl+1
				local ch	= string.byte(scrollText,ix)
	
				local uch= ch & ~0x20
				local six= nil
				local srot = 0
				if ch == 45 then
					six = 464
				elseif	ch >= 48 and ch <= 64 then
					local sk = specialKeys[ch-47]
					six = sk[1]
					srot = sk[2]
				elseif uch >= 65 and 90 >= uch then
					six = 480 + uch-65
				end
	
				local etm = atm+6
				if btm > atm and six then
					if btm < (atm+0.1) then
						bix = 449
					end
					local tx = x*9+30
					local ty = y*9+4+tyani
					local lx = tx
					local ly = ty
					if btm<etm then
						local ani = exp(-(btm-atm))
						local f  = appearPos(tm)
						local fx = f[1]
						local fy = f[2]
						
					 lx = round(mix(tx,fx,ani))
						ly = round(mix(ty,fy,ani))
					end
						
					poke4(0x3FF0*2+12,15)
					spr(six,lx+1,ly+1,0,1,0,srot)
					poke4(0x3FF0*2+12,12)
					spr(six,lx,ly,0,1,0,srot)
					
					atm = atm + 0.25
					
				end
			end
		end
		poke4(0x3FF0*2+12,save)
	end

	local curr = appearPos(tm)
	spr(bix, curr[1], curr[2],0)
end

function fadeInScreen(n,r,s,tm,ltm)
	local etm,fade
	etm = 60/bpm*6
	fade = smoothstep(0.25*etm,etm,ltm)
	sky(fade)

	print("Impulse!",26,40,12,0,4)
 print("Rascals of Retro Raster Revolution",18,66,12,0,1)
 print("@Gerp 2025",56,78,12,0,2)
	line (26,62,71,62,12)
	line (84,62,213,62,12)
--	line (120,0,120,110,12)
	if r >= 30 then
		cls(12+r-30)
	end
end

function starScrollerScreen(n,r,s,tm,ltm)
	local sp,sx,sy,etm,i,j,spd,nor

	spd = vec2(-220,120)
	nor = vnormalize(spd)

	starScroller(tm)

	for j=0,3 do
		etm= max(tm-btime(9)-j*15/bpm,0)
		sp = 450+(4*etm)%2
		
		sx = 244+spd[1]*etm
		sy = spd[2]*etm+40*j*nor[2]
	
		for i=0,3 do
			line(
				sx-25*nor[1]*i,
				sy-25*nor[2]*i,
				sx-25*nor[1]*(i+1),
				sy-25*nor[2]*(i+1), 
				4-i
				)
		end
		
		spr(sp,sx-3,sy-3,5)
	end	
end

function dolphinScreen(n,r,s,tm,ltm)
	starScroller(tm)
	local col,yoff,text,x,i,s2
	col  = 11
	yoff = round(120-10*ltm)
--	yoff = -20
	spr(0,60,yoff,5,1,0,0,16,12)
	s2 = snare2(tm)
	if s2 > 0.75 then
		spr(round(451-clamp((s2-0.75)*4,0,1)),105,yoff+73,5)
	end

	yoff = yoff + 116
	line (30,yoff-10,210,yoff-10,12)		


	for i=1,#impulseTexts do
		text,x,col = table.unpack(impulseTexts[i])
--		print(text,x+1,yoff-7+i*8,8)
		print(text,x,yoff-8+i*8,col)
	end

--	line (120,0,120,110,12)
	if r >= 158 then
		cls(12+r-158)
	end
end

function bobsScreen(n,r,s,tm,ltm,e)
	local a,c1,c2,s1,s2,z,yoff,points,zbuffer
	local i,px,py,pz,pc,tmp,zz,mz,izbuffer,sr
	local etm,si,p

	starScroller(tm)
	snareEffect(s)

	etm     = btime(e)
	a							= ltm
	c1						= cos(a)
	s1						= sin(a)	
	c2						= cos(a*1.234)
	s2						= sin(a*1.234)	
	
	a       = ltm*bpm/60/8
	si						= floor(a)
	a  					= tau*a
	yoff 			= 130*smoothstep(0.5,1,cos(a))
	points 	= shapes[si%#shapes+1]
	zbuffer	= {}

	sr = (40+20*s)
	
	for i=1,#points do
		p  = points[i]
		px = p[1]
		py = p[2]
		pz = p[3]
		pc = p[4]
		
		tmp=  c1*px+s1*py
		py = -s1*px+c1*py
		px = tmp
		
		tmp=  c2*py+s2*pz
		pz = -s2*py+c2*pz
		py = tmp

		table.insert(zbuffer, {px,py,pz,pc})

	end

	table.sort(
		zbuffer,
		function(a,b)
			return a[3] > b[3]
		end)

	for i,p in ipairs(zbuffer) do
		px,py,pz,pc = table.unpack(p)
		mz = 4/(4+pz)
		px = px*mz
		py = py*mz
		px = 120-4+px*sr
		py = 68-4+py*sr+yoff

		spr(pc,px,py,5)
	end
end

mountainLayers = {
 {50,16,8*15,0},
 {40,9 ,3   ,1},
 {30,8	,8*15,0},
 {20,10,2   ,1},
 {10,0	,8*15,0},
 {5 ,12,1   ,1},
}

function smokestack(tm,x,y)
	local i,dt,dx,dy,et,h0,h1
	local dtm,ftm,c,h,r,col,ntm
	
	et = 20
	dt = bpm/60/4
	dtm= tm/dt
	ntm= floor(dtm)
	ftm= dtm-ntm
	dx = -10
	dy = -2
	for i=et,0,-1 do
		c = i-ntm
		h0=hash(c+456)
		h1=hash(c+123)
		r = round(0.125*i+mix(1,3,h0))
		col = max(12,round(
			-0.125*i
			+mix(15,13,h1)
			))
		circ(
			round(x+i*dt*dx),
			round(y+(ftm+i)*dt*dy),
			r,
			col
			)
	end

end

function parallaxScreen(n,r,s,tm,ltm,e,args)
	local i,msz,x,y,yoff,bx,by,mlayer,spd,dist,tz,zs,bsz,myoff,bt
	local cx,ch0,ch1,ch2,fi,fo,etm,bt1,bt2,bt3
	
	bt1= btime(1)
	bt2= btime(2)
	bt3= btime(3)
	etm= btime(e)
	fi = smoothstep(bt1,0,ltm)
	fo = smoothstep(etm-bt2,etm,tm)
	zs = 30
	myoff = 50-100*(fi+fo)
	
	starScroller(tm,-112*fo)
		
	circ(200,myoff,30,12)
	circ(200-4,myoff+4,30,0)
	spr(256,20+ltm*5,myoff-50,5,1,0,0,10,5)
	for i=1,#mountainLayers do
		mlayer = mountainLayers[i]
		dist = mlayer[1]
		bx 		= mlayer[2]
		by 		= mlayer[3]
		bt   = mlayer[4]
		tz   = zs/(zs+dist)
		msz  = round(100*tz)
		bsz  = 2*msz-10
		yoff = round(96+18*tz)-dist*tz+100*(fo+smoothstep(bt3,bt1,ltm-dist*0.02))
		spd  = tz
		if bt == 0 then
			x = -bsz*fract(0.5*tm*spd)
			y = 0
			
			while (x < 240) do
				ttri(
					x,yoff+y,
					x+msz,yoff-msz,
					x+msz*2,yoff+y,
					bx,by,
					bx,by+8,
					bx+8,by+8,
					0
				)
				x = x + bsz
			end
		else
			x = -bsz*(0.5*ltm*spd)
			for i=0,13 do
				cx  = floor((-x+20*i)/20)*20
						
				ch0 = hash(cx+by)
				ch1 = fract(8667*ch0)
				
				cx = cx+ x
				
				circ(cx,yoff,tz*mix(15,30, ch0),bx)
			end
		
		end
	end
	x = floor(ltm*12-100)
	y = 102+30*(fi+fo)
	smokestack(ltm,x+140,y-2)
	line(0,y+8,240,y+8,14)
	spr(232,x+120,y,5,1,0,0,3,1)
	spr(229,x+96,y,5,1,0,0,3,1)
	spr(229,x+72,y,5,1,0,0,3,1)
	spr(229,x+48,y,5,1,0,0,3,1)
	writer(tm,ltm*2*bpm/60,1)
end

function triArea(px0, py0, px1, py1, px2, py2)
 local area = (
  (px0 * (py1 - py2) +
   px1 * (py2 - py0) +
   px2 * (py0 - py1)) / 2
  )
 return area
end

glenzShapes = {}
glenzLightDir = vnormalize(vec3(-1,1,2))

function glenzScreen(n,r,s,tm,ltm,e,args)
	local a,c1,s1,c2,s2,c3,s3,i,tmp,tz,col,ta
	local p0,px0,py0,pz0
	local p1,px1,py1,pz1
	local p2,px2,py2,pz2
	local n0,nx0,ny0,nz0
	local l0,lx0,ly0,l,lx,ly,lz
	local dif,sz,f,etm,si,yoff
	local faces,face,sr,zbuffer,_

	starScroller(tm)
	snareEffect(s)
 sr = 60+20*s
	zbuffer = {}

	l       = glenzLightDir
	lx					 = l[1]
	ly					 = l[2]
	lz					 = l[3]

	etm  		 = btime(e)
	a							= ltm
	c1						= cos(a)
	s1						= sin(a)	
	c2						= cos(a*1.234)
	s2						= sin(a*1.234)	

	a       = ltm*bpm/60/8
	si						= floor(a)
	a  					= tau*a
	yoff 			= 150*smoothstep(0.5,1,cos(a))

	faces 		= glenzShapes[si%#shapes+1]

	for i=1,#faces do
	 face= faces[i]
		col = face[5]
		
		p0  = face[1]
		px0 = p0[1]
		py0 = p0[2]
		pz0 = p0[3]

		tmp = c1*px0+s1*py0
		py0 =-s1*px0+c1*py0
		px0 = tmp

		tmp = c2*py0+s2*pz0
		pz0 =-s2*py0+c2*pz0
		py0 = tmp
		
		tz 	= 4/(pz0+4)
		px0 = px0*sr*tz+120
		py0 = py0*sr*tz+50

		p1  = face[2]
		px1 = p1[1]
		py1 = p1[2]
		pz1 = p1[3]

		tmp = c1*px1+s1*py1
		py1 =-s1*px1+c1*py1
		px1 = tmp

		tmp = c2*py1+s2*pz1
		pz1 =-s2*py1+c2*pz1
		py1 = tmp
		
		tz 	= 4/(pz1+4)
		px1 = px1*sr*tz+120
		py1 = py1*sr*tz+50

		p2  = face[3]
		px2 = p2[1]
		py2 = p2[2]
		pz2 = p2[3]

		tmp = c1*px2+s1*py2
		py2 =-s1*px2+c1*py2
		px2 = tmp

		tmp = c2*py2+s2*pz2
		pz2 =-s2*py2+c2*pz2
		py2 = tmp
	
		tz 	= 4/(pz2+4)
		px2 = px2*sr*tz+120
		py2 = py2*sr*tz+50

	 ta  = triArea(px0,py0,px1,py1,px2,py2)

		if ta > 0 then		
			n0  = face[4]
			nx0 = n0[1]
			ny0 = n0[2]
			nz0 = n0[3]
	
			tmp = c1*nx0+s1*ny0
			ny0 =-s1*nx0+c1*ny0
			nx0 = tmp
	
			tmp = c2*ny0+s2*nz0
			nz0 =-s2*ny0+c2*nz0
			ny0 = tmp
	
			dif = max(nx0*lx+ny0*ly+nz0*lz,0)
			
			sz  = min(min(pz0,pz1),pz2)
	
			table.insert(zbuffer,{
					sz,
					px0,py0,px1,py1,px2,py2, col+min(3,round(4*(dif)))
				})

		end
	end

	table.sort(
		zbuffer,
		function(a,b)
			return a[1] > b[1]
		end)

	for i,f in ipairs(zbuffer) do
		_,px0,py0,px1,py1,px2,py2,col=table.unpack(f)
		tri(px0,py0+yoff,px1,py1+yoff,px2,py2+yoff,col)
		line(px0,py0+yoff,px1,py1+yoff,1)
--		line(px1,py1,px2,py2,1)
--  line(px0,py0,px2,py2,1)
	end
end

function twistScreen(n,r,s,tm,ltm,e,args)
	starScroller(tm)

	local r,off,x,y,z,col,colmap
	local scra,spra,distr,distx,a,w
	local xx,fi,fo,bt4,etm
	etm = btime(e)
	bt4 = btime(4)
	fi  = smoothstep(bt4,0,ltm)
	fo  = smoothstep(etm-bt4,etm,tm)


	for w=1,3 do
		colmap = twistColmap[w]
		for z=0,110 do	
			a     = ltm+z/120+w
		 distx = round(48*cos(a)+80)-200*(fi+fo)
			distr = 36+round(20*sin(a)-48*smoothstep(-0.5,0.5,sin(ltm)))
			r     = round(distr)%48
			off	  = 64*(336 + (r//8)*16)+(r%8)*8
			scra  = 0x0000+240*z
			spra  = 0x4000*2+off
			for y=0,7 do
				for x=0,7 do
					xx = distx+x+8*y
					col = peek4(spra+x+64*y)
					if xx >= 0 and not (col == 5)  then
						poke4(scra+xx,colmap[col])
					end
				end
			end
		end
	end
	writer(tm,ltm*2*bpm/60,2)
end

function tanh_approx(x)
	local x2 = x*x
 return clamp(x*(27 + x2)/(27+9*x2), -1, 1)
end


function apollianScreen(n,r,s,tm,ltm,e,args)
	starScroller(tm)
--	snareEffect(s)
	
	local scale,i,px,py,pz,r2,s,d
	local a,c1,s1,c2,s2,dlimit,bt2,fi,fo,etm,f
	local tmp,k,spx

	etm					= btime(e)

	bt2					= btime(2)
	fi						= smoothstep(0,bt2,ltm)	
	fo						= smoothstep(etm,etm-bt2,tm)	
	lineOff	= round(mix(-50,30, fi*fo))

	bt2					= btime(4)
	fi						= smoothstep(0,bt2,ltm)	
	fo						= smoothstep(etm,etm-bt2,tm)	

	s 						= 1.5
	a							= ltm*0.25
	c1						= cos(a)
	s1						= sin(a)	
	c2						= cos(a*1.234)
	s2						= sin(a*1.234)
	f       = fi*fo	
	dlimit  = 0.005*f
	for x=0,99 do
		spx = -1+x*0.02
		spx = tanh_approx(spx)
		for y=0,110 do
			px = spx
			py = -1+y*0.02
			px = px*0.5
			py = py*0.5
			pz = 0.3*(c1+s2)
			tmp=  c1*px+s1*pz
			pz = -s1*px+c1*pz
			px = tmp
			
			tmp=  c2*py+s2*pz
			pz = -s2*py+c2*pz
			py = tmp
			scale = 1
			for i=0,2 do
				px = -1+2*fract(0.5*px+0.5)
				py = -1+2*fract(0.5*py+0.5)
				pz = -1+2*fract(0.5*pz+0.5)
				r2 = px*px+py*py+pz*pz
				k  = s/r2
				px = k*px
				py = k*py
				pz = k*pz
				scale = scale*k
			end
			
			scale = 1/scale

			if abs(pz)*scale < dlimit then
				pix(x+70,y,11)
				pix(68-x,y,3)
				pix(270-x,y,5)
			end

			if abs(py)*scale < dlimit then
				pix(x+70,y,10)
				pix(68-x,y,2)
				pix(270-x,y,6)
			end

			if abs(px)*scale < dlimit then
				pix(x+70,y,9)
				pix(68-x,y,1)
				pix(270-x,y,7)
			end
		end
	end
	if f > 0.33 then
		line(69,0,69,110,2)
		line(170,0,170,110,6)
	end
 spr(344,55,-16+lineOff,5,2,0,0,8,3)
end

function fadeOutScreen(n,r,s,tm,ltm,e,args)
	local etm,fade,yoff
	etm = 60/bpm*6
	sky(smoothstep(etm,btime(2),ltm))
	yoff = 39+25*smoothstep(btime(2),0,ltm)
	
	print("Code"    ,0,50+yoff,3)
	print("Lance"   ,0,58+yoff,4)

	print("Pixels"  ,100,50+yoff,6)
	print("GlimGlam",100,58+yoff,5)
	print("Music"   ,206,50+yoff,10)
	print("Virgill ",206,58+yoff,11)
end

function exitScreen(n,r,s,tm,ltm,e,args)
	exit()
end

script = {
	{0  , fadeInScreen						, nil	, "fadeInScreen"						},
	{8  , starScrollerScreen, nil	, "starScrollerScreen"},
	{12 , dolphinScreen 				, nil	, "dolphinScreen"					},
	{40 , glenzScreen							, nil	, "glenzScreen"							, {"'Glenz' Vector"		, "Pretend it's a torus"				}},
	{56 , bobsScreen			 				, nil , "bobsScreen"								, {"Rotating 3D BOBs", "Every demo needs some"			}},
	{72 , apollianScreen 			, nil	, "apollianScreen"			 , {"Uhm,math I guess", "We think it's fractal"   }},
	{88 , twistScreen			 			, nil , "twistScreen"			 			, {"Our Greetings"   , "This demo is canonical"		}},
	{104, parallaxScreen			 , nil , "parallaxScreen"			 , {"Parallax scroll" , "So many parallax layers" }},
	{120, fadeOutScreen 				, nil	, "fadeOutScreen"					},
	{128, exitScreen			 				, nil	, "exitScreen"								},
	{129, exitScreen			 				, nil	, "exitScreen"								},
}

effectiveScript = { }

function intro(tm)
	local w,t,s,e
	e = 16
	if (tm > e+6) then
		cls(0)
		return
	elseif (tm > e+3) then
		cls(0)
		if (floor(2*tm)%2) == 0 then
			rectb(2,2,238,36,2)
		end
		print("Software Failure.  Press left mouse button to continue.",12,8,2,0,1,1)
		print("Dude Zoning Out      #0BADBEEF.#FACEB00B",12,24,2)
		return
	end
	tm = min(tm,e)
	cls(8)

	print("Impulse welcomes you to a",75,23,0,0,1,1)
	print("Impulse welcomes you to a",74,22,13,0,1,1)
	print("Blunderous Bit-Blasting Bonanza",37,31,0)
	print("Blunderous Bit-Blasting Bonanza",36,30,12)

	print("Music 'ripped' from Timeline 2 and created by amazing",15,59,0,0,1,1)
	print("Music 'ripped' from Timeline 2 and created by amazing",14,58,13,0,1,1)
	print("Virgill",104,67,0)
	print("Virgill",103,66,tm*8+12)

	print("Precalculating...",91,101,0,0,1,1)
	print("Precalculating...",90,100,13,0,1,1)

	s = (floor(math.exp(0.25*tm)-1)%#introTexts)+1
	t = introTexts[s]	
	w = print(t,0,-8,13)
	print(t,(241-w)/2,109,0)
	print(t,(240-w)/2,108,12)

	if tm >= e then
		for i=0,2 do	
			spr(436,i*16,68-8,5,1,0,0,2,2)
		end
	end
end

function TIC()
	local b,s,r,n,tm,ltm,tmp,current,args,e
	local i,w,glenzInfo,fi,fo,bt1,etm,itm
	itm = 24
	vbank(0)
	
	bt1 = btime(1)
	tm= time()/1000
--	tm=tm+24
	if tm < itm then
		poke(0x3FFB,11)
		intro(tm)
		return
	end
	poke(0x3FFB,0)
	
	if not musicStarted then
		musicStarted = true
		music(0)
	end

	cls(0)
	tm= tm-itm
	r = nrow(tm)
	n = r//4

	current = effectiveScript[n]
	args = current[3]
	
	e   = current[0]
	ltm = tm-current[1]*60/bpm
	s = snare(tm)
	etm = btime(e)

	fi  =	smoothstep(bt1,0,ltm)
	fo  = smoothstep(etm-bt1,etm,tm)

	if false then
		print(string.format("%s", current[4]),0,0)
		print(string.format("Beat   %d", n),0,6)
		print(string.format("EBeat  %d", e),0,12)
		print(string.format("Row    %d", r),0,18)
		print(string.format("Time   %0.2f", tm),0,24)
		print(string.format("LTime  %0.2f", ltm),0,30)
		print(string.format("Fade   %0.2f,%0.2f", fi,fo),0,36)
		
	end

	lineOff = NaN
 current[2](n,r,s,tm,ltm,e,args)
	
	glenzInfo = current[5]

	if glenzInfo then
		tmp = btime(1)
		for i=1,#glenzInfo do
		 tmp = nil
			if i > 1 then
				tmp = 1
			end
			w = print(glenzInfo[i],0,-8,12,0,1,tmp)
		 print(glenzInfo[i],221-w,20*(fi+fo)+110-6*(#glenzInfo-i+1),15,0,1,tmp)
		 print(glenzInfo[i],220-w,20*(fi+fo)+109-6*(#glenzInfo-i+1),11+i,0,1,tmp)
		end
	end
	mirror(tm)
end

function BDR(l)
	if not musicStarted then
		return
	end
	local col,v
	if l == 0 then
		for i=0,15 do
			col = standardPalette[i]
			poke(0x3FC0+i*3,col[1])
			poke(0x3FC1+i*3,col[2])
			poke(0x3FC2+i*3,col[3])
		end		
	end
	if l == 115 then
		for i=0,15 do
			col = reflectionPalette[i]
			poke(0x3FC0+i*3,col[1])
			poke(0x3FC1+i*3,col[2])
			poke(0x3FC2+i*3,col[3])
		end		
	end
	col = lineCol[l]
	if col then
		poke(0x3FC0, col[1])	
		poke(0x3FC1, col[2])	
		poke(0x3FC2, col[3])
	end
	if not (isNaN(lineOff)) then
		col = lineCol4[l-lineOff]
		if col then
			poke(0x3FC0+4*3, col[1])	
			poke(0x3FC1+4*3, col[2])	
			poke(0x3FC2+4*3, col[3])
		end
		col = lineCol12[l-lineOff]
		if col then
			poke(0x3FC0+12*3, col[1])	
			poke(0x3FC1+12*3, col[2])	
			poke(0x3FC2+12*3, col[3])
		end
	end
end

function setupScript()
	local current,idx,beat,next
	current = script[1]
	next 			= script[2]
	idx 	= 3
	beat = 0
	while current and next do
		current[0] = next[1]
		while beat < next[1] do
			effectiveScript[beat] = current
			beat = beat + 1
		end
		current = next
		next 			= script[idx] 
		idx = idx+1
	end
end

function setupShapes()
	local function df0(p)
		local d,d0,d1,t
		t = vec2(0.9,0.1)
		d0 = abs(sphere(p, 0.4))-0.1
		d1 = torus(p,t)
		d  = min(d0,d1)
		return vec2(d,d0-0.01)
	end
	
	local function df1(p)
		local d,d0,d1
		d0  = ssphere4(p,0.8)
		d1  = sphere(p,0.9)
		d   = max(d0,-d1)
		return vec2(d,d1-0.05)
	end
	
	local function df2(p)
		local d0,p0,s0
		p0 = p
		s0 = vsign(p0)
		p0 = vabs(p0)
		p0 = vsub(p0,vec3(0.5,0.5,0.5))
	
		d0  	= abs(ssphere4(p0,0.2))-0.1
		return vec2(d0,s0[1]*s0[2]*s0[3])
	end
	
	local function df3(p)
		local d0,d1,d2,d
		d0 = vlength(vec2(p[1],p[2]))	
		d1 = vlength(vec2(p[1],p[3]))	
		d2 = vlength(vec2(p[2],p[3]))	
		d = min(d0,d1)
		d = min(d, d2)
		d = d - 0.2
		return vec2(d,d+0.01)
	end
	
	local dfs = {df0,df1,df2,df3}
	

	local x,y,i, sshape,points,dim,iter
	local p,d,df,etm
	
	etm = time()+1000

	for i=1,#dfs do
		iter 		= 0 
		df 				= dfs[i]
		points = {}
		
		while #points < 900 do
			iter = iter + 1
			if time() > etm then
				error("Generating points are too slow")
			end
			p = srnd3()
			d = df(p)
			if d[1] < 0 then
				p[4] = balli
				if (d[2] < 0) then
					p[4] = balli+1
				end
				table.insert(points, p)
			end
		end
		table.insert(shapes, points)
	end
end

function setupStarLayers()
	local i,j,layer,px,py,pc,tmp
	for i=1,3 do
		layer = {}

		for j=1,100	do
			px = round(240*rnd())
			py = round((100-10*i)*rnd())
			tmp= rnd()
 		if tmp > 0.2 then
   	pc	= 12+i
 		elseif tmp > 0.05 then
				pc = 12-i
   else
				pc = 4-i
			end
			layer[j]=vec3(px,py,pc)
		end
		
		layers[i]=layer
		
	end
end

function setupPalettes()
	local i,col
	for i=0,15 do
		col = vec3(
				peek(0x3FC0+3*i)
			,peek(0x3FC1+3*i)
			,peek(0x3FC2+3*i)
			)
		standardPalette[i] = col
		reflectionPalette[i] = vec3(
				round(col[1]*0.7)
			,round(col[2]*0.6)
			,round(col[3]*0.9)
			)
	end
end

function setupTwist()
	local colmap
	colmap = {}
	colmap[8]=7
	colmap[13]=5
	colmap[14]=6
	colmap[15]=7
	table.insert(twistColmap,colmap)
	
	colmap = {}
	colmap[8]=8
	colmap[13]=10
	colmap[14]=9
	colmap[15]=8
	table.insert(twistColmap,colmap)
	
	colmap = {}
	colmap[8]=1
	colmap[13]=3
	colmap[14]=2
	colmap[15]=1
	table.insert(twistColmap,colmap)
	
end

function setupGlenzShapes()
	local x,y,xx,yy,i,j,k, sshape,points,dim,iter
	local p,d,df,v0,v1,faces
	
	local faceDefs,faceDef,face,c
	faceDefs =	{
		{{0,0},{0,1},{1,1}},
		{{1,0},{0,0},{1,1}},
	}

	local function flatFace1(s,m,c)
		local sgn, amp
		sgn = sign(s)
		amp = abs(s)
		return {
			m(vec3( amp, amp, s)),
			m(vec3( sgn*amp,-sgn*amp, s)),
			m(vec3(-sgn*amp, sgn*amp, s)),
			m(vec3( 0, 0,-sgn)),
			c
		}
	end

	local function flatFace2(s,m,c)
		local sgn, amp
		sgn = sign(s)
		amp = abs(s)
		return {
			m(vec3( -amp, -amp, s)),
			m(vec3(-sgn*amp, sgn*amp, s)),
			m(vec3( sgn*amp,-sgn*amp, s)),
			m(vec3( 0, 0,-sgn)),
			c
		}
	end
	faces = {
	 flatFace1( 0.6,vxyz,1),
	 flatFace2( 0.6,vxyz,1),
	 flatFace1(-0.6,vxyz,1),
	 flatFace2(-0.6,vxyz,1),
	 flatFace1( 0.6,vyzx,1),
	 flatFace2( 0.6,vyzx,1),
	 flatFace1(-0.6,vyzx,1),
	 flatFace2(-0.6,vyzx,1),
	 flatFace1( 0.6,vzxy,1),
	 flatFace2( 0.6,vzxy,1),
	 flatFace1(-0.6,vzxy,1),
	 flatFace2(-0.6,vzxy,1),
	}
	table.insert(glenzShapes, faces)

	for i=1,#sshapes do
		sshape = sshapes[i]
		faces = {}
		dim = 16
		for x=0,(dim-1) do
			for y=0,(dim-1) do
				for j=1,#faceDefs do
					faceDef = faceDefs[j]
					face = {}
					for j=1,#faceDef do
						c = faceDef[j]
						xx = (x+c[1])/dim
						yy = (y+c[2])/dim
						p  = supershape(vec2(xx,yy),sshape, sshape, 0)
--						p 	= vec3(p[3],p[1],p[2])
						face[j] = p
					end
					v0 = vnormalize(vsub(face[2],face[1]))
					v1 = vnormalize(vsub(face[3],face[1]))
					face[4] = vcross3(v0,v1)
					face[5] = 1+8*((x+y)%2)

					
					table.insert(faces,face)
				end
			end
		end
		table.insert(glenzShapes, faces)
	end

end

function init()
	-- Enable strict mode
 -- strict()
	
	local col,df,points,d,p,iter,layer,px,py,pc,ii
	local xx,yy,ssharp,dim,tmp

	setupScript()
	setupPalettes()
	setupGlenzShapes()
	setupTwist()
	setupShapes()
	setupStarLayers()
	sky(1)
	cls(0)
end


init()


-- <TILES>
-- 000:5555555555555555555555555555555555555555555555555555555555555555
-- 001:5555555555555555555555555555555555555555555555555555555555555555
-- 002:5555555555555555555555555555555555555555555555555555555555555555
-- 003:5555555555555555555555555555555555555555555555555555555555555555
-- 004:5555555555555555555555555555555555555555555555555555555555555555
-- 005:5555555555555555555555555555555555555555555555555555555555555555
-- 006:5555555555555555555555555555555555555555555555555555555555555555
-- 007:5555555555555555555555555555555555555555555555555555555555555555
-- 008:5555555555555555555555555555555555555555555555555555555555555555
-- 009:5555555555555555555555555555555555555555555555555555555555555555
-- 010:5555555555555555555555555555555555555555555555555555555555555555
-- 011:5555555555555555555555555555555555555555555555555555555555555555
-- 012:55555555555555555555b5555555b8555555b855555ba855555b985555ba8955
-- 013:5555555555555555555555555555555555555555555555555555555555555555
-- 014:5555555555555555555555555555555555555555555555555555555555555555
-- 015:5555555555555555555555555555555555555555555555555555555555555555
-- 016:5555555555555555555555555555555555555555555555555555555555555555
-- 017:5555555555555555555555555555555555555555555555555555555555555555
-- 018:5555555555555555555555555555555555555555555555555555555555555555
-- 019:5555555555555555555555555555555555555555555555555555555555555555
-- 020:5555555555555555555555555555555555555555555555555555555555555555
-- 021:5555555555555555555555555555555555555555555555555555555555555555
-- 022:5555555555555555555555555555555555555555555555555555555555555555
-- 023:5555555555555555555555555555555555555555555555555555555555555555
-- 024:5555555555555555555555555555555555555555555555555555555555555555
-- 025:5555555555555555555555555555555555555555555555555555555555555555
-- 026:5555555555555555555555555555555555555555555555555555555555555555
-- 027:5555555555555555555555555555555555555555555555555555555b5555555b
-- 028:55b9955555b885555ba885555b989555ba999555b9988555a888555598995555
-- 029:5555555555555555555555555555555555555555555555555555555555555555
-- 030:5555555555555555555555555555555555555555555555555555555555555555
-- 031:5555555555555555555555555555555555555555555555555555555555555555
-- 032:5555555555555555555a5555555a555555ba855555ba755555b7785555bf7755
-- 033:5555555555555555555555555555555555555555555555555555555555555555
-- 034:5555555555555555555555555555555555555555555555555555555555555555
-- 035:5555555555555555555555555555555555555555555555555555555555555555
-- 036:5555555555555555555555555555555555555555555555555555555555555555
-- 037:5555555555555555555555555555555555555555555555555555555555555555
-- 038:5555555555555555555555555555555555555555555555555555555555555555
-- 039:5555555555555555555555555555555555555555555555555555555555555555
-- 040:5555555555555555555555555555555555555555555555555555555555555555
-- 041:5555555555555555555555555555555555555555555555555555555555555555
-- 042:5555555555555555555555555555555555555555555555555555555555555555
-- 043:555555ba555555b955555ba955555b9955555b985555ba885555b988555ba889
-- 044:9999555588885555888855559995555599955555888555558885555599555555
-- 045:5555555555555555555555555555555555555555555555555555555555555555
-- 046:5555555555555555555555555555555555555555555555555555555555555555
-- 047:5555555555555555555555555555555555555555555555555555555555555555
-- 048:55baff85555b6998555b6977555baf795555b6995555ba9755555b6755555baf
-- 049:5555555555555555555555558555555598555555978555557f985555f9998555
-- 050:5555555555555555555555555555555555555555555555555555555555555555
-- 051:5555555555555555555555555555555555555555555555555555555555555555
-- 052:5555555555555555555555555555555555555555555555555555555555555555
-- 053:5555555555555555555555555555555555555555555555555555555555555555
-- 054:5555555555555555555555555555555555555555555555555555555555555555
-- 055:5555555555555555555555555555555555555555555555555555555555555555
-- 056:555555555555555555555555555555555555555555555555555555bb55555ba9
-- 057:555555555555555555555555555555555555555555555555a555555555555555
-- 058:555555555555555555555555555555555555555555555555555555555555555b
-- 059:555b999955ba888855b988885ba888895b999999ba888999b9888888a8889999
-- 060:9855555598555555855555559555555585555555855555555555555555555555
-- 061:5555555555555555555555555555555555555555555555555555555555555555
-- 062:5555555555555555555555555555555555555555555555555555555555555555
-- 063:5555555555555555555555555555555555555555555555555555555555555555
-- 064:555555b6555555ba5555555b5555555b55555555555555555555555555555555
-- 065:99777855f77f99856f999998a6999f77baf7777fba6ff7f95ba6ff9955b69999
-- 066:555555555555555555555555855555559855555599855555999855559ff78555
-- 067:5555555555555555555555555555555555555555555555555555555555555555
-- 068:5555555555555555555555555555555555555555555555555555555555555555
-- 069:5555555555555555555555555555555555555555555555555555555555555555
-- 070:5555555555555555555555555555555555555555555555555555555555555555
-- 071:555555555555555555555555555555555555555555555555555555555555555b
-- 072:5555ba9f555ba9f5555b97f555ba77555ba99f55ba997555ba77f555a9975555
-- 073:5555555555555555555555555555555555555555555555555555555555555555
-- 074:5555555b555555ba55555ba855555b985555ba885555b999555ba999555b9888
-- 075:9999999888999998888888858888888588899985999999559999985589999855
-- 076:5555555555555555555555555555555555555555555555555555555555555555
-- 077:5555555555555555555555555555555555555555555555555555555555555555
-- 078:5555555555555555555555555555555555555555555555555555555555555555
-- 079:5555555555555555555555555555555555555555555555555555555555555555
-- 080:5555555555555555555555555555555555555555555555555555555555555555
-- 081:55ba979f555baff7555ba67f5555ba6f55555b6755555ba6555555ba5555555b
-- 082:777f98557f999985f9999f789999f7f999f77799f777ff9997fff9996fff9999
-- 083:5555555555555555555555558555555598555555998555559f785555f7f98855
-- 084:5555555555555555555555555555555555555555555555555555555555555555
-- 085:5555555555555555555555555555555555555555555555555555555555555555
-- 086:5555555555555555555555555555555555555555555555555555555555555555
-- 087:555555ba555555ba55555ba755555ba95555ba995555ba99555ba777555ba977
-- 088:999f55559775555577f5555597f55555995555557f5555557f5555557f555555
-- 089:55555555555555555555555555555555555555555555555b5555555b555555ba
-- 090:55ba88885ba988885b988888ba899999b9999999a98888999888888888888888
-- 091:8888855588888555899985559999555599985555999855558995555588855555
-- 092:5555555555555555555555555555555555555555555555555555555555555555
-- 093:5555555555555555555555555555555555555555555555555555555555555555
-- 094:5555555555555555555555555555555555555555555555555555555555555555
-- 095:5555555555555555555555555555555555555555555555555555555555555555
-- 096:5555555555555555555555555555555555555555555555555555555555555555
-- 097:5555555b55555555555555555555555555555555555555555555555555555555
-- 098:a6f999f7ba6f77775ba977ff5ba6fff955ba6f99555ba69f5555ba6755555ba6
-- 099:7f999985f99999789999f779999f77f99f777f997777ff99777ff999f7fff999
-- 100:5555555585555555985555559985555599988555999f78559f777988f777f999
-- 101:5555555555555555555555555555555555555555555555555555555588555555
-- 102:5555555555555555555555555555555555555555555555555555555555555555
-- 103:555ba99955ba999955ba997755ba77775ba777775ba997775b9999995a999999
-- 104:f5555555f5555555f5555555f55555557f5555557755555597f5555599995555
-- 105:555555b955555ba95555ba985555b988555ba888555b988855ba88885ba99999
-- 106:8889999999999999889999998888899988888888888888888888999899999999
-- 107:9985555599555555985555559855555595555555855555558555555555555555
-- 108:5555555555555555555555555555555555555555555555555555555555555555
-- 109:5555555555555555555555555555555555555555555555555555555555555555
-- 110:5555555555555555555555555555555555555555555555555555555555555555
-- 111:5555555555555555555555555555555555555555555555555555555555555555
-- 112:5555555555555555555555555555555555555555555555555555555555555555
-- 113:5555555555555555555555555555555555555555555555555555555555555555
-- 114:555555ba5555555b555555555555555555555555555555555555555555555555
-- 115:6fff999fa6f99ff7ba69f7775ba6777755ba677f555ba6ff5555baa655555bba
-- 116:77779999777f999977f999997ff9999fff9999f7f999ff77f99f777769f77777
-- 117:9988555599f78555ff779855777f998877f9999977f999997f999997ff999977
-- 118:55555555555555575555557b555557ba88557ba99789ba9879aba988eaba988f
-- 119:a9999aaa77aaaaaaaa999888a888888888888fff88ffffffff7aa7f87abbba78
-- 120:aaaa995599998889888888ab888889b9ff888b98f8f7b9888f7b9888f7b99999
-- 121:ba999999b9889999988888888888888888888888888888888999999999999989
-- 122:9999999999999998999999958888998588888855889995559998555589855555
-- 123:5555555555555555555555555555555555555555555555555555555555555555
-- 124:5555555555555555555555555555555555555555555555555555555555555555
-- 125:5555555555555555555555555555555555555555555555555555555555555555
-- 126:5555555555555555555555555555555555555555555555555555555555555555
-- 127:5555555555555555555555555555555555555555555555555555555555555555
-- 128:5555555555555555555555555555555555555555555555555555555555555555
-- 129:5555555555555555555555555555555555555555555555555555555555555555
-- 130:5555555555555555555555555555555555555555555555555555555555555555
-- 131:5555555b55555555555555555555555555555555555555555555555555555555
-- 132:a677777fbba677ff55ba6fff555ba6ff5555bba6555555ba5555555b55555555
-- 133:f999977ff99977f999977ff99777ff9b777fffab6ffff9baba6ffaba5bba9ba9
-- 134:9ba988f7aba9887bba98f7bca98ffabba98f7bbb98ff7ab798f7aa7f8ff777f8
-- 135:bccbba78cbbba78abbaff86bb78f8ab97f87ab98f87ba98887ba88887ba88897
-- 136:7b988899b9888888988888888888888888888997889977759775555555555555
-- 137:9999999888899999888888889999888877779998555557795555555555555555
-- 138:98955555998a555588899a55888889a58888889a988888897998888855798888
-- 139:5555555555555555555555555555555555555555a55555559555555579555555
-- 140:5555555555555555555555555555555555555555555555555555555555555555
-- 141:5555555555555555555555555555555555555555555555555555555555555555
-- 142:5555555555555555555555555555555555555555555555555555555555555555
-- 143:5555555555555555555555555555555555555555555555555555555555555555
-- 144:5555555555555555555555555555555555555555555555555555555555555555
-- 145:5555555555555555555555555555555555555555555555555555555555555555
-- 146:5555555555555555555555555555555555555555555555555555555555555555
-- 147:5555555555555555555555555555555555555555555555555555555555555555
-- 148:5555555555555555555555555555555555555555555555555555555555555555
-- 149:555baba95555ba985555ba88555ba980555ba8f055ba888f55ba888855ba8888
-- 150:8fffff8788ff889b00888aba00088b98c008a9f50088b7558888755588875555
-- 151:ba889755a8875555885555557555555555555555555555555555555555555555
-- 152:5555555555555555555555555555555555555555555555555555555555555555
-- 153:5555555555555555555555555555555555555555555555555555555555555555
-- 154:55579888555579885555598855555798555555985555557855555a7855555998
-- 155:895555558795555588955555887955558889955588879555888899958888799a
-- 156:55555555555555555555555555555555555555555555555555555555a5555555
-- 157:5555555555555555555555555555555555555555555555555555555555555555
-- 158:5555555555555555555555555555555555555555555555555555555555555555
-- 159:5555555555555555555555555555555555555555555555555555555555555555
-- 160:5555555555555555555555555555555555555555555555555555555555555555
-- 161:5555555555555555555555555555555555555555555555555555555555555555
-- 162:5555555555555555555555555555555555555555555555555555555555555555
-- 163:5555555555555555555555555555555555555555555555555555555555555555
-- 164:5555555555555555555555555555555555555555555555555555555555555555
-- 165:55ba8888555b9f88555baf88555baf89555b9889555b987555ba887555b98855
-- 166:8975555595555555755555555555555555555555555555555555555555555555
-- 167:5555555555555555555555555555555555555555555555555555555555555555
-- 168:555555555555555555555555555555555555555555555555555555555555555a
-- 169:5555555555555555555555555555555a55555aa9555aa9975aa97888a9988888
-- 170:5555a978555a97885aa97888a99788889788888f888888f7888f888f88f7ff88
-- 171:888888778888888888888888f888888f7f9888f7775888f978598f7979559788
-- 172:9aaa55558799aaaa888887798888888888888f88f888f7f87888f97f7f8f789f
-- 173:55555555a55555559aaa55558799aa55888799aa888f879988f7f8888f787888
-- 174:5555555555555555555555555555555555555555aa555555799a5555f879a555
-- 175:5555555555555555555555555555555555555555555555555555555555555555
-- 176:5555555555555555555555555555555555555555555555555555555555555555
-- 177:5555555555555555555555555555555555555555555555555555555555555555
-- 178:5555555555555555555555555555555555555555555555555555555555555555
-- 179:5555555555555555555555555555555555555555555555555555555555555555
-- 180:5555555555555555555555555555555555555555555555555555555555555555
-- 181:55b98955555a8955555b95555555555555555555555555555555555555555555
-- 182:5555555555555555555555555555555555555555555555555555555555555555
-- 183:555555555555555555555555555555555555555a555555a9555555a755555559
-- 184:55555aa95555a99755aa9788aa978f7f9788f7978888f7888855555555555555
-- 185:97888f888888f7f8888f7977f88798877ff78885777555555555555555555555
-- 186:8f7977f787988979f78889557795555555555555555555555555555555555555
-- 187:9555598855555555555555555555555555555555555555555555555555555555
-- 188:7ff7888797798889555978755555555555555555555555555555555555555555
-- 189:f7989f887557777f555555575555555555555555555555555555555555555555
-- 190:fff79aa59888879a777f88795557988755555588555555555555555555555555
-- 191:5555555555555555a55555559a5555557a55555587a555555755555555555555
-- 192:55111155511344251134cc411234cc4111234431111233115111211555111155
-- 193:55555555551232555123c3255124cc3551234325511222155511115555555555
-- 194:5555555555555555555345555524c45555234355555225555555555555555555
-- 195:5555555555555555555555555554c55555534555555555555555555555555555
-- 208:55999955599bcc9599bcccc99abcccc99abbccb999abbb99599aa99555999955
-- 209:55555555559aba5559abcba559acccb559abcba5599aaa955599995555555555
-- 210:5555555555555555555ab555559bcb55559aba55555995555555555555555555
-- 211:555555555555555555555555555bc555555ab555555555555555555555555555
-- 224:55999955599bcc9599bcccc99abcccc999bbccb9999abb995999a99555999955
-- 225:5511115551134425113444411234444111334431111233115111211555111155
-- 227:50000000503040405030000e5040000e5040000f00000000550d00d055505505
-- 228:5555005500000005eeeeeee00e0e0e00000000000000000555550d0555555055
-- 229:500000005038484850388888504808085040000000000000550d00d055505505
-- 230:0000000048488484888888880808080800000000000000005555555555555555
-- 231:0000000584848305888883050808040500000405000000000d00d05550550555
-- 232:505555555000005550eeee0550e0e0e0500000000000000050d050d055055505
-- 233:50000000503040405030000e5040000e5040000f00000000550d00d055505505
-- 234:5555005500000005eeeeeee00e0e0e00000000000000000555550d0555555055
-- 240:f0000000ff000000eff00000deff0000bdeff000cbdeff00ccbdeff0cccbdeff
-- 241:f00000008f00000088f00000988f00009988f000a9988f00aa9988f0aaa9988f
-- 242:f0000000ff0000008ff0000088ff0000888ff0009888ff0099888ff0999888ff
-- 243:55005555500000000eeeeeee00e0e0e0000000005000000050d0555555055555
-- 244:0000000504040305e0000305e0000405f0000405000000000d00d05550550555
-- </TILES>

-- <SPRITES>
-- 000:555555555effffff5ffffffe5fffffff5fffffff5fffffff5fffffff5effffff
-- 001:55555555ffff555555555555ffffffe5ffffffffffffffffffffffffffffffee
-- 002:555555555555555555555555555efffffffffffefffffeeeefefeeeeefeeeeee
-- 003:5555555555555efffffffeefffeefffefeeeeeefeeeeeeeeeeeeeeeeeeeeeeee
-- 004:55555555ffffffffffeefffefefeefefeeeeeeeeeeeeeefeeeeeeeeeeeeeeeee
-- 005:55555555ffffffffffffefffeeeefefeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 006:55555555fe555555effffffeeeefffffeeeefeeeeeeefeeeeeeeeeeeeeeeeeee
-- 007:555555555555555555555555ffff5555efeffffeeeeeffffeeeeeeefeeeeeeef
-- 008:5555555555555555555555555555555555555555ee555555efee5555eeffe555
-- 009:5555555555555555555555555555555555555555555555555555555555555555
-- 010:00f00ff000f0fccfffcfcccf00ffcff00fccfcf0fccfcfcffccffcff0ff00ff0
-- 011:4444444432222221322222103222230032222230322122233210122031000100
-- 016:55ffffff55ffffff555fffff5555fffe5555efee5555eeee5555feee555efeff
-- 017:ffffffeeffefeeeeffeeeeeeeeeeeeefeeeeeeeeeeeeeffeeffeffffeeffffff
-- 018:feeeeeeeeeeeeeeefefeeeefeeffeeffefeeeffeffeffffeffffffffffffffff
-- 019:eeeeeefefeeeefefefeefffefeefeefefefffeffffffffffffffffffffffffff
-- 020:eefeefeeefeeeefefffeefffffffffffffffffefffffffefffffffffffffffff
-- 021:eeeeeefefeefefeeeeffeeffffeefffffffeffffffffffffffffffffffffffff
-- 022:eeeeeeeeeeeefefefffeefeeeeffeffeeefffffeffffffffffffffffffffffff
-- 023:eeeeeeeeeeeeeeeeeefefeeeeffffeeefffefeeefffeffefffffffffffffffff
-- 024:eefffe55efefffffeeeeeeffefefeeefffeeeeeeffeefeeeffefffeefffffeef
-- 025:5555555555555555f5555555ef555555ef555555efe55555eef55555fef5f555
-- 032:555effff555effff555effff555effff555eeeff5555efff5555ffff55efffff
-- 033:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 034:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 035:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 036:ffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffefe
-- 037:fffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 038:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 039:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 040:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 041:ffffe555fffff555fff5f555fff55555ffe55555ff555555fe555555e5555555
-- 048:55ffffff55ffffff5fffffff5fffffff5fffffff5fffffff5fffffff5ffffffe
-- 049:fffffffffffffffffffffffffffffffffffffffffffffffeffffffe555555555
-- 050:ffffffffffffffffffffffffffffffffffffffffffffffff555555ff55555555
-- 051:fffffeffffffffffffffffffffffffffffffffffffffffffffffffff55555eff
-- 052:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 053:fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4f4f4
-- 054:fffffffffffffffffffffffffffffffffffffffffffffffffffffffffe555555
-- 055:fffffffffffffffffffffffffffffffffffffffffffff555e555555555555555
-- 056:ffffffeefffffe55fffe5555fee55555e5555555555555555555555555555555
-- 057:5555555555555555555555555555555555555555555555555555555555555555
-- 064:5effffff55555555555555555555555555555555555555555555555555555555
-- 065:ffff555555555555555555555555555555555555555555555555555555555555
-- 066:5555555555555555555555555555555555555555555555555555555555555555
-- 067:555f5fff555effff555f55555555555555555555555555555555555555555555
-- 068:ffffffffffffffff555555555555555555555555555555555555555555555555
-- 069:fffffffffffffff5555555555555555555555555555555555555555555555555
-- 070:f555555555555555555555555555555555555555555555555555555555555555
-- 071:5555555555555555555555555555555555555555555555555555555555555555
-- 072:5555555555555555555555555555555555555555555555555555555555555555
-- 073:5555555555555555555555555555555555555555555555555555555555555555
-- 080:555fffff555fffff555fffff555fffff555fffff555fffff555fffff5555ffff
-- 081:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 082:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 083:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 084:fffeedddff8eedddffeeddddf8eeddddfeeedddd8eeeddddeeeeddddeeeedddd
-- 085:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 086:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 087:dddddf55dddddf55dddddf55dddddf55ddddd555ddddd555dddde555dddde555
-- 088:55555555555555555555555555555555555555555555555555555555cccc5554
-- 089:5555555555555555555555555555555555555555555555554555554544555444
-- 090:55555555555555555555555555555555555555555555555555555555555ccccc
-- 091:55555555555555555555555555555555555555555555555555555555c555ccc5
-- 092:555555555555555555555555555555555555555555555555555555555ccc5ccc
-- 093:555555555555555555555555555555555555555555555555555555555555555c
-- 094:55555555555555555555555555555555555555555555555555555555cccccc55
-- 095:55555555555555555555555555555555555555555555555555555555ccccccc5
-- 096:5555ffff5555ffff5555ffff5555ffff55555fff55555fff55555fff55555fff
-- 097:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 098:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 099:fffffff8fffffffefffffffefffffffefffffff8fffffff8ffffffffffffffff
-- 100:eeeeddddeeeeeeddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88eeeeeeffff8888
-- 101:ddddddddddddddddeeeeeeddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888eeeee
-- 102:ddddddddddddddddddddddddeeddddddeeedddddeeeeddddeeeeddddeeeedddd
-- 103:ddddf555ddddf555ddddf555ddde5555ddde5555dddf5555dddf5555dde55555
-- 104:cccc5554cccc555455555554cccc5554cccc5554cccc5544cccc5544cccc5544
-- 105:4445444444444444444444444444444445444544454445444554554445545544
-- 106:555ccccc555ccccc555ccc55555ccc55555ccccc455ccccc455ccccc455ccc55
-- 107:cc55ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5cc55ccc5c555ccc55555ccc5
-- 108:5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc5ccc
-- 109:555555cc555555cc555555cc555555cc555555cc5555555c5555555555555555
-- 110:cccccc5ccccccc5cc555555cc555555cccccc55ccccccc5c555ccc5c555ccc5c
-- 111:ccccccc5ccccccc5cc555555cc555555ccccc555ccccc555cc555555cc555555
-- 112:555555ff555555ff555555ff5555555f5555555f555555555555555555555555
-- 113:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 114:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 115:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 116:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 117:ffff88eeffffff8efffffff8fffffff8fffffff8fffffff8fffffff8ffffffff
-- 118:eeeeddddeeeeddddeeedddddeeedddddeeedddddeeedddddeeddddddeedddddd
-- 119:dde55555ddf55555dd555555de555555df555555df555555e5555555f5555555
-- 120:cccc5444ccc55444cc554444c554444455444444444444454444444544444455
-- 121:4555554445555544555555545555555455555554555555555555555555555555
-- 122:445ccc554455cc5544455c554444555544444555444444454444444554444445
-- 123:5555cccc5555cccc55555ccc5555555555555555555555555555555555555555
-- 124:cccc5ccccccc5cccccc555cc5555555555555555555555555555555555555555
-- 125:ccccc5ccccccc5ccccccc5cc5555555555555555555555555555555555555555
-- 126:cccccc5ccccccc5cccccc5555555555555555555555555555555555555555555
-- 127:ccccccc5ccccccc5ccccccc55555555555555555555555555555555555555555
-- 128:555555555555555f5555555f5555555f555555ff555555ff555555ff555555ff
-- 129:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 130:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 131:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 132:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 133:fffffffffffffffefffffffeffffff8effffffeeffffffedfffffeedfffffedd
-- 134:eeddddddeddddddeeddddddfdddddddfdddddddfdddddddfdddddddedddddddd
-- 135:f5555555f5555555f5555555f5555555f5555555f5555555ef555555def55555
-- 144:55555fff55555fff55555fff55555fff5555ffff5555ffff5555ffff5555ffff
-- 145:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 146:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 147:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 148:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 149:ffffeeddffffedddfffeedddfffeddddffeeddddf8edddddfedddddd8edddddd
-- 150:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 151:ddf55555ddef5555dddf5555dddf5555ddde5555dddef555ddddf555ddddf555
-- 160:5555ffff555fffff555fffff555fffff555fffff555fffff555fffff555fffff
-- 161:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 162:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 163:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 164:fffffffffffffffefffffffeffffffeefffff8edfffffeedffffeeddffffeedd
-- 165:edddddddeddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 166:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 167:ddddf555dddde555dddde555ddddd555dddddf55dddddf55dddddf55dddddf55
-- 176:1c1c1c1cc1c1c1c1131313133131313113131313212121211212121221212121
-- 177:c0c0cccc040c0cccc0cc00ccccc0000ccc00c000cc000000ccc0000ccccc00cc
-- 178:5505500555050cc000c0ccc05500c0c050cc0c050cc0c0c00ccc0c0050005005
-- 180:cccc00ccc0c0cc0cccccccc00cc0cccccc0ccc00cccccc00cccc0000ccc00000
-- 181:cccccccccccccccccccccccc0ccccccc000ccccc000ccccc00000ccc000000cc
-- 192:0000000000bbbb000b0000b00b00c0b00b0000b00b0000b000bbbb0000000000
-- 193:00bbbb000b0000b0b000c00bb0000c0bb000000bb000000b0b0000b000bbbb00
-- 194:55555555555c5555555c55555cc5cc55555c5555555c55555555555555555555
-- 195:555555555555555555b5b555555b555555b5b555555555555555555555555555
-- 196:ccc000c0cc000000cc000000ccc00000ccc00000cccc0000ccccc000ccccccc0
-- 197:000000cc0000000c0000000c00c000cc00c000cc0c000ccc0000cccc00cccccc
-- 208:0000000000000000000000000cccccc000000000000000000000000000000000
-- 209:000000000000000000000000cccccccccccccccc000000000000000000000000
-- 210:0000000000000000005500000055cccc000ccccc000cc000000cc000000cc000
-- 211:000cc000000cc000000cc0000033cccc0033cccc000cc000000cc000000cc000
-- 212:000cc000000cc000000cc000cccccccccccccccc000cc000000cc000000cc000
-- 213:0000000000000000000000000000aacc000acccc000ac000000cc000000cc000
-- 214:0110110012212c10122222101222221001222100001210000001000000000000
-- 224:0cccc000cccccc00cc00cc00cc000cc0ccccccc0cc000cc0ccc00cc00ccc0c00
-- 225:0cccc000cccccc00cc00cc00cc000cc0ccccccc0cc0000c0ccc00cc00ccccc00
-- 226:00cccc000cccccc00cc00cc0cc000000cc000cc0ccc0ccc00ccccc0000ccc000
-- 227:0cccc000cccccc00cc00ccc0cc000cc0cc0000c0cc000cc0ccccccc00ccccc00
-- 228:00ccc0000ccccc00ccc0cc00cc000000cccc0000cc000cc00cccccc000cccc00
-- 229:00cccc000cccccc0cc000cc0cccc00c0cc000000ccc000000ccc000000cc0000
-- 230:000ccc0000ccccc00cc00cc0ccc00000cc00ccc0cc000cc0ccccccc00ccccc00
-- 231:0cc0cc00ccc0ccc0cc000cc0ccccccc0ccccccc0cc000cc0ccc0ccc00cc0cc00
-- 232:0000cc000cc0cc000ccc000000ccc000000cc000000cc00000cccc0000cccc00
-- 233:000ccc000cccccc00cc00cc0000000c0000000c0cc000cc0ccccccc00ccccc00
-- 234:cc000cc0cc000cc0cc00cc00cc0cc0000ccccc000cc0ccc0cc000cc0cc0000c0
-- 235:00cc00000ccc00000cc00000cc000000ccc000000ccc00c000ccccc0000ccc00
-- 236:0cc0cc00ccc0ccc0ccccccc0cc0c0cc0cc0c0cc0cc000cc0ccc0ccc00cc0cc00
-- 237:0ccc0000ccccc000cc0ccc00cc00cc00cc000cc0cc000cc0ccc00cc00cc00c00
-- 238:000ccc0000ccccc00cc00cc0cc0000c0cc0000c0cc000cc0ccccccc00ccccc00
-- 239:00cccc000cccccc0ccc000c0cc000cc0cccccc00cc0000000cc000000cc00000
-- 240:000ccc0000ccccc00cc00cc0cc0000c0cc00c0c0cc000cc0ccccccc00ccccc00
-- 241:0ccc0000cccccc00cc00ccc0cc000cc0cc00cc00ccccc000cc0ccc00cc00ccc0
-- 242:00cccc000cccccc00cc00cc000cc0000000ccc00cc000cc00cccccc000cccc00
-- 243:0ccccc00ccccccc0cc0cc0c0000cc00000cc000000cc000000ccc000000cc000
-- 244:0cc0cc00ccc0cc00cc000cc0cc0000c0cc0000c00cc00cc00cccccc000cccc00
-- 245:cc000c00cc000cc0cc0000c0cc0000c0cc000cc0ccc0ccc00ccccc0000ccc000
-- 246:0cc00c00ccc00cc0cc000cc0cc0c0cc0cc0c0cc0ccccccc0cccc0c000cc00000
-- 247:0cc0c000ccc0cc00cc000cc00ccccc000ccccc00cc000cc00cc0ccc000c0cc00
-- 248:0cc00c00ccc00cc0cc000cc0ccc0cc000cccc00000cc000000ccc000000cc000
-- 249:0ccccc00ccccccc0cc000cc00000cc0000ccc0000ccc0000ccccccc00cccccc0
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:89bcdeefffeedcb98754322111223457
-- 004:89bcdfffffffdcb98754311111113457
-- 005:89bcfffffffffcb98754111111111457
-- 006:8acfffffffffffca8641111511111146
-- 007:8afffffffffffffa8611111191111116
-- 008:0000000000ffffff0000000000ffffff
-- 009:000000000000ffff000000000000ffff
-- 010:00000000000000ff00000000000000ff
-- 011:000000000000000f000000000000000f
-- 013:ffffffffffffffffffffffffffffffff
-- 014:f0e0d0c0b0a090807060504030201000
-- 015:ff00dd00bb0099007700550033001100
-- </WAVES>

-- <SFX>
-- 000:0700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007002740c80004fd
-- 001:07c007c0070007000600060006000600050005000500050004000400040004000301030103000300070f070f070007000701070107000700070007001790c80004fe
-- 002:03c003c0030003000400040004000400050005000500050006000600060006000701070107000700070f070f070007000701070107000700070007004700c80004fe
-- 003:00c000c000000000080008000800080009000900090009000a000a000a000a000b010b020b020b010a000a0f0a0e0a0e090f090009000900080008004f20c80004fb
-- 004:0bc00bc00b000b000a000a000a000a000900090009000900080008000800080000010002000200010a000a0f0a0e0a0e090f090009000900080008003f70c80004fb
-- 005:0bc00bc04b007b009a00aa00ba00ca00c900d900d900e900e800f800f800f800f000f000f000f000fa00fa00fa00fa00f900f901f900f900f800f8004870c80004fb
-- 006:e3c0d390c3f0b350a32093a083c073306360530043e033b023d013600330039013f52312334e43a3532d63df73f483a39377a3c0b3a0c330d3d0e370b6200000fdfb
-- 007:0cf7000c1cc7200b3c97300a5c6760097c3780089c17a008bc07b008cc08d008dc08d008ec08e008fc08fc08fc08fc08fc08fc08fc08fc08fc08fc08b75000000000
-- 008:0cf7300c6cc7800bac97b00acc67c009dc37d008ec17e008ec07e008ec07e008ec07e008ec07e008ec07ec08ec07ec08ec07ec08ec07ec08ec07ec07d19000940000
-- 009:bec07e5acee65f8a8f205f26cf2c8ee07ea89e986d5c4d0e0d0f0d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d000d002520090c0b0f
-- 010:00c700c400c300c1080008000800080009000900090009000a000a000a000a000b000b000b000b000a000a000a000a0009000900090009000800080098504c0008f0
-- 011:0cf70e091cc72e094c976e097c678e099c37ae08ac17ce08dc07de08ec00ee08fc00fe08fc00fe08fc08fc08fc08fc08fc08fc08fc08fc08fc08fc08b05000000000
-- 012:0b000b000a000a00090009000800080000000000080008000a000a000b000b0000010001000100010000000f000f000f000f0000000000000000000048202e0004fb
-- 016:002080c008308820097089300ac08a700b000b000a000a0009000900080008000000000000000000000000000000000000000000000000000000000035200f080800
-- 017:002080c008308820098089300ac08a800b000b000a000a0009000900080008000000000000000000000000000000000000000000000000000000000035200f080800
-- 018:001080c008408810098089400ac08a800b000b000a000a0009000900080008000000000000000000000000000000000000000000000000000000000035200f080800
-- 019:001080d008408810098089400ad08a800b000b000a000a0009000900080008000000000000000000000000000000000000000000000000000000000035200f080800
-- 020:002080b008308820098089300ab08a800b000b000a000a0009000900080008000000000000000000000000000000000000000000000000000000000035200f080800
-- 021:003080a008508830097089500aa08a700b000b000a000a0009000900080008000000000000000000000000000000000000000000000000000000000035200f080800
-- </SFX>

-- <PATTERNS>
-- 000:6f8124000000000000000000000000000000000000000000600014000000000000000000000000000000000000000000600024000000000000000000000000000000000000000000000000000000000000000000900024000000000000000000600024000000000000000000000000000000000000000000600014000000000000000000000000000000000000000000600024000000000000000000000000000000000000000000000000000000000000000000900014000000000000000000
-- 001:68f124082500000000000000000000000000000000000000600014000000000000000000000000000000000000000000600024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600024000000000000000000000000000000000000000000600014000000000000000000000000000000000000000000600014000000000000000000000000000000000000000000624712000000000000000000000000000000000000000000
-- 002:00000000000000000000000000000000000000000000000080f16a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000660000009021880000009ff176000000000000000000
-- 003:00000000000000000000000000000000000000000000000064016a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600068000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600064000000000000940188000000902176000000000000
-- 004:68f126082500000000000000d08416000000000000000000600414000000000000000000000000000000000000000000600024000000000000000000000000000000000000000000620422000000000000000000000000000000000000000000638424000000000000000000000000000000000000000000600414000000000000000000000000000000000000000000624714000000000000000000000000000000000000000000600012000000000000000000000000000000000000000000
-- 005:92217600000060f126000000000000000000d0f4260000000000000000000000000000006f016a00000000000000000000000000000000000000000000000000000000000000000060006800000000000000000000000000000000000000000060110500210000310000410000510000610000710000810001910002a10003b10004c10005d10006e10007f10008e10009d1000ac1000bb1000ca1000d91000e81000f71000f61000e51000d41000c31000b21000a1100080100070100060100
-- 006:ef8122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00012000000000000000000a00022000000000000000000000000000000000000000000000000000000000000000000700012000000000000000000700024000000000000000000000000000000000000000000000000000000000000000000500012000000000000000000000000000000000000000000000000000000500014000000000000000000000000000000
-- 007:e8f122082500000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00012000000000000000000a00022000000000000000000a20424000000000000000000000000000000000000000000720412000000000000000000700414082500000000000000000000000000000000000000000000000000000000000000500022000000000000000000000000000000000000000000000000000000500014000000000000000000000000000000
-- 008:eff1420f010000f10008010000810004010094018a90618a9ff17608f1000f810000000060006800000000000000000000000000000000000000000000000000000094018a90618a9ff17608f1000f81000000000000000000000000000000007ff1320f010000f10008010000810004010094018a90618a9ff17608f1000f810000000000000000000000000000000000000000000000000000000000000000000094018a90618a9ff17608f1000f8100000000000000000000000000000000
-- 009:6221150441000661000881000aa1000fc1000fe1000fe1000ff1000ef1000cf1000af10008f10006f10004f10002f10062f12504f10006f10008f1000af1000cf1000ef1000ff1006ff1350fe1000fc1000fa1000f81000f61000f41000f21006f21350f41000f61000f81000fa1000fc1000fe1000fe1000ff1000ef1000cf1000af10008f10006f10004f10002f10062f14504f10006f10008f1000af1000cf1000ef1000ef1000ff1000fe1000fc1000fa1000f81000f61000f41000f2100
-- 010:ef8122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00012000000000000000000a000220000000000000000000000000000000000000000000000000000000000000000007000120000000000000000007000240000000000000000000000000000000000000000000000000000000000000000009000220000000000000000000000000000000000000000000e71000c61000a5100084100063100042100021100011100
-- 011:e8f122082500000000000000000000000000000000000000900026000000000000000000e00026000000000000000000a00012000000000000000000a00022000000000000000000a20424000000000000000000000000000000000000000000720412000000000000000000700414082500000000000000a0002600000000000000000070002600000000000000000098054200000000000000000000000000000000000000000007e10006c10005a100048100036100024100012100011100
-- 012:6f21170f41000f61000f81000fa1000fc1000fe1000fe1000ff1000ef1000cf1000af10008f10006f10004f10002f10062f12704f10006f10008f1000af1000cf1000ef1000ff1006ff1370fe1000fc1000fa1000f81000f61000f41000f21006f21370f41000f61000f81000fa1000fc1000fe1000fe1000ff1000ef1000cf1000af10008f10006f10004f10002f10062f15704f10006f10008f1000af1000cf1000ef1000ef1000ff1000fe1000fc1000fa1000f81000f61000f41000f2100
-- 013:eff1420f010090f14608010000810004010094018a90618a9ff17608f1000f810000000090006a00000000000000000000000000000000000000000000000000000094018a90618a9ff17608f1000f81000000000000000000000000000000007ff1320f010000f10008010000810004010094018a90618a9ff17608f1000f810000000000000000000000000000000000000000000000000000000000000000000094018a90618a9ff17608f1000f8100600066000000000000000000000000
-- 014:6ff1070ff1000ff1000ff1000ee1000ee1000ee1000ee1000dd1000dd1000dd1000dd1000cc1000cc1000cc1000cc1000bb1000bb1000bb1000bb1000aa1000aa1000aa1000aa100099100099100099100099100088100088100088100088100077100077100077100077100066100066100066100066100055100055100055100055100044100044100044100044100033100033100033100033100022100022100022100022100011100011100011100011100011100011100011100011100
-- 015:60019800010000010000110000110000110000210000210000210000310000310000310000410000410000410000510000510000510000610000610000610000710000710000710001810001810001810002910002910002910003a10003a1006f049204b10004b10004b10005c10005c10005c10006d10006d10006d10007e10007e10007e10008f10008f10008f10009f10009f10009f1000af1000af1000af1000af10004f10004f10004f10004f10004f10002f10002f10002f10002f100
-- 016:6ff1a20000006000a290008a6000b86801b86ff1546000b890008a9000866000a2000000dff17608f1000f810008f1006ff1a20000006000a290008a6000b86801b86ff1546000b890008a6000366000a2000000dff17608f1000f81006000a46ff1a20000006000a290008a6000b86801b86ff1546000b890008a9000866000a2000000dff17608f1000f810008f1006ff1a20000006000a290008a6000b86801b86ff1546000b890008a6000366000a26000a4dff17608f1006f8188000000
-- 017:68f1360f810008f1000f8100d8f1441f810088f1360f810008f1000f810008f1000f8100d8f1441f810098f1360f810008f1000f810008f1000f810008f1000f810018f1000f810098f1180f810018f1000f8100b8f1281f810008f1000f8100d8f1180f810008f1000f8100e8f1281f8100b8f1180f810008f1000f810008f1000f810098f1281f8100b8f1180f810008f1000f810008f1000f810008f1000f810018f1000f810008f1000f810008f1000f810008f1000f810008f1000f8100
-- 018:6ff132000000000000000000648136000000000000000000d48134000000848136000000000000000000d481340080006ff132000000000000000000948146000000000000000000022100000000948118000000000000000000b481280000006ff132000000000000000000d48118000000e48128000000b481180000000000000000000000000000009481280000006ff132000000000000000000b48118000000000000000000044100000000000000000000022100000000000000000000
-- 019:64a107000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:eff1a2000000e000a290008a6000b86801b8eff1546000b890008a900086e000a2000000dff17608f1000f810008f100aff1a2000000a000a290008a6000b86801b8aff1546000b890008aa00036a000a2000000dff17608f1000f81007000a47ff1a20000007000a290008a6000b86801b87ff1546000b890008a9000867000a2000000dff17608f1000f810008f1005ff1a20000005000a290008a6000b86801b85ff1546000b890008a5000365000a45000a4dff17608f1006f8188000000
-- 021:eff1a2000000e000a290008a6000b86801b8eff1546000b890008a900086e000a2000000dff17608f1000f810008f100aff1a2000000a000a290008a6000b86801b8aff1546000b890008aa00036a000a2000000dff17608f1000f81007000a47ff1a20000007000a290008a6000b86801b87ff1546000b890008a9000867000a2000000dff17608f1000f810008f1009ff1a20000009000a290008a6000b86801b89ff1546000b890008a9000369000a49000a4dff17608f1006f8188000000
-- 022:68f1360f810008f1000f810088f1361f810098f1360f810008f1000f810008f1000f810088f1461f810068f1360f810008f1000f810008f1000f810008f1000f810018f1000f810098f1180f810018f1000f8100b8f1281f810008f1000f8100d8f1180f810008f1000f8100e8f1281f8100b8f1180f810008f1000f810008f1000f810098f1281f810088f1180f810008f1000f810008f1000f810008f1000f810008f1000f810048f1180f810008f1000f810008f1000f810008f1000f8100
-- 023:6ff1320000000000000000006481360000000000000000008481360000009481360000000000000000008481360080006ff132000000000000000000648136000000000000000000022100000000948118000000000000000000b481280000006ff132000000000000000000d48118000000e48128000000b481180000000000000000000000000000009481280000006ff132000000000000000000848118000000000000000000000000000000448118000000000000000000000000000000
-- 024:68f1c60f810008f1000f8100e8f1c41f810098f1c60f810008f1000f810008f1000f810018f1000f810008f1000f810098f1c60f810008f1000f8100a8f1c61f810078f1c60f810008f1000f810008f1000f810008f1001f810008f1000f810078f1c60f810008f1000f810098f1c61f810058f1c60f810008f1000f810008f1000f810008f1001f810048f1c60f810008f1000f810058f1c61f810098f1c40f810008f1000f810008f1000f810008f1000f810018f1000f810008f1000f8100
-- 025:eff1300000000000000000006481c6000000e000c40000009000c6000000000000000000000000000000044100000000aff1320000000000000000009481c6000000a000c60000007000c60000000000000000000000000000000441000000007ff1320000000000000000007481c60000009000c60000005000c60000000000000000000000000000000441000000005ff1320000000000004481c65481c60000009000c4000000000000000000000000000000000000000000044100000000
-- 026:68f1c60f810008f1000f8100e8f1c41f810098f1c60f810008f1000f810008f1000f810018f1000f810008f1000f810098f1c60f810008f1000f8100a8f1c61f810078f1c60f810008f1000f810008f1000f810008f1001f810008f1000f810078f1c60f810008f1000f810098f1c61f810058f1c60f810008f1000f810008f1000f810008f1001f810048f1c60f810008f1000f8100d8f1c41f810098f1c60f810008f1000f810008f1000f810008f1000f810018f1000f810008f1000f8100
-- 027:eff1300000000000000000006481c6000000e000c40000009000c6000000000000000000000000000000044100000000aff1320000000000000000009481c6000000a000c60000007000c60000000000000000000000000000000441000000007ff1320000000000000000007481c60000009000c60000005000c60000000000000000000000000000000441000000009ff1320000000000004481c6d000c40000009000c6000000000000000000000000000000000000000000044100000000
-- 028:68f1c80f810008f1000f8100e8f1c61f810098f1c80f810008f1000f810008f1000f810018f1000f810008f1000f810098f1c80f810008f1000f8100a8f1c81f810078f1c80f810008f1000f810008f1000f810008f1001f810008f1000f810078f1c80f810008f1000f810098f1c81f810058f1c80f810008f1000f810008f1000f810008f1001f810048f1c80f810008f1000f810058f1c81f810098f1c60f810008f1000f810008f1000f810008f1000f810018f1000f810008f1000f8100
-- 029:eff1300000000000000000006481c8000000e000c60000009000c8000000000000000000000000000000044100000000aff1320000000000000000009481c8000000a000c80000007000c80000000000000000000000000000000441000000007ff1320000000000000000007481c80000009000c80000005000c80000000000000000000000000000000441000000005ff1320000000000004481c85000c80000009000c6000000000000000000000000000000000000000000044100000000
-- 030:68f1c80f810008f1000f8100e8f1c61f810098f1c80f810008f1000f810008f1000f810018f1000f810008f1000f810098f1c80f810008f1000f8100a8f1c81f810078f1c80f810008f1000f810008f1000f810008f1001f810008f1000f810078f1c80f810008f1000f810098f1c81f810058f1c80f810008f1000f810008f1000f810008f1001f810048f1c80f810008f1000f8100d8f1c61f810098f1c80f810008f1000f810008f1000f810008f1000f810018f1000f810008f1000f8100
-- 031:eff1300000000000000000006481c8000000e000c60000009000c8000000000000000000000000000000044100000000aff1320000000000000000009481c8000000a000c80000007000c80000000000000000000000000000000441000000007ff1320000000000000000007481c80000009000c80000005000c80000000000000000000000000000000441000000009ff1320000000000004481c8d000c60000009000c8000000000000000000000000000000000000000000044100000000
-- 032:6ff1a20000006000a290008a6000b86801b86ff1546000b890008a9000866000a2000000dff17608f1000f810008f1006ff1a20000006000a290008a6000b86801b86ff1546000b890008a6000366000a2000000dff17608f1000f81006000a46ff1a20000006000a290008a6000b86801b86ff1546000b890008a9000866000a2000000dff17608f1000f810008f1006ff1a20000006000a290008a6000b86801b86ff1546000b84000a2000000000000000000000000000000000000000000
-- 033:eff1a2000000e000a290008a6000b86801b8eff1546000b890008a900086e000a2000000dff17608f1000f810008f100aff1a2000000a000a290008a6000b86801b8aff1546000b890008aa00036a000a2000000dff17608f1000f81007000a47ff1a20000007000a290008a6000b86801b87ff1546000b890008a9000867000a2000000dff17608f1000f810008f1009ff1a20000009000a290008a6000b86801b89ff1546000b89000a2000000000000000000000000000000000000000000
-- 034:00000000000000000000000000000000000000000000000080416a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600066000000902188000000966176000000000000000000
-- 035:62f1320000000000006041440000001000000000000000000000000000000000000000006ff18a0f010000000000000062f1320000000000006041440000001000000000000000000000000000000000000000006ff18a00000068018c60818c62f1320000000000006041440000001000000000000000000000000000000000000000006ff18a00000000000000000062f1320000000000006041440000001000000000000000000000000000000000000000006ff18a62f134000000604146
-- 036:eff1320ff1000ff1000ff1000ee1000ee100eee1420ee1000dd1000dd1000dd1000dd100ecc1320cc1000cc1000cc1000bb1000bb100ebb1420bb1000aa1000aa1000aa1000aa100e99132099100099100099100088100088100e88142088100077100077100077100077100e66132066100066100066100055100055100e55142055100044100044100044100044100e33132033100033100033100022100022100e22142022100011100011100011100011100011100011100011100011100
-- 037:e00012000000000000000000000000000000e00022000000000000000000000000000000e00022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 038:6ff1170ff1000ff1000ff1000ee1000ee1000ee1000ee1000dd1000dd1000dd1000dd1000cc1000cc1000cc1000cc1000bb1000bb1000bb1000bb1000aa1000aa1000aa1000aa100099100099100099100099100088100088100088100088100077100077100077100077100066100066100066100066100055100055100055100055100044100044100044100044100033100033100033100033100022100022100022100022100011100011100011100011100011100011100011100011100
-- 039:e000a400000001110000000000000000000000000000000080f16a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600064000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 040:600008900008600008e00008022100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 041:00000062210892210862210862210a011100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 042:6101240111000211000211000321000321000421000421006531140531000631000631000741000741000841000841006951240951000a51000a51000b61000b61000c61000c61000d71000d71000e71000e71009f81240f81000f81000f81006f8124000000000000000000000000000000000000000000600014000000000000000000000000000000000000000000600024000000000000000000000000000000000000000000000000000000000000000000900014000000000000000000
-- 043:60112408250001210001210002310002310002410002410063511403510003610003610004710004710004810004810065912405910005a10005a10006b10006b10006c10006c10007d10007d10007e10007e10008f10008f10008f10008f10068f124000000000000000000000000000000000000000000600014000000000000000000000000000000000000000000600014000000000000000000000000000000000000000000624712000000000000000000000000000000000000000000
-- 044:600158000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 045:00000000000064110a94110a64110a64110c011100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 046:e00014000000000000eff1120ef1000df1000cf1000bf1000af10009f10008f10007f10006f10005f10004f10003f10002f10001f10001e10001d10001c10001b10001a100019100018100017100016100015100014100013100012100011100011100001100001100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:b2b321141381702982b03e431043c315b42515b4251943151e5815556a926d6c53557e922e7063702982b03e435a98e9000020
-- 001:9aaeeb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <SCREEN>
-- 000:ff0000000000ff000000000009fff0000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:ffff000fff003fff000ffff0fff0000ffff0ffff000fff000fff00ffff0000000000000000000000000000000000ee0000000000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000
-- 002:ff00f0ff00f0ff00f0fff0000fff00fff000ff00f0ff0ff0ff0ff0ff00f000000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000e000000000000f00000000000000000000000b0000000000000000000000
-- 003:ff00f0ff00f0ff00f000fff000fff0fff000ff0000fff000fff000ff00f000000d0000000a0000000000000000000000f00000000000000000000000000000000000000000000000000e00000000000000000000000000d000000000000000e000000000000000000000000000000000000e000000000000
-- 004:ffff000fff00ffff00ffff00ffff000ffff0ff00000fff000fff00ff00f000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000
-- 005:0000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000e000000000000000000
-- 006:ffff000000000000000ff000000000000000fffff000ff00000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000d0000000
-- 007:ff00f00fff000ffff0fefff0000000000000ff00000fff00000000000000000000000000000000000000f00000000e00000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000
-- 008:ffff00ff0ffdf00ff00ff000000000000000ffff00ff0f000000000000000000000e00000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000e00000000000000000000000
-- 009:ff00f0fff000f00ff00ff000000000000000000ff0fffff0000000000000000000000000000000000000000000f000000000000000000000000000000000000e0000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:ffff000fff000ffff000fff0000000000000ffff00000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000
-- 011:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000000000d000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:ffff00000000000e000000000000000000ffff000ff00fffff0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:ff00f00fff00f000f00000000000000000000ff0fff00000ff0000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:ff00f0ff00f0f0f0f000000000000000000fff000ff0000ff000000000000000f0000000000000000000000090000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:ffdf00fd00f0fffff000000000000000f0ff00000ff000ff0000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000b000000000000000000000000000000000e000000000000000000000000000000000000000000000000
-- 016:f900f00fff00ff0ff00010000000000000fffff0ffff0ff00000000000000000000000000000e000000000000000f0000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000
-- 017:0000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000d00e0000000000000000000000000000000000000000000000000d000000000000000000000000000000000000
-- 018:ffff0ff0000000000000000000000000fffff0fffff00000fff000ff000000000a00000000000000000000000000000000000000000000000000000009000000a000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:0ff00000ff0f000fff00000000000000ff0e00000ff0000ff00f0ffe00000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:0ff00ff0fdfff0ff0ff0000000000000ffff0000ff0d0000ffff00ff000000000000000000000000000000000000d000000000000000000000000f000000000000000000000000000000000000000000e0000000000000000000000000000000000cccccccccccf000000000000000000000000000000000
-- 021:0ff00ff0f0f0f0fff000000000000000000ff00ff000ff0000090dfff0000000000000000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00000000000000000000ccccccccccccccccccc000000000000000000000000000000
-- 022:0ff00ff0f0f0f00fff00000000000000ffef00ff0000df00fff00ffff0000e000000000000000e00000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000000000000000000000f0ccccccccccccccccccccccc0000000000000000000000000000
-- 023:00000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000e00000000000000000000000000000000000000000f090000000000000000000000000000000000000000ccccccccccccccccccccccccccccc0000000000000000000000000
-- 024:ff0000ffff0ff0000000000000000020000ff00fffff0000ffff0000ff00000f00000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc00000000000cccccccccccccc000000000000000000000000
-- 025:ff00f00ff00000ff0f000fff0000000000fff00ff0000000000ff00fff000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000e0000000000000cccc0000000000000000000cccccccccccc0000000000000000000000
-- 026:ff00000ff00ff0fffff0ff0ff0000000000ff00ffff000000fff00ff0f00000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000d0000000000000000000000000000000ccc00000000000000000000000ccccccccccc000000000000000000000
-- 027:ff00000ff00ffff0f0f0fff000000000000ff000f0ff0ff0ff0000fffff000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000ccccccccc000000e0000000000000
-- 028:fffff00ff00ff0f0f0f00fff0000000000ffff0ffff00ff0fffff0000f00000000000000000000000000000000b0000000000000000000000000000000000000000000100000000000000000000000000000000000f000000000c0000000000000000000000000000000ccccccccc0000000000000000000
-- 029:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc000000000000000000
-- 030:0000000000000000009000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc00000000000000000
-- 031:0000000000000000000000000000000000000000000d0000d000000de000000000000000000000000f000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000cccccccc0000000000000000
-- 032:00000000000000000000000000000000000000000000000000000000000000000000b0000b00000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc000000000000000
-- 033:000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000000000b00000000000000000000e00000000000000000000000000000000000000000000000000000000cccccccc00000000000000
-- 034:0000000000d00000000000000000e000000000e0000000000000000000000000000f0000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc00000000000000
-- 035:000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000000000ccccccc0000000000000
-- 036:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccc00000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000ccccccc000000000000
-- 037:0000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccce00000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc000000000000
-- 038:000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000ccccccc0000000000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc000000000000
-- 039:00000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000ccccccccc0000000000000000000000e000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc00000000000
-- 040:0000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000ccccccccccc000000e0000000f000000000e0000000000000e00000000000000000000000000000000000000000000000000000000000000000ccccc00000000000
-- 041:0000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000e0000000e00000000ccccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc000000000a
-- 042:00000000000000000000f000000000000000000000e0e00000000000000000000000000000000000000000000000000000000000000ccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc0000000000
-- 043:0000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000ccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc0000000000
-- 044:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc0000000000
-- 045:00000000000000000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000ccccccccccccccccccccc00000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000ccccc000000000
-- 046:0000000000000000000000000000000000000000000000000000000f00000000000000000000000000f00000000000000000000ccccccccccccccccccccccc0000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc000000000
-- 047:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00000ccccccccccccccccccccccccc0000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc000000000
-- 048:000000000000000000000000090000f0000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc000000000
-- 049:00000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc000000000
-- 050:0000000000000000000000000000000000000000000000000000000000000000000000000f0000000000000000000000000ccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc00000000c
-- 051:00000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc0000f00cc
-- 052:00000000000000000000000000000000000f000000000000000000000f000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccccc000000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000cccc000000ccc
-- 053:000e00000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccccccc0000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc00000cccc
-- 054:0000000000000000000000000d00000000000000000000000e00000000000000000000000000000000000f000000000ccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc0000ccccc
-- 055:0000000a0000f0000000000000000000d000000000000000000000f000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccccccccccc0000000d00000000000000000000000000000000000000000000a000000000000000000000000000000000000000cccc000cccccc
-- 056:000000aaa0000000000000f0000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000aaa00000000000000000000000000000000000000ccc000ccccccc
-- 057:000e0aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000aaaaa0000000000000000000000000000000000000ccc00cccccccc
-- 058:0000aaaaaaa0000000000000000000000000000000000000f000000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000aaaaaaa000000000000000000000000000000000000ccc0ccccccccc
-- 059:000aaaaaaaaa00000d000000000000000000000000000000000000000000000000000f00000000000000000000ccccccccccccccccccccccccccccccccccccccccccccccccc00000000000f00000000000000000000000000000000aaaaaaaaa00000000000000000000000000000000000ccccccccccccc
-- 060:00aaaaaaaaaaa000000000000000000000000000000000000e000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000aaaaaaaaaaa000000000000000000000000000000000cccccccccccccc
-- 061:caaaaaaaaaaaaa000000d0000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000aaaaaaaaaaaaa00000000000000000000000000000000cccccccccccccc
-- 062:ccaaaaaaaaaaaaa000000000000000000000000000000000000000000000020000900000000000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000aaaaaaaaaaaaaaa0000000000000000000000000000000cccccccccccccc
-- 063:cccaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000bccccccccccccccccccbccccccccccccccccccbcccccccccccccccccc000000000000000000000000000000000000aaaaaaaaaaaaaaaaa000000000000000000000000000000bccccccccccccc
-- 064:ccbbaaaaaaaaaaaaa0000000000000000000000000000000000000000d000000000000000000000000000bbbccccccccccccccccbbbccccccccccccccccbbbccccccccccccccccbb0000000000000000000000000000000000aaaaaaaaaaaaaaaaaaa0000000000000000000000000000bbbcccccccccccc
-- 065:cbbbbaaaaaaaaaaaaa00000000000000000000000000000900000000000d0000000d0000000000000000bbbbbccccccccccccccbbbbbccccccccccccccbbbbbccccccccccccccbbbb000000000000000000f0000000000000aaaaaaaaaaaaaaaaaaaaa00000000000000000000000000bbbbbccccccccccc
-- 066:bbbbbbaaaaaaaaaaaaa0000000000000000000000000009990000000000000000000000000000000000bbbbbbbccccccccccccbbbbbbbccccccccccccbbbbbbbccccccccccccbbbbbb000000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaa000000000000000000000000bbbbbbbcccccccccc
-- 067:bbbbbbbaaaaaaaaaaaaa00000000000000000000000009999900000000000000000000000000000000bbbbbbbbbccccccccccbbbbbbbbbccccccccccbbbbbbbbbccccccccccbbbbbbbb0000000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaa0000000000000000000000bbbbbbbbbccccccccc
-- 068:bbbbbbbbaaaaaaaaaaaaa0000000000000000000000099999990000000000100000000000000f0000bbbbbbbbbbbccccccccbbbbbbbbbbbccccccccbbbbbbbbbbbccccccccbbbbbbbbbb00000000000000000000d00000aaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000bbbbbbbbbbbcccccccc
-- 069:bbbbbbbbbaaaaaaaaaaaaab0000000000000000000099999999900000000000000000000000d0000bbbbbbbbbbbbbccccccbbbbbbbbbbbbbccccccbbbbbbbbbbbbbccccccbbbbbbbbbbbb000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000000000bbbbbbbbbbbbbccccccb
-- 070:bbbbbbbbbbaaaaaaaaaaaaa00000000000000000009999999999900000000000000000000000000bbbbbbbbbbbbbbbccccbbbbbbbbbbbbbbbccccbbbbbbbbbbbbbbbccccbbbbbbbbbbbbbb0000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000000000bbbbbbbbbbbbbbbccccbb
-- 071:bbbbbbbbbbbaaaaaaaaaaaaa000000000000000009999999999999000000000000000000000000bbbbbbbbbbbbbbbbbccbbbbbbbbbbbbbbbbbccbbbbbbbbbbbbbbbbbccbbbbbbbbbbbbbbbb00000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000bbbbbbbbbbbbbbbbbccbbb
-- 072:bbbbbbbbbbbbaaaaaaaaaaaaa0000000000000009999999999999990000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000bbbbbbbbbbbbbbbbbbbbbbb
-- 073:bbbbbbbbbbbddaaaaaaaaaaaaa00000000000009999999999999999900000000000000000000ddbbbbbbbbbbbbbbbbbddbbbbbbbbbbbbbbbbbddbbbbbbbbbbbbbbbbbddbbbbbbbbbbbbbbbbdd0000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000ddbbbbbbbbbbbbbbbbbddbbb
-- 074:bbbbbbbbbbddddaaaaaaaaaaa99000000000009999999999999999999000000000000000000ddddbbbbbbbbbbbbbbbddddbbbbbbbbbbbbbbbddddbbbbbbbbbbbbbbbddddbbbbbbbbbbbbbbdddd000000000000009aaaaaaaaaaa99aaaaaaaaaaa9aaaaaaaaaaa9900000000ddddbbbbbbbbbbbbbbbddddbb
-- 075:bbbbbbbbbddddddaaaaaaaaa99990000000009999999999999999999990000000000000000ddddddbbbbbbbbbbbbbddddddbbbbbbbbbbbbbddddddbbbbbbbbbbbbbddddddbbbbbbbbbbbbdddddd000000000000999aaaaaaaaa9999aaaaaaaaa999aaaaaaaaa9999000000ddddddbbbbbbbbbbbbbddddddb
-- 076:bbbbbbbbddddddddaaaaaaa99999900000009999999999999999999999900000000000000ddddddddbbbbbbbbbbbddddddddbbbbbbbbbbbddddddddbbbbbbbbbbbddddddddbbbbbbbbbbdddddddd000000000099999aaaaaaa999999aaaaaaa99999aaaaaaa9999990000ddddddddbbbbbbbbbbbdddddddd
-- 077:bbbbbbbddddddddddaaaaa99999999000009999999999999999999999999000000000000ddddddddddbbbbbbbbbddddddddddbbbbbbbbbddddddddddbbbbbbbbbddddddddddbbbbbbbbdddddddddd000000009999999aaaaa99999999aaaaa9999999aaaaa9999999900ddddddddddbbbbbbbbbddddddddd
-- 078:bbbbbbddddddddddddaaa99999999990009999999999999999999999999990000000000ddddddddddddbbbbbbbddddddddddddbbbbbbbddddddddddddbbbbbbbddddddddddddbbbbbbdddddddddddd000000999999999aaa9999999999aaa999999999aaa9999999999ddddddddddddbbbbbbbdddddddddd
-- 079:dbbbbdddddddddddddda99999999999909999999998999999999999999999800000000ddddddddddddddbbbbbddddddddddddddbbbbbddddddddddddddbbbbbddddddddddddddbbbbdddddddddddddd000099999999999a999999999999a99999999999a9999999999ddddddddddddddbbbbbddddddddddd
-- 080:ddbbdddddddddddddddd9999999999999899999998889999999889999999888000000ddddddddddddddddbbbddddddddddddddddbbbddddddddddddddddbbbddddddddddddddddbbdddddddddddddddd0099999999999999999999999999999999999999999999999ddddddddddddddddbbbdddddddddddd
-- 081:ddddddddddddddddddddd99999999999998999998888899999888899999888880000ddddddddddddddddddbddddddddddddddddddbddddddddddddddddddbdddddddddddddddddddddddddddddddddddd99999999999999999999999999999999999999999999999ddddddddddddddddddbddddddddddddd
-- 082:ddeeddddddddddddddddde999999999999989998888888999888888999888888800eedddddddddddddddddeddddddddddddddddddeddddddddddddddddddedddddddddddddddddeeddddddddddddddddde999999999999999999999999999999999999999999999eedddddddddddddddddeddddddddddddd
-- 083:deeeedddddddddddddddeee9999999999999898888888889888888889888888888eeeedddddddddddddddeeeddddddddddddddddeeeddddddddddddddddeeedddddddddddddddeeeedddddddddddddddeee9999999999999999999999999999999999999999999eeeedddddddddddddddeeedddddddddddd
-- 084:eeeeeedddddddddddddeeeee99999999999998888888888888888888888888888eeeeeedddddddddddddeeeeeddddddddddddddeeeeeddddddddddddddeeeeedddddddddddddeeeeeedddddddddddddeeeee99999999999999999999999999999999999999999eeeeeedddddddddddddeeeeeddddddddddd
-- 085:eeeeeeedddddddddddeeeeeee999999999999988888888888888888888888888eeeeeeeedddddddddddeeeeeeeddddddddddddeeeeeeeddddddddddddeeeeeeedddddddddddeeeeeeeedddddddddddeeeeeee999999999999999999999999999999999999999eeeeeeeedddddddddddeeeeeeedddddddddd
-- 086:eeeeeeeedddddddddeeeeeeeee9999999999998888888888888888888888888eeeeeeeeeedddddddddeeeeeeeeeddddddddddeeeeeeeeeddddddddddeeeeeeeeedddddddddeeeeeeeeeedddddddddeeeeeeeee9989999999999999999999999998999999999eeeeeeeeeedddddddddeeeeeeeeeddddddddd
-- 087:eeeeeeeeedddddddeeeeeeeeeee9999999aaaaaaaaa8888888888888888888eeeeeeeeeeeedddddddeeeeeeeeeeeddddddddeeeeeeeeeeeddddddddeeeeeeeeeeedddddddeeeeeeeeeeeedddddddeeeeeeeccccccccc999999998899999999998889999999eeeeeeeeeeeedddddddeeeeeeeeeeedddddddd
-- 088:eeeeeeeeeedddddeeeeeeeeeeeee999aaaaaaaaaaaaaaa888888888888888eeeeeeeeeeeeeedddddeeeeeeeeeeeeeddddddeeeeeeeeeeeeeddddddeeeeeeeeeeeeedddddeeeeeeeeeeeeeedddddeeeeccccccccccccccccc9998888999999998888899999eeeeeeeeeeeeeedddddeeeeeeeeeeeeedddddde
-- 089:eeeeeeeeeeedddeeeeeeeeecccccccccaaaaaaaaaaaaaaaa888888888888eeeeeeeeeeeeeeeedddeeeeeeeeeeeeeeeddddeeeeeeeeeeeeeeeddddeeeeeeeeeeeeeeedddeeeeeeeeeeeeeeeedddeeeccccccccccccccccccccc8888889999998888888999eeeeeeeeeeeeeeeedddeeeeeeeeeeeeeeeddddee
-- 090:eeeeeeeeeeeedeeeeeecccccccccccccccccaaaaaaaaaaaaaa888888888eeeeeeeeeeeeeeeeeedeeeeeeeeeeeeeeeeeddeeeeeeeeeeeeeeeeeddeeeeeeeeeeeeeeeeedeeeeeeeeeeeeeeeeeedeeccccccccccccccccccccccccc8888899998888888889eeeeeeeeeeeeeeeeeedeeeeeeeeeeeeeeeeeddeee
-- 091:eeeeeeeeeeeefeeeecccccccccccccccccccccaaaaaaaaaaaaa8888888feeeeeeeeeeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeecccccccccccccccccccccccccccccccccccccccc888899888888aaaafeeeeeeeeeeeeeeeeeefeeeeeeeeeeeeeeeeeeeeee
-- 092:eeeeeeeeeeefffecccccccccccccccccccccccccaaaaaaaaaaaa88888fffeeeeeeeeeeeeeeeefffeeeeeeeeeeeeeeeeffeeeeeeeeeeeeeeeeeffeeeeeeeeeeeeeeeefffeeeccccccccccccccccccccccccccccccccccccccccccccc888888888aaaaafffeeeeeeeeeeeeeeeefffeeeeeeeeeeeeeeeeffecc
-- 093:eeecccccccccfcccccccccccccccccccccccccccccaaaaaaaaaaa88afffffeeeeeeeeeeeeeefffffeeeeeeeeeeeeeeffffeeeeeccccccccceffffeeeeeeeeeeeeeefffffcccccccccccccccccccccccccccccccccccccccccccccccc888888aaaaaafffffeeeeeeeeeeeeeefffffeeeccccccccceeffcccc
-- 094:cccccccccccccccccccccccccccccccccccccccccccccccccccccaafffffffeeeeeeeeeeeefffffffeeeeeeeeeeeeffffffcccccccccccccccccffeeeeeeeeeeeeffffccccccccccccccccccccccccccccccccccccccccccccccccccc888aaaaaaafffffffeeeeeeeeeeeefffffccccccccccccccccccccc
-- 095:ccccccccccccccccccccccccccccccccccccccccccccccccccccccccfffffffeeeeeeeeeefffffffffeeeeeeeeeefffffcccccccccccccccccccccfeeeeeeeeeefffcccccccccccccccccccccccccccccccccccccccccccccccccccccc8aaaaaaafffffffffeeeeeeeeeeffffccccccccccccccccccccccc
-- 096:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfffffeeeeeeeefffffffffffeeeeeeeeffffccccccccccccccccccccccccceeeeeeeefffccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaafffffffffffeeeeeeeefffccccccccccccccccccccccccc
-- 097:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffcccccccccfffffffffffcccccccccffccccccccccccccccccccccccccceecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaafffffffffffcccccccccfccccccccccccccccccccccccccc
-- 098:ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfffffffccccccccccccccccccccccccccccccccccccccccc
-- 099:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffccccccccccccccccccccccccccccccccccccccccccc
-- 100:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 101:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 102:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 103:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 104:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 105:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 106:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 107:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 108:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 109:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 110:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 111:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 112:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 113:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 114:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 115:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 116:ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfffffffccccccccccccccccccccccccccccccccccccccccccccc
-- 117:cccccccccccccccccccccccccccccccccccccccccccccccccccccccfffffeeeeeeeefffffffffffeeeeeeeeffffccccccccccccccccccccccccceeeeeeeefffccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaafffffffffffeeeeeeeefffccccccccccccccccccccccccccccc
-- 118:cccccccccccccccccccccccccccccccccccccccccccccccccaafffffffeeeeeeeeeeeefffffffeeeeeeeeeeeeffffffcccccccccccccccccffeeeeeeeeeeeeffffccccccccccccccccccccccccccccccccccccccccccccccccccc888aaaaaaafffffffeeeeeeeeeeeefffffccccccccccccccccccccccccc
-- 119:ccccccccfcccccccccccccccccccccccccccccaaaaaaaaaaa88afffffeeeeeeeeeeeeeefffffeeeeeeeeeeeeeeffffeeeeeccccccccceffffeeeeeeeeeeeeeefffffcccccccccccccccccccccccccccccccccccccccccccccccc888888aaaaaafffffeeeeeeeeeeeeeefffffeeeccccccccceeffcccccccc
-- 120:eeeeeeeefeeeecccccccccccccccccccccaaaaaaaaaaaaa8888888feeeeeeeeeeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeecccccccccccccccccccccccccccccccccccccccc888899888888aaaafeeeeeeeeeeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeee
-- 121:eeeeeeeeedddeeeeeeeeecccccccccaaaaaaaaaaaaaaaa888888888888eeeeeeeeeeeeeeeedddeeeeeeeeeeeeeeeddddeeeeeeeeeeeeeeeddddeeeeeeeeeeeeeeedddeeeeeeeeeeeeeeeedddeeeccccccccccccccccccccc8888889999998888888999eeeeeeeeeeeeeeeedddeeeeeeeeeeeeeeeddddeeee
-- 122:eeeeeeedddddddeeeeeeeeeee9999999aaaaaaaaa8888888888888888888eeeeeeeeeeeedddddddeeeeeeeeeeeddddddddeeeeeeeeeeeddddddddeeeeeeeeeeedddddddeeeeeeeeeeeedddddddeeeeeeeccccccccc999999998899999999998889999999eeeeeeeeeeeedddddddeeeeeeeeeeeddddddddee
-- 123:eeeeeedddddddddeeeeeeeee9999999999998888888888888888888888888eeeeeeeeeedddddddddeeeeeeeeeddddddddddeeeeeeeeeddddddddddeeeeeeeeedddddddddeeeeeeeeeedddddddddeeeeeeeee9989999999999999999999999998999999999eeeeeeeeeedddddddddeeeeeeeeedddddddddee
-- 124:eeeeeedddddddddddddeeeee99999999999998888888888888888888888888888eeeeeedddddddddddddeeeeeddddddddddddddeeeeeddddddddddddddeeeeedddddddddddddeeeeeedddddddddddddeeeee99999999999999999999999999999999999999999eeeeeedddddddddddddeeeeeddddddddddd
-- 125:deeeedddddddddddddddeee9999999999999898888888889888888889888888888eeeedddddddddddddddeeeddddddddddddddddeeeddddddddddddddddeeedddddddddddddddeeeedddddddddddddddeee9999999999999999999999999999999999999999999eeeedddddddddddddddeeedddddddddddd
-- 126:ddddddddddddddddddddddd99999999999998999998888899999888899999888880000ddddddddddddddddddbddddddddddddddddddbddddddddddddddddddbdddddddddddddddddddddddddddddddddddd99999999999999999999999999999999999999999999999ddddddddddddddddddbddddddddddd
-- 127:ddddbbdddddddddddddddd9999999999999899999998889999999889999999888000000ddddddddddddddddbbbddddddddddddddddbbbddddddddddddddddbbbddddddddddddddddbbdddddddddddddddd0099999999999999999999999999999999999999999999999ddddddddddddddddbbbdddddddddd
-- 128:dddddbbbbdddddddddddddda99999999999909999999998999999999999999999800000000ddddddddddddddbbbbbddddddddddddddbbbbbddddddddddddddbbbbbddddddddddddddbbbbdddddddddddddd000099999999999a999999999999a99999999999a9999999999ddddddddddddddbbbbbddddddd
-- 129:ddddbbbbbbbddddddddddaaaaa99999999000009999999999999999999999999000000000000ddddddddddbbbbbbbbbddddddddddbbbbbbbbbddddddddddbbbbbbbbbddddddddddbbbbbbbbdddddddddd000000009999999aaaaa99999999aaaaa9999999aaaaa9999999900ddddddddddbbbbbbbbbddddd
-- 130:dddddbbbbbbbbbddddddddaaaaaaa99999900000009999999999999999999999900000000000000ddddddddbbbbbbbbbbbddddddddbbbbbbbbbbbddddddddbbbbbbbbbbbddddddddbbbbbbbbbbdddddddd000000000099999aaaaaaa999999aaaaaaa99999aaaaaaa9999990000ddddddddbbbbbbbbbbbdd
-- 131:ddddbbbbbbbbbbbddddddaaaaaaaaa99990000000009999999999999999999990000000000000000ddddddbbbbbbbbbbbbbddddddbbbbbbbbbbbbbddddddbbbbbbbbbbbbbddddddbbbbbbbbbbbbdddddd000000000000999aaaaaaaaa9999aaaaaaaaa999aaaaaaaaa9999000000ddddddbbbbbbbbbbbbbd
-- 132:bbddddbbbbbbbbbbbddddddaaaaaaaaa99990000000009999999999999999999990000000000000000ddddddbbbbbbbbbbbbbddddddbbbbbbbbbbbbbddddddbbbbbbbbbbbbbddddddbbbbbbbbbbbbdddddd000000000000999aaaaaaaaa9999aaaaaaaaa999aaaaaaaaa9999000000ddddddbbbbbbbbbbbb
-- 133:bbbddbbbbbbbbbbbbbddddaaaaaaaaaaa99000000000009999999999999999999000000000000000000ddddbbbbbbbbbbbbbbbddddbbbbbbbbbbbbbbbddddbbbbbbbbbbbbbbbddddbbbbbbbbbbbbbbdddd000000000000009aaaaaaaaaaa99aaaaaaaaaaa9aaaaaaaaaaa9900000000ddddbbbbbbbbbbbbb
-- 134:bbbbbbbbbbbbbbbbbbbddaaaaaaaaaaaaa00000000000009999999999999999900000000000000000000ddbbbbbbbbbbbbbbbbbddbbbbbbbbbbbbbbbbbddbbbbbbbbbbbbbbbbbddbbbbbbbbbbbbbbbbdd0000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000ddbbbbbbbbbbbbbb
-- 135:bbbbbccbbbbbbbbbbbbbbbaaaaaaaaaaaaa0000000000000009999999999999990000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000bbbbbbbbbbbbb
-- </SCREEN>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

