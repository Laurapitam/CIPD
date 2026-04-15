-- ============================================================
-- CIPD — Secretaría Ejecutiva
-- Script SQL completo para Supabase
-- Pegar en: Supabase > SQL Editor > New query > Run
-- ============================================================

-- ============================================================
-- 1. EXTENSIONES
-- ============================================================
create extension if not exists "uuid-ossp";

-- ============================================================
-- 2. TABLA DE PERFILES DE USUARIO
--    Vinculada a auth.users de Supabase
-- ============================================================
create table public.perfiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  nombre       text not null,
  cargo        text,
  gerencia     text not null,
  rol          text not null default 'vocal',
  -- roles: 'presidente' | 'vicepresidente' | 'secretario' | 'vocal' | 'invitado'
  activo       boolean not null default true,
  avatar_url   text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

comment on table public.perfiles is 'Perfil extendido de cada usuario del CIPD';

-- ============================================================
-- 3. TABLA DE SOLICITUDES / BACKLOG
-- ============================================================
create table public.solicitudes (
  id               uuid primary key default uuid_generate_v4(),
  id_cipd          text unique not null,      -- ej: SOL-031
  id_glpi          text,                       -- ej: #4892
  nombre           text not null,
  descripcion      text,
  gerencia         text not null,
  solicitante_id   uuid references public.perfiles(id),
  patrocinador     text,
  problema         text,
  beneficio        text,
  recursos_dias    integer,
  presupuesto_usd  numeric(12,2),
  dependencias     text,
  fecha_limite     date,
  -- Dimensiones de la matriz (1-5)
  dim_operativo    integer check (dim_operativo between 1 and 5),
  dim_comercial    integer check (dim_comercial between 1 and 5),
  dim_regulatorio  integer check (dim_regulatorio between 1 and 5),
  dim_estrategico  integer check (dim_estrategico between 1 and 5),
  dim_urgencia     integer check (dim_urgencia between 1 and 5),
  -- Modificadores
  mod_regulatorio  boolean default false,   -- +2
  mod_dependencia  boolean default false,   -- +1
  mod_sin_recursos boolean default false,   -- -1
  mod_duplicado    boolean default false,   -- -2
  score            integer generated always as (
    coalesce(dim_operativo,0) + coalesce(dim_comercial,0) +
    coalesce(dim_regulatorio,0) + coalesce(dim_estrategico,0) +
    coalesce(dim_urgencia,0) +
    (case when mod_regulatorio then 2 else 0 end) +
    (case when mod_dependencia then 1 else 0 end) -
    (case when mod_sin_recursos then 1 else 0 end) -
    (case when mod_duplicado then 2 else 0 end)
  ) stored,
  nivel            text generated always as (
    case
      when (coalesce(dim_operativo,0)+coalesce(dim_comercial,0)+coalesce(dim_regulatorio,0)+coalesce(dim_estrategico,0)+coalesce(dim_urgencia,0)+(case when mod_regulatorio then 2 else 0 end)+(case when mod_dependencia then 1 else 0 end)-(case when mod_sin_recursos then 1 else 0 end)-(case when mod_duplicado then 2 else 0 end)) >= 21 then 'CRÍTICO'
      when (coalesce(dim_operativo,0)+coalesce(dim_comercial,0)+coalesce(dim_regulatorio,0)+coalesce(dim_estrategico,0)+coalesce(dim_urgencia,0)+(case when mod_regulatorio then 2 else 0 end)+(case when mod_dependencia then 1 else 0 end)-(case when mod_sin_recursos then 1 else 0 end)-(case when mod_duplicado then 2 else 0 end)) >= 15 then 'ALTO'
      when (coalesce(dim_operativo,0)+coalesce(dim_comercial,0)+coalesce(dim_regulatorio,0)+coalesce(dim_estrategico,0)+coalesce(dim_urgencia,0)+(case when mod_regulatorio then 2 else 0 end)+(case when mod_dependencia then 1 else 0 end)-(case when mod_sin_recursos then 1 else 0 end)-(case when mod_duplicado then 2 else 0 end)) >= 9  then 'MEDIO'
      else 'BAJO'
    end
  ) stored,
  estado           text not null default 'Pendiente',
  -- estados: 'Pendiente' | 'En evaluación' | 'Aprobado' | 'Rechazado' | 'Aplazado'
  motivo_rechazo   text,
  created_by       uuid references public.perfiles(id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ============================================================
-- 4. TABLA DE PROYECTOS ACTIVOS
-- ============================================================
create table public.proyectos (
  id               uuid primary key default uuid_generate_v4(),
  id_cipd          text unique not null,       -- ej: TI-018
  id_glpi          text,
  solicitud_id     uuid references public.solicitudes(id),
  nombre           text not null,
  descripcion      text,
  gerencia         text not null,
  lider_id         uuid references public.perfiles(id),
  lider_nombre     text,                        -- campo libre si el líder no tiene perfil
  avance_pct       integer not null default 0 check (avance_pct between 0 and 100),
  fecha_inicio     date,
  fecha_entrega    date,
  proximo_hito     text,
  presupuesto_usd  numeric(12,2),
  presupuesto_ejec numeric(12,2) default 0,
  -- Semáforo: 'green' | 'yellow' | 'red'
  semaforo         text not null default 'green',
  -- Perfil GLPI: 'A' | 'B' | 'C' | 'D'
  perfil_glpi      text not null default 'A',
  bloqueos         text,
  notas            text,
  activo           boolean not null default true,
  created_by       uuid references public.perfiles(id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ============================================================
-- 5. TABLA DE RIESGOS
-- ============================================================
create table public.riesgos (
  id               uuid primary key default uuid_generate_v4(),
  proyecto_id      uuid references public.proyectos(id) on delete cascade,
  nombre           text not null,
  tipo             text,
  -- tipos: 'Técnico' | 'Recursos' | 'Regulatorio' | 'Organizacional' | 'Interdependencia' | 'Financiero'
  probabilidad     integer not null check (probabilidad between 1 and 5),
  impacto          integer not null check (impacto between 1 and 5),
  nivel            text generated always as (
    case
      when probabilidad * impacto >= 16 then 'ALTO'
      when probabilidad * impacto >= 9  then 'MEDIO'
      else 'BAJO'
    end
  ) stored,
  estado           text not null default 'Activo',
  -- estados: 'Activo' | 'Mitigando' | 'Monitoreando' | 'Cerrado'
  plan_mitigacion  text,
  responsable      text,
  fecha_revision   date,
  created_by       uuid references public.perfiles(id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ============================================================
-- 6. TABLA DE SESIONES
-- ============================================================
create table public.sesiones (
  id               uuid primary key default uuid_generate_v4(),
  numero           integer not null,
  tipo             text not null default 'Ordinaria',
  -- tipos: 'Ordinaria' | 'Estratégica' | 'Extraordinaria' | 'Cierre'
  fecha            date not null,
  hora_inicio      time,
  modalidad        text default 'Presencial',
  quorum_valido    boolean default false,
  miembros_presentes integer default 0,
  estado           text not null default 'Programada',
  -- estados: 'Programada' | 'En curso' | 'Finalizada' | 'Cancelada'
  temas            text,
  observaciones    text,
  created_by       uuid references public.perfiles(id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ============================================================
-- 7. TABLA DE ASISTENCIA A SESIONES
-- ============================================================
create table public.asistencia (
  id          uuid primary key default uuid_generate_v4(),
  sesion_id   uuid references public.sesiones(id) on delete cascade,
  perfil_id   uuid references public.perfiles(id) on delete cascade,
  asistio     boolean default false,
  tiene_voto  boolean default true,
  unique(sesion_id, perfil_id)
);

-- ============================================================
-- 8. TABLA DE ACUERDOS
-- ============================================================
create table public.acuerdos (
  id               uuid primary key default uuid_generate_v4(),
  sesion_id        uuid references public.sesiones(id) on delete cascade,
  numero           integer not null,
  descripcion      text not null,
  responsable_id   uuid references public.perfiles(id),
  responsable_txt  text,                        -- campo libre alternativo
  proyecto_id      uuid references public.proyectos(id),
  fecha_compromiso date,
  estado           text not null default 'Pendiente',
  -- estados: 'Pendiente' | 'En proceso' | 'Completado' | 'Vencido'
  notas_cierre     text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ============================================================
-- 9. TABLA DE VOTACIONES EN SESIÓN
-- ============================================================
create table public.votaciones (
  id               uuid primary key default uuid_generate_v4(),
  sesion_id        uuid references public.sesiones(id) on delete cascade,
  solicitud_id     uuid references public.solicitudes(id),
  descripcion      text not null,
  resultado        text,
  -- resultados: 'Aprobado' | 'Rechazado' | 'Aplazado' | 'Más información'
  votos_favor      integer default 0,
  votos_contra     integer default 0,
  votos_abstencion integer default 0,
  notas            text,
  created_at       timestamptz not null default now()
);

-- ============================================================
-- 10. TABLA DE CHECKLIST CONSTITUTIVO
-- ============================================================
create table public.checklist (
  id               uuid primary key default uuid_generate_v4(),
  orden            integer not null,
  descripcion      text not null,
  responsable      text,
  plazo_label      text,
  completado       boolean not null default false,
  completado_por   uuid references public.perfiles(id),
  completado_at    timestamptz,
  created_at       timestamptz not null default now()
);

-- ============================================================
-- 11. TABLA DE INFORMES EJECUTIVOS
-- ============================================================
create table public.informes (
  id               uuid primary key default uuid_generate_v4(),
  sesion_id        uuid references public.sesiones(id),
  periodo_inicio   date,
  periodo_fin      date,
  logros           jsonb default '[]',
  riesgos_activos  jsonb default '[]',
  decisiones       jsonb default '[]',
  escalamientos    jsonb default '[]',
  kpi_entrega_pct  numeric(5,2),
  kpi_acuerdos_pct numeric(5,2),
  kpi_evaluacion_dias numeric(5,1),
  kpi_proyectos_rojo integer,
  kpi_sincronia_pct numeric(5,2),
  estado           text default 'Borrador',
  -- estados: 'Borrador' | 'Enviado'
  enviado_at       timestamptz,
  created_by       uuid references public.perfiles(id),
  created_at       timestamptz not null default now()
);

-- ============================================================
-- 12. TRIGGERS: updated_at automático
-- ============================================================
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_perfiles_updated_at       before update on public.perfiles       for each row execute function public.set_updated_at();
create trigger trg_solicitudes_updated_at    before update on public.solicitudes    for each row execute function public.set_updated_at();
create trigger trg_proyectos_updated_at      before update on public.proyectos      for each row execute function public.set_updated_at();
create trigger trg_riesgos_updated_at        before update on public.riesgos        for each row execute function public.set_updated_at();
create trigger trg_sesiones_updated_at       before update on public.sesiones       for each row execute function public.set_updated_at();
create trigger trg_acuerdos_updated_at       before update on public.acuerdos       for each row execute function public.set_updated_at();

-- ============================================================
-- 13. TRIGGER: crear perfil automáticamente al registrar usuario
-- ============================================================
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.perfiles (id, nombre, gerencia, rol)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nombre', split_part(new.email,'@',1)),
    coalesce(new.raw_user_meta_data->>'gerencia', 'Sin asignar'),
    coalesce(new.raw_user_meta_data->>'rol', 'vocal')
  );
  return new;
end;
$$;

create trigger trg_on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- 14. ROW LEVEL SECURITY (RLS)
-- ============================================================
alter table public.perfiles      enable row level security;
alter table public.solicitudes   enable row level security;
alter table public.proyectos     enable row level security;
alter table public.riesgos       enable row level security;
alter table public.sesiones      enable row level security;
alter table public.asistencia    enable row level security;
alter table public.acuerdos      enable row level security;
alter table public.votaciones    enable row level security;
alter table public.checklist     enable row level security;
alter table public.informes      enable row level security;

-- Todos los usuarios autenticados leen todo
create policy "Usuarios autenticados pueden leer perfiles"      on public.perfiles      for select using (auth.role() = 'authenticated');
create policy "Usuarios autenticados pueden leer solicitudes"   on public.solicitudes   for select using (auth.role() = 'authenticated');
create policy "Usuarios autenticados pueden leer proyectos"     on public.proyectos     for select using (auth.role() = 'authenticated');
create policy "Usuarios autenticados pueden leer riesgos"       on public.riesgos       for select using (auth.role() = 'authenticated');
create policy "Usuarios autenticados pueden leer sesiones"      on public.sesiones      for select using (auth.role() = 'authenticated');
create policy "Usuarios autenticados pueden leer asistencia"    on public.asistencia    for select using (auth.role() = 'authenticated');
create policy "Usuarios autenticados pueden leer acuerdos"      on public.acuerdos      for select using (auth.role() = 'authenticated');
create policy "Usuarios autenticados pueden leer votaciones"    on public.votaciones    for select using (auth.role() = 'authenticated');
create policy "Usuarios autenticados pueden leer checklist"     on public.checklist     for select using (auth.role() = 'authenticated');
create policy "Usuarios autenticados pueden leer informes"      on public.informes      for select using (auth.role() = 'authenticated');

-- Cada usuario edita su propio perfil
create policy "Usuario edita su propio perfil"
  on public.perfiles for update using (auth.uid() = id);

-- Secretario y Presidente pueden insertar/actualizar/eliminar todo
create policy "Secretario y Presidente gestionan solicitudes"
  on public.solicitudes for all
  using (exists (select 1 from public.perfiles where id = auth.uid() and rol in ('secretario','presidente')));

create policy "Secretario y Presidente gestionan proyectos"
  on public.proyectos for all
  using (exists (select 1 from public.perfiles where id = auth.uid() and rol in ('secretario','presidente')));

create policy "Secretario y Presidente gestionan riesgos"
  on public.riesgos for all
  using (exists (select 1 from public.perfiles where id = auth.uid() and rol in ('secretario','presidente')));

create policy "Secretario y Presidente gestionan sesiones"
  on public.sesiones for all
  using (exists (select 1 from public.perfiles where id = auth.uid() and rol in ('secretario','presidente')));

create policy "Secretario y Presidente gestionan acuerdos"
  on public.acuerdos for all
  using (exists (select 1 from public.perfiles where id = auth.uid() and rol in ('secretario','presidente')));

create policy "Secretario y Presidente gestionan votaciones"
  on public.votaciones for all
  using (exists (select 1 from public.perfiles where id = auth.uid() and rol in ('secretario','presidente')));

create policy "Secretario y Presidente gestionan checklist"
  on public.checklist for all
  using (exists (select 1 from public.perfiles where id = auth.uid() and rol in ('secretario','presidente')));

create policy "Secretario y Presidente gestionan informes"
  on public.informes for all
  using (exists (select 1 from public.perfiles where id = auth.uid() and rol in ('secretario','presidente')));

-- Vocales pueden insertar solicitudes
create policy "Cualquier miembro puede crear solicitudes"
  on public.solicitudes for insert
  with check (auth.role() = 'authenticated');

-- ============================================================
-- 15. DATOS INICIALES — CHECKLIST CONSTITUTIVO
-- ============================================================
insert into public.checklist (orden, descripcion, responsable, plazo_label) values
(1,  'Exportar tickets activos GLPI con categoría Desarrollo / Cambio',                              'Admin GLPI',                        'Día 1'),
(2,  'Revisar cada ticket con el técnico asignado y completar la Ficha de Incorporación',             'Secretario Ejecutivo + Gte. TI',     'Días 2–4'),
(3,  'Identificar proyectos sin líder asignado, sin fecha de entrega o sin presupuesto',              'Secretario Ejecutivo',               'Día 3'),
(4,  'Aplicar la Matriz de Criticidad CIPD a cada proyecto existente',                               'Secretario Ejecutivo',               'Días 4–5'),
(5,  'Clasificar cada proyecto en perfil A (control), B (riesgo), C (crítico) o D (revisar)',         'Secretario Ejecutivo',               'Día 5'),
(6,  'Construir el tablero inicial del portafolio con todos los proyectos clasificados',              'Secretario Ejecutivo',               'Días 6–7'),
(7,  'Preparar propuesta de líderes para proyectos sin responsable designado',                        'Gte. TI + Gte. Planificación',       'Día 7'),
(8,  'Definir fechas de entrega tentativas para proyectos que no las tienen',                         'Gte. TI + Gerencias responsables',   'Días 7–8'),
(9,  'Preparar agenda de sesión constitutiva con el portafolio completo adjunto',                     'Secretario Ejecutivo',               'Día 9'),
(10, 'Enviar convocatoria formal a todos los miembros del Comité (48 h de anticipación)',              'Secretario Ejecutivo',               'Día 10'),
(11, 'Sesión constitutiva: ratificar portafolio, asignar líderes y aprobar backlog inicial',          'Todos los miembros CIPD',            'Días 12–15');

-- ============================================================
-- 16. DATOS DE EJEMPLO — SOLICITUDES
-- ============================================================
insert into public.solicitudes
  (id_cipd, id_glpi, nombre, gerencia, dim_operativo, dim_comercial, dim_regulatorio, dim_estrategico, dim_urgencia, mod_regulatorio, estado)
values
  ('SOL-031','#4892','Sistema GIS distribución red',         'Distribución', 5,4,5,5,4, true,  'En evaluación'),
  ('SOL-029','#4901','Automatización cortes y reconexiones', 'Distribución', 5,4,4,4,4, false, 'En evaluación'),
  ('SOL-030','#4888','Módulo gestión pérdidas técnicas',     'TI',           4,3,4,4,3, false, 'Aprobado'),
  ('SOL-028','#4875','CRM clientes masivos',                 'Comercial',    3,4,3,4,3, false, 'Aprobado'),
  ('SOL-026','#4862','Integración SAP-SCADA',                'TI',           4,3,3,3,3, false, 'En evaluación'),
  ('SOL-025','#4849','App móvil lectura de medidores',       'Comercial',    2,3,2,3,3, false, 'Pendiente'),
  ('SOL-024','#4836','Capacitación LMS personal técnico',    'RRHH',         1,1,2,3,2, false, 'Pendiente'),
  ('SOL-023','#4822','Rediseño intranet corporativa',        'TI',           1,1,1,2,1, false, 'Pendiente');

-- ============================================================
-- 17. DATOS DE EJEMPLO — PROYECTOS
-- ============================================================
insert into public.proyectos
  (id_cipd, id_glpi, nombre, gerencia, lider_nombre, avance_pct, fecha_entrega, proximo_hito, semaforo, perfil_glpi, presupuesto_usd)
values
  ('TI-018',    '#4821', 'Migración BD Regulatoria',            'TI',           'R. Mejía',    45, '2025-04-15', 'Entrega datos Q1',          'red',    'C', 35000),
  ('GDist-024', '#4856', 'Modernización subestaciones zona sur','Distribución', 'C. Andrade',  10, '2025-06-30', 'Diseño conceptual',         'green',  'A', 85000),
  ('GCom-019',  '#4780', 'Portal atención al cliente',          'Comercial',    'L. Paz',      88, '2025-04-25', 'UAT final',                 'green',  'A', 22000),
  ('TI-021',    '#4834', 'Actualización SCADA',                 'TI',           'M. Torres',   55, '2025-04-30', 'Módulo alarmas',            'yellow', 'B', 48000),
  ('AMR-003',   '#4802', 'Integración medidores AMI',           'Distribución', 'J. Flores',   62, '2025-05-15', 'Piloto zona norte',         'yellow', 'B', 67000),
  ('FIN-009',   '#4845', 'Conciliación bancaria automática',    'Financiero',   'A. Ramos',    30, '2025-05-31', 'Reglas conciliación',       'yellow', 'B', 18000),
  ('TI-022',    '#4871', 'Seguridad perimetral red',            'TI',           'H. Soto',     70, '2025-04-10', 'Firewall zona DMZ',         'red',    'C', 29000),
  ('GCom-027',  '#4880', 'Medición inteligente tarifas',        'Comercial',    'P. Girón',    15, '2025-07-30', 'Análisis tarifario',        'green',  'A', 41000),
  ('GDist-020', '#4798', 'GIS red distribución',                'Distribución', '—',            0, null,         'Sin asignar',               'red',    'C', null),
  ('RRHH-005',  '#4812', 'LMS capacitación técnica',            'RRHH',         'S. López',    40, '2025-06-15', 'Módulo seguridad eléctrica','green',  'A', 12000),
  ('LEG-002',   '#4855', 'Sistema gestión contratos',           'Legal',        'T. Reyes',    25, '2025-07-30', 'Prototipo flujos',          'yellow', 'B', 15000),
  ('FIN-011',   '#4890', 'Dashboard financiero gerencial',      'Financiero',   'E. Cruz',     60, '2025-05-20', 'Módulo proyecciones',       'green',  'A', 9000);

-- ============================================================
-- 18. DATOS DE EJEMPLO — RIESGOS
-- ============================================================
insert into public.riesgos (proyecto_id, nombre, tipo, probabilidad, impacto, estado, plan_mitigacion, responsable)
select p.id, r.nombre, r.tipo, r.prob, r.imp, r.estado, r.plan, r.resp
from (values
  ('TI-018',    'Retraso proveedor BD Regulatoria',      'Técnico',         4, 4, 'Activo',       'Evaluar proveedor alternativo',              'Gte. TI'),
  ('AMR-003',   'Atraso importación hardware AMR',       'Recursos',        3, 4, 'Mitigando',    'Gestión aduanal urgente',                    'Gte. Distribución'),
  ('TI-022',    'Capacidad equipo TI al límite',         'Recursos',        4, 3, 'Activo',       'Solicitud horas extra pendiente',            'Gte. TI'),
  ('GDist-024', 'Cambio normativa CREE pendiente',       'Regulatorio',     2, 5, 'Monitoreando', 'Seguimiento activo con Gerencia Legal',      'Gte. Legal'),
  ('FIN-009',   'Rotación líder proyecto FIN-009',       'Organizacional',  2, 3, 'Mitigando',    'Plan de sucesión en preparación',            'Gte. RRHH')
) as r(id_cipd, nombre, tipo, prob, imp, estado, plan, resp)
join public.proyectos p on p.id_cipd = r.id_cipd;

-- ============================================================
-- 19. DATOS DE EJEMPLO — SESIÓN INICIAL
-- ============================================================
insert into public.sesiones (numero, tipo, fecha, hora_inicio, quorum_valido, miembros_presentes, estado, temas)
values
  (12, 'Ordinaria',   '2025-04-14', '09:00', true,  7, 'Programada', 'Revisión portafolio activo, evaluación SOL-031 y SOL-029, bloqueos TI-018 y TI-022'),
  (11, 'Ordinaria',   '2025-03-05', '09:00', true,  8, 'Finalizada', null),
  (10, 'Ordinaria',   '2025-02-19', '09:00', true,  9, 'Finalizada', null),
  (9,  'Estratégica', '2025-02-05', '09:00', true,  9, 'Finalizada', null);

-- ============================================================
-- 20. DATOS DE EJEMPLO — ACUERDOS
-- ============================================================
insert into public.acuerdos (sesion_id, numero, descripcion, responsable_txt, fecha_compromiso, estado)
select s.id, a.num, a.desc, a.resp, a.fecha::date, a.estado
from (values
  (12, 1, 'Aprobar SOL-031 para inicio Q2',                              'Gte. Planificación', '2025-04-03', 'Pendiente'),
  (12, 2, 'Contratar proveedor alternativo para BD Regulatoria',         'Gte. TI',            '2025-03-25', 'En proceso'),
  (12, 3, 'Solicitar presupuesto adicional USD 85,000 a Gte. General',   'Secretaría',         '2025-03-22', 'En proceso'),
  (12, 4, 'Validar UAT Portal Cliente con Gerencia Comercial',           'Gte. Comercial',     '2025-03-24', 'Completado')
) as a(num_ses, num, desc, resp, fecha, estado)
join public.sesiones s on s.numero = a.num_ses;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
