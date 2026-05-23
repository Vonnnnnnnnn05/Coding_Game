create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  display_name text not null,
  avatar_url text,
  xp integer not null default 0,
  level integer not null default 1,
  streak integer not null default 0,
  solved_challenge_ids text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  difficulty text not null check (difficulty in ('easy', 'intermediate', 'hard')),
  description text not null,
  examples jsonb not null default '[]',
  constraints text[] not null default '{}',
  starter_code jsonb not null default '{}',
  tags text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.test_cases (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.challenges(id) on delete cascade,
  input text not null,
  expected_output text not null,
  visibility text not null check (visibility in ('public', 'hidden')),
  sort_order integer not null default 0
);

create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  challenge_id uuid not null references public.challenges(id) on delete cascade,
  language_id integer not null,
  language_name text not null,
  code text not null,
  status text not null,
  runtime_ms integer,
  memory_kb integer,
  output text,
  error text,
  created_at timestamptz not null default now()
);

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  description text not null,
  xp_reward integer not null default 0
);

create table if not exists public.user_achievements (
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_id uuid not null references public.achievements(id) on delete cascade,
  earned_at timestamptz not null default now(),
  primary key (user_id, achievement_id)
);

alter table public.profiles enable row level security;
alter table public.challenges enable row level security;
alter table public.test_cases enable row level security;
alter table public.submissions enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;

create policy "profiles are readable"
  on public.profiles for select
  using (true);

create policy "users update their profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "users insert their profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "challenges are readable"
  on public.challenges for select
  using (true);

create policy "public test cases are readable"
  on public.test_cases for select
  using (visibility = 'public');

create policy "users read their submissions"
  on public.submissions for select
  using (auth.uid() = user_id);

create policy "users insert their submissions"
  on public.submissions for insert
  with check (auth.uid() = user_id);

create policy "achievements are readable"
  on public.achievements for select
  using (true);

create policy "users read their achievements"
  on public.user_achievements for select
  using (auth.uid() = user_id);
