-- Rode este complemento em uma NOVA QUERY no SQL Editor do Supabase.
-- Mantem as tabelas existentes intactas e cria um armazenamento do
-- estado completo da vitrine original (produtos, cupons, combos, etc).
CREATE TABLE IF NOT EXISTS public.shop_state (
  id text PRIMARY KEY,
  data jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT shop_state_singleton CHECK (id = 'store')
);
ALTER TABLE public.shop_state ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.shop_state TO anon,authenticated;
GRANT INSERT,UPDATE ON public.shop_state TO authenticated;
DROP POLICY IF EXISTS ma_shop_read ON public.shop_state;
DROP POLICY IF EXISTS ma_shop_insert ON public.shop_state;
DROP POLICY IF EXISTS ma_shop_update ON public.shop_state;
CREATE POLICY ma_shop_read ON public.shop_state FOR SELECT TO anon,authenticated USING (true);
CREATE POLICY ma_shop_insert ON public.shop_state FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.admins WHERE user_id=(SELECT auth.uid())));
CREATE POLICY ma_shop_update ON public.shop_state FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.admins WHERE user_id=(SELECT auth.uid())))
WITH CHECK (EXISTS (SELECT 1 FROM public.admins WHERE user_id=(SELECT auth.uid())));
-- Nao precisa inserir o catalogo via SQL: o painel oferece o botao "Importar".
