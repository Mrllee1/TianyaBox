const {chromium}=require('/Users/king/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const path=require('node:path');
const fs=require('node:fs/promises');
const {execFileSync}=require('node:child_process');
const {pathToFileURL}=require('node:url');
(async()=>{
 const root=__dirname;await fs.mkdir(path.join(root,'rendered'),{recursive:true});
 const browser=await chromium.launch({executablePath:'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',headless:true});
 const page=await browser.newPage({viewport:{width:1206,height:2622},deviceScaleFactor:1});
 const results=[];
 for(const dir of ['a','b','c','d']){
  for(let i=0;i<5;i++){
   await page.goto(pathToFileURL(path.join(root,'poster.html')).href+'?dir='+dir+'&slide='+i);
   await page.locator('.main img').evaluate(img=>img.decode());
   await page.locator('.aux img').evaluate(img=>img.decode());await page.evaluate(()=>document.fonts.ready);
   const name=`${dir}-${String(i+1).padStart(2,'0')}`;
   await page.screenshot({path:path.join(root,'rendered',name+'.png')});
   const copy=await page.locator('.copy').boundingBox();const title=await page.locator('h1').boundingBox();
   results.push({dir,slide:i+1,copyInside:copy.x>=0&&copy.x+copy.width<=1206,titleBottom:title.y+title.height,titleBelowBrand:title.y>180,exportWidth:1206,exportHeight:2622});
   // Technical thumbnail export of the verified full-size layout. Avoid Chromium
   // retaining composited tiles after resizing and scaling the same long page.
   execFileSync('/usr/bin/sips',['-s','format','jpeg','-s','formatOptions','88','--resampleHeightWidth','874','402',path.join(root,'rendered',name+'.png'),'--out',path.join(root,'rendered',name+'.jpg')],{stdio:'ignore'});
  }
  console.log('RENDERED',dir);
 }
 await fs.writeFile(path.join(root,'rendered','geometry.json'),JSON.stringify(results,null,2));
 await browser.close();
})().catch(error=>{console.error(error);process.exit(1)});
