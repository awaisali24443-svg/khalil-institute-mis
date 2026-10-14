-- ============================================================
-- KIN Management System — Cloud migration (Supabase / Postgres)
-- Run ONCE in Supabase Dashboard -> SQL Editor -> New query -> Run.
-- Creates: 27 tables, role helpers, Row Level Security policies,
--          auto-profile trigger for new auth users.
-- Roles: admin, accountant, teacher, reception, student, pending
-- ============================================================

-- ---------- tables ----------
-- cnic-keyed (app uses CNIC as the record key)
create table if not exists public.students  (key text primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.employees (key text primary key, data jsonb not null, updated_at timestamptz default now());
-- id-keyed
create table if not exists public.profiles      (id uuid primary key references auth.users(id) on delete cascade, role text not null default 'pending', cnic text, created_at timestamptz default now());
create table if not exists public.fee_heads     (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.challans      (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.payments      (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.expenses      (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.sessions      (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.attendance    (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.settings      (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.subjects      (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.timetable     (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.exams         (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.exam_students (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.marks         (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.letters       (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.hospitals     (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.trainees      (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.visitors      (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.events        (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.problems      (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.cvs           (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.books         (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.book_issues   (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.stock_cats    (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());
create table if not exists public.stock_items   (id bigserial primary key, data jsonb not null, updated_at timestamptz default now());

-- ---------- grants (RLS policies below do the real gating) ----------
grant usage on schema public to anon, authenticated;
grant all on all tables in schema public to anon, authenticated;
grant all on all sequences in schema public to anon, authenticated;
alter default privileges in schema public grant all on tables to anon, authenticated;
alter default privileges in schema public grant all on sequences to anon, authenticated;

-- ---------- helpers (after tables: function bodies reference profiles) ----------
create or replace function public.my_role() returns text
language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.my_cnic() returns text
language sql stable security definer set search_path = public as $$
  select cnic from public.profiles where id = auth.uid();
$$;

-- ---------- RLS on ----------
alter table public.profiles      enable row level security;
alter table public.students      enable row level security;
alter table public.employees     enable row level security;
alter table public.fee_heads     enable row level security;
alter table public.challans      enable row level security;
alter table public.payments      enable row level security;
alter table public.expenses      enable row level security;
alter table public.sessions      enable row level security;
alter table public.attendance    enable row level security;
alter table public.settings      enable row level security;
alter table public.subjects      enable row level security;
alter table public.timetable     enable row level security;
alter table public.exams         enable row level security;
alter table public.exam_students enable row level security;
alter table public.marks         enable row level security;
alter table public.letters       enable row level security;
alter table public.hospitals     enable row level security;
alter table public.trainees      enable row level security;
alter table public.visitors      enable row level security;
alter table public.events        enable row level security;
alter table public.problems      enable row level security;
alter table public.cvs           enable row level security;
alter table public.books         enable row level security;
alter table public.book_issues   enable row level security;
alter table public.stock_cats    enable row level security;
alter table public.stock_items   enable row level security;

-- ---------- profiles ----------
create policy "profiles self read, admin all" on public.profiles for select
  using (id = auth.uid() or public.my_role() = 'admin');
create policy "profiles admin write" on public.profiles for all
  using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

-- ---------- students ----------
create policy "students read" on public.students for select
  using (public.my_role() in ('admin','accountant','reception','teacher')
         or (public.my_role() = 'student' and key = public.my_cnic()));
create policy "students write" on public.students for insert
  with check (public.my_role() in ('admin','reception'));
create policy "students update" on public.students for update
  using (public.my_role() in ('admin','reception')) with check (public.my_role() in ('admin','reception'));
create policy "students delete" on public.students for delete
  using (public.my_role() = 'admin');

-- ---------- employees ----------
create policy "employees read" on public.employees for select
  using (public.my_role() in ('admin','accountant')
         or (public.my_role() = 'teacher' and key = public.my_cnic()));
create policy "employees write" on public.employees for all
  using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

-- ---------- finance: fee_heads, challans, payments, expenses ----------
create policy "fee_heads staff" on public.fee_heads for all
  using (public.my_role() in ('admin','accountant')) with check (public.my_role() in ('admin','accountant'));

create policy "challans read" on public.challans for select
  using (public.my_role() in ('admin','accountant')
         or (public.my_role() = 'student' and data->>'cnic' = public.my_cnic()));
create policy "challans write" on public.challans for all
  using (public.my_role() in ('admin','accountant')) with check (public.my_role() in ('admin','accountant'));

create policy "payments read" on public.payments for select
  using (public.my_role() in ('admin','accountant')
         or (public.my_role() = 'student' and data->>'cnic' = public.my_cnic()));
create policy "payments write" on public.payments for all
  using (public.my_role() in ('admin','accountant')) with check (public.my_role() in ('admin','accountant'));

create policy "expenses staff" on public.expenses for all
  using (public.my_role() in ('admin','accountant')) with check (public.my_role() in ('admin','accountant'));

-- ---------- academics: subjects, timetable, exams, exam_students ----------
create policy "subjects read" on public.subjects for select
  using (auth.role() = 'authenticated');
create policy "subjects write" on public.subjects for all
  using (public.my_role() in ('admin','teacher')) with check (public.my_role() in ('admin','teacher'));

create policy "timetable read" on public.timetable for select
  using (auth.role() = 'authenticated');
create policy "timetable write" on public.timetable for all
  using (public.my_role() in ('admin','teacher')) with check (public.my_role() in ('admin','teacher'));

create policy "exams read" on public.exams for select
  using (auth.role() = 'authenticated');
create policy "exams write" on public.exams for all
  using (public.my_role() in ('admin','teacher')) with check (public.my_role() in ('admin','teacher'));

create policy "exam_students read" on public.exam_students for select
  using (auth.role() = 'authenticated');
create policy "exam_students write" on public.exam_students for all
  using (public.my_role() in ('admin','teacher')) with check (public.my_role() in ('admin','teacher'));

-- ---------- marks ----------
create policy "marks read" on public.marks for select
  using (public.my_role() in ('admin','teacher','accountant')
         or (public.my_role() = 'student' and data->>'cnic' = public.my_cnic()));
create policy "marks write" on public.marks for all
  using (public.my_role() in ('admin','teacher')) with check (public.my_role() in ('admin','teacher'));

-- ---------- attendance ----------
create policy "attendance read" on public.attendance for select
  using (public.my_role() in ('admin','accountant','teacher')
         or (public.my_role() = 'student' and data->>'ref' = public.my_cnic()));
create policy "attendance write" on public.attendance for insert
  with check (public.my_role() in ('admin','teacher'));
create policy "attendance update" on public.attendance for update
  using (public.my_role() in ('admin','teacher')) with check (public.my_role() in ('admin','teacher'));
create policy "attendance delete" on public.attendance for delete
  using (public.my_role() = 'admin');

-- ---------- office ----------
create policy "letters read" on public.letters for select
  using (public.my_role() in ('admin','reception','accountant')
         or (public.my_role() = 'student' and data->>'cnic' = public.my_cnic()));
create policy "letters write" on public.letters for all
  using (public.my_role() in ('admin','reception')) with check (public.my_role() in ('admin','reception'));

create policy "hospitals rw" on public.hospitals for all
  using (public.my_role() in ('admin','teacher','reception')) with check (public.my_role() in ('admin','teacher','reception'));
create policy "trainees rw" on public.trainees for all
  using (public.my_role() in ('admin','teacher','reception')) with check (public.my_role() in ('admin','teacher','reception'));

create policy "visitors rw" on public.visitors for all
  using (public.my_role() in ('admin','reception')) with check (public.my_role() in ('admin','reception'));
create policy "events rw" on public.events for all
  using (public.my_role() in ('admin','reception')) with check (public.my_role() in ('admin','reception'));
create policy "problems rw" on public.problems for all
  using (public.my_role() in ('admin','reception','teacher')) with check (public.my_role() in ('admin','reception','teacher'));
create policy "cvs rw" on public.cvs for all
  using (public.my_role() in ('admin','reception')) with check (public.my_role() in ('admin','reception'));

-- ---------- library & stock ----------
create policy "books read" on public.books for select
  using (auth.role() = 'authenticated');
create policy "books write" on public.books for all
  using (public.my_role() in ('admin','reception')) with check (public.my_role() in ('admin','reception'));

create policy "book_issues read" on public.book_issues for select
  using (auth.role() = 'authenticated');
create policy "book_issues write" on public.book_issues for all
  using (public.my_role() in ('admin','reception')) with check (public.my_role() in ('admin','reception'));

create policy "stock_cats staff" on public.stock_cats for all
  using (public.my_role() in ('admin','accountant')) with check (public.my_role() in ('admin','accountant'));
create policy "stock_items staff" on public.stock_items for all
  using (public.my_role() in ('admin','accountant')) with check (public.my_role() in ('admin','accountant'));

-- ---------- system ----------
create policy "sessions read" on public.sessions for select
  using (auth.role() = 'authenticated');
create policy "sessions write" on public.sessions for all
  using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

create policy "settings read" on public.settings for select
  using (auth.role() = 'authenticated');
create policy "settings write" on public.settings for all
  using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

-- ---------- auto-profile on signup ----------
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, role) values (new.id, 'pending')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- DONE. Next: create login users in Dashboard -> Authentication,
-- then run the role-assignment snippet (provided separately).
-- ============================================================
