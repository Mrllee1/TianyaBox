"""Pin the user-approved A layout and adapt it to genuine iPad captures."""
from pathlib import Path
import shutil
import json

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
PREVIEW = REPO / 'design-previews/2026-11-08-appstore-portrait'
selection = json.loads((PREVIEW / 'selection.json').read_text())
assert selection['id'] == 'A' and selection['source'] == 'explicit user reply in chat'
html = (PREVIEW / 'poster.html').read_text()
html = html.replace('assets/icon.png', 'brand-icon.png')
for old, new in [('library.png','01-character.png'),('scene.png','02-simulator.png'),('theater.png','03-theater.png'),('cast.png','04-identity.png'),('creator.png','05-creator.png')]:
    html = html.replace(old,new)
html = html.replace("const dir=(q.get('dir')||'a').toLowerCase();", "const dir='a';const device=q.get('device')==='ipad'?'ipad':'iphone';")
html = html.replace("p.className='poster dir-'+dir+' p'+(i+1);", "p.className='poster dir-'+dir+' p'+(i+1)+(device==='ipad'?' tablet':'');if(device==='ipad'){document.documentElement.style.width='2064px';document.documentElement.style.height='2752px';document.body.style.width='2064px';document.body.style.height='2752px';}")
html = html.replace("'assets/'+data.image", "'source/'+device+'/'+data.image")
html = html.replace("'assets/'+slides[(i+1)%5].image", "'source/'+device+'/'+slides[(i+1)%5].image")
html = html.replace('viewBox="0 0 6030 2622"', 'viewBox="0 0 6030 2622" preserveAspectRatio="none"')
tablet_css = '''
/* iPad: native tablet content and proportions, same approved brand composition. */
.poster.tablet{width:2064px;height:2752px}.tablet .brand{top:75px;left:135px;gap:24px;font-size:47px}.tablet .brand img{width:90px;height:90px;border-radius:25px}.tablet .wordmark{font-size:34px}.tablet .dots{top:116px;right:135px}.tablet .copy{left:135px;right:120px;top:235px}.tablet .copy h1{font-size:150px;line-height:1.18;letter-spacing:-6px}.tablet .copy p{font-size:45px;line-height:1.5;margin-top:34px}.tablet .rule{left:135px;right:135px;top:714px}.tablet .flow{left:calc(var(--i) * -2064px);width:10320px;height:2752px}.tablet .circle{width:2200px;height:2200px;left:100px;top:700px}.tablet .phone{padding:18px;border-radius:82px}.tablet .phone img{border-radius:60px}.tablet .phone:after{border-radius:80px}.tablet.dir-a.p1 .main{width:1660px;left:252px;top:855px;transform:rotate(-5deg)}.tablet.dir-a.p2 .main{width:1660px;left:205px;top:840px;transform:rotate(4deg)}.tablet.dir-a.p3 .main{width:1680px;left:212px;top:815px;transform:rotate(-2deg)}.tablet.dir-a.p4 .main{width:1660px;left:195px;top:850px;transform:rotate(3deg)}.tablet.dir-a.p5 .main{width:1660px;left:220px;top:820px;transform:rotate(-2deg)}
'''
html = html.replace('</style>',tablet_css+'</style>')
(HERE/'layout.html').write_text(html)
shutil.copy2(REPO/'NIVMHost/Runner/Assets.xcassets/AijinAppIcon.appiconset/Aijin-AppIcon-1024x1024@1x.png', HERE/'brand-icon.png')
print('Prepared approved A layout, iPhone and iPad')
