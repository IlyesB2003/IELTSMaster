import cairo, math, sys
S=1024
def squircle(ctx,x,y,w,h,n=5.0,steps=720):
    cx,cy,a,b=x+w/2,y+h/2,w/2,h/2
    for i in range(steps+1):
        t=2*math.pi*i/steps
        c,s=math.cos(t),math.sin(t)
        px=cx+a*(abs(c)**(2/n))*(1 if c>=0 else -1)
        py=cy+b*(abs(s)**(2/n))*(1 if s>=0 else -1)
        (ctx.move_to if i==0 else ctx.line_to)(px,py)
    ctx.close_path()
def hexc(h,a=1): return ((h>>16&255)/255,(h>>8&255)/255,(h&255)/255,a)
def lerp(c1,c2,t): return tuple(c1[i]+(c2[i]-c1[i])*t for i in range(4))

surf=cairo.ImageSurface(cairo.FORMAT_ARGB32,S,S); ctx=cairo.Context(surf)
X,Y,W=100,100,824
# soft drop shadow
for i in range(24):
    ctx.save(); squircle(ctx,X-i*0.4,Y+14+i*0.6-i*0.4,W+i*0.8,W+i*0.8); ctx.set_source_rgba(0,0,0,0.006); ctx.fill(); ctx.restore()
# body gradient (ink navy)
squircle(ctx,X,Y,W,W,n=4.6); g=cairo.LinearGradient(0,Y,0,Y+W)
g.add_color_stop_rgba(0,*hexc(0x1B3A78)); g.add_color_stop_rgba(0.55,*hexc(0x0F2452)); g.add_color_stop_rgba(1,*hexc(0x091833))
ctx.set_source(g); ctx.fill_preserve()
# top sheen
rg=cairo.RadialGradient(512,170,20,512,170,620); rg.add_color_stop_rgba(0,1,1,1,0.16); rg.add_color_stop_rgba(1,1,1,1,0)
ctx.set_source(rg); ctx.fill_preserve()
# hairline edge
ctx.set_line_width(3); ctx.set_source_rgba(1,1,1,0.10); ctx.stroke()

cx,cy,R,lw=512,516,262,54
c1,c2=hexc(0x34D3B8),hexc(0x3B82F6)
start,end=math.radians(-90+34),math.radians(-90+34+300)
N=240
ctx.set_line_width(lw); ctx.set_line_cap(cairo.LINE_CAP_BUTT)
for i in range(N):
    a0=start+(end-start)*i/N; a1=start+(end-start)*(i+1.6)/N
    ctx.set_source_rgba(*lerp(c1,c2,i/N)); ctx.arc(cx,cy,R,a0,min(a1,end)); ctx.stroke()
# round caps
for a,c in ((start,c1),(end,c2)):
    ctx.set_source_rgba(*c); ctx.arc(cx+R*math.cos(a),cy+R*math.sin(a),lw/2,0,2*math.pi); ctx.fill()
# gold target dot in the gap
ga=math.radians(-90+17)
ctx.set_source_rgba(*hexc(0xF5C76A)); ctx.arc(cx+R*math.cos(ga),cy+R*math.sin(ga),17,0,2*math.pi); ctx.fill()

# open book
ctx.save(); ctx.translate(cx,cy+12); ctx.scale(1.32,1.32); ctx.translate(-cx,-cy)
def page(sign):
    ctx.new_path()
    sx=cx; by=cy+92; ty=cy-70
    ctx.move_to(sx,by)
    ctx.curve_to(sx+sign*52,by-30, sx+sign*120,by-36, sx+sign*150,by-18)
    ctx.line_to(sx+sign*150,ty-6)
    ctx.curve_to(sx+sign*118,ty-28, sx+sign*50,ty-22, sx,ty+6)
    ctx.close_path()
for sign in (-1,1):
    page(sign); pg=cairo.LinearGradient(cx,0,cx+sign*150,0)
    pg.add_color_stop_rgba(0,*hexc(0xC9D8F2)); pg.add_color_stop_rgba(0.25,*hexc(0xF4F8FF)); pg.add_color_stop_rgba(1,1,1,1,1)
    ctx.set_source(pg); ctx.fill()
# spine line
ctx.set_source_rgba(*hexc(0x0F2452,0.55)); ctx.set_line_width(5)
ctx.move_to(cx,cy-62); ctx.line_to(cx,cy+90); ctx.stroke()
# text lines on pages
ctx.set_line_width(7); ctx.set_line_cap(cairo.LINE_CAP_ROUND); ctx.set_source_rgba(*hexc(0x3B82F6,0.55))
for sign in (-1,1):
    for k in range(3):
        y=cy-22+k*30
        ctx.move_to(cx+sign*34,y+4-k*1); ctx.line_to(cx+sign*(112-k*14),y-6-k*1); ctx.stroke()
ctx.restore()
surf.write_to_png(sys.argv[1])
