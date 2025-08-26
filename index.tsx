<!DOCTYPE html>
<html lang="fa">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Rama - AI Storybook Creator</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" integrity="sha512-..." crossorigin="anonymous" referrerpolicy="no-referrer" />
<style>
  body { margin:0; font-family:sans-serif; background:linear-gradient(120deg,#0b1023,#0e1b3c,#142a5b); color:#fff; text-align:center; }
  .view { padding:20px; display:none; }
  .view.active { display:block; }
  input, button { padding:10px; margin:5px; border-radius:5px; border:none; }
  button { cursor:pointer; background:#6200EE; color:#fff; }
  .loading-indicator { display:flex; flex-direction:column; align-items:center; margin-top:20px; }
  .loading-indicator .spinner { border:4px solid #f3f3f3; border-top:4px solid #6200EE; border-radius:50%; width:36px; height:36px; animation:spin 1s linear infinite; margin-bottom:10px; }
  @keyframes spin { 0% { transform:rotate(0deg); } 100% { transform:rotate(360deg); } }
  .page-container img { max-width:80%; border-radius:10px; margin-bottom:10px; }
  .page-text { font-size:1.2rem; margin-bottom:10px; }
  .recording-controls { margin:10px; }
  #record-button.recording { background:red; }
  .book-nav button { margin:5px; background:#03DAC6; color:#000; }
  .hidden { display:none !important; }
  .error-message { color:red; font-weight:bold; margin:20px; }
</style>
</head>
<body>

<div class="app-main"></div>

<!-- Templates injected by JS -->

<script type="module">
// ----------------- TypeScript-like JS -----------------
import { GoogleGenAI } from "@google/genai";

interface Page { text:string; image_prompt:string; imageUrl?:string; audioUrl?:string; }
interface Story { title:string; pages:Page[]; }

let story:Story|null=null;
let currentPageIndex=0;
let mediaRecorder:MediaRecorder|null=null;
let audioChunks:Blob[]=[];
let isLoading=false;
let ai:GoogleGenAI;

const mainContainer = document.querySelector(".app-main") as HTMLElement;
const navButtons:NodeListOf<HTMLElement> = document.querySelectorAll('.nav-button');

function initialize() {
  try {
    if(!process.env.API_KEY){ showError("کلید API تنظیم نشده است."); return; }
    ai=new GoogleGenAI({ apiKey:process.env.API_KEY });
    addTemplates();
    setupEventListeners();
    showView('home-view');
  } catch(e){ console.error(e); showError("خطا در راه‌اندازی."); }
}

function setupEventListeners() {
  document.getElementById('nav-home')?.addEventListener('click',()=>story?showView('book-viewer'):showView('home-view'));
  document.getElementById('nav-create')?.addEventListener('click',()=>showView('create-view'));
}

function showView(viewId:'home-view'|'create-view'|'book-viewer'){
  mainContainer.innerHTML='';
  const template=document.getElementById(viewId) as HTMLTemplateElement;
  if(!template){ console.error(`Template not found: ${viewId}`); return; }
  mainContainer.appendChild(template.content.cloneNode(true));
  if(viewId==='book-viewer') renderBookPage();
  if(viewId==='create-view') {
    const form=mainContainer.querySelector("#story-form") as HTMLFormElement;
    form.addEventListener('submit',handleStoryFormSubmit);
  }
  navButtons.forEach(btn=>btn.classList.remove('active'));
  if((viewId==='home-view')||(viewId==='book-viewer')) document.getElementById('nav-home')?.classList.add('active');
  if(viewId==='create-view') document.getElementById('nav-create')?.classList.add('active');
}

async function handleStoryFormSubmit(e:Event){
  e.preventDefault();
  const prompt=(document.getElementById('story-prompt') as HTMLInputElement).value.trim();
  if(!prompt||isLoading) return;
  setLoading(true,"در حال نوشتن داستان...");
  try{
    const pages = await generateStoryPages(prompt);
    setLoading(true,"در حال کشیدن تصاویر...");
    const pagesWithImages=await Promise.all(pages.map(async(p,index)=>{
      setLoading(true,`در حال کشیدن تصویر ${index+1} از ${pages.length}...`);
      const imageUrl=await generateImage(p.image_prompt);
      return {...p,imageUrl};
    }));
    story={title:prompt,pages:pagesWithImages};
    currentPageIndex=0;
    showView('book-viewer');
  }catch(err){ console.error(err); showError("خطا در ساخت داستان."); }
  finally{ setLoading(false); }
}

async function generateStoryPages(prompt:string):Promise<Page[]>{
  const generationPrompt=`یک داستان کوتاه کودکانه در مورد "${prompt}" بساز. JSON با آرایه صفحات با keys: text (فارسی) و image_prompt (انگلیسی).`;
  const response=await ai.models.generateContent({ model:"gemini-2.5-flash-preview-04-17", contents:generationPrompt, config:{ responseMimeType:"application/json" } });
  let jsonStr=response.text.trim();
  const match=jsonStr.match(/^```(\w*)?\s*([\s\S]*?)\s*```$/m);
  if(match&&match[2]) jsonStr=match[2];
  const parsed=JSON.parse(jsonStr);
  if(!Array.isArray(parsed)) throw new Error("فرمت پاسخ درست نیست");
  return parsed as Page[];
}

async function generateImage(prompt:string):Promise<string>{
  const response=await ai.models.generateImages({ model:'imagen-3.0-generate-002', prompt:`child-friendly, colorful storybook illustration of: ${prompt}`, config:{numberOfImages:1, outputMimeType:'image/jpeg'} });
  return `data:image/jpeg;base64,${response.generatedImages[0].image.imageBytes}`;
}

function renderBookPage(){
  if(!story){ showView('home-view'); return; }
  const page=story.pages[currentPageIndex];
  const pageImage=document.querySelector(".page-image") as HTMLElement;
  const pageText=document.querySelector(".page-text") as HTMLElement;
  const prevButton=document.getElementById("prev-page") as HTMLButtonElement;
  const nextButton=document.getElementById("next-page") as HTMLButtonElement;
  const recordButton=document.getElementById('record-button') as HTMLButtonElement;
  const audioPlayback=document.getElementById('audio-playback') as HTMLAudioElement;

  pageImage.innerHTML=page.imageUrl?`<img src="${page.imageUrl}" alt="${page.image_prompt}">`:'<div class="spinner"></div>';
  pageText.textContent=page.text;
  prevButton.disabled=currentPageIndex===0;
  nextButton.disabled=currentPageIndex===story.pages.length-1;
  prevButton.onclick=()=>{if(currentPageIndex>0){currentPageIndex--;renderBookPage();}};
  nextButton.onclick=()=>{if(currentPageIndex<story.pages.length-1){currentPageIndex++;renderBookPage();}};
  recordButton.onclick=toggleRecording;
  if(page.audioUrl){ audioPlayback.src=page.audioUrl; audioPlayback.classList.remove('hidden'); }
  else{ audioPlayback.classList.add('hidden'); }
}

async function toggleRecording(){
  if(mediaRecorder&&mediaRecorder.state==="recording"){ mediaRecorder.stop(); document.getElementById('record-button')?.classList.remove('recording'); return; }
  try{
    const stream=await navigator.mediaDevices.getUserMedia({ audio:true });
    mediaRecorder=new MediaRecorder(stream);
    audioChunks=[];
    mediaRecorder.ondataavailable=ev=>audioChunks.push(ev.data);
    mediaRecorder.onstop=()=>{
      const audioBlob=new Blob(audioChunks,{type:'audio/webm'});
      const audioUrl=URL.createObjectURL(audioBlob);
      if(story) story.pages[currentPageIndex].audioUrl=audioUrl;
      renderBookPage();
    };
    mediaRecorder.start();
    document.getElementById('record-button')?.classList.add('recording');
  }catch(err){ console.error(err); showError("دسترسی به میکروفون امکان‌پذیر نیست."); }
}

function setLoading(show:boolean,text=""){
  isLoading=show;
  const view=document.getElementById('create-view');
  if(!view) return;
  const form=view.querySelector('#story-form');
  const loader=view.querySelector('.loading-indicator');
  const button=view.querySelector('#generate-button') as HTMLButtonElement;
  const loaderText=view.querySelector('#loading-text');
  if(show){ form?.classList.add('hidden'); loader?.classList.remove('hidden'); if(loaderText) loaderText.textContent=text; }
  else{ form?.classList.remove('hidden'); loader?.classList.add('hidden'); }
  if(button) button.disabled=show;
}

function showError(msg:string){
  const errorEl=document.createElement('div');
  errorEl.className='error-message'; errorEl.textContent=msg;
  mainContainer.innerHTML=''; mainContainer.appendChild(errorEl);
}

function addTemplates(){
  const templates=`
  <template id="home-view">
    <div class="view active">
      <p>سلام! به «راما» خوش آمدید.<br>برای شروع، از منوی پایین یک داستان جدید بسازید.</p>
    </div>
  </template>
  <template id="create-view">
    <div class="view active" id="create-story-container">
      <form id="story-form">
        <label for="story-prompt">دوست داری داستان در مورد چی باشه؟</label>
        <input type="text" id="story-prompt" placeholder="مثلاً: یک اژدهای مهربون که آشپزی دوست داره" required>
        <button type="submit" id="generate-button"><i class="fas fa-magic-sparkles"></i><span>بساز!</span></button>
      </form>
      <div class="loading-indicator hidden"><div class="spinner"></div><p id="loading-text">در حال ساخت داستان...</p></div>
    </div>
  </template>
  <template id="book-viewer">
    <div id="book-viewer" class="view active">
      <div class="page-container"><div class="page-image"></div><p class="page-text"></p></div>
      <div class="recording-controls">
        <button id="record-button" aria-label="ضبط صدا"><i class="fas fa-microphone"></i></button>
        <audio id="audio-playback" controls class="hidden"></audio>
      </div>
      <div class="book-nav">
        <button class="book-nav-button" id="next-page" aria-label="صفحه بعد"><i class="fas fa-chevron-right"></i></button>
        <button class="book-nav-button" id="prev-page" aria-label="صفحه قبل"><i class="fas fa-chevron-left"></i></button>
      </div>
    </div>
  </template>
  `;
  document.body.insertAdjacentHTML('beforeend', templates);
}

document.addEventListener("DOMContentLoaded", initialize);
</script>

</body>
</html>
