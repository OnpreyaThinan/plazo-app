import React, { useState } from 'react';
import { 
  CheckCircle2, 
  Calendar, 
  Clock, 
  Globe, 
  Settings, 
  ShieldCheck, 
  ArrowRight, 
  Menu, 
  ChevronDown,
  Trash2,
  Lock,
  BookOpen,
  Plus,
  Layout,
  Bell,
  MapPin,
  User,
  Home,
  Pencil,
  Trash,
  Sun,
  Camera,
  Info,
  HelpCircle,
  LogOut,
  Shield,
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

// --- Theme Colors ---
const COLORS = {
  primary: '#9BD1B3', // Matches Flutter app primary color
  primaryDark: '#7FB199',
  bgLight: '#F8FBF9',
  surface: '#FFFFFF',
  textDark: '#2A3B34',
  textMuted: '#64748B'
};

const APP_URL = 'https://plazo-c83e7.web.app';

const COPY = {
  en: {
    features: 'Features',
    guide: 'Guide',
    faq: 'FAQ',
    getStarted: 'GET STARTED',
    new: 'New',
    sync: 'Real-time Academic Sync',
    heroTitle1: 'Manage all your',
    heroTitle2: 'Tasks & Exams',
    heroTitle3: 'in one place',
    heroDesc:
      'PLAZO helps you stay organized, never miss deadlines, and focus on what truly matters in your academic journey.',
    startUsing: 'Start using PLAZO',
    why: 'Why PLAZO?',
    explore: 'Explore every feature',
    exploreDesc:
      'From powerful scheduling to personal customization, PLAZO is designed to be your favorite academic companion.',
    home: 'Home',
    details: 'Details',
    finished: 'finished',
    addPlan: 'add plan',
    settings: 'Settings',
    simplify: 'Simplify Your Journey',
    simplifyDesc:
      'Get organized in 3 simple steps. Beautifully designed for modern students.',
    questions: 'Questions?',
    questionsDesc: 'Everything you need to know about starting with PLAZO.',
    stop1: 'Stop letting deadlines',
    stop2: 'control your life',
    stopDesc: 'Open PLAZO in your browser and start winning today.',
    launch: 'Launch Web App',
    footer: '© 2026 PLAZO. Designed for learners.',
    privacy: 'Privacy Policy',
  },
  th: {
    features: 'ฟีเจอร์',
    guide: 'วิธีใช้',
    faq: 'คำถาม',
    getStarted: 'เริ่มใช้งาน',
    new: 'ใหม่',
    sync: 'ซิงก์การเรียนแบบเรียลไทม์',
    heroTitle1: 'จัดการ',
    heroTitle2: 'งานและสอบ',
    heroTitle3: 'ไว้ในที่เดียว',
    heroDesc:
      'PLAZO ช่วยให้คุณจัดระเบียบชีวิตการเรียน ไม่พลาดเดดไลน์ และโฟกัสกับสิ่งสำคัญได้มากขึ้น',
    startUsing: 'เข้าใช้งาน PLAZO',
    why: 'ทำไมต้อง PLAZO?',
    explore: 'สำรวจทุกฟีเจอร์',
    exploreDesc:
      'ตั้งแต่การวางแผนที่ทรงพลังไปจนถึงการปรับแต่งส่วนตัว PLAZO ถูกออกแบบมาเพื่อเป็นคู่หูการเรียนของคุณ',
    home: 'Home',
    details: 'Details',
    finished: 'finished',
    addPlan: 'add plan',
    settings: 'Settings',
    simplify: 'ทำให้การเรียนง่ายขึ้น',
    simplifyDesc: 'เริ่มจัดระบบการเรียนได้ใน 3 ขั้นตอนแบบสวยและใช้ง่าย',
    questions: 'มีคำถาม?',
    questionsDesc: 'ทุกอย่างที่ต้องรู้ก่อนเริ่มใช้ PLAZO',
    stop1: 'หยุดให้เดดไลน์',
    stop2: 'คุมชีวิตคุณ',
    stopDesc: 'เปิด PLAZO บนเบราว์เซอร์และเริ่มได้ทันที',
    launch: 'เปิดใช้งานเว็บแอป',
    footer: '© 2026 PLAZO. ออกแบบเพื่อผู้เรียน',
    privacy: 'นโยบายความเป็นส่วนตัว',
  },
} as const;

// --- Brand Logo Component ---
const BrandLogo = ({ className = "w-12 h-12" }: { className?: string }) => (
  <motion.div
    animate={{ y: [0, -3, 0] }}
    transition={{ duration: 3.5, repeat: Infinity, ease: 'easeInOut' }}
    className={`relative overflow-hidden rounded-2xl shadow-lg ${className}`}
  >
    <svg viewBox="0 0 300 250" className="h-full w-full" role="img" aria-label="Plazo logo">
      <defs>
        <linearGradient id="pageGradient" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stopColor="#FFF9F0" />
          <stop offset="45%" stopColor="#F5E6D3" />
          <stop offset="50%" stopColor="#E8D5C0" />
          <stop offset="55%" stopColor="#F5E6D3" />
          <stop offset="100%" stopColor="#FFF9F0" />
        </linearGradient>
        <linearGradient id="coverGradient" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" stopColor="#A2D2BB" />
          <stop offset="100%" stopColor="#7FB89D" />
        </linearGradient>
        <linearGradient id="capTopGradient" x1="50%" y1="0%" x2="50%" y2="100%">
          <stop offset="0%" stopColor="#2D4A44" />
          <stop offset="100%" stopColor="#1A2E2A" />
        </linearGradient>
        <linearGradient id="capBaseGradient" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stopColor="#1A2E2A" />
          <stop offset="50%" stopColor="#2D4A44" />
          <stop offset="100%" stopColor="#1A2E2A" />
        </linearGradient>
        <linearGradient id="tasselGradient" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" stopColor="#F4D03F" />
          <stop offset="100%" stopColor="#D4AC0D" />
        </linearGradient>
      </defs>

      <g transform="translate(20, 70)">
        <path d="M10 165C10 165 70 155 140 165C210 155 270 165 270 165V45C270 45 210 35 140 45C70 35 10 45 10 45V165Z" fill="#86C0A1" />
        <path d="M10 160C10 160 70 150 140 160C210 150 270 160 270 160V40C270 40 210 30 140 40C70 30 10 40 10 40V160Z" fill="url(#coverGradient)" stroke="#86C0A1" strokeWidth="1"/>
        <path d="M15 155C15 155 72 145 140 155C208 145 265 155 265 155V35C265 35 208 25 140 35C72 25 15 35 15 35V155Z" fill="#E8D5C0" />
        <path d="M20 150C20 150 75 140 140 150C205 140 260 150 260 150V30C260 30 205 20 140 30C75 20 20 30 20 30V150Z" fill="url(#pageGradient)"/>
        <g opacity="0.15" stroke="#2D4A44" strokeWidth="1" strokeLinecap="round">
          <path d="M45 60C45 60 75 57 110 58" /><path d="M45 80C45 80 75 77 110 78" />
          <path d="M45 100C45 100 75 97 110 98" /><path d="M45 120C45 120 75 117 110 118" />
          <path d="M170 58C170 58 205 57 235 60" /><path d="M170 78C170 78 205 77 235 80" />
          <path d="M170 98C170 98 205 97 235 100" /><path d="M170 118C170 118 205 117 235 120" />
        </g>
        <path d="M140 30V150" stroke="#2D4A44" strokeOpacity="0.2" strokeWidth="1.5"/>
      </g>

      <g transform="translate(85, 20)">
        <path d="M35 55C35 55 35 80 70 80C105 80 105 55 105 55" fill="#0D1A18"/>
        <path d="M35 55C35 55 35 76 70 76C105 76 105 55 105 55" fill="url(#capBaseGradient)"/>
        <path d="M70 20L135 45L70 70L5 45L70 20Z" fill="#0D1A18"/>
        <path d="M70 15L135 40L70 65L5 40L70 15Z" fill="url(#capTopGradient)" stroke="#2D4A44" strokeWidth="0.5"/>
        <circle cx="70" cy="40" r="4.5" fill="#D4AC0D"/>
        <circle cx="70" cy="40" r="3.5" fill="url(#tasselGradient)"/>
        <path d="M70 40C70 40 55 45 45 65" stroke="#D4AC0D" strokeWidth="2.5" strokeLinecap="round"/>
        <path d="M70 40C70 40 55 45 45 65" stroke="url(#tasselGradient)" strokeWidth="1.5" strokeLinecap="round"/>
        <g>
          <rect x="40" y="65" width="10" height="20" rx="1" fill="#D4AC0D"/>
          <rect x="41" y="65" width="8" height="20" rx="1" fill="url(#tasselGradient)"/>
        </g>
      </g>
    </svg>
  </motion.div>
);

const AppDashboardScreen = () => (
  <div className="bg-[#F8FBF9] h-full w-full rounded-[2.5rem] p-5 text-left flex flex-col pt-10 select-none overflow-hidden relative">
    <div className="flex justify-between items-center mb-5">
      <h2 className="text-xl font-black text-gray-800 tracking-tight">Hi, JANE</h2>
      <div className="w-10 h-10 bg-gray-200 rounded-full overflow-hidden border-2 border-white shadow-sm">
        <img src="https://picsum.photos/seed/student_avatar/200/200" alt="avatar" referrerPolicy="no-referrer" />
      </div>
    </div>
    
    <h3 className="text-4xl font-black mb-5 tracking-tighter">April</h3>
    
    <div className="flex gap-2 justify-between items-center py-2 mb-5">
      <div className="w-7 h-7 bg-emerald-50 rounded-lg flex items-center justify-center text-emerald-600 opacity-40"><ChevronDown size={14} className="rotate-90" /></div>
      <div className="flex gap-2">
        {[17, 18, 19].map((day) => (
          <div key={day} className={`w-[60px] h-20 flex flex-col items-center justify-center rounded-[1.5rem] border transition-all ${day === 17 ? 'bg-[#9CCEB5] text-white border-transparent shadow-xl' : 'bg-white border-emerald-50 text-gray-400'}`}>
            <span className="text-xl font-black mb-0.5">{day}</span>
            <span className="text-[9px] uppercase font-black opacity-60 tracking-widest">{day === 17 ? 'Fri' : day === 18 ? 'Sat' : 'Sun'}</span>
          </div>
        ))}
      </div>
      <div className="w-7 h-7 bg-emerald-50 rounded-lg flex items-center justify-center text-emerald-600 opacity-40"><ChevronDown size={14} className="-rotate-90" /></div>
    </div>

    <div className="flex-1 overflow-y-auto no-scrollbar space-y-5 pb-20">
      <div>
        <div className="flex justify-between items-center mb-3">
          <h4 className="font-black text-lg">Tasks</h4>
          <span className="text-emerald-300 text-[9px] font-black uppercase tracking-wider">4 PENDING</span>
        </div>
        <div className="space-y-3">
          {[
            { title: 'Statistics Project', date: '23/04/2026', time: '13:00', color: 'bg-emerald-200' },
            { title: 'Software Design Doc', date: '24/04/2026', time: '15:30', color: 'bg-emerald-300' },
            { title: 'Database Lab Report', date: '25/04/2026', time: '11:00', color: 'bg-emerald-200' },
            { title: 'UI Prototype Review', date: '26/04/2026', time: '10:00', color: 'bg-emerald-300' },
          ].map((item) => (
            <div key={item.title} className="bg-white p-4 rounded-[1.8rem] border border-emerald-50 flex items-center justify-between shadow-sm">
              <div className="flex items-center gap-3">
                <div className={`w-1 h-8 ${item.color} rounded-full`} />
                <div>
                  <p className="font-black text-base">{item.title}</p>
                  <div className="flex items-center gap-2 text-[9px] text-gray-400 font-bold tracking-tight">
                    <Calendar size={9} className="text-emerald-200" /> {item.date} • <Clock size={9} className="text-emerald-200" /> {item.time}
                  </div>
                </div>
              </div>
              <ChevronDown size={12} className="text-gray-100 -rotate-90" />
            </div>
          ))}
        </div>
      </div>

      <div>
        <div className="flex justify-between items-center mb-3">
          <h4 className="font-black text-lg">Exams</h4>
          <span className="text-pink-300 text-[9px] font-black uppercase tracking-wider">4 Upcoming</span>
        </div>
        <div className="space-y-3">
          {[
            { title: 'Calc Quiz', date: '25/04/2026', time: '09:00', room: 'Room 302' },
            { title: 'Physics Midterm', date: '27/04/2026', time: '10:30', room: 'Hall 3' },
            { title: 'DBMS Practical', date: '29/04/2026', time: '14:00', room: 'Lab B' },
            { title: 'English Oral Test', date: '30/04/2026', time: '08:45', room: 'Room 105' },
          ].map((item) => (
            <div key={item.title} className="bg-white p-4 rounded-[1.8rem] border border-emerald-50 flex items-center justify-between shadow-sm">
              <div className="flex items-center gap-3">
                <div className="w-1 h-8 bg-pink-200 rounded-full" />
                <div>
                  <p className="font-black text-base tracking-tight uppercase">{item.title}</p>
                  <div className="flex items-center gap-2 text-[9px] text-gray-400 font-bold mb-0.5 tracking-tight">
                    <Calendar size={9} className="text-pink-200" /> {item.date} • <Clock size={9} className="text-pink-200" /> {item.time}
                  </div>
                  <p className="text-[9px] text-gray-400 font-bold flex items-center gap-1"><MapPin size={9} /> {item.room}</p>
                </div>
              </div>
              <ChevronDown size={12} className="text-gray-100 -rotate-90" />
            </div>
          ))}
        </div>
      </div>
    </div>

    <div className="absolute bottom-3 left-5 right-5 flex justify-between items-center bg-white/80 backdrop-blur-md p-2.5 rounded-[2rem] shadow-lg border border-white px-7">
      <div className="text-emerald-500 bg-emerald-50/50 p-1.5 rounded-xl"><Home size={20} fill="currentColor" opacity="0.2" /></div>
      <div className="text-gray-300"><CheckCircle2 size={20} /></div>
      <div className="bg-[#9BD1B3] p-2.5 rounded-full text-white shadow-lg -mt-8 border-4 border-[#F8FBF9]"><Plus size={22} strokeWidth={3} /></div>
      <div className="text-gray-300"><Settings size={20} /></div>
    </div>
  </div>
);

const AppFinishedScreen = () => (
  <div className="bg-[#F8FBF9] h-full w-full rounded-[2.5rem] p-5 text-left flex flex-col pt-10 select-none overflow-hidden relative">
    <h2 className="text-3xl font-black mb-6 tracking-tight text-gray-800">Finished</h2>
    
    <div className="space-y-3 flex-1 overflow-y-auto no-scrollbar pb-20">
      {[
        { title: 'PHY-I', date: '12/04/2026', time: '10:00', room: 'Hall 3', color: 'bg-pink-100' },
        { title: 'DIS Math', date: '08/04/2026', time: '08:30', room: 'Room 201', color: 'bg-emerald-100' },
        { title: 'Chem Lab', date: '05/04/2026', time: '13:00', room: 'Lab A', color: 'bg-pink-100' },
        { title: 'English Essay', date: '03/04/2026', time: '16:15', room: 'Online', color: 'bg-emerald-100' },
      ].map((item) => (
        <div key={item.title} className="bg-white p-4 rounded-[1.8rem] border border-emerald-50 flex items-center justify-between shadow-sm overflow-hidden relative">
          <div className="flex items-center gap-3">
            <div className={`w-1 h-8 ${item.color} rounded-full`} />
            <div>
              <p className="font-black text-base uppercase text-gray-800 tracking-tight">{item.title}</p>
              <div className="flex items-center gap-2 text-[9px] text-gray-400 font-bold">
                <Calendar size={9} className="text-emerald-100" /> {item.date} • <Clock size={9} className="text-emerald-100" /> {item.time}
              </div>
              <p className="text-[9px] text-gray-300 font-bold mt-0.5 flex items-center gap-1"><MapPin size={9} /> {item.room}</p>
            </div>
          </div>
          <ChevronDown size={12} className="text-gray-100 -rotate-90" />
        </div>
      ))}
    </div>

    <div className="absolute bottom-3 left-5 right-5 flex justify-between items-center bg-white/80 backdrop-blur-md p-2.5 rounded-[2rem] shadow-lg border border-white px-7">
      <div className="text-gray-300"><Home size={20} /></div>
      <div className="text-emerald-500 bg-emerald-50/50 p-1.5 rounded-xl"><CheckCircle2 size={20} fill="currentColor" opacity="0.2" /></div>
      <div className="bg-[#9BD1B3] p-2.5 rounded-full text-white shadow-lg -mt-8 border-4 border-[#F8FBF9]"><Plus size={22} strokeWidth={3} /></div>
      <div className="text-gray-300"><Settings size={20} /></div>
    </div>
  </div>
);

const AppAddPlanScreen = () => (
  <div className="bg-[#F8FBF9] h-full w-full rounded-[2.5rem] p-6 text-left flex flex-col pt-10 items-center select-none overflow-hidden relative">
    <h2 className="w-full text-3xl font-black mb-5 tracking-tight text-gray-800">Add Plan</h2>
    
    <div className="w-full bg-emerald-50/30 p-1 rounded-[1.5rem] flex mb-5">
      <button className="flex-1 p-2.5 rounded-2xl text-[10px] font-black text-gray-400">Tasks</button>
      <button className="flex-1 bg-white p-2.5 rounded-2xl text-center text-[10px] font-black text-emerald-500 shadow-sm border border-emerald-50/50">Exams</button>
    </div>

    <div className="w-full overflow-y-auto no-scrollbar space-y-4 flex-1 pb-24">
      {[ 
        { label: 'SUBJECT', placeholder: 'e.g. Operating Systems' }, 
        { label: 'ACTIVITY', placeholder: 'e.g. Lab Report 1' },
        { label: 'LOCATION', placeholder: 'e.g. Science Hall C' }
      ].map((field, i) => (
        <div key={i} className="space-y-1.5">
          <p className="text-[9px] font-black text-gray-400 uppercase tracking-widest px-1">{field.label}</p>
          <div className="bg-emerald-50/30 border border-emerald-50/50 rounded-xl p-3 text-gray-300 text-xs font-bold italic">
            {field.placeholder}
          </div>
        </div>
      ))}
      <div className="space-y-1.5">
        <p className="text-[9px] font-black text-gray-400 uppercase tracking-widest px-1">BRIEF NOTES</p>
        <div className="bg-emerald-50/30 border border-emerald-50/50 rounded-xl p-3 text-gray-300 text-xs font-bold italic h-20">
          Add some notes...
        </div>
      </div>
      
      <div className="grid grid-cols-2 gap-3 pt-1">
        <div className="space-y-1.5">
          <p className="text-[9px] font-black text-gray-400 uppercase tracking-widest px-1">DUE DATE</p>
          <div className="bg-emerald-50/30 border border-emerald-50/50 rounded-xl p-3 flex items-center justify-between text-gray-300 text-[10px] font-bold italic">
            <span>Select a date</span>
            <Calendar size={14} />
          </div>
        </div>
        <div className="space-y-1.5">
          <p className="text-[9px] font-black text-gray-400 uppercase tracking-widest px-1">TIME</p>
          <div className="bg-emerald-50/30 border border-emerald-50/50 rounded-xl p-3 flex items-center justify-between text-gray-300 text-[10px] font-bold italic">
            <span>Select a time</span>
            <Clock size={14} />
          </div>
        </div>
      </div>
    </div>

    <div className="absolute bottom-18 left-6 right-6">
      <button className="w-full bg-[#9BD1B3] text-white py-4 rounded-[1.5rem] font-black text-base shadow-lg shadow-emerald-50 hover:bg-[#8bbfa5] transition-all">
          Add Plan
       </button>
    </div>

    <div className="absolute bottom-3 left-5 right-5 flex justify-between items-center bg-white/80 backdrop-blur-md p-2.5 rounded-[2rem] shadow-lg border border-white px-7 mt-auto">
      <div className="text-gray-300"><Home size={20} /></div>
      <div className="text-gray-300"><CheckCircle2 size={20} /></div>
      <div className="bg-[#9BD1B3] p-2.5 rounded-full text-white shadow-lg -mt-8 border-4 border-[#F8FBF9]"><Plus size={22} strokeWidth={3} /></div>
      <div className="text-gray-300"><Settings size={20} /></div>
    </div>
  </div>
);

const AppDetailScreen = () => (
  <div className="bg-[#F8FBF9] h-full w-full rounded-[2.5rem] p-5 text-left flex flex-col pt-10 items-center select-none overflow-hidden relative">
    <div className="w-full flex justify-between items-center mb-6 px-1">
       <div className="w-9 h-9 bg-white rounded-full flex items-center justify-center text-gray-400 shadow-sm border border-emerald-50"><ArrowRight className="rotate-180" size={18} /></div>
       <div className="flex gap-2">
          <div className="w-9 h-9 bg-white rounded-full flex items-center justify-center text-red-100 shadow-sm border border-emerald-50"><Trash size={16} fill="currentColor" /></div>
          <div className="w-9 h-9 bg-white rounded-full flex items-center justify-center text-emerald-100 shadow-sm border border-emerald-50"><Pencil size={16} fill="currentColor" /></div>
       </div>
    </div>

    <div className="bg-white w-full p-6 rounded-[2rem] border border-emerald-50 shadow-xl space-y-6 relative overflow-hidden flex-1 mb-16 overflow-y-auto no-scrollbar">
       <div className="space-y-1.5">
          <div className="bg-emerald-50 text-emerald-400 px-2.5 py-1 rounded-full text-[9px] font-black uppercase w-fit inline-block tracking-widest">TASK</div>
          <h2 className="text-3xl font-black text-gray-900 tracking-tight leading-tight">Software Eng</h2>
          <p className="text-gray-400 font-bold italic tracking-tight text-xs">Sprint 2 Review</p>
       </div>

       <div className="flex gap-6">
          <div className="flex items-center gap-2">
             <div className="bg-emerald-50 p-1.5 rounded-lg text-emerald-600"><Calendar size={14} /></div>
             <p className="font-bold text-gray-800 tracking-tight text-xs">23/04/2026</p>
          </div>
          <div className="flex items-center gap-2">
             <div className="bg-emerald-50 p-1.5 rounded-lg text-emerald-600"><Clock size={14} /></div>
             <p className="font-bold text-gray-800 tracking-tight text-xs">13:00</p>
          </div>
       </div>

       <div className="space-y-2">
          <p className="text-[9px] font-black text-gray-300 uppercase tracking-[0.2em]">Brief Notes</p>
          <div className="bg-emerald-50/30 p-4 rounded-xl border border-emerald-50/50 italic text-gray-600 font-medium text-xs leading-relaxed">
             Finalize the documentation for the project and update the database schema before the review session on Thursday.
          </div>
       </div>

       <button className="w-full bg-[#9CCEB5] text-white py-4 rounded-[1.8rem] font-black text-base shadow-lg shadow-emerald-50 hover:bg-[#8bbfa5] transition-all">
          Done
       </button>
    </div>
  </div>
);

const AppSettingsScreen = () => (
  <div className="bg-[#F8FBF9] h-full w-full rounded-[2.5rem] p-5 text-left flex flex-col pt-10 select-none overflow-hidden relative">
    <h2 className="text-3xl font-black mb-6 tracking-tight text-gray-800">Settings</h2>
    
    <div className="flex-1 overflow-y-auto no-scrollbar space-y-6 pb-28">
       {/* User Profile */}
       <div className="flex flex-col items-center space-y-2 mb-4">
          <div className="w-20 h-20 bg-gray-200 rounded-full border-4 border-white shadow-md relative group">
             <img src="https://picsum.photos/seed/student_profile/300/300" alt="profile" referrerPolicy="no-referrer" className="w-full h-full object-cover rounded-full" />
             <div className="absolute bottom-[-2px] right-[-2px] w-7 h-7 bg-[#9BD1B3] rounded-full border-2 border-white flex items-center justify-center text-white shadow-sm"><Camera size={14} /></div>
          </div>
          <div className="text-center">
             <p className="font-black text-lg text-gray-800 tracking-tight">JANE DOE</p>
             <p className="text-[10px] text-gray-400 font-bold tracking-tight">jane.doe@student.app</p>
          </div>
       </div>

       {/* Account Section */}
       <div className="space-y-4">
          <div className="flex items-center gap-2 px-1">
             <User size={12} className="text-gray-400" />
             <span className="text-[9px] font-black text-gray-400 uppercase tracking-widest opacity-80">Account</span>
          </div>
          <div className="space-y-2">
             <div className="bg-emerald-50/30 border border-emerald-50/50 p-3.5 rounded-xl">
                <p className="text-[8px] text-gray-400 font-black mb-1">Name</p>
                <div className="flex justify-between items-center">
                   <p className="font-black text-gray-800 text-xs uppercase">JANE DOE</p>
                   <Pencil size={12} className="text-emerald-300" />
                </div>
             </div>
             <div className="bg-emerald-50/30 border border-emerald-50/50 p-3.5 rounded-xl">
                <p className="text-[8px] text-gray-400 font-black mb-1">Email</p>
                <p className="font-black text-gray-800 text-xs tracking-tight">jane.doe@student.app</p>
             </div>
          </div>
       </div>

       {/* Preferences Section */}
       <div className="space-y-4">
          <div className="flex items-center gap-2 px-1">
             <Layout size={12} className="text-gray-400" />
             <span className="text-[9px] font-black text-gray-400 uppercase tracking-widest opacity-80">Preferences</span>
          </div>
          <div className="space-y-2">
             <div className="bg-white border border-emerald-50 p-4 rounded-xl flex justify-between items-center">
                <div className="flex items-center gap-3">
                   <Globe size={16} className="text-amber-400" />
                   <p className="font-black text-gray-800 text-xs">Language</p>
                </div>
                <div className="flex items-center gap-1.5">
                   <span className="text-[10px] font-bold text-gray-400">English</span>
                   <ChevronDown size={12} className="text-gray-300 -rotate-90" />
                </div>
             </div>
             <div className="bg-[#F3F8F5] border border-emerald-100/50 p-4 rounded-xl flex justify-between items-center">
                <div className="flex items-center gap-3">
                   <Sun size={16} className="text-amber-500" />
                   <p className="font-black text-gray-800 text-xs">Dark Mode</p>
                </div>
                <div className="w-10 h-5 bg-gray-300 rounded-full p-0.5"><div className="w-4 h-4 bg-white rounded-full translate-x-0 shadow-sm" /></div>
             </div>
          </div>
       </div>

       {/* Notifications Section */}
       <div className="space-y-4">
          <div className="px-1 text-[9px] font-black text-gray-400 uppercase tracking-widest opacity-80">Notifications</div>
          <div className="space-y-2">
             <div className="bg-[#F3F8F5] border border-emerald-100/50 p-4 rounded-xl">
                <div className="flex justify-between items-center mb-1">
                  <div className="flex items-center gap-3">
                    <Bell size={16} className="text-[#9BD1B3]" />
                    <p className="font-black text-gray-800 text-xs">Notifications On</p>
                  </div>
                  <div className="w-10 h-5 bg-[#9BD1B3] rounded-full p-0.5"><div className="w-4 h-4 bg-white rounded-full translate-x-5 shadow-sm" /></div>
                </div>
                <p className="text-[9px] text-[#9CCEB5] font-bold ml-7 tracking-tight">30 minutes before</p>
             </div>
             <div className="bg-white border border-emerald-50 p-4 rounded-xl flex items-center justify-between">
                <div className="flex items-center gap-3">
                   <Clock size={16} className="#9BD1B3 text-emerald-300" />
                   <p className="font-black text-gray-600 text-xs">30 minutes before</p>
                </div>
                <ChevronDown size={12} className="text-gray-300 -rotate-90" />
             </div>
          </div>
       </div>

       {/* Security Section */}
       <div className="space-y-4">
          <div className="flex items-center gap-2 px-1">
             <Shield size={12} className="text-gray-400" />
             <span className="text-[9px] font-black text-gray-400 uppercase tracking-widest opacity-80">Security</span>
          </div>
          <div className="space-y-2">
             <div className="bg-[#F3F8F5] border border-emerald-100/50 p-4 rounded-xl flex items-center justify-between">
                <div className="flex items-center gap-3">
                   <Lock size={16} className="text-emerald-500" />
                   <p className="font-black text-gray-800 text-xs">Change Password</p>
                </div>
                <ChevronDown size={12} className="text-gray-300 -rotate-90" />
             </div>
             <div className="bg-[#F3F8F5] border border-emerald-100/50 p-4 rounded-xl">
                <p className="text-[8px] text-gray-400 font-black mb-1">Last Login</p>
                <div className="flex justify-between items-center">
                   <p className="text-[#2A3B34] font-black text-xs">Apr 17, 2026 10:18 PM</p>
                   <CheckCircle2 size={16} className="text-emerald-400 fill-emerald-50" />
                </div>
             </div>
          </div>
       </div>

       {/* Support Section */}
       <div className="space-y-4">
          <div className="flex items-center gap-2 px-1">
             <Info size={12} className="text-gray-400" />
             <span className="text-[9px] font-black text-gray-400 uppercase tracking-widest opacity-80">Support / About</span>
          </div>
          <div className="space-y-2">
             <div className="bg-[#F3F8F5] border border-emerald-100/50 p-4 rounded-xl flex items-center justify-between cursor-pointer">
                <div className="flex items-center gap-3">
                   <Layout size={16} className="text-[#9CCEB5]" />
                   <p className="font-black text-gray-800 text-xs">About App</p>
                </div>
                <ChevronDown size={12} className="text-gray-300 -rotate-90" />
             </div>
             <div className="bg-[#F3F8F5] border border-emerald-100/50 p-4 rounded-xl flex items-center justify-between cursor-pointer">
                <div className="flex items-center gap-3">
                   <ShieldCheck size={16} className="text-emerald-400" />
                   <p className="font-black text-gray-800 text-xs">Privacy Policy</p>
                </div>
                <ChevronDown size={12} className="text-gray-300 -rotate-90" />
             </div>
             <div className="bg-[#F3F8F5] border border-emerald-100/50 p-4 rounded-xl flex items-center justify-between cursor-pointer">
                <div className="flex items-center gap-3">
                   <HelpCircle size={16} className="text-emerald-400" />
                   <p className="font-black text-gray-800 text-xs">Help / Contact</p>
                </div>
                <ChevronDown size={12} className="text-gray-300 -rotate-90" />
             </div>
          </div>
       </div>

       {/* Danger Zone */}
       <div className="pt-4 space-y-3">
          <div className="bg-red-50 border border-red-100 text-red-500 p-4 rounded-2xl flex items-center justify-center gap-2 font-black text-xs uppercase tracking-widest">
             <Trash2 size={14} /> Delete My Account
          </div>
          <div className="bg-white border-2 border-red-100 text-red-500 p-4 rounded-2xl flex items-center justify-center gap-2 font-black text-xs uppercase tracking-widest">
             <LogOut size={14} /> Sign Out
          </div>
       </div>
    </div>

    <div className="absolute bottom-3 left-5 right-5 flex justify-between items-center bg-white/80 backdrop-blur-md p-2.5 rounded-[2rem] shadow-lg border border-white px-7 mt-auto">
      <div className="text-gray-300"><Home size={20} /></div>
      <div className="text-gray-300"><CheckCircle2 size={20} /></div>
      <div className="bg-[#9BD1B3] p-2.5 rounded-full text-white shadow-lg -mt-8 border-4 border-[#F8FBF9]"><Plus size={22} strokeWidth={3} /></div>
      <div className="text-emerald-500 bg-emerald-50/50 p-1.5 rounded-xl"><Settings size={20} fill="currentColor" opacity="0.2" /></div>
    </div>
  </div>
);

const PhoneMockup = ({ children, className = "" }: { children: React.ReactNode, className?: string }) => (
  <div className={`relative w-[280px] h-[580px] sm:w-[300px] sm:h-[620px] bg-black rounded-[3.5rem] p-[8px] shadow-[0_2.75rem_5.5rem_-1.25rem_rgba(0,0,0,0.5),0_0_0_1px_rgba(255,255,255,0.1)_inset] border border-gray-900 ${className}`}>
    {/* Dynamic Island */}
    <div className="absolute top-4 left-1/2 -translate-x-1/2 w-[100px] h-7 bg-black rounded-full z-30 flex items-center justify-end px-3">
        <div className="w-2 h-2 bg-[#0f0f0f] rounded-full border border-gray-800 shadow-inner" />
    </div>
    
    <div className="h-full w-full bg-white rounded-[2.8rem] overflow-hidden relative shadow-inner">
      {children}
    </div>
  </div>
);

// --- Sections ---

const GallerySection = ({
  labels,
  title,
  description,
}: {
  labels: { home: string; details: string; finished: string; addPlan: string; settings: string };
  title: string;
  description: string;
}) => (
  <section className="py-24 bg-white overflow-hidden">
    <div className="max-w-7xl mx-auto px-4 mb-20 text-center">
      <h2 className="text-4xl lg:text-5xl font-black mb-6 italic">{title}</h2>
      <p className="text-gray-400 font-semibold max-w-lg mx-auto leading-relaxed">{description}</p>
    </div>
    
    <div className="relative">
      {/* Auto-sliding row or simple flex row for preview */}
      <div className="flex gap-8 overflow-x-auto pb-16 px-4 no-scrollbar justify-start lg:justify-center">
        <div className="shrink-0 transition-all">
          <PhoneMockup><AppDashboardScreen /></PhoneMockup>
          <p className="mt-8 text-center font-extrabold text-emerald-600 uppercase tracking-[0.2em] text-sm">{labels.home}</p>
        </div>
        <div className="shrink-0 transition-all">
          <PhoneMockup><AppDetailScreen /></PhoneMockup>
          <p className="mt-8 text-center font-extrabold text-emerald-600 uppercase tracking-[0.2em] text-sm">{labels.details}</p>
        </div>
        <div className="shrink-0 transition-all">
          <PhoneMockup><AppFinishedScreen /></PhoneMockup>
          <p className="mt-8 text-center font-extrabold text-emerald-600 uppercase tracking-[0.2em] text-sm">{labels.finished}</p>
        </div>
        <div className="shrink-0 transition-all">
          <PhoneMockup><AppAddPlanScreen /></PhoneMockup>
          <p className="mt-8 text-center font-extrabold text-emerald-600 uppercase tracking-[0.2em] text-sm">{labels.addPlan}</p>
        </div>
        <div className="shrink-0 transition-all">
          <PhoneMockup><AppSettingsScreen /></PhoneMockup>
          <p className="mt-8 text-center font-extrabold text-emerald-600 uppercase tracking-[0.2em] text-sm">{labels.settings}</p>
        </div>
      </div>
    </div>
  </section>
);

const Navbar = ({
  labels,
  lang,
  onToggleLanguage,
}: {
  labels: { features: string; guide: string; faq: string; getStarted: string };
  lang: 'en' | 'th';
  onToggleLanguage: () => void;
}) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-emerald-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-20 items-center">
          <div className="flex items-center">
            <BrandLogo className="w-10 h-10" />
            <span className="ml-3 text-3xl font-black tracking-tighter text-[#2A3B34] uppercase scale-y-110 origin-left">PLAZO</span>
          </div>

          <div className="hidden md:flex items-center space-x-10">
            {[labels.features, labels.guide, labels.faq].map(item => (
              <a key={item} href={`#${item.toLowerCase()}`} className="text-gray-500 hover:text-[#9BD1B3] font-bold text-sm uppercase tracking-widest transition-colors">{item}</a>
            ))}
            <button
              onClick={onToggleLanguage}
              className="border border-emerald-100 text-[#2A3B34] px-3 py-2 rounded-full font-bold text-xs"
            >
              {lang === 'en' ? 'TH' : 'EN'}
            </button>
            <a href={APP_URL} target="_blank" rel="noreferrer" className="bg-[#9BD1B3] text-white px-8 py-3 rounded-full font-bold text-sm shadow-lg shadow-emerald-100 hover:bg-[#7FB199] transition-all flex items-center gap-2 group">
              {labels.getStarted}
              <ArrowRight size={16} className="group-hover:translate-x-1 transition-transform" />
            </a>
          </div>

          <div className="md:hidden">
            <button onClick={() => setIsOpen(!isOpen)} className="text-gray-900"><Menu /></button>
          </div>
        </div>
      </div>
      
      <AnimatePresence>
            {isOpen && (
              <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -20 }} className="md:hidden bg-white border-t border-gray-50 p-4 space-y-4">
                {[labels.features, labels.guide, labels.faq].map(item => (
                  <a key={item} href={`#${item.toLowerCase()}`} className="block text-xl font-bold text-gray-900 py-2" onClick={() => setIsOpen(false)}>{item}</a>
                ))}
                <button
                  onClick={onToggleLanguage}
                  className="w-full border border-emerald-100 text-[#2A3B34] py-3 rounded-2xl font-bold"
                >
                  {lang === 'en' ? 'TH' : 'EN'}
                </button>
                <a href={APP_URL} target="_blank" rel="noreferrer" className="w-full bg-[#9BD1B3] text-white py-4 rounded-2xl font-bold flex items-center justify-center gap-2">
                  {labels.getStarted}
                  <ArrowRight size={18} />
                </a>
              </motion.div>
            )}
      </AnimatePresence>
    </nav>
  );
};

export default function App() {
  const [lang, setLang] = useState<'en' | 'th'>('en');
  const t = COPY[lang];

  return (
    <div className="min-h-screen bg-white font-sans text-gray-900 selection:bg-emerald-100 selection:text-emerald-900">
      <Navbar
        labels={{
          features: t.features,
          guide: t.guide,
          faq: t.faq,
          getStarted: t.getStarted,
        }}
        lang={lang}
        onToggleLanguage={() => setLang((prev) => (prev === 'en' ? 'th' : 'en'))}
      />

      {/* 1. HERO SECTION (Image 1 Style) */}
      <section className="relative pt-32 pb-20 lg:pt-48 lg:pb-32 overflow-hidden px-4">
        <div className="absolute top-0 right-0 w-[50%] h-[70%] bg-emerald-50/50 blur-[150px] -z-10 rounded-full" />
        
        <div className="max-w-7xl mx-auto flex flex-col lg:flex-row items-center gap-16 lg:gap-24">
          <motion.div 
            initial={{ opacity: 0, x: -30 }} 
            animate={{ opacity: 1, x: 0 }}
            className="flex-1 text-center lg:text-left"
          >
            <div className="inline-flex items-center gap-2 bg-emerald-50 p-2 pr-4 rounded-full mb-8">
              <div className="bg-[#9BD1B3] text-white px-3 py-1 rounded-full text-xs font-bold uppercase">{t.new}</div>
              <span className="text-xs font-bold text-[#9BD1B3]">{t.sync}</span>
            </div>
            <h1 className="text-5xl lg:text-7xl font-black mb-6 leading-tight tracking-tighter">
              {t.heroTitle1} <br />
              <span className="text-[#9BD1B3]">{t.heroTitle2}</span> <br />
              {t.heroTitle3}
            </h1>
            <p className="text-xl text-gray-500 max-w-xl mb-10 leading-relaxed font-medium">
              {t.heroDesc}
            </p>

            <div className="flex flex-col sm:flex-row items-center gap-6 mb-10 lg:justify-start">
               <a href={APP_URL} target="_blank" rel="noreferrer" className="bg-[#9BD1B3] text-white px-10 py-5 rounded-[1.4rem] font-bold text-lg shadow-2xl shadow-emerald-100 hover:bg-[#7FB199] transition-all flex items-center gap-3 group">
                  {t.startUsing}
                  <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
               </a>
            </div>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, scale: 0.8, rotate: 5 }}
            animate={{ opacity: 1, scale: 1, rotate: 0 }}
            transition={{ type: 'spring', damping: 15 }}
            className="flex-1 relative"
          >
             <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[140%] h-[140%] bg-emerald-100/50 blur-[100px] -z-10 rounded-full" />
             <PhoneMockup className="mx-auto">
                <AppDashboardScreen />
             </PhoneMockup>
             
             {/* Floating elements like Figure 1 */}
             <motion.div 
              animate={{ y: [0, -10, 0] }} 
              transition={{ repeat: Infinity, duration: 4, ease: "easeInOut" }}
              className="absolute -top-6 -right-12 bg-white p-4 rounded-2xl shadow-xl border border-emerald-50 hidden md:block"
             >
                <div className="flex items-center gap-3">
                   <div className="w-10 h-10 bg-amber-100 text-amber-600 rounded-xl flex items-center justify-center"><Clock size={20} /></div>
                   <div>
                      <p className="text-xs font-bold">Quiz Alert</p>
                      <p className="text-[10px] text-gray-400">DBMS Quiz in 1 hour</p>
                   </div>
                </div>
             </motion.div>

             <motion.div 
              animate={{ y: [0, 10, 0] }} 
              transition={{ repeat: Infinity, duration: 4, ease: "easeInOut", delay: 1 }}
              className="absolute top-1/2 -left-20 bg-white p-4 rounded-2xl shadow-xl border border-emerald-50 hidden md:block"
             >
                <div className="flex items-center gap-3">
                   <div className="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center"><CheckCircle2 size={20} /></div>
                   <div>
                      <p className="text-xs font-bold">Task Done!</p>
                      <p className="text-[10px] text-gray-400">SE Project Sync</p>
                   </div>
                </div>
             </motion.div>
          </motion.div>
        </div>
      </section>

      {/* 2. WHY PLAZO (Figure 1 Style) */}
      <section id="features" className="py-24 bg-white px-4">
        <div className="max-w-7xl mx-auto text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-black mb-6">{t.why}</h2>
          <div className="h-1.5 w-20 bg-[#9BD1B3] mx-auto rounded-full" />
        </div>
        <div className="max-w-7xl mx-auto grid md:grid-cols-3 gap-8">
          {[
            { 
              title: "Easy To Use", 
              icon: <Layout size={28} />, 
              desc: "Quickly add tasks with details like subject, date, and priority in seconds." 
            },
            { 
              title: "Smart Reminders", 
              icon: <Bell size={28} />, 
              desc: "Set up notifications to never miss a deadline. 30min or 1 day? You choose." 
            },
            { 
              title: "Academic Focus", 
              icon: <BookOpen size={28} />, 
              desc: "Purpose-built for students. Track assignments and exams in separate dedicated flows." 
            }
          ].map((item, idx) => (
            <motion.div 
              key={idx}
              whileHover={{ y: -5 }}
              className="p-12 bg-gray-50/50 border border-gray-100 rounded-[3rem] text-center"
            >
              <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-[#9BD1B3] mx-auto mb-8 shadow-sm">{item.icon}</div>
              <h3 className="text-2xl font-bold mb-4">{item.title}</h3>
              <p className="text-gray-500 leading-relaxed font-medium">{item.desc}</p>
            </motion.div>
          ))}
        </div>
      </section>

      {/* 3. APP SCREENS GALLERY - NEW */}
      <GallerySection
        title={t.explore}
        description={t.exploreDesc}
        labels={{
          home: t.home,
          details: t.details,
          finished: t.finished,
          addPlan: t.addPlan,
          settings: t.settings,
        }}
      />

      {/* 4. SIMPLIFY YOUR ACADEMICS (Figure 1 & 2 Center Layout) */}
      <section id="guide" className="py-24 bg-[#F8FBF9] overflow-hidden px-4">
        <div className="max-w-7xl mx-auto text-center mb-20">
          <h2 className="text-4xl lg:text-5xl font-black mb-6">{t.simplify}</h2>
          <p className="text-gray-500 max-w-xl mx-auto font-medium">{t.simplifyDesc}</p>
        </div>

        <div className="max-w-7xl mx-auto flex flex-col lg:flex-row items-center justify-between gap-16 lg:gap-24">
          <motion.div 
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="flex-1"
          >
             <PhoneMockup className="mx-auto rotate-[-2deg]">
                <AppAddPlanScreen />
             </PhoneMockup>
          </motion.div>

          <div className="flex-1 space-y-12">
            {[
              { 
                step: 1, 
                title: "Create an account", 
                desc: "Open your own account in simple steps or log in to your existing dashboard." 
              },
              { 
                step: 2, 
                title: "Add your subjects", 
                desc: "Populate your academic year with subjects. PLAZO automatically organizes them." 
              },
              { 
                step: 3, 
                title: "Track & Conquer", 
                desc: "Add exam dates and project deadlines. Relax as PLAZO keeps you ahead of schedule." 
              }
            ].map((item, idx) => (
              <motion.div 
                key={idx}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: idx * 0.1 }}
                viewport={{ once: true }}
                className="flex gap-8 group"
              >
                <div className="flex flex-col items-center">
                  <div className="w-12 h-12 bg-white border-2 border-[#9BD1B3] rounded-full flex items-center justify-center text-[#9BD1B3] font-black group-hover:bg-[#9BD1B3] group-hover:text-white transition-all shadow-lg shadow-emerald-50">
                    {item.step}
                  </div>
                  {idx < 2 && <div className="flex-1 w-[2px] bg-emerald-100 my-4" />}
                </div>
                <div>
                  <h3 className="text-2xl font-bold mb-3">{item.title}</h3>
                  <p className="text-gray-500 leading-relaxed font-medium max-w-sm">{item.desc}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* 5. FAQ */}
      <section id="faq" className="py-24 bg-[#F8FBF9] px-4">
        <div className="max-w-3xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-black mb-4">{t.questions}</h2>
            <p className="text-gray-400 font-medium">{t.questionsDesc}</p>
          </div>
          <div className="bg-white rounded-[3.5rem] p-10 lg:p-14 shadow-2xl shadow-emerald-100/20 border border-emerald-50">
            {[
              { q: "Is PLAZO free to use?", a: "Yes, all core features are available for free. We are committed to helping students succeed." },
              { q: "What devices are supported?", a: "PLAZO works on both iPhone (iOS) and Android, as well as any modern web browser." },
              { q: "Do I need an internet connection?", a: "Yes, to keep your data synced in real-time between devices, an active connection is needed." }
            ].map((item, i) => (
              <div key={i} className={`py-8 ${i !== 0 ? 'border-t border-gray-50' : ''}`}>
                <h4 className="text-xl font-bold mb-4">{item.q}</h4>
                <p className="text-gray-500 font-medium leading-relaxed">{item.a}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 7. FINAL DOWNLOAD (Figure 1 Style) */}
      <section className="py-24 px-4 bg-white">
        <div className="max-w-7xl mx-auto flex flex-col items-center text-center">
          <motion.div 
            initial={{ scale: 0.9, opacity: 0 }} 
            whileInView={{ scale: 1, opacity: 1 }}
            className="w-full max-w-5xl bg-[#2A3B34] rounded-[5rem] p-16 lg:p-24 text-white relative overflow-hidden"
          >
            <div className="absolute bottom-[-20%] left-[-10%] w-[50%] h-[80%] bg-emerald-500/10 blur-[100px] rounded-full rotate-45" />
            <h2 className="text-4xl lg:text-7xl font-black mb-8 leading-tight relative text-center">
              {t.stop1} <br /> {t.stop2}
            </h2>
            <p className="text-xl text-emerald-100/50 mb-12 font-bold relative text-center">{t.stopDesc}</p>
            <div className="flex flex-col sm:flex-row justify-center items-center gap-6 relative">
              <a href={APP_URL} target="_blank" rel="noreferrer" className="bg-[#9BD1B3] text-white px-12 py-6 rounded-[2rem] font-bold text-xl shadow-2xl shadow-black/20 hover:bg-[#7FB199] transition-all flex items-center gap-3 group">
                {t.launch}
                  <ArrowRight size={24} className="group-hover:translate-x-1 transition-transform" />
              </a>
            </div>
          </motion.div>
        </div>
      </section>

      {/* FOOTER */}
      <footer className="py-20 border-t border-gray-100 bg-[#F8FBF9]">
        <div className="max-w-7xl mx-auto px-4 flex flex-col lg:flex-row justify-between items-center gap-12">
          <div>
            <div className="flex items-center mb-6 justify-center lg:justify-start">
               <BrandLogo className="w-10 h-10" />
               <span className="ml-3 text-3xl font-black tracking-tighter text-[#2A3B34] uppercase scale-y-110 origin-left">PLAZO</span>
            </div>
            <p className="text-emerald-900/40 text-sm font-bold text-center lg:text-left">{t.footer}</p>
          </div>
          <div className="flex flex-wrap justify-center gap-10 text-xs font-black uppercase tracking-[0.2em] text-emerald-400">
             <a href={`${APP_URL}/privacy-policy.html`} target="_blank" rel="noreferrer" className="hover:text-emerald-600">{t.privacy}</a>
          </div>
          <p className="text-emerald-900/20 text-[10px] font-bold uppercase tracking-widest italic">Made with ❤️ for students</p>
        </div>
      </footer>
    </div>
  );
}
