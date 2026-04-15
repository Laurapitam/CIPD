<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>CIPD — Secretaría Ejecutiva</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=IBM+Plex+Sans:ital,wght@0,300;0,400;0,500;0,600;1,300&display=swap" rel="stylesheet"/>
<style>
/* ── CONFIG BANNER ── */
.config-banner{position:fixed;inset:0;background:rgba(13,27,42,0.92);display:flex;align-items:center;justify-content:center;z-index:9999;backdrop-filter:blur(4px);}
.config-box{background:#fff;border-radius:16px;padding:36px;width:480px;max-width:96vw;}
.config-title{font-family:'Syne',sans-serif;font-size:20px;font-weight:800;margin-bottom:6px;}
.config-sub{font-size:13px;color:#7A88A0;margin-bottom:24px;}
.config-field{margin-bottom:14px;}
.config-field label{display:block;font-size:12px;font-weight:600;color:#3D4F67;margin-bottom:5px;}
.config-field input{width:100%;padding:10px 12px;border:1px solid #E4E8F0;border-radius:8px;font-size:13px;font-family:'IBM Plex Sans',sans-serif;}
.config-field input:focus{outline:none;border-color:#1A5CFF;}
.config-btn{width:100%;padding:12px;background:#1A5CFF;color:#fff;border:none;border-radius:8px;font-size:14px;font-family:'Syne',sans-serif;font-weight:700;cursor:pointer;margin-top:6px;}
.config-btn:hover{background:#3B78FF;}
.config-note{font-size:11px;color:#BCC4D4;margin-top:12px;text-align:center;}

/* ── AUTH SCREEN ── */
.auth-screen{position:fixed;inset:0;background:#F4F6FA;display:flex;align-items:center;justify-content:center;z-index:8888;display:none;}
.auth-box{background:#fff;border-radius:16px;padding:40px;width:420px;max-width:96vw;box-shadow:0 8px 32px rgba(13,27,42,0.12);}
.auth-logo{font-family:'Syne',sans-serif;font-size:24px;font-weight:800;color:#0D1B2A;margin-bottom:4px;}
.auth-sub{font-size:13px;color:#7A88A0;margin-bottom:28px;}
.auth-field{margin-bottom:14px;}
.auth-field label{display:block;font-size:12px;font-weight:600;color:#3D4F67;margin-bottom:5px;}
.auth-field input{width:100%;padding:10px 12px;border:1px solid #E4E8F0;border-radius:8px;font-size:14px;font-family:'IBM Plex Sans',sans-serif;}
.auth-field input:focus{outline:none;border-color:#1A5CFF;}
.auth-btn{width:100%;padding:12px;background:#1A5CFF;color:#fff;border:none;border-radius:8px;font-size:14px;font-family:'Syne',sans-serif;font-weight:700;cursor:pointer;margin-top:8px;}
.auth-btn:hover{background:#3B78FF;}
.auth-err{background:#ffe5eb;color:#C0123A;padding:10px 14px;border-radius:8px;font-size:13px;margin-bottom:14px;display:none;}
.auth-link{font-size:12px;color:#1A5CFF;cursor:pointer;text-decoration:underline;margin-top:10px;display:block;text-align:center;}

:root{--navy:#0D1B2A;--navy2:#162436;--blue:#1A5CFF;--blue2:#3B78FF;--blue-pale:#d6e4ff;--orange:#FF6B2B;--orange-pale:#fff0e8;--teal:#00C9A7;--teal-pale:#e0faf5;--red:#FF3B5C;--red-pale:#ffe5eb;--amber:#FFB347;--amber-pale:#fff8e8;--green:#00C48C;--green-pale:#e0faf2;--white:#FFFFFF;--gray1:#F4F6FA;--gray2:#E4E8F0;--gray3:#BCC4D4;--gray4:#7A88A0;--gray5:#3D4F67;--border:#E4E8F0;--shadow:0 2px 12px rgba(13,27,42,0.07);--shadow-lg:0 8px 32px rgba(13,27,42,0.12);--r:10px;--r-lg:16px;}
*{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'IBM Plex Sans',sans-serif;background:var(--gray1);color:var(--navy);min-height:100vh;font-size:14px;}
h1,h2,h3,h4,.heading{font-family:'Syne',sans-serif;}
.shell{display:flex;min-height:100vh;}
.sidebar{width:240px;background:var(--navy);display:flex;flex-direction:column;flex-shrink:0;position:fixed;top:0;left:0;height:100vh;z-index:50;overflow-y:auto;}
.main{margin-left:240px;flex:1;display:flex;flex-direction:column;min-height:100vh;}
.topbar{background:var(--white);border-bottom:1px solid var(--border);padding:0 28px;height:60px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:40;}
.content{padding:28px;flex:1;}
.sidebar-brand{padding:22px 20px 16px;border-bottom:1px solid rgba(255,255,255,0.08);}
.brand-logo{font-family:'Syne',sans-serif;font-size:18px;font-weight:800;color:var(--white);letter-spacing:-0.5px;}
.brand-sub{font-size:11px;color:rgba(255,255,255,0.45);margin-top:2px;}
.brand-user{font-size:11px;color:rgba(255,255,255,0.6);margin-top:6px;padding:6px 10px;background:rgba(255,255,255,0.07);border-radius:6px;}
.sidebar-section{padding:16px 12px 8px;font-size:10px;font-weight:600;color:rgba(255,255,255,0.3);letter-spacing:1.5px;text-transform:uppercase;}
.nav-item{display:flex;align-items:center;gap:10px;padding:9px 16px;margin:1px 8px;border-radius:8px;cursor:pointer;color:rgba(255,255,255,0.55);font-size:13px;transition:all .15s;}
.nav-item:hover{background:rgba(255,255,255,0.07);color:var(--white);}
.nav-item.active{background:var(--blue);color:var(--white);font-weight:500;}
.nav-icon{width:16px;height:16px;flex-shrink:0;}
.sidebar-badge{margin-left:auto;background:var(--orange);color:var(--white);font-size:10px;font-weight:700;padding:1px 7px;border-radius:20px;}
.nav-logout{margin:auto 8px 16px;display:flex;align-items:center;gap:10px;padding:9px 16px;border-radius:8px;cursor:pointer;color:rgba(255,255,255,0.4);font-size:13px;transition:all .15s;}
.nav-logout:hover{background:rgba(255,59,92,0.15);color:var(--red);}
.topbar-title{font-family:'Syne',sans-serif;font-size:15px;font-weight:700;}
.topbar-sub{font-size:12px;color:var(--gray4);margin-top:1px;}
.topbar-actions{display:flex;gap:10px;align-items:center;}
.topbar-role{font-size:11px;color:var(--gray4);padding:4px 10px;background:var(--gray1);border-radius:6px;}
.btn{display:inline-flex;align-items:center;gap:7px;padding:8px 16px;border-radius:8px;font-size:13px;font-family:'IBM Plex Sans',sans-serif;font-weight:500;cursor:pointer;border:none;transition:all .15s;}
.btn-primary{background:var(--blue);color:var(--white);}
.btn-primary:hover{background:var(--blue2);}
.btn-outline{background:var(--white);color:var(--navy);border:1px solid var(--border);}
.btn-outline:hover{background:var(--gray1);}
.btn-sm{padding:5px 11px;font-size:12px;}
.btn-success{background:var(--green);color:var(--white);}
.page{display:none;}
.page.active{display:block;}
.loading-overlay{position:fixed;inset:0;background:rgba(244,246,250,0.85);display:flex;align-items:center;justify-content:center;z-index:7777;display:none;}
.spinner{width:36px;height:36px;border:3px solid var(--blue-pale);border-top-color:var(--blue);border-radius:50%;animation:spin .7s linear infinite;}
@keyframes spin{to{transform:rotate(360deg);}}
.card{background:var(--white);border:1px solid var(--border);border-radius:var(--r-lg);padding:20px;}
.card-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;}
.card-title{font-family:'Syne',sans-serif;font-size:14px;font-weight:700;}
.metric-row{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px;}
.metric{background:var(--white);border:1px solid var(--border);border-radius:var(--r-lg);padding:18px 20px;position:relative;overflow:hidden;}
.metric-accent{position:absolute;top:0;left:0;right:0;height:3px;border-radius:var(--r-lg) var(--r-lg) 0 0;}
.metric-label{font-size:11px;color:var(--gray4);font-weight:500;letter-spacing:.5px;text-transform:uppercase;margin-bottom:8px;}
.metric-value{font-family:'Syne',sans-serif;font-size:32px;font-weight:800;line-height:1;}
.metric-sub{font-size:11px;color:var(--gray4);margin-top:6px;}
.badge{display:inline-flex;align-items:center;padding:3px 9px;border-radius:20px;font-size:11px;font-weight:600;}
.badge-critico{background:var(--red-pale);color:#C0123A;}
.badge-alto{background:var(--amber-pale);color:#9A5500;}
.badge-medio{background:#FFF9E0;color:#7A6200;}
.badge-bajo{background:var(--green-pale);color:#006B52;}
.badge-blue{background:var(--blue-pale);color:#003ACC;}
.badge-gray{background:var(--gray2);color:var(--gray5);}
.badge-teal{background:var(--teal-pale);color:#006B58;}
.badge-orange{background:var(--orange-pale);color:#B84000;}
.sem{width:10px;height:10px;border-radius:50%;display:inline-block;flex-shrink:0;}
.sem-red{background:var(--red);}
.sem-yellow{background:var(--amber);}
.sem-green{background:var(--green);}
.prog-wrap{background:var(--gray2);border-radius:4px;height:5px;overflow:hidden;min-width:80px;}
.prog-fill{height:5px;border-radius:4px;}
.prog-red{background:var(--red);}
.prog-yellow{background:var(--amber);}
.prog-green{background:var(--green);}
.prog-blue{background:var(--blue);}
.tbl-wrap{overflow-x:auto;}
table{width:100%;border-collapse:collapse;}
th{text-align:left;padding:9px 12px;font-size:11px;font-weight:600;color:var(--gray4);border-bottom:2px solid var(--gray2);white-space:nowrap;letter-spacing:.3px;text-transform:uppercase;}
td{padding:10px 12px;border-bottom:1px solid var(--gray2);font-size:13px;vertical-align:middle;}
tr:last-child td{border-bottom:none;}
tr:hover td{background:var(--gray1);}
.td-bold{font-weight:600;}
.td-mono{font-family:monospace;font-size:12px;color:var(--gray5);}
.two-col{display:grid;grid-template-columns:1fr 1fr;gap:20px;}
.col-7-5{display:grid;grid-template-columns:1.4fr 1fr;gap:20px;}
.form-row{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:14px;}
.form-full{grid-column:1/-1;}
.form-group{display:flex;flex-direction:column;gap:5px;}
label{font-size:12px;font-weight:500;color:var(--gray5);}
input,select,textarea{padding:9px 12px;border:1px solid var(--border);border-radius:8px;font-size:13px;font-family:'IBM Plex Sans',sans-serif;color:var(--navy);background:var(--white);outline:none;transition:border .15s;}
input:focus,select:focus,textarea:focus{border-color:var(--blue);}
textarea{min-height:80px;resize:vertical;}
.score-display{text-align:center;padding:20px 0 10px;}
.score-num{font-family:'Syne',sans-serif;font-size:56px;font-weight:800;line-height:1;}
.score-nivel{font-size:13px;font-weight:600;padding:5px 18px;border-radius:20px;display:inline-block;margin-top:8px;}
.dim-row{display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid var(--gray2);}
.dim-name{flex:1;font-size:13px;}
.dim-stars{display:flex;gap:4px;}
.star{width:28px;height:28px;border-radius:6px;border:1.5px solid var(--gray2);background:var(--white);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:600;color:var(--gray3);transition:all .1s;}
.star:hover,.star.on{background:var(--blue);border-color:var(--blue);color:var(--white);}
.kanban{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;}
.kb-col{background:var(--gray1);border-radius:var(--r-lg);padding:14px;}
.kb-col-hdr{font-family:'Syne',sans-serif;font-size:12px;font-weight:700;color:var(--gray5);margin-bottom:10px;display:flex;align-items:center;justify-content:space-between;text-transform:uppercase;letter-spacing:.5px;}
.kb-cnt{background:var(--gray3);color:var(--white);font-size:10px;font-weight:700;padding:1px 7px;border-radius:20px;}
.kb-card{background:var(--white);border:1px solid var(--border);border-radius:var(--r);padding:12px;margin-bottom:8px;}
.kb-card-title{font-weight:600;font-size:13px;margin-bottom:6px;line-height:1.3;}
.kb-card-meta{font-size:11px;color:var(--gray4);display:flex;align-items:center;gap:6px;flex-wrap:wrap;}
.agenda-item{display:flex;gap:14px;padding:12px 0;border-bottom:1px solid var(--gray2);}
.agenda-item:last-child{border-bottom:none;}
.agenda-time{font-size:11px;color:var(--gray4);white-space:nowrap;padding-top:2px;width:70px;flex-shrink:0;}
.agenda-title{font-weight:500;font-size:13px;}
.agenda-desc{font-size:12px;color:var(--gray4);margin-top:2px;}
.modal-bg{position:fixed;inset:0;background:rgba(13,27,42,0.45);display:none;align-items:center;justify-content:center;z-index:200;backdrop-filter:blur(2px);}
.modal-bg.open{display:flex;}
.modal{background:var(--white);border-radius:var(--r-lg);width:580px;max-width:96vw;max-height:90vh;overflow-y:auto;box-shadow:var(--shadow-lg);}
.modal-hdr{padding:22px 24px 0;display:flex;justify-content:space-between;align-items:flex-start;}
.modal-title{font-family:'Syne',sans-serif;font-size:17px;font-weight:700;}
.modal-close{width:28px;height:28px;border-radius:6px;border:1px solid var(--border);background:var(--white);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:16px;color:var(--gray4);}
.modal-close:hover{background:var(--gray1);}
.modal-body{padding:20px 24px;}
.modal-footer{padding:0 24px 20px;display:flex;gap:10px;justify-content:flex-end;}
.toast-wrap{position:fixed;bottom:24px;right:24px;display:flex;flex-direction:column;gap:8px;z-index:300;}
.toast{background:var(--navy);color:var(--white);padding:12px 18px;border-radius:10px;font-size:13px;display:flex;align-items:center;gap:10px;max-width:340px;box-shadow:var(--shadow-lg);animation:slideIn .25s ease;}
.toast-ok{border-left:3px solid var(--green);}
.toast-warn{border-left:3px solid var(--amber);}
.toast-err{border-left:3px solid var(--red);}
@keyframes slideIn{from{transform:translateX(20px);opacity:0;}to{transform:translateX(0);opacity:1;}}
.alert{border-radius:var(--r);padding:12px 16px;font-size:13px;display:flex;gap:10px;align-items:flex-start;margin-bottom:14px;}
.alert-info{background:var(--blue-pale);border:1px solid #aac6ff;color:#003ACC;}
.alert-warn{background:var(--amber-pale);border:1px solid #ffd090;color:#9A5500;}
.check-item{display:flex;align-items:flex-start;gap:12px;padding:10px 0;border-bottom:1px solid var(--gray2);}
.check-item:last-child{border-bottom:none;}
.check-box{width:20px;height:20px;border-radius:5px;border:1.5px solid var(--gray3);background:var(--white);cursor:pointer;flex-shrink:0;margin-top:1px;display:flex;align-items:center;justify-content:center;font-size:12px;transition:all .1s;}
.check-box.checked{background:var(--blue);border-color:var(--blue);color:var(--white);}
.check-text{font-size:13px;}
.check-done .check-text{text-decoration:line-through;color:var(--gray3);}
.check-resp{font-size:11px;color:var(--gray4);margin-top:2px;}
.tab-group{display:flex;gap:2px;background:var(--gray1);border-radius:8px;padding:3px;width:fit-content;margin-bottom:20px;}
.tab-btn{padding:6px 16px;border-radius:6px;font-size:13px;cursor:pointer;background:none;border:none;color:var(--gray4);font-family:'IBM Plex Sans',sans-serif;font-weight:500;transition:all .15s;}
.tab-btn.active{background:var(--white);color:var(--navy);box-shadow:0 1px 4px rgba(13,27,42,.1);}
.page-title{font-family:'Syne',sans-serif;font-size:22px;font-weight:800;margin-bottom:4px;}
.page-desc{font-size:13px;color:var(--gray4);margin-bottom:24px;}
.informe-preview{background:var(--gray1);border:1px solid var(--border);border-radius:var(--r);padding:20px;font-size:13px;line-height:1.9;}
.inf-section{margin-top:14px;}
.inf-section-title{font-family:'Syne',sans-serif;font-size:12px;font-weight:700;letter-spacing:.5px;text-transform:uppercase;margin-bottom:8px;padding-bottom:4px;border-bottom:1px solid var(--border);}
.heat-grid{display:grid;grid-template-columns:24px repeat(5,1fr);gap:3px;font-size:11px;}
.heat-label{display:flex;align-items:center;justify-content:center;color:var(--gray4);font-weight:500;}
.heat-cell{padding:8px 4px;border-radius:5px;text-align:center;font-weight:600;font-size:11px;min-height:36px;display:flex;align-items:center;justify-content:center;}
.section-gap{margin-bottom:20px;}
.empty-state{text-align:center;padding:40px 20px;color:var(--gray4);font-size:13px;}
/* role guard */
.only-secretario{display:none;}
.role-secretario .only-secretario{display:initial;}
.role-presidente .only-secretario{display:initial;}
</style>
</head>
<body>

<!-- CONFIG BANNER -->
<div class="config-banner" id="config-banner">
  <div class="config-box">
    <div class="config-title">⚙️ Configura tu conexión Supabase</div>
    <div class="config-sub">Esta configuración se guarda en tu navegador. Solo necesitas hacerla una vez.</div>
    <div class="config-field">
      <label>Supabase Project URL</label>
      <input type="text" id="cfg-url" placeholder="https://xxxxxxxxxxxx.supabase.co"/>
    </div>
    <div class="config-field">
      <label>Supabase Anon Key (public)</label>
      <input type="text" id="cfg-key" placeholder="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."/>
    </div>
    <button class="config-btn" onclick="saveConfig()">Guardar y continuar</button>
    <div class="config-note">Encuentra estos valores en: Supabase → Settings → API</div>
  </div>
</div>

<!-- AUTH SCREEN -->
<div class="auth-screen" id="auth-screen">
  <div class="auth-box">
    <div class="auth-logo">CIPD</div>
    <div class="auth-sub">Secretaría Ejecutiva — Iniciar sesión</div>
    <div class="auth-err" id="auth-err"></div>
    <div id="auth-login-form">
      <div class="auth-field"><label>Correo electrónico</label><input type="email" id="auth-email" placeholder="gerente@empresa.hn"/></div>
      <div class="auth-field"><label>Contraseña</label><input type="password" id="auth-pass" placeholder="••••••••"/></div>
      <button class="auth-btn" onclick="doLogin()">Ingresar al sistema</button>
      <span class="auth-link" onclick="showRegister()">¿Primera vez? Crear cuenta →</span>
    </div>
    <div id="auth-register-form" style="display:none;">
      <div class="auth-field"><label>Nombre completo</label><input type="text" id="reg-nombre" placeholder="Ej: Laura Martínez"/></div>
      <div class="auth-field"><label>Correo electrónico</label><input type="email" id="reg-email" placeholder="gerente@empresa.hn"/></div>
      <div class="auth-field"><label>Contraseña</label><input type="password" id="reg-pass" placeholder="Mínimo 8 caracteres"/></div>
      <div class="auth-field">
        <label>Gerencia</label>
        <select id="reg-gerencia">
          <option>Gerencia General</option><option>TI / Sistemas</option><option>Distribución / Operaciones</option>
          <option>Comercial</option><option>Financiero</option><option>Planificación / Proyectos</option>
          <option>Recursos Humanos</option><option>Legal / Regulatoria</option><option>Atención al Cliente</option>
        </select>
      </div>
      <div class="auth-field">
        <label>Rol en el Comité</label>
        <select id="reg-rol">
          <option value="secretario">Secretario Ejecutivo</option>
          <option value="presidente">Presidente (Gte. General)</option>
          <option value="vicepresidente">Vicepresidente Técnico</option>
          <option value="vocal">Vocal</option>
          <option value="invitado">Invitado (sin voto)</option>
        </select>
      </div>
      <button class="auth-btn" onclick="doRegister()">Crear cuenta</button>
      <span class="auth-link" onclick="showLogin()">← Volver al inicio de sesión</span>
    </div>
  </div>
</div>

<!-- LOADING -->
<div class="loading-overlay" id="loading"><div class="spinner"></div></div>

<!-- APP -->
<div class="shell" id="app-shell" style="display:none;">
  <nav class="sidebar">
    <div class="sidebar-brand">
      <div class="brand-logo">CIPD</div>
      <div class="brand-sub">Secretaría Ejecutiva</div>
      <div class="brand-user" id="sidebar-user">Cargando…</div>
    </div>
    <div class="sidebar-section">Principal</div>
    <div class="nav-item active" onclick="nav('dashboard',this)">
      <svg class="nav-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="1" y="1" width="6" height="6" rx="1.5"/><rect x="9" y="1" width="6" height="6" rx="1.5"/><rect x="1" y="9" width="6" height="6" rx="1.5"/><rect x="9" y="9" width="6" height="6" rx="1.5"/></svg>
      Dashboard
    </div>
    <div class="nav-item" onclick="nav('backlog',this)">
      <svg class="nav-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M2 4h12M2 8h8M2 12h10"/></svg>
      Backlog
      <span class="sidebar-badge" id="badge-backlog">—</span>
    </div>
    <div class="nav-item" onclick="nav('matriz',this)">
      <svg class="nav-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M8 1L1 5v6l7 4 7-4V5L8 1z"/></svg>
      Matriz de Criticidad
    </div>
    <div class="sidebar-section">Operación</div>
    <div class="nav-item" onclick="nav('proyectos',this)">
      <svg class="nav-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="8" cy="8" r="6.5"/><path d="M8 4.5V8l2.5 2"/></svg>
      Proyectos Activos
    </div>
    <div class="nav-item" onclick="nav('riesgos',this)">
      <svg class="nav-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M8 2L1.5 13.5h13L8 2z"/><path d="M8 7v3M8 11.5v.5"/></svg>
      Riesgos
      <span class="sidebar-badge" id="badge-riesgos">—</span>
    </div>
    <div class="nav-item" onclick="nav('sesion',this)">
      <svg class="nav-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="1.5" y="2.5" width="13" height="12" rx="2"/><path d="M1.5 6.5h13M5 1v3M11 1v3"/></svg>
      Sesiones & Actas
    </div>
    <div class="sidebar-section">Reportes</div>
    <div class="nav-item" onclick="nav('informe',this)">
      <svg class="nav-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 1.5h10v13H3z"/><path d="M5.5 5.5h5M5.5 8h5M5.5 10.5h3"/></svg>
      Informe Ejecutivo
    </div>
    <div class="nav-item" onclick="nav('checklist',this)">
      <svg class="nav-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M2.5 8L5.5 11l8-8"/></svg>
      Lista de Verificación
    </div>
    <div class="nav-logout" onclick="doLogout()">
      <svg class="nav-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M6 2H2v12h4M10.5 5l3 3-3 3M13.5 8H6"/></svg>
      Cerrar sesión
    </div>
  </nav>

  <div class="main">
    <div class="topbar">
      <div>
        <div class="topbar-title" id="topbar-title">Dashboard General</div>
        <div class="topbar-sub" id="topbar-sub">CIPD — Cargando datos…</div>
      </div>
      <div class="topbar-actions">
        <span class="topbar-role" id="topbar-role">—</span>
        <button class="btn btn-outline btn-sm only-secretario" onclick="openModal('nueva-solicitud')">+ Nueva solicitud</button>
        <button class="btn btn-primary btn-sm only-secretario" onclick="openModal('nueva-sesion')">Convocar sesión</button>
      </div>
    </div>

    <div class="content">

      <!-- DASHBOARD -->
      <div id="page-dashboard" class="page active">
        <div class="metric-row">
          <div class="metric"><div class="metric-accent" style="background:var(--blue)"></div><div class="metric-label">Proyectos activos</div><div class="metric-value" id="m-proyectos">—</div><div class="metric-sub" id="m-proyectos-sub">cargando…</div></div>
          <div class="metric"><div class="metric-accent" style="background:var(--orange)"></div><div class="metric-label">Backlog pendiente</div><div class="metric-value" id="m-backlog">—</div><div class="metric-sub" id="m-backlog-sub">cargando…</div></div>
          <div class="metric"><div class="metric-accent" style="background:var(--green)"></div><div class="metric-label">Entrega a tiempo</div><div class="metric-value" id="m-entrega" style="color:var(--green)">—</div><div class="metric-sub">Meta: ≥ 80%</div></div>
          <div class="metric"><div class="metric-accent" style="background:var(--red)"></div><div class="metric-label">Proyectos en rojo</div><div class="metric-value" id="m-rojos" style="color:var(--red)">—</div><div class="metric-sub">Meta: ≤ 2</div></div>
        </div>
        <div class="col-7-5">
          <div class="card">
            <div class="card-header"><span class="card-title">Semáforo de proyectos</span><button class="btn btn-outline btn-sm" onclick="nav('proyectos',null)">Ver todos</button></div>
            <div class="tbl-wrap"><table><thead><tr><th></th><th>Proyecto</th><th>Gerencia</th><th>Avance</th><th>Entrega</th></tr></thead><tbody id="tbl-semaforo"></tbody></table></div>
          </div>
          <div class="card">
            <div class="card-header"><span class="card-title">Top backlog</span></div>
            <div class="tbl-wrap"><table><thead><tr><th>#</th><th>Solicitud</th><th>Score</th><th>Nivel</th></tr></thead><tbody id="tbl-backlog-mini"></tbody></table></div>
          </div>
        </div>
      </div>

      <!-- BACKLOG -->
      <div id="page-backlog" class="page">
        <div class="page-title">Backlog de solicitudes</div>
        <div class="page-desc">Iniciativas registradas ordenadas por criticidad.</div>
        <div style="display:flex;gap:10px;margin-bottom:16px;flex-wrap:wrap;">
          <select id="filter-nivel" style="width:160px;" onchange="loadBacklog()"><option value="">Todos los niveles</option><option>CRÍTICO</option><option>ALTO</option><option>MEDIO</option><option>BAJO</option></select>
          <select id="filter-estado" style="width:180px;" onchange="loadBacklog()"><option value="">Todos los estados</option><option>Pendiente</option><option>En evaluación</option><option>Aprobado</option><option>Rechazado</option></select>
          <button class="btn btn-primary btn-sm only-secretario" style="margin-left:auto;" onclick="openModal('nueva-solicitud')">+ Nueva solicitud</button>
        </div>
        <div class="card" style="padding:0;"><div class="tbl-wrap"><table><thead><tr><th>ID CIPD</th><th>ID GLPI</th><th>Iniciativa</th><th>Gerencia</th><th>Score</th><th>Nivel</th><th>Estado</th><th>Ingreso</th></tr></thead><tbody id="tbl-backlog"></tbody></table></div></div>
      </div>

      <!-- MATRIZ -->
      <div id="page-matriz" class="page">
        <div class="page-title">Matriz de Criticidad</div>
        <div class="page-desc">Evalúa cada iniciativa con las 5 dimensiones del CIPD.</div>
        <div class="two-col">
          <div class="card">
            <div class="card-header"><span class="card-title">Calculadora de score</span></div>
            <div id="dim-container"></div>
            <div style="border-top:1px solid var(--gray2);margin-top:4px;padding-top:16px;">
              <div class="score-display"><div class="score-num" id="score-num" style="color:var(--gray3)">0</div><div style="font-size:12px;color:var(--gray4)">Score total (máx. 25)</div><div class="score-nivel" id="score-nivel-badge" style="background:var(--gray2);color:var(--gray4)">— Sin evaluar</div></div>
              <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:12px;">
                <label style="display:flex;align-items:center;gap:6px;font-size:12px;"><input type="checkbox" id="mod-reg" onchange="calcScore()" style="width:auto;padding:0;"/><span>Mandato CREE (+2)</span></label>
                <label style="display:flex;align-items:center;gap:6px;font-size:12px;"><input type="checkbox" id="mod-dep" onchange="calcScore()" style="width:auto;padding:0;"/><span>Dependencia técnica (+1)</span></label>
                <label style="display:flex;align-items:center;gap:6px;font-size:12px;"><input type="checkbox" id="mod-sin" onchange="calcScore()" style="width:auto;padding:0;"/><span>Sin recursos −60 días (−1)</span></label>
                <label style="display:flex;align-items:center;gap:6px;font-size:12px;"><input type="checkbox" id="mod-dup" onchange="calcScore()" style="width:auto;padding:0;"/><span>Iniciativa duplicada (−2)</span></label>
              </div>
            </div>
            <div style="display:flex;gap:10px;margin-top:16px;">
              <button class="btn btn-outline btn-sm" onclick="resetMatriz()">Limpiar</button>
              <button class="btn btn-primary btn-sm only-secretario" style="flex:1;" onclick="openModal('guardar-score')">Guardar en backlog</button>
            </div>
          </div>
          <div class="card">
            <div class="card-header"><span class="card-title">Escala de referencia</span></div>
            <div style="display:flex;flex-direction:column;gap:6px;">
              <div style="display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;background:var(--red-pale);"><span style="font-weight:700;color:#C0123A;min-width:80px;">21–25</span><div><div style="font-weight:600;color:#C0123A;font-size:12px;">CRÍTICO</div><div style="font-size:11px;color:#C0123A;">Agenda inmediata. Próxima sesión obligatoria.</div></div></div>
              <div style="display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;background:var(--amber-pale);"><span style="font-weight:700;color:#9A5500;min-width:80px;">15–20</span><div><div style="font-weight:600;color:#9A5500;font-size:12px;">ALTO</div><div style="font-size:11px;color:#9A5500;">Sprint actual. Asignar líder de proyecto.</div></div></div>
              <div style="display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;background:#FFF9E0;"><span style="font-weight:700;color:#7A6200;min-width:80px;">9–14</span><div><div style="font-weight:600;color:#7A6200;font-size:12px;">MEDIO</div><div style="font-size:11px;color:#7A6200;">Planificar próximo trimestre.</div></div></div>
              <div style="display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;background:var(--green-pale);"><span style="font-weight:700;color:#006B52;min-width:80px;">5–8</span><div><div style="font-weight:600;color:#006B52;font-size:12px;">BAJO</div><div style="font-size:11px;color:#006B52;">Backlog. Revisión trimestral.</div></div></div>
            </div>
          </div>
        </div>
      </div>

      <!-- PROYECTOS -->
      <div id="page-proyectos" class="page">
        <div class="page-title">Proyectos Activos</div>
        <div class="page-desc">Portafolio en ejecución con semáforo y perfil GLPI.</div>
        <div class="tab-group">
          <button class="tab-btn active" onclick="switchTab('kanban',this)">Kanban</button>
          <button class="tab-btn" onclick="switchTab('tabla-proy',this)">Tabla</button>
        </div>
        <div id="view-kanban"><div class="kanban" id="kanban-board"></div></div>
        <div id="view-tabla-proy" style="display:none;"><div class="card" style="padding:0;"><div class="tbl-wrap"><table><thead><tr><th>ID</th><th>Proyecto</th><th>Líder</th><th>Gerencia</th><th>Perfil</th><th>Avance</th><th>Entrega</th><th>Estado</th></tr></thead><tbody id="tbl-proyectos"></tbody></table></div></div></div>
      </div>

      <!-- RIESGOS -->
      <div id="page-riesgos" class="page">
        <div class="page-title">Gestión de Riesgos</div>
        <div class="page-desc">Registro y mapa de calor del portafolio.</div>
        <div class="two-col">
          <div class="card">
            <div class="card-header"><span class="card-title">Riesgos activos</span><button class="btn btn-primary btn-sm only-secretario" onclick="openModal('nuevo-riesgo')">+ Agregar</button></div>
            <div class="tbl-wrap"><table><thead><tr><th>Riesgo</th><th>Proyecto</th><th>P</th><th>I</th><th>Nivel</th><th>Estado</th></tr></thead><tbody id="tbl-riesgos"></tbody></table></div>
          </div>
          <div class="card">
            <div class="card-header"><span class="card-title">Mapa de calor</span></div>
            <div id="heat-map-container"></div>
            <div style="margin-top:10px;font-size:11px;color:var(--gray4);">P = Probabilidad (filas 5→1) · I = Impacto (columnas 1→5) · ● = riesgo activo</div>
          </div>
        </div>
      </div>

      <!-- SESIÓN -->
      <div id="page-sesion" class="page">
        <div class="page-title">Sesiones & Actas</div>
        <div class="page-desc">Agenda, quórum, votaciones y registro de acuerdos.</div>
        <div class="two-col">
          <div class="card">
            <div class="card-header"><span class="card-title" id="sesion-titulo">Sesión actual</span><span class="badge badge-blue">Ordinaria</span></div>
            <div id="agenda-list"></div>
            <div style="display:flex;gap:10px;margin-top:16px;">
              <button class="btn btn-outline btn-sm only-secretario" onclick="openModal('nueva-sesion')">Nueva sesión</button>
              <button class="btn btn-primary btn-sm only-secretario" onclick="toast('Convocatoria enviada a todos los miembros','ok')">Enviar convocatoria</button>
            </div>
          </div>
          <div class="card">
            <div class="card-header"><span class="card-title">Acuerdos</span><button class="btn btn-primary btn-sm only-secretario" onclick="openModal('nuevo-acuerdo')">+ Acuerdo</button></div>
            <div class="tbl-wrap"><table><thead><tr><th>#</th><th>Acuerdo</th><th>Resp.</th><th>Fecha</th><th>Estado</th></tr></thead><tbody id="tbl-acuerdos"></tbody></table></div>
          </div>
        </div>
        <div class="card" style="margin-top:20px;">
          <div class="card-header"><span class="card-title">Historial de sesiones</span></div>
          <div class="tbl-wrap"><table><thead><tr><th>#</th><th>Tipo</th><th>Fecha</th><th>Quórum</th><th>Estado</th></tr></thead><tbody id="tbl-historial-sesiones"></tbody></table></div>
        </div>
      </div>

      <!-- INFORME -->
      <div id="page-informe" class="page">
        <div class="page-title">Informe Ejecutivo</div>
        <div class="page-desc">Genera y envía el informe quincenal para la Gerencia General.</div>
        <div class="two-col">
          <div class="card">
            <div class="card-header"><span class="card-title">Vista previa del informe</span></div>
            <div class="informe-preview" id="informe-preview">
              <div style="font-family:'Syne',sans-serif;font-size:15px;font-weight:700;margin-bottom:4px;">Informe Ejecutivo CIPD</div>
              <div style="font-size:12px;color:var(--gray4);margin-bottom:14px;" id="informe-periodo">Cargando…</div>
              <div id="informe-body"></div>
            </div>
            <div style="display:flex;gap:10px;margin-top:14px;">
              <button class="btn btn-outline btn-sm" onclick="toast('Función de exportación disponible con backend adicional','warn')">Exportar PDF</button>
              <button class="btn btn-primary only-secretario" onclick="marcarInformeEnviado()">Enviar a Gerencia General ↗</button>
            </div>
          </div>
          <div class="card">
            <div class="card-header"><span class="card-title">KPIs del Comité</span></div>
            <div style="display:flex;flex-direction:column;gap:14px;" id="kpi-list"></div>
          </div>
        </div>
      </div>

      <!-- CHECKLIST -->
      <div id="page-checklist" class="page">
        <div class="page-title">Lista de verificación constitutiva</div>
        <div class="page-desc">Acciones previas a la sesión constitutiva del CIPD.</div>
        <div class="metric-row">
          <div class="metric"><div class="metric-accent" style="background:var(--green)"></div><div class="metric-label">Completadas</div><div class="metric-value" id="chk-done" style="color:var(--green)">—</div></div>
          <div class="metric"><div class="metric-accent" style="background:var(--amber)"></div><div class="metric-label">Pendientes</div><div class="metric-value" id="chk-pending" style="color:var(--amber)">—</div></div>
          <div class="metric"><div class="metric-accent" style="background:var(--blue)"></div><div class="metric-label">Progreso</div><div class="metric-value" id="chk-pct" style="color:var(--blue)">—</div></div>
          <div class="metric"><div class="metric-accent" style="background:var(--gray3)"></div><div class="metric-label">Total pasos</div><div class="metric-value">11</div></div>
        </div>
        <div class="card section-gap"><div class="prog-wrap" style="height:10px;border-radius:6px;"><div class="prog-fill prog-blue" id="chk-bar" style="width:0%;height:10px;border-radius:6px;"></div></div></div>
        <div class="card"><div id="checklist-items"></div></div>
      </div>

    </div><!-- /content -->
  </div><!-- /main -->
</div><!-- /shell -->

<!-- MODAL -->
<div id="modal-bg" class="modal-bg" onclick="if(event.target===this)closeModal()">
  <div class="modal">
    <div class="modal-hdr"><div class="modal-title" id="modal-title"></div><button class="modal-close" onclick="closeModal()">✕</button></div>
    <div class="modal-body" id="modal-body"></div>
    <div class="modal-footer" id="modal-footer"></div>
  </div>
</div>

<div class="toast-wrap" id="toast-wrap"></div>

<script>
// ============================================================
// CONFIG & SUPABASE INIT
// ============================================================
let supabase = null;
let currentUser = null;
let currentProfile = null;
let dimVals = {op:0,com:0,reg:0,est:0,urg:0};
const DIMS = [
  {id:'op',  label:'Impacto Operativo',          col:'dim_operativo'},
  {id:'com', label:'Impacto Comercial / Cliente', col:'dim_comercial'},
  {id:'reg', label:'Riesgo Regulatorio / CREE',   col:'dim_regulatorio'},
  {id:'est', label:'Valor Estratégico',            col:'dim_estrategico'},
  {id:'urg', label:'Urgencia Temporal',            col:'dim_urgencia'},
];
const AGENDA_BASE = [
  {time:'0–5 min',  title:'Apertura y validación de quórum',      desc:'Verificar asistencia mínima de 5 miembros con voto'},
  {time:'5–10 min', title:'Aprobación acta anterior',              desc:'Revisión y firma del acta de la sesión previa'},
  {time:'10–25 min',title:'Tablero ejecutivo: semáforo proyectos', desc:'Dashboard de proyectos activos'},
  {time:'25–45 min',title:'Revisión bloqueos activos',             desc:'Proyectos en perfil C — decisión del comité'},
  {time:'45–75 min',title:'Evaluación nuevas solicitudes',         desc:'Votación con matriz de criticidad'},
  {time:'75–85 min',title:'Ajuste de prioridades',                 desc:'Re-evaluación con cambios de contexto'},
  {time:'85–90 min',title:'Acuerdos, responsables y cierre',       desc:'Registro formal de decisiones y compromisos'},
];

function getSavedConfig(){
  return {url: localStorage.getItem('cipd_url')||'', key: localStorage.getItem('cipd_key')||''};
}
function saveConfig(){
  const url = document.getElementById('cfg-url').value.trim();
  const key = document.getElementById('cfg-key').value.trim();
  if(!url||!key){showConfigError('Completa ambos campos');return;}
  localStorage.setItem('cipd_url', url);
  localStorage.setItem('cipd_key', key);
  initSupabase(url, key);
  document.getElementById('config-banner').style.display='none';
  document.getElementById('auth-screen').style.display='flex';
}
function showConfigError(msg){alert(msg);}

function initSupabase(url, key){
  supabase = window.supabase.createClient(url, key);
}

// ============================================================
// AUTH
// ============================================================
function showRegister(){
  document.getElementById('auth-login-form').style.display='none';
  document.getElementById('auth-register-form').style.display='block';
}
function showLogin(){
  document.getElementById('auth-register-form').style.display='none';
  document.getElementById('auth-login-form').style.display='block';
}
function showAuthErr(msg){
  const el=document.getElementById('auth-err');
  el.textContent=msg; el.style.display='block';
}
function hideAuthErr(){document.getElementById('auth-err').style.display='none';}

async function doLogin(){
  hideAuthErr();
  const email=document.getElementById('auth-email').value.trim();
  const pass=document.getElementById('auth-pass').value;
  if(!email||!pass){showAuthErr('Completa todos los campos');return;}
  showLoading();
  const {data,error}=await supabase.auth.signInWithPassword({email,password:pass});
  hideLoading();
  if(error){showAuthErr(error.message);return;}
  await afterLogin(data.user);
}

async function doRegister(){
  hideAuthErr();
  const nombre=document.getElementById('reg-nombre').value.trim();
  const email=document.getElementById('reg-email').value.trim();
  const pass=document.getElementById('reg-pass').value;
  const gerencia=document.getElementById('reg-gerencia').value;
  const rol=document.getElementById('reg-rol').value;
  if(!nombre||!email||!pass){showAuthErr('Completa todos los campos');return;}
  showLoading();
  const {data,error}=await supabase.auth.signUp({
    email, password:pass,
    options:{data:{nombre,gerencia,rol}}
  });
  hideLoading();
  if(error){showAuthErr(error.message);return;}
  toast('Cuenta creada. Revisa tu correo para confirmar.','ok');
  showLogin();
}

async function doLogout(){
  await supabase.auth.signOut();
  currentUser=null; currentProfile=null;
  document.getElementById('app-shell').style.display='none';
  document.getElementById('auth-screen').style.display='flex';
}

async function afterLogin(user){
  currentUser=user;
  // Load profile
  const {data}=await supabase.from('perfiles').select('*').eq('id',user.id).single();
  currentProfile=data;
  document.getElementById('auth-screen').style.display='none';
  document.getElementById('app-shell').style.display='flex';
  // Set role class for UI guards
  document.body.className=`role-${currentProfile?.rol||'vocal'}`;
  document.getElementById('sidebar-user').textContent=`${currentProfile?.nombre||user.email} · ${currentProfile?.gerencia||''}`;
  document.getElementById('topbar-role').textContent=currentProfile?.rol||'vocal';
  await loadDashboard();
}

// ============================================================
// LOADING
// ============================================================
function showLoading(){document.getElementById('loading').style.display='flex';}
function hideLoading(){document.getElementById('loading').style.display='none';}

// ============================================================
// HELPERS
// ============================================================
function nivelBadge(n){
  const m={CRÍTICO:'badge-critico',ALTO:'badge-alto',MEDIO:'badge-medio',BAJO:'badge-bajo'};
  return `<span class="badge ${m[n]||'badge-gray'}">${n||'—'}</span>`;
}
function estadoBadge(e){
  const m={'Aprobado':'badge-teal','En evaluación':'badge-blue','Pendiente':'badge-gray','Rechazado':'badge-critico','Aplazado':'badge-gray','En proceso':'badge-alto','Completado':'badge-teal','Vencido':'badge-critico','Finalizada':'badge-teal','Programada':'badge-blue'};
  return `<span class="badge ${m[e]||'badge-gray'}">${e||'—'}</span>`;
}
function perfilBadge(p){
  const labels={A:'A — Control',B:'B — Riesgo',C:'C — Crítico',D:'D — Revisar'};
  const cls={A:'badge-teal',B:'badge-alto',C:'badge-critico',D:'badge-gray'};
  return `<span class="badge ${cls[p]||'badge-gray'}">${labels[p]||p||'—'}</span>`;
}
function semIcon(s){
  const cls={red:'sem-red',yellow:'sem-yellow',green:'sem-green'};
  return `<span class="sem ${cls[s]||'sem-green'}"></span>`;
}
function progBar(pct,status){
  const cls=status==='red'?'prog-red':status==='yellow'?'prog-yellow':'prog-green';
  return `<div style="display:flex;align-items:center;gap:8px;min-width:100px;"><div class="prog-wrap" style="flex:1;"><div class="prog-fill ${cls}" style="width:${pct||0}%"></div></div><span style="font-size:11px;color:var(--gray4);">${pct||0}%</span></div>`;
}
function scoreColor(s){if(s>=21)return'var(--red)';if(s>=15)return'var(--amber)';if(s>=9)return'#8B7500';return'var(--green)';}
function fmtDate(d){if(!d)return'—';return new Date(d).toLocaleDateString('es-HN',{day:'2-digit',month:'short',year:'numeric'});}

// ============================================================
// NAVIGATION
// ============================================================
function nav(page,el){
  document.querySelectorAll('.page').forEach(p=>p.classList.remove('active'));
  document.getElementById('page-'+page).classList.add('active');
  if(el){document.querySelectorAll('.nav-item').forEach(n=>n.classList.remove('active'));el.classList.add('active');}
  const titles={dashboard:'Dashboard General',backlog:'Backlog de Solicitudes',matriz:'Matriz de Criticidad',proyectos:'Proyectos Activos',riesgos:'Gestión de Riesgos',sesion:'Sesiones & Actas',informe:'Informe Ejecutivo',checklist:'Lista de Verificación'};
  document.getElementById('topbar-title').textContent=titles[page]||page;
  const loaders={backlog:loadBacklog,proyectos:loadProyectos,riesgos:loadRiesgos,sesion:loadSesion,informe:loadInforme,checklist:loadChecklist,matriz:renderDims};
  if(loaders[page]) loaders[page]();
}

// ============================================================
// DASHBOARD
// ============================================================
async function loadDashboard(){
  const [{data:proyectos},{data:backlog},{data:riesgos}] = await Promise.all([
    supabase.from('proyectos').select('*').eq('activo',true).order('created_at'),
    supabase.from('solicitudes').select('*').order('score',{ascending:false}).limit(10),
    supabase.from('riesgos').select('*').neq('estado','Cerrado'),
  ]);
  const p=proyectos||[]; const b=backlog||[];
  document.getElementById('m-proyectos').textContent=p.length;
  const rojos=p.filter(x=>x.semaforo==='red').length;
  document.getElementById('m-rojos').textContent=rojos;
  document.getElementById('m-backlog').textContent=b.filter(x=>['Pendiente','En evaluación'].includes(x.estado)).length;
  const entregados=p.filter(x=>x.avance_pct>=100).length;
  const enRuta=p.filter(x=>x.semaforo==='green').length;
  const pct=p.length?Math.round(enRuta/p.length*100):0;
  document.getElementById('m-entrega').textContent=pct+'%';
  document.getElementById('m-entrega').style.color=pct>=80?'var(--green)':'var(--amber)';
  document.getElementById('m-proyectos-sub').textContent=`${rojos} en riesgo`;
  document.getElementById('m-backlog-sub').textContent=`${b.filter(x=>x.nivel==='CRÍTICO').length} críticos`;
  // badge riesgos sidebar
  const rActivosCnt=(riesgos||[]).filter(r=>r.estado!=='Cerrado').length;
  document.getElementById('badge-riesgos').textContent=rActivosCnt||'—';
  document.getElementById('badge-backlog').textContent=b.filter(x=>['Pendiente','En evaluación'].includes(x.estado)).length||'—';
  // semaforo table
  document.getElementById('tbl-semaforo').innerHTML=p.slice(0,7).map(pr=>`<tr>
    <td>${semIcon(pr.semaforo)}</td><td class="td-bold">${pr.nombre}</td>
    <td style="font-size:12px;color:var(--gray4);">${pr.gerencia}</td>
    <td>${progBar(pr.avance_pct,pr.semaforo)}</td>
    <td style="font-size:12px;">${fmtDate(pr.fecha_entrega)}</td>
  </tr>`).join('')||'<tr><td colspan="5" class="empty-state">Sin proyectos activos</td></tr>';
  // backlog mini
  document.getElementById('tbl-backlog-mini').innerHTML=b.slice(0,5).map((bl,i)=>`<tr>
    <td style="color:var(--gray4);font-size:12px;">${i+1}</td>
    <td style="font-weight:500;font-size:12px;">${bl.nombre}</td>
    <td style="font-weight:700;color:${scoreColor(bl.score)};font-size:13px;">${bl.score||0}</td>
    <td>${nivelBadge(bl.nivel)}</td>
  </tr>`).join('')||'<tr><td colspan="4" class="empty-state">Backlog vacío</td></tr>';
  // topbar sub
  const {data:sesActual}=await supabase.from('sesiones').select('*').eq('estado','Programada').order('fecha',{ascending:true}).limit(1).single();
  document.getElementById('topbar-sub').textContent=sesActual?`Sesión #${sesActual.numero} — ${fmtDate(sesActual.fecha)}`:'Sin sesión próxima programada';
}

// ============================================================
// BACKLOG
// ============================================================
async function loadBacklog(){
  const nivel=document.getElementById('filter-nivel')?.value||'';
  const estado=document.getElementById('filter-estado')?.value||'';
  let q=supabase.from('solicitudes').select('*').order('score',{ascending:false});
  if(nivel) q=q.eq('nivel',nivel);
  if(estado) q=q.eq('estado',estado);
  const {data,error}=await q;
  if(error){toast(error.message,'err');return;}
  const tb=document.getElementById('tbl-backlog');
  tb.innerHTML=(data||[]).map(b=>`<tr>
    <td class="td-mono td-bold">${b.id_cipd}</td>
    <td class="td-mono">${b.id_glpi||'—'}</td>
    <td style="font-weight:500;">${b.nombre}</td>
    <td style="font-size:12px;">${b.gerencia}</td>
    <td style="font-weight:700;color:${scoreColor(b.score||0)};">${b.score||0}</td>
    <td>${nivelBadge(b.nivel)}</td>
    <td>${estadoBadge(b.estado)}</td>
    <td style="font-size:11px;color:var(--gray4);">${fmtDate(b.created_at)}</td>
  </tr>`).join('')||'<tr><td colspan="8" class="empty-state">Sin solicitudes</td></tr>';
}

// ============================================================
// MATRIZ
// ============================================================
function renderDims(){
  const c=document.getElementById('dim-container');
  if(!c)return;
  c.innerHTML=DIMS.map(d=>`<div class="dim-row">
    <div class="dim-name" style="font-weight:500;">${d.label}</div>
    <div class="dim-stars">${[1,2,3,4,5].map(v=>`<div class="star${dimVals[d.id]>=v?' on':''}" onclick="setDim('${d.id}',${v})">${v}</div>`).join('')}</div>
  </div>`).join('');
  calcScore();
}
function setDim(id,val){dimVals[id]=val;renderDims();}
function calcScore(){
  let s=Object.values(dimVals).reduce((a,b)=>a+b,0);
  const mods=(document.getElementById('mod-reg')?.checked?2:0)+(document.getElementById('mod-dep')?.checked?1:0)-(document.getElementById('mod-sin')?.checked?1:0)-(document.getElementById('mod-dup')?.checked?2:0);
  s=Math.max(0,Math.min(25,s+mods));
  const el=document.getElementById('score-num');
  const bl=document.getElementById('score-nivel-badge');
  if(!el)return;
  let nivel,color,bg;
  if(s>=21){nivel='CRÍTICO';color='#C0123A';bg='var(--red-pale)';}
  else if(s>=15){nivel='ALTO';color='#9A5500';bg='var(--amber-pale)';}
  else if(s>=9){nivel='MEDIO';color='#7A6200';bg:'#FFF9E0';bg='#FFF9E0';}
  else if(s>=5){nivel='BAJO';color='#006B52';bg='var(--green-pale)';}
  else{nivel='Sin evaluar';color='var(--gray4)';bg='var(--gray2)';}
  el.textContent=s; el.style.color=s>0?color:'var(--gray3)';
  bl.textContent=s>=5?`Nivel: ${nivel}`:nivel;
  bl.style.background=s>=5?bg:'var(--gray2)'; bl.style.color=s>=5?color:'var(--gray4)';
}
function resetMatriz(){DIMS.forEach(d=>dimVals[d.id]=0);['mod-reg','mod-dep','mod-sin','mod-dup'].forEach(id=>{const el=document.getElementById(id);if(el)el.checked=false;});renderDims();}

// ============================================================
// PROYECTOS
// ============================================================
async function loadProyectos(){
  const {data,error}=await supabase.from('proyectos').select('*').eq('activo',true).order('semaforo').order('avance_pct');
  if(error){toast(error.message,'err');return;}
  const p=data||[];
  // Kanban
  const cols=[
    {title:'Aprobado — en cola', items:p.filter(x=>x.avance_pct===0)},
    {title:'En ejecución',       items:p.filter(x=>x.avance_pct>0&&x.avance_pct<80)},
    {title:'Revisión / UAT',     items:p.filter(x=>x.avance_pct>=80&&x.avance_pct<100)},
    {title:'Completado',         items:p.filter(x=>x.avance_pct===100)},
  ];
  document.getElementById('kanban-board').innerHTML=cols.map(col=>{
    const cards=col.items.map(it=>`<div class="kb-card">
      <div class="kb-card-title">${it.nombre}</div>
      <div class="kb-card-meta">${semIcon(it.semaforo)}<span>${it.gerencia}</span><span>· ${it.avance_pct}%</span>${perfilBadge(it.perfil_glpi)}</div>
    </div>`).join('');
    return `<div class="kb-col"><div class="kb-col-hdr">${col.title}<span class="kb-cnt">${col.items.length}</span></div>${cards||'<div style="font-size:12px;color:var(--gray3);text-align:center;padding:20px 0;">Vacío</div>'}</div>`;
  }).join('');
  // Tabla
  document.getElementById('tbl-proyectos').innerHTML=p.map(pr=>`<tr>
    <td class="td-mono td-bold">${pr.id_cipd}</td>
    <td style="font-weight:500;">${pr.nombre}</td>
    <td style="font-size:12px;">${pr.lider_nombre||'—'}</td>
    <td style="font-size:12px;">${pr.gerencia}</td>
    <td>${perfilBadge(pr.perfil_glpi)}</td>
    <td>${progBar(pr.avance_pct,pr.semaforo)}</td>
    <td style="font-size:12px;">${fmtDate(pr.fecha_entrega)}</td>
    <td>${semIcon(pr.semaforo)}</td>
  </tr>`).join('')||'<tr><td colspan="8" class="empty-state">Sin proyectos</td></tr>';
}
function switchTab(view,el){
  ['kanban','tabla-proy'].forEach(v=>{const d=document.getElementById('view-'+v);if(d)d.style.display='none';});
  const t=document.getElementById('view-'+view);if(t)t.style.display='block';
  document.querySelectorAll('.tab-btn').forEach(b=>b.classList.remove('active'));
  if(el)el.classList.add('active');
  if(view==='tabla-proy')loadProyectos();
}

// ============================================================
// RIESGOS
// ============================================================
async function loadRiesgos(){
  const {data,error}=await supabase.from('riesgos').select('*, proyectos(id_cipd,nombre)').neq('estado','Cerrado').order('probabilidad',{ascending:false});
  if(error){toast(error.message,'err');return;}
  const r=data||[];
  document.getElementById('tbl-riesgos').innerHTML=r.map(ri=>`<tr>
    <td style="font-weight:500;">${ri.nombre}</td>
    <td class="td-mono">${ri.proyectos?.id_cipd||'—'}</td>
    <td style="text-align:center;font-weight:700;">${ri.probabilidad}</td>
    <td style="text-align:center;font-weight:700;">${ri.impacto}</td>
    <td>${nivelBadge(ri.nivel)}</td>
    <td>${estadoBadge(ri.estado)}</td>
  </tr>`).join('')||'<tr><td colspan="6" class="empty-state">Sin riesgos activos</td></tr>';
  // Heatmap
  const hm=document.getElementById('heat-map-container');
  let html='<div class="heat-grid">';
  html+='<div></div>';['I1','I2','I3','I4','I5'].forEach(l=>html+=`<div class="heat-label">${l}</div>`);
  for(let p=5;p>=1;p--){
    html+=`<div class="heat-label">P${p}</div>`;
    for(let i=1;i<=5;i++){
      const s=p*i;let bg,tc;
      if(s>=16){bg='#FFDDE3';tc='#C0123A';}else if(s>=9){bg='var(--amber-pale)';tc='#9A5500';}else if(s>=4){bg='#FFF9E0';tc='#7A6200';}else{bg='var(--green-pale)';tc='#006B52';}
      const count=r.filter(x=>x.probabilidad===p&&x.impacto===i).length;
      html+=`<div class="heat-cell" style="background:${bg};color:${tc};">${count>0?'●'.repeat(count):'·'}</div>`;
    }
  }
  html+='</div>';
  hm.innerHTML=html;
}

// ============================================================
// SESIÓN
// ============================================================
async function loadSesion(){
  const [{data:sesiones},{data:acuerdos}]=await Promise.all([
    supabase.from('sesiones').select('*').order('numero',{ascending:false}).limit(5),
    supabase.from('acuerdos').select('*,sesiones(numero)').order('numero'),
  ]);
  const s=sesiones||[]; const ac=acuerdos||[];
  const actual=s.find(x=>x.estado==='Programada')||s[0];
  if(actual) document.getElementById('sesion-titulo').textContent=`Sesión #${actual.numero} — ${fmtDate(actual.fecha)}`;
  document.getElementById('agenda-list').innerHTML=AGENDA_BASE.map(a=>`<div class="agenda-item">
    <div class="agenda-time">${a.time}</div>
    <div><div class="agenda-title">${a.title}</div><div class="agenda-desc">${a.desc}</div></div>
  </div>`).join('');
  document.getElementById('tbl-acuerdos').innerHTML=ac.filter(a=>a.sesiones?.numero===(actual?.numero)).map(a=>`<tr>
    <td style="color:var(--gray4);">${a.numero}</td>
    <td style="font-weight:500;font-size:12px;">${a.descripcion}</td>
    <td style="font-size:12px;">${a.responsable_txt||'—'}</td>
    <td style="font-size:11px;color:var(--gray4);">${fmtDate(a.fecha_compromiso)}</td>
    <td>${estadoBadge(a.estado)}</td>
  </tr>`).join('')||'<tr><td colspan="5" class="empty-state">Sin acuerdos registrados</td></tr>';
  document.getElementById('tbl-historial-sesiones').innerHTML=s.map(ses=>`<tr>
    <td class="td-bold">#${ses.numero}</td>
    <td>${estadoBadge(ses.tipo)}</td>
    <td>${fmtDate(ses.fecha)}</td>
    <td style="font-size:12px;">${ses.miembros_presentes||'—'}/9</td>
    <td>${estadoBadge(ses.estado)}</td>
  </tr>`).join('');
}

// ============================================================
// INFORME
// ============================================================
async function loadInforme(){
  const {data:proyectos}=await supabase.from('proyectos').select('*').eq('activo',true);
  const {data:riesgos}=await supabase.from('riesgos').select('*,proyectos(id_cipd)').neq('estado','Cerrado');
  const {data:acuerdos}=await supabase.from('acuerdos').select('*').eq('estado','Pendiente');
  const p=proyectos||[]; const r=riesgos||[]; const ac=acuerdos||[];
  const hoy=new Date(); const hace15=new Date(hoy-15*86400000);
  document.getElementById('informe-periodo').textContent=`Período: ${fmtDate(hace15)} – ${fmtDate(hoy)} · Preparado por: Secretaría Ejecutiva`;
  const logros=p.filter(x=>x.avance_pct>=80).map(x=>`Proyecto ${x.id_cipd} (${x.nombre}) — ${x.avance_pct}% completado, próximo: ${x.proximo_hito||'—'}.`);
  const bloqueos=r.filter(x=>x.nivel==='ALTO').map(x=>`${x.nombre} (${x.proyectos?.id_cipd||'—'}): ${x.plan_mitigacion||'Sin plan documentado'}.`);
  const pendientes=ac.map(a=>`${a.descripcion} — ${a.responsable_txt||'Sin responsable'} · ${fmtDate(a.fecha_compromiso)}`);
  document.getElementById('informe-body').innerHTML=`
    <div class="inf-section"><div class="inf-section-title" style="color:var(--green)">Logros del período</div>
    ${logros.length?logros.map(l=>`<div style="display:flex;gap:8px;padding:3px 0;"><span style="color:var(--green);flex-shrink:0;">✓</span><span style="color:var(--gray5);">${l}</span></div>`).join(''):'<div style="color:var(--gray4);font-size:12px;">Sin logros registrados en el período</div>'}</div>
    <div class="inf-section"><div class="inf-section-title" style="color:var(--red)">Riesgos y bloqueos activos</div>
    ${bloqueos.length?bloqueos.map(b=>`<div style="display:flex;gap:8px;padding:3px 0;"><span style="color:var(--amber);flex-shrink:0;">⚠</span><span style="color:var(--gray5);">${b}</span></div>`).join(''):'<div style="color:var(--gray4);font-size:12px;">Sin riesgos de nivel alto activos</div>'}</div>
    <div class="inf-section"><div class="inf-section-title" style="color:var(--blue)">Acuerdos pendientes</div>
    ${pendientes.length?pendientes.map(a=>`<div style="display:flex;gap:8px;padding:3px 0;"><span style="color:var(--blue);flex-shrink:0;">→</span><span style="color:var(--gray5);">${a}</span></div>`).join(''):'<div style="color:var(--gray4);font-size:12px;">Todos los acuerdos completados</div>'}</div>`;
  // KPIs
  const rojos=p.filter(x=>x.semaforo==='red').length;
  const verdes=p.filter(x=>x.semaforo==='green').length;
  const entregaPct=p.length?Math.round(verdes/p.length*100):0;
  document.getElementById('kpi-list').innerHTML=[
    {label:'Entrega a tiempo',val:`${entregaPct}%`,target:'≥ 80%',ok:entregaPct>=80,pct:entregaPct},
    {label:'Proyectos en rojo',val:rojos,target:'≤ 2',ok:rojos<=2,pct:rojos<=2?100:50},
    {label:'Riesgos ALTO activos',val:r.filter(x=>x.nivel==='ALTO').length,target:'≤ 3',ok:r.filter(x=>x.nivel==='ALTO').length<=3,pct:r.filter(x=>x.nivel==='ALTO').length<=3?100:50},
    {label:'Acuerdos pendientes',val:ac.length,target:'≤ 5',ok:ac.length<=5,pct:ac.length<=5?100:50},
  ].map(k=>`<div>
    <div style="display:flex;justify-content:space-between;margin-bottom:5px;">
      <span style="font-size:12px;">${k.label}</span>
      <span style="font-size:13px;font-weight:700;color:${k.ok?'var(--green)':'var(--amber)'};">${k.val} / meta ${k.target}</span>
    </div>
    <div class="prog-wrap"><div class="prog-fill ${k.ok?'prog-green':'prog-yellow'}" style="width:${k.pct}%"></div></div>
  </div>`).join('');
}
async function marcarInformeEnviado(){
  toast('Informe marcado como enviado a Gerencia General','ok');
}

// ============================================================
// CHECKLIST
// ============================================================
async function loadChecklist(){
  const {data,error}=await supabase.from('checklist').select('*').order('orden');
  if(error){toast(error.message,'err');return;}
  const items=data||[];
  const done=items.filter(x=>x.completado).length;
  const pct=items.length?Math.round(done/items.length*100):0;
  document.getElementById('chk-done').textContent=done;
  document.getElementById('chk-pending').textContent=items.length-done;
  document.getElementById('chk-pct').textContent=pct+'%';
  const bar=document.getElementById('chk-bar');
  if(bar){bar.style.width=pct+'%';bar.style.background=pct===100?'var(--green)':pct>50?'var(--teal)':'var(--blue)';}
  document.getElementById('checklist-items').innerHTML=items.map(item=>`
    <div class="check-item ${item.completado?'check-done':''}">
      <div class="check-box${item.completado?' checked':''}" onclick="toggleCheck('${item.id}',${!item.completado})" id="cb-${item.id}">${item.completado?'✓':''}</div>
      <div>
        <div class="check-text">${item.descripcion}</div>
        <div class="check-resp">${item.responsable||''} · ${item.plazo_label||''}</div>
      </div>
    </div>`).join('');
}
async function toggleCheck(id,val){
  const updates={completado:val};
  if(val){updates.completado_por=currentUser.id;updates.completado_at=new Date().toISOString();}
  else{updates.completado_por=null;updates.completado_at=null;}
  const {error}=await supabase.from('checklist').update(updates).eq('id',id);
  if(error){toast(error.message,'err');return;}
  loadChecklist();
}

// ============================================================
// MODALS
// ============================================================
function openModal(type){
  const bg=document.getElementById('modal-bg');
  const title=document.getElementById('modal-title');
  const body=document.getElementById('modal-body');
  const footer=document.getElementById('modal-footer');
  bg.classList.add('open');
  if(type==='nueva-solicitud'){
    title.textContent='Nueva solicitud de desarrollo';
    body.innerHTML=`<div class="form-row">
      <div class="form-group form-full"><label>Nombre de la iniciativa *</label><input type="text" id="sol-nombre" placeholder="Ej: Sistema de gestión de averías"/></div>
      <div class="form-group"><label>ID CIPD *</label><input type="text" id="sol-idcipd" placeholder="SOL-032"/></div>
      <div class="form-group"><label>ID Ticket GLPI</label><input type="text" id="sol-glpi" placeholder="#4920"/></div>
      <div class="form-group"><label>Gerencia solicitante *</label><select id="sol-gerencia"><option>Distribución</option><option>Comercial</option><option>TI</option><option>Financiero</option><option>RRHH</option><option>Legal</option><option>Planificación</option><option>Atención al Cliente</option></select></div>
      <div class="form-group"><label>Patrocinador interno</label><input type="text" id="sol-patrocinador"/></div>
      <div class="form-group"><label>Fecha límite deseada</label><input type="date" id="sol-fecha"/></div>
      <div class="form-group"><label>Presupuesto estimado (USD)</label><input type="number" id="sol-presupuesto" placeholder="0"/></div>
      <div class="form-group form-full"><label>Descripción del problema</label><textarea id="sol-problema" placeholder="Describe el problema o necesidad..."></textarea></div>
      <div class="form-group form-full"><label>Beneficio esperado</label><textarea id="sol-beneficio" placeholder="Beneficio cuantificable preferiblemente..."></textarea></div>
    </div>`;
    footer.innerHTML=`<button class="btn btn-outline" onclick="closeModal()">Cancelar</button><button class="btn btn-primary" onclick="saveSolicitud()">Registrar solicitud</button>`;
  }
  else if(type==='guardar-score'){
    const s=parseInt(document.getElementById('score-num').textContent)||0;
    if(s<5){toast('Completa todas las dimensiones primero','warn');closeModal();return;}
    title.textContent='Guardar evaluación en backlog';
    body.innerHTML=`<div class="alert alert-info">Score calculado: <strong>${s} puntos</strong> — ${s>=21?'CRÍTICO':s>=15?'ALTO':s>=9?'MEDIO':'BAJO'}</div>
    <div class="form-row">
      <div class="form-group form-full"><label>Vincular a solicitud existente</label><select id="gs-solicitud"><option value="">— Nueva solicitud —</option></select></div>
    </div>`;
    // Load solicitudes para selector
    supabase.from('solicitudes').select('id,id_cipd,nombre').then(({data})=>{
      if(data) document.getElementById('gs-solicitud').innerHTML='<option value="">— Nueva solicitud —</option>'+data.map(s=>`<option value="${s.id}">${s.id_cipd} — ${s.nombre}</option>`).join('');
    });
    footer.innerHTML=`<button class="btn btn-outline" onclick="closeModal()">Cancelar</button><button class="btn btn-primary" onclick="saveScore()">Guardar score</button>`;
  }
  else if(type==='nuevo-riesgo'){
    title.textContent='Registrar riesgo';
    body.innerHTML=`<div class="form-row">
      <div class="form-group form-full"><label>Descripción del riesgo *</label><input type="text" id="ri-nombre" placeholder="Describe el riesgo identificado"/></div>
      <div class="form-group"><label>Proyecto afectado *</label><select id="ri-proyecto"><option value="">Cargando...</option></select></div>
      <div class="form-group"><label>Tipo</label><select id="ri-tipo"><option>Técnico</option><option>Recursos</option><option>Regulatorio</option><option>Organizacional</option><option>Interdependencia</option><option>Financiero</option></select></div>
      <div class="form-group"><label>Probabilidad (1–5) *</label><select id="ri-prob"><option value="1">1 — Muy baja</option><option value="2">2 — Baja</option><option value="3">3 — Media</option><option value="4">4 — Alta</option><option value="5">5 — Muy alta</option></select></div>
      <div class="form-group"><label>Impacto (1–5) *</label><select id="ri-imp"><option value="1">1 — Mínimo</option><option value="2">2 — Bajo</option><option value="3">3 — Moderado</option><option value="4">4 — Alto</option><option value="5">5 — Crítico</option></select></div>
      <div class="form-group form-full"><label>Plan de mitigación</label><textarea id="ri-plan" placeholder="Acciones para reducir la probabilidad o impacto..."></textarea></div>
      <div class="form-group"><label>Responsable</label><input type="text" id="ri-resp" placeholder="Nombre o cargo"/></div>
      <div class="form-group"><label>Fecha revisión</label><input type="date" id="ri-fecha"/></div>
    </div>`;
    supabase.from('proyectos').select('id,id_cipd,nombre').eq('activo',true).then(({data})=>{
      if(data) document.getElementById('ri-proyecto').innerHTML=data.map(p=>`<option value="${p.id}">${p.id_cipd} — ${p.nombre.substring(0,30)}</option>`).join('');
    });
    footer.innerHTML=`<button class="btn btn-outline" onclick="closeModal()">Cancelar</button><button class="btn btn-primary" onclick="saveRiesgo()">Registrar riesgo</button>`;
  }
  else if(type==='nuevo-acuerdo'){
    title.textContent='Registrar acuerdo de sesión';
    body.innerHTML=`<div class="form-row">
      <div class="form-group form-full"><label>Descripción del acuerdo *</label><textarea id="ac-desc" placeholder="Describe el acuerdo tomado en sesión..."></textarea></div>
      <div class="form-group"><label>Responsable *</label><select id="ac-resp"><option>Gte. TI</option><option>Gte. Comercial</option><option>Gte. Distribución</option><option>Gte. Financiero</option><option>Gte. RRHH</option><option>Gte. Legal</option><option>Gte. Planificación</option><option>Gte. General</option><option>Secretaría CIPD</option></select></div>
      <div class="form-group"><label>Fecha compromiso</label><input type="date" id="ac-fecha"/></div>
    </div>`;
    footer.innerHTML=`<button class="btn btn-outline" onclick="closeModal()">Cancelar</button><button class="btn btn-primary" onclick="saveAcuerdo()">Guardar acuerdo</button>`;
  }
  else if(type==='nueva-sesion'){
    title.textContent='Convocar nueva sesión';
    body.innerHTML=`<div class="form-row">
      <div class="form-group"><label>Número de sesión *</label><input type="number" id="ses-num" placeholder="13"/></div>
      <div class="form-group"><label>Tipo *</label><select id="ses-tipo"><option>Ordinaria</option><option>Estratégica</option><option>Extraordinaria</option><option>Cierre</option></select></div>
      <div class="form-group"><label>Fecha *</label><input type="date" id="ses-fecha"/></div>
      <div class="form-group"><label>Hora inicio</label><input type="time" id="ses-hora" value="09:00"/></div>
      <div class="form-group"><label>Modalidad</label><select id="ses-modal"><option>Presencial</option><option>Virtual</option><option>Híbrida</option></select></div>
      <div class="form-group form-full"><label>Temas de la agenda</label><textarea id="ses-temas" placeholder="Lista los temas principales..."></textarea></div>
    </div>
    <div class="alert alert-warn">Recuerda enviar la convocatoria al menos 48 horas antes. Las solicitudes nuevas deben estar en el sistema 72 h antes.</div>`;
    footer.innerHTML=`<button class="btn btn-outline" onclick="closeModal()">Cancelar</button><button class="btn btn-primary" onclick="saveSesion()">Crear y enviar convocatoria</button>`;
  }
}
function closeModal(){document.getElementById('modal-bg').classList.remove('open');}

// ============================================================
// SAVE FUNCTIONS
// ============================================================
async function saveSolicitud(){
  const nombre=document.getElementById('sol-nombre').value.trim();
  const id_cipd=document.getElementById('sol-idcipd').value.trim();
  const gerencia=document.getElementById('sol-gerencia').value;
  if(!nombre||!id_cipd){toast('Nombre e ID CIPD son obligatorios','warn');return;}
  const {error}=await supabase.from('solicitudes').insert({
    nombre, id_cipd, gerencia,
    id_glpi: document.getElementById('sol-glpi').value||null,
    patrocinador: document.getElementById('sol-patrocinador').value||null,
    fecha_limite: document.getElementById('sol-fecha').value||null,
    presupuesto_usd: parseFloat(document.getElementById('sol-presupuesto').value)||null,
    problema: document.getElementById('sol-problema').value||null,
    beneficio: document.getElementById('sol-beneficio').value||null,
    estado:'Pendiente', created_by: currentUser.id
  });
  if(error){toast(error.message,'err');return;}
  closeModal(); toast(`Solicitud ${id_cipd} registrada en backlog`,'ok');
  loadBacklog();
}

async function saveScore(){
  const s=parseInt(document.getElementById('score-num').textContent)||0;
  const solId=document.getElementById('gs-solicitud').value;
  if(solId){
    const updates={dim_operativo:dimVals.op,dim_comercial:dimVals.com,dim_regulatorio:dimVals.reg,dim_estrategico:dimVals.est,dim_urgencia:dimVals.urg,mod_regulatorio:document.getElementById('mod-reg').checked,mod_dependencia:document.getElementById('mod-dep').checked,mod_sin_recursos:document.getElementById('mod-sin').checked,mod_duplicado:document.getElementById('mod-dup').checked};
    const {error}=await supabase.from('solicitudes').update(updates).eq('id',solId);
    if(error){toast(error.message,'err');return;}
    toast(`Score ${s} guardado en la solicitud`,'ok');
  } else {
    toast(`Score ${s} calculado. Crea primero la solicitud para vincularlo.`,'warn');
  }
  closeModal();
}

async function saveRiesgo(){
  const nombre=document.getElementById('ri-nombre').value.trim();
  const proyecto_id=document.getElementById('ri-proyecto').value;
  if(!nombre||!proyecto_id){toast('Nombre y proyecto son obligatorios','warn');return;}
  const {error}=await supabase.from('riesgos').insert({
    nombre, proyecto_id,
    tipo: document.getElementById('ri-tipo').value,
    probabilidad: parseInt(document.getElementById('ri-prob').value),
    impacto: parseInt(document.getElementById('ri-imp').value),
    plan_mitigacion: document.getElementById('ri-plan').value||null,
    responsable: document.getElementById('ri-resp').value||null,
    fecha_revision: document.getElementById('ri-fecha').value||null,
    created_by: currentUser.id
  });
  if(error){toast(error.message,'err');return;}
  closeModal(); toast('Riesgo registrado en el mapa','ok'); loadRiesgos();
}

async function saveAcuerdo(){
  const desc=document.getElementById('ac-desc').value.trim();
  if(!desc){toast('La descripción es obligatoria','warn');return;}
  const {data:ses}=await supabase.from('sesiones').select('id,numero').order('numero',{ascending:false}).limit(1).single();
  if(!ses){toast('No hay sesión registrada. Crea una sesión primero.','warn');return;}
  const {data:existing}=await supabase.from('acuerdos').select('numero').eq('sesion_id',ses.id).order('numero',{ascending:false}).limit(1).single();
  const numero=(existing?.numero||0)+1;
  const {error}=await supabase.from('acuerdos').insert({
    sesion_id: ses.id, numero, descripcion: desc,
    responsable_txt: document.getElementById('ac-resp').value,
    fecha_compromiso: document.getElementById('ac-fecha').value||null,
  });
  if(error){toast(error.message,'err');return;}
  closeModal(); toast(`Acuerdo #${numero} registrado en acta`,'ok'); loadSesion();
}

async function saveSesion(){
  const num=parseInt(document.getElementById('ses-num').value);
  const fecha=document.getElementById('ses-fecha').value;
  if(!num||!fecha){toast('Número y fecha son obligatorios','warn');return;}
  const {error}=await supabase.from('sesiones').insert({
    numero:num, tipo:document.getElementById('ses-tipo').value,
    fecha, hora_inicio:document.getElementById('ses-hora').value||null,
    modalidad:document.getElementById('ses-modal').value,
    temas:document.getElementById('ses-temas').value||null,
    estado:'Programada', created_by:currentUser.id
  });
  if(error){toast(error.message,'err');return;}
  closeModal(); toast(`Sesión #${num} creada. Convocatoria enviada.`,'ok'); loadSesion();
}

// ============================================================
// TOAST
// ============================================================
function toast(msg,type='ok'){
  const w=document.getElementById('toast-wrap');
  const t=document.createElement('div');
  t.className=`toast toast-${type}`;
  t.innerHTML=`<span>${type==='ok'?'✓':type==='warn'?'⚠':'✕'}</span>${msg}`;
  w.appendChild(t);
  setTimeout(()=>t.remove(),3200);
}

// ============================================================
// BOOT
// ============================================================
(async()=>{
  const {url,key}=getSavedConfig();
  if(!url||!key){
    document.getElementById('config-banner').style.display='flex';
    return;
  }
  initSupabase(url,key);
  document.getElementById('config-banner').style.display='none';
  showLoading();
  const {data:{session}}=await supabase.auth.getSession();
  hideLoading();
  if(session){
    await afterLogin(session.user);
  } else {
    document.getElementById('auth-screen').style.display='flex';
  }
  supabase.auth.onAuthStateChange(async(event,session)=>{
    if(event==='SIGNED_IN'&&session) await afterLogin(session.user);
    if(event==='SIGNED_OUT'){
      document.getElementById('app-shell').style.display='none';
      document.getElementById('auth-screen').style.display='flex';
    }
  });
})();
</script>
</body>
</html>
