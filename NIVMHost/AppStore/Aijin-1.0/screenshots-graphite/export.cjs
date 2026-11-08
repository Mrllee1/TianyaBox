const {chromium}=require('/Users/king/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('node:fs/promises');const path=require('node:path');const crypto=require('node:crypto');
const {pathToFileURL}=require('node:url');const {execFileSync}=require('node:child_process');
const slugs=['01-character','02-simulator','03-theater','04-identity','05-creator'];
(async()=>{
 const root=__dirname;const browser=await chromium.launch({executablePath:'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',headless:true});
 const records=[];const errors=[];
 for(const [device,width,height]of [['iphone',1206,2622],['ipad',2064,2752]]){
  const folder=path.join(root,device);await fs.mkdir(folder,{recursive:true});
  const page=await browser.newPage({viewport:{width,height},deviceScaleFactor:1});page.on('pageerror',e=>errors.push(e.message));
  for(let i=0;i<5;i++){
   const source=path.join(root,'source',device,slugs[i]+'.png');const raw=await fs.readFile(source);
   if(raw.readUInt32BE(16)!==width||raw.readUInt32BE(20)!==height)throw Error('Wrong source device dimensions: '+source);
   await page.goto(pathToFileURL(path.join(root,'layout.html')).href+'?device='+device+'&slide='+i);
   await page.locator('.main img').evaluate(img=>img.decode());await page.locator('.brand img').evaluate(img=>img.decode());await page.evaluate(()=>document.fonts.ready);
   const heading=await page.locator('.copy').boundingBox();if(heading.x<0||heading.x+heading.width>width||heading.y+heading.height>760)throw Error('Heading outside safe area');
   const filename='aijin-'+slugs[i]+'-'+device+'-'+width+'x'+height+'.png';const outfile=path.join(folder,filename);
   await page.screenshot({path:outfile});const output=await fs.readFile(outfile);
   if(output.readUInt32BE(16)!==width||output.readUInt32BE(20)!==height)throw Error('Wrong export dimensions');
   if(output.readUInt8(25)!==2)throw Error('PNG must use opaque RGB without alpha');
   execFileSync('/usr/bin/sips',['-s','format','jpeg','-s','formatOptions','90','--resampleWidth','402',outfile,'--out',path.join(folder,'preview-'+slugs[i]+'.jpg')],{stdio:'ignore'});
   records.push({order:i+1,device,file:device+'/'+filename,width,height,colorType:'opaque RGB',bytes:output.length,sha256:crypto.createHash('sha256').update(output).digest('hex'),source:'source/'+device+'/'+slugs[i]+'.png',sourceSha256:crypto.createHash('sha256').update(raw).digest('hex'),title:await page.locator('h1').innerText(),copyBox:heading});
   console.log('EXPORTED',device,filename);
  }
  await page.close();
 }
 if(errors.length)throw Error('Browser render errors: '+errors.join('; '));
 await fs.writeFile(path.join(root,'manifest.json'),JSON.stringify({design:'A 石墨暖光',userSelection:'Explicit chat answer',exportedAt:new Date().toISOString(),appVersion:'1.0.0',build:'2',productChanged:false,bSideChanged:false,renderer:'HTML/CSS composition using native matching-device UI captures',screenshots:records},null,2)+'\n');
 const src=f=>'data:image/jpeg;base64,'+require('fs').readFileSync(path.join(root,f)).toString('base64');
 const strip=device=>'<div class="strip '+device+'">'+slugs.map(slug=>'<img alt="'+slug+'" src="'+src(device+'/preview-'+slug+'.jpg')+'">').join('')+'</div>';
 const html='<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>爱锦 · 石墨暖光商店截图</title><style>*{box-sizing:border-box}body{margin:0;background:#e8ece4;color:#253024;font-family:-apple-system,"PingFang SC",sans-serif;padding:28px}h1{font-size:24px;margin:0 0 10px}p{font-size:14px;color:#5b6c53;margin-bottom:26px}h2{font-size:16px;margin-top:28px}.strip{display:flex;gap:6px;max-width:100%;overflow:auto;align-items:flex-start}.strip img{width:calc((100vw - 80px)/5);height:auto;flex:none;min-width:190px;max-width:340px}@media(max-width:700px){body{padding:18px}.strip img{width:240px}}</style><h1>爱锦 · 石墨暖光</h1><p>正式竖屏截图 · 每种设备五张 · 来自对应设备真实界面</p><h2>iPhone · 1206 × 2622</h2>'+strip('iphone')+'<h2>iPad · 2064 × 2752</h2>'+strip('ipad')+'</html>';
 await fs.writeFile(path.join(root,'index.html'),html);
 const p=await browser.newPage({viewport:{width:1700,height:1800},deviceScaleFactor:1});await p.setContent(html);await p.locator('img').evaluateAll(imgs=>Promise.all(imgs.map(x=>x.decode())));
 await p.locator('.strip.iphone').screenshot({path:path.join(root,'iphone-contact.png')});await p.locator('.strip.ipad').screenshot({path:path.join(root,'ipad-contact.png')});await p.screenshot({path:path.join(root,'all-devices.png'),fullPage:true});await browser.close();
})().catch(e=>{console.error(e);process.exit(1)});
