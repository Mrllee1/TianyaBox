"""Build store-art direction previews from genuine product UI captures.

Only HTML/CSS layout and asset copies. Product pixels and source stay unchanged.
The previews are not uploads or App Store submission approval.
"""
from pathlib import Path
import base64
import hashlib
import json
import shutil

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
ASSETS = HERE / 'assets'
ASSETS.mkdir(exist_ok=True)
sources = {
    'library.png': 'NIVMHost/Build/QA/aijin-appstore-20261108/upload/store-screenshots/iphone/library.png',
    'scene.png': 'NIVMHost/Build/QA/qingqing-parity/ios-simulator-detail.png',
    'theater.png': 'NIVMHost/AppStore/Aijin-1.0/screenshots/iphone/03-theater.png',
    'cast.png': 'NIVMHost/Build/QA/qingqing-parity/ios-simulator-cast.png',
    'creator.png': 'NIVMHost/AppStore/Aijin-1.0/screenshots/iphone/04-creator.png',
    'icon.png': 'NIVMHost/Runner/Assets.xcassets/AijinAppIcon.appiconset/Aijin-AppIcon-1024x1024@1x.png',
}
records = []
for name, source in sources.items():
    origin = REPO / source
    shutil.copy2(origin, ASSETS / name)
    records.append({'asset': 'assets/' + name, 'source': source, 'sha256': hashlib.sha256(origin.read_bytes()).hexdigest()})
(HERE / 'provenance.json').write_text(json.dumps({
    'purpose': 'Portrait App Store marketing direction preview; not submitted.',
    'layout': 'HTML and CSS framing of unmodified native UI captures; no generated app UI or fixture screens.',
    'limitation': 'Historical scene and cast captures are preview references; final device-size exports require current matching-device captures.',
    'product_changes': False, 'b_side_changes': False, 'assets': records,
}, ensure_ascii=False, indent=2) + '\n')

poster = '''<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>爱锦 · 竖屏组图样机</title><style>
*{box-sizing:border-box}html,body{margin:0;width:1206px;height:2622px;overflow:hidden}body{font-family:"PingFang SC","Hiragino Sans GB",sans-serif;-webkit-font-smoothing:antialiased}.poster{width:1206px;height:2622px;position:relative;overflow:hidden;isolation:isolate}.brand{position:absolute;top:86px;left:92px;display:flex;align-items:center;gap:20px;z-index:5;font-size:39px;font-weight:650;letter-spacing:2px}.brand img{height:76px;width:76px;border-radius:22px}.wordmark{font-size:30px;letter-spacing:3px;font-weight:500;margin-left:20px;opacity:.66}.copy{position:absolute;left:92px;top:235px;right:80px;z-index:5}.copy h1{font-size:116px;font-weight:700;line-height:1.22;letter-spacing:-5px;margin:0}.copy p{font-size:36px;font-weight:400;letter-spacing:1px;line-height:1.6;margin:38px 0 0}.copy em{font-style:normal}.phone{position:absolute;width:948px;padding:14px;border:3px solid rgba(255,255,255,.35);border-radius:96px;background:#242726;box-shadow:0 55px 100px #0005;overflow:hidden;z-index:3;transform-origin:center}.phone img{display:block;width:100%;border-radius:78px;height:auto}.phone:after{content:"";position:absolute;inset:0;pointer-events:none;border-radius:94px;box-shadow:inset 0 0 0 3px #fff4}.phone.main{left:129px;top:695px}.phone.aux{display:none}.flow{position:absolute;left:calc(var(--i) * -1206px);top:0;width:6030px;height:2622px;z-index:1;overflow:visible}.rule{position:absolute;left:92px;right:92px;top:626px;height:1px;background:currentColor;opacity:.18}.caption{position:absolute;bottom:62px;left:92px;z-index:6;font-size:27px;letter-spacing:2px}.circle{position:absolute;width:1540px;height:1540px;border-radius:50%;left:80px;top:720px;z-index:0}.texture{position:absolute;inset:0;pointer-events:none;z-index:0}.stamp{display:none}.poster .dots{position:absolute;top:116px;right:92px;display:flex;gap:10px}.dots span{width:9px;height:9px;border-radius:50%;background:currentColor;opacity:.23}.dots span.on{opacity:1;width:30px;border-radius:8px}
/* A: editorial technology. Continuous coral route, alternating natural device poses. */
.dir-a{background:#161b1a;color:#f4f3ec}.dir-a .copy em{color:#ff9c83}.dir-a .copy p{color:#bac5be}.dir-a .circle{background:radial-gradient(circle at 45% 40%,#3d493b 0,#242d27 38%,#161b1a 70%)}.dir-a .flow path.route{stroke:#db806d;stroke-width:58;opacity:.55}.dir-a .flow path.hair{stroke:#cbd2c5;stroke-width:2;opacity:.18}.dir-a .phone{border-color:#88998b;background:#313c34;box-shadow:0 60px 130px #0008}.dir-a.p1 .main{left:170px;top:790px;transform:rotate(-8deg)}.dir-a.p2 .main{left:110px;top:740px;transform:rotate(5deg)}.dir-a.p3 .main{left:132px;top:710px;transform:rotate(-3deg)}.dir-a.p4 .main{left:120px;top:740px;transform:rotate(4deg)}.dir-a.p5 .main{left:135px;top:720px;transform:rotate(-3deg)}.dir-a .caption{color:#bac5be}.dir-a .texture{background-image:radial-gradient(#e1ead81a .8px,transparent .8px);background-size:12px 12px;opacity:.15}
/* B: print-like warm gallery, serif headlines, square editorial slab behind native screens. */
.dir-b{background:#f1e8d9;color:#352e28}.dir-b .brand{top:82px;font-size:36px}.dir-b .copy{top:250px}.dir-b .copy h1{font-family:"Songti SC","STSong",serif;font-weight:700;font-size:120px;line-height:1.25;letter-spacing:-4px}.dir-b .copy em{color:#a64736}.dir-b .copy p{color:#73685b;font-size:34px}.dir-b .circle{border-radius:430px 430px 0 0;left:118px;top:770px;width:970px;height:1800px;background:#d6c1a4}.dir-b .phone{padding:8px;border:0;border-radius:66px;background:#8d8172;box-shadow:0 30px 60px #4b3a2626}.dir-b .phone img{border-radius:58px}.dir-b .phone:after{border-radius:66px;box-shadow:inset 0 0 0 1px #211a1730}.dir-b .phone.main{left:160px;top:825px;width:886px}.dir-b .flow path.route{stroke:#b87d5e;stroke-width:8;opacity:.28}.dir-b .flow path.hair{stroke:#9d8b73;stroke-width:1;opacity:.2}.dir-b .rule{top:670px}.dir-b .stamp{display:block;position:absolute;left:92px;top:723px;font-size:25px;letter-spacing:6px;text-transform:uppercase;color:#8a7864}.dir-b .caption{color:#8a7864}
/* C: pale mint, precise grid, generous product framing, sans-serif black typography. */
.dir-c{background:#e9f2e9;color:#14251e}.dir-c .copy{top:230px}.dir-c .copy h1{font-size:112px;line-height:1.2;letter-spacing:-6px;font-weight:650}.dir-c .copy em{color:#23745d}.dir-c .copy p{color:#4d6a5c}.dir-c .brand img{border-radius:50%}.dir-c .wordmark{font-family:Menlo,monospace;font-size:28px;letter-spacing:4px}.dir-c .texture{background-image:linear-gradient(#224d3212 1px,transparent 1px),linear-gradient(90deg,#224d3212 1px,transparent 1px);background-size:100px 100px;mask-image:linear-gradient(transparent 20%,#000 60%)}.dir-c .circle{width:1410px;height:1410px;left:-100px;top:810px;background:#b5cbb7;border:32px solid #d7e3d3}.dir-c .flow path.route{stroke:#4f8063;stroke-width:2;opacity:.35}.dir-c .flow path.hair{stroke:#699477;stroke-width:25;opacity:.15}.dir-c .phone{background:#355c47;border-color:#c2d5c1;box-shadow:0 30px 90px #264b3938}.dir-c .main{top:755px;width:926px;left:140px}.dir-c.p2 .main,.dir-c.p4 .main{top:790px;transform:rotate(5deg)}.dir-c .caption{color:#557360}.dir-c .rule{top:625px}
/* D: lively coral collage, centered title, offset second genuine screen, no fabricated chat UI. */
.dir-d{background:#e47760;color:#251d1b}.dir-d .brand{font-size:35px}.dir-d .copy{text-align:center;top:246px;left:56px;right:56px}.dir-d .copy h1{font-size:115px;line-height:1.17;font-weight:750;letter-spacing:-6px}.dir-d .copy em{color:#fff4e7}.dir-d .copy p{color:#4b2a22;font-size:34px;margin-top:34px}.dir-d .rule{display:none}.dir-d .circle{top:1070px;left:-230px;width:1670px;height:1670px;background:#f6e6d0}.dir-d .flow path.route{stroke:#f6e6d0;stroke-width:140;opacity:1}.dir-d .flow path.hair{stroke:#371e19;stroke-width:3;opacity:.18}.dir-d .phone{width:900px;padding:12px;border-color:#f4d4bd;background:#5d3e34;box-shadow:0 35px 100px #6b2c1c55}.dir-d .phone.main{top:825px;left:210px;transform:rotate(8deg)}.dir-d .phone.aux{display:block;left:-560px;top:1280px;width:810px;transform:rotate(-11deg);z-index:2;filter:brightness(.94)}.dir-d.p2 .main,.dir-d.p4 .main{left:87px;transform:rotate(-6deg)}.dir-d.p2 .aux,.dir-d.p4 .aux{left:1040px;transform:rotate(10deg)}.dir-d .caption{color:#59433a}.dir-d .wordmark{color:#4e2a20}
.poster .caption{display:none}
</style></head><body><main class="poster"><div class="circle"></div><div class="texture"></div><svg class="flow" viewBox="0 0 6030 2622" fill="none"><path class="route" d="M-200 1780C650 980 1130 1010 1550 1720S2650 2450 3140 1570S4200 1010 4710 1810S5480 2230 6270 1470"/><path class="hair" d="M-200 1870C650 1070 1130 1100 1550 1810S2650 2540 3140 1660S4200 1100 4710 1900S5480 2320 6270 1560"/></svg><div class="brand"><img src="assets/icon.png" alt="">爱锦<span class="wordmark">AIJIN</span></div><div class="dots" aria-hidden="true"></div><div class="copy"><h1></h1><p></p></div><div class="rule"></div><div class="stamp"></div><div class="phone aux"><img alt="真实界面辅助图"></div><div class="phone main"><img alt="真实 App 界面"></div><div class="caption"></div></main><script>
const slides=[
{image:'library.png',title:'相遇角色，<br><em>从一句话开始</em>',sub:'发现喜欢的角色，开启 AI 对话',tag:'DISCOVER YOUR CHARACTER',caption:'AI 角色 · 个性对话'},
{image:'scene.png',title:'换个身份，<br><em>故事由你推进</em>',sub:'进入模拟器，探索不同的人生',tag:'STEP INTO ANOTHER LIFE',caption:'情境模拟 · 身份扮演'},
{image:'theater.png',title:'走进剧场，<br><em>让剧情继续</em>',sub:'置身故事之中，演绎你的选择',tag:'YOU ARE IN THE STORY',caption:'互动剧场 · 沉浸体验'},
{image:'cast.png',title:'选择角色，<br><em>进入你的世界</em>',sub:'挑选扮演身份，邀请角色加入',tag:'CHOOSE YOUR POINT OF VIEW',caption:'多角色 · 不同视角'},
{image:'creator.png',title:'写下设定，<br><em>创造你的角色</em>',sub:'从形象到性格，让灵感有自己的样子',tag:'MAKE IMAGINATION PERSONAL',caption:'角色创作 · 自由设定'}];
const q=new URLSearchParams(location.search);const dir=(q.get('dir')||'a').toLowerCase();const i=Math.min(4,Math.max(0,Number(q.get('slide')||0)));const data=slides[i];const p=document.querySelector('.poster');p.className='poster dir-'+dir+' p'+(i+1);p.style.setProperty('--i',i);document.querySelector('h1').innerHTML=data.title;document.querySelector('.copy p').textContent=data.sub;document.querySelector('.stamp').textContent=data.tag;document.querySelector('.caption').textContent=data.caption;document.querySelector('.main img').src='assets/'+data.image;document.querySelector('.aux img').src='assets/'+slides[(i+1)%5].image;document.querySelector('.dots').innerHTML=slides.map((_,n)=>'<span class="'+(n===i?'on':'')+'"></span>').join('');
</script></body></html>'''
(HERE / 'poster.html').write_text(poster)

directions=[
    {'id':'A','name':'石墨暖光','note':'推荐 · 与黑色锦鲤图标呼应，连屏关系最清楚','brief':'深石墨底、珊瑚色连续曲线、无衬线大字、轻倾斜真实手机；不使用发光星云与巨型吉祥物。'},
    {'id':'B','name':'奶油画册','note':'温暖文艺 · 更像一套精装故事画册','brief':'奶油纸、宋体短标题、拱形画廊、端正窄边框与印刷细线；不使用暗底或倾斜手机。'},
    {'id':'C','name':'薄荷未来','note':'清爽科技 · 网格与留白，突出界面细节','brief':'浅薄荷、墨绿、等宽英文、精准网格与居中单机；不用珊瑚大色块、旧纸感。'},
    {'id':'D','name':'珊瑚拼贴','note':'活泼醒目 · 交错设备构成连续拼贴','brief':'珊瑚红、奶油大圆、粗字居中、双机交错，面向年轻用户；不用深色界面与纤细标题。'},
]
(HERE/'briefs.json').write_text(json.dumps(directions,ensure_ascii=False,indent=2)+'\n')
(HERE/'DESIGN.md').write_text('''# 爱锦 App Store 竖屏组图方向

设计读取：App Store 竖屏截图系列，面向 AI 角色聊天与互动故事用户，用真实界面、简短标题和连续构图传达功能。

原方案问题：横幅创意资产与常规竖屏截图混淆；吉祥物过大；原生搜索裁切让主体和标题丢失。
保留品牌：现有黑色锦鲤图标；App 内配色、B 面、build 2、审核说明及隐私回答不变。
现状：App 原生白色基础界面、青色功能色、剧情全幅插画；商店图目前是四张未排版的竖屏截图。

功能契约：三秒能识别 AI 角色对话、情境模拟和互动剧情；每张单看能读，五张连看能连续；产品界面必须是真实截图。
拨盘：视觉冒险度 6/10（连屏组合但标题克制），动效 1/10（静态素材），密度 4/10（每张一个卖点）。

四个方向使用独立 brief、独立命名空间制作；按当前单代理执行边界，使用单 agent 隔离 brief 降级。
本目录是设计方向样机。原始 UI 截图逐字节复制并记录哈希，未重绘或拼造产品状态。
场景与身份页使用历史真实 UI 作为版式参照；选定方向后再以匹配设备的当前截图导出最终上传稿。
不把样机当成已配置完成，不把推荐态当成用户选择。

## 预览验收

检查桌面 2×2 方向对比、移动端单列、五张展开、选择弹层取消、键盘选择、滑块数值。
只通过模拟弹层与拦截请求测试回传，不创建虚假 selection.json。
真实确认回传后才允许进入最终截图制作、替换后台及重新提交。
''')

def build_index():
    panels=[]
    for d in directions:
        id=d['id']; items=[]
        for i in range(5):
            f=HERE/'rendered'/f'{id.lower()}-{i+1:02}.jpg'
            src='data:image/jpeg;base64,'+base64.b64encode(f.read_bytes()).decode() if f.exists() else ''
            items.append(f'<img src="{src}" alt="{d["name"]}第{i+1}张竖屏样机" width="1206" height="2622">')
        panels.append(f'''<article class="direction" data-design-option="{id}" data-name="{d['name']}" data-label="选 {id}：{d['name']}" data-variance="6" data-motion="1" data-density="4"><div class="direction-top"><h2><span>{id}</span>{d['name']}</h2>{'<b class="recommend">推荐</b>' if id=='A' else ''}<small>方向样机</small></div><div class="stage"><div class="stage-inner">{''.join(items[:3])}</div></div><div class="summary">{d['note']}</div><div class="actions"><button type="button" class="expand" data-expand="{id}">看完整 5 张 ↗</button><button type="button" class="qmdp-pick-button">选择 {id} · {d['name']}</button></div><template id="series-{id}">{''.join(items)}</template></article>''')
    html='''<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>爱锦 · App Store 竖屏组图方向</title><style>
*{box-sizing:border-box}body{margin:0;background:#eeefeb;color:#262c29;font-family:-apple-system,BlinkMacSystemFont,"PingFang SC","Microsoft YaHei",sans-serif;-webkit-font-smoothing:antialiased}main{max-width:1520px;margin:0 auto;padding:30px}.intro{display:flex;justify-content:space-between;align-items:end;gap:30px;margin:0 0 26px}.intro h1{margin:0 0 10px;font-size:30px;font-weight:650;letter-spacing:-1px}.intro p{margin:0;font-size:14px;color:#606a63;line-height:1.7}.intro .aside{font-size:13px;color:#637269;text-align:right}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:28px}.direction{background:#fafbf8;border:1px solid #d4d9d1;border-radius:16px;overflow:hidden;min-width:0}.direction-top{display:flex;align-items:center;gap:12px;padding:18px 20px}.direction-top h2{font-size:18px;margin:0;display:flex;align-items:center;gap:12px;font-weight:650}.direction-top h2 span{border:1px solid #cbd2c9;border-radius:6px;font-size:12px;width:26px;height:26px;display:grid;place-items:center}.direction-top small{color:#738077;margin-left:auto;font-size:11px}.recommend{font-size:11px;border:1px solid #b4c4ad;background:#e5eddf;color:#3e5935;border-radius:20px;padding:3px 9px}.stage{background:#d7dcd4;padding:16px 22px;overflow:hidden}.stage-inner{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:5px;max-width:636px;margin:auto}.stage img{display:block;width:100%;height:auto;box-shadow:0 4px 12px #1d28111a}.summary{font-size:13px;color:#57665b;padding:15px 20px 0;line-height:1.6;min-height:37px}.actions{display:grid;grid-template-columns:auto 1fr;gap:14px;padding:12px 20px 18px;align-items:center}.expand{font:500 12px inherit;font-family:inherit;border:0;background:transparent;color:#52634f;padding:12px 0;cursor:pointer}.actions .qmdp-pick-button{font-family:inherit;font-size:13px;min-height:44px;cursor:pointer;border:1px solid #c3cdbf;background:#eef2e9;color:#354b2e;border-radius:9px}.actions button:active{transform:translateY(1px)}button:focus-visible,a:focus-visible{outline:3px solid #688c4f;outline-offset:3px}.detail{margin:28px 0 0;border-top:1px solid #cfd5ca;padding:20px 0;color:#657260;font-size:13px;line-height:1.8}.detail strong{color:#354732}.viewer{position:fixed;inset:0;z-index:2147483010;background:#edf0e9;display:none;flex-direction:column}.viewer.open{display:flex}.viewer-head{display:flex;align-items:center;justify-content:space-between;padding:16px 22px;border-bottom:1px solid #cbd1c5;font-size:15px;gap:18px}.viewer-head strong{display:block}.viewer-head small{display:block;margin-top:5px;color:#64725d;font-size:12px;font-weight:400}.viewer-head button{font-family:inherit;border:1px solid #c0c9b8;border-radius:9px;background:#fafcf6;padding:12px 22px;cursor:pointer}.viewer-strip{display:flex;gap:8px;align-items:center;margin:auto;max-width:100%;overflow-x:auto;padding:24px;overscroll-behavior:contain}.viewer-strip img{height:min(73vh,780px);width:auto;flex:none;box-shadow:0 8px 24px #1f2d171f}.viewer-note{text-align:center;padding:10px 24px 18px;font-size:12px;color:#6d7966}.sr-only{position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0}@media(max-width:720px){main{padding:20px 14px}.intro{display:block}.intro h1{font-size:24px}.intro .aside{display:none}.grid{grid-template-columns:1fr;gap:22px}.stage{padding:12px}.direction-top{padding:15px}.actions{padding:10px 15px 15px;gap:12px}.summary{padding-left:15px;padding-right:15px;font-size:12px}.viewer-head{padding:14px}.viewer-strip{padding:14px;gap:5px}.viewer-strip img{height:67vh}.detail{font-size:12px}}@media(prefers-reduced-motion:reduce){*{scroll-behavior:auto!important}}
</style></head><body data-qmdp-variance="6" data-qmdp-motion="1" data-qmdp-density="4"><main><div class="intro"><div><h1>爱锦，换一种出场方式。</h1><p>一组竖屏，讲清角色、故事与创作。真实界面是主角，锦鲤只留下品牌印记。</p></div><div class="aside">设计方向样机 · 并非最终商店图<br>App 内 UI 与 B 面保持不变</div></div><section class="grid">'''+''.join(panels)+'''</section><div class="detail"><strong>推荐 A「石墨暖光」：</strong>延续黑色锦鲤图标，用一条贯穿的珊瑚曲线串起五张图；字更大，界面更突出，单张和连看都成立。<br>也可以组合细节，例如 A 的颜色、B 的字体。当前是排版样机，选定后再补齐最终尺寸与设备截图。</div></main><section class="viewer" aria-label="完整五张连图" aria-modal="true" role="dialog"><div class="viewer-head"><div><strong id="viewer-title"></strong><small>向右滑动看完整组图 · 每张均为竖屏</small></div><button type="button" id="close-viewer">关闭 ×</button></div><div class="viewer-strip"></div><div class="viewer-note">真实产品截图排版样机 · 5 张共同叙事，也能独立展示</div></section><script>
let returnFocus;const viewer=document.querySelector('.viewer');document.querySelectorAll('[data-expand]').forEach(button=>button.addEventListener('click',()=>{returnFocus=button;const id=button.dataset.expand;const card=button.closest('.direction');document.getElementById('viewer-title').textContent=id+' · '+card.dataset.name;document.querySelector('.viewer-strip').innerHTML=document.getElementById('series-'+id).innerHTML;viewer.classList.add('open');document.body.style.overflow='hidden';document.getElementById('close-viewer').focus()}));function closeViewer(){viewer.classList.remove('open');document.body.style.overflow='';returnFocus?.focus()}document.getElementById('close-viewer').addEventListener('click',closeViewer);document.addEventListener('keydown',e=>{if(!viewer.classList.contains('open'))return;if(e.key==='Escape'){e.preventDefault();e.stopImmediatePropagation();closeViewer()}if(e.key==='Tab'){e.preventDefault();document.getElementById('close-viewer').focus()}},true);
</script></body></html>'''
    native_dials='''<section class="design-dials" data-qmdp-dials aria-label="设计参数"><label><span>视觉冒险度 <output data-qmdp-output="variance">6</output> · 连屏组合</span><input data-qmdp-dial="variance" type="range" min="1" max="10" value="6"></label><label><span>动效强度 <output data-qmdp-output="motion">1</output> · 静态截图</span><input data-qmdp-dial="motion" type="range" min="1" max="10" value="1"></label><label><span>信息密度 <output data-qmdp-output="density">4</output> · 每张一个卖点</span><input data-qmdp-dial="density" type="range" min="1" max="10" value="4"></label></section>'''
    dial_css='''.design-dials{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:28px;margin:26px 0 10px;padding-top:22px;border-top:1px solid #d0d6ca}.design-dials label{display:grid;gap:12px;font-size:12px;color:#62705b}.design-dials input{width:100%;accent-color:#587148}.design-dials output{font-variant-numeric:tabular-nums;color:#35492b;font-weight:650}@media(max-width:720px){.design-dials{grid-template-columns:1fr;gap:18px}}'''
    html=html.replace('</main><section class="viewer"',native_dials+'</main><section class="viewer"').replace('</style>',dial_css+'</style>')
    (HERE/'index.html').write_text(html)

if __name__=='__main__':
    build_index()
    print('Prepared genuine UI assets and portrait HTML:',HERE)
