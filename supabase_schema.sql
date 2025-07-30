-- Script SQL pour créer les tables Supabase pour l'application de budget
-- À exécuter dans l'éditeur SQL de votre projet Supabase

-- 1. Table des transactions
CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    date DATE NOT NULL,
    description TEXT,
    category_id TEXT NOT NULL,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('income', 'expense', 'savings_deposit')),
    recurrence_type TEXT CHECK (recurrence_type IN ('none', 'daily', 'weekly', 'monthly', 'quarterly', 'yearly')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Table des pockets
CREATE TABLE IF NOT EXISTS pockets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    icon TEXT NOT NULL,
    color TEXT NOT NULL,
    budget DECIMAL(10,2) NOT NULL DEFAULT 0,
    spent DECIMAL(10,2) NOT NULL DEFAULT 0,
    pocket_type TEXT NOT NULL CHECK (pocket_type IN ('needs', 'wants', 'savings', 'custom')),
    savings_goal_type TEXT CHECK (savings_goal_type IN ('emergency', 'vacation', 'house', 'car', 'investment', 'retirement', 'education', 'other')),
    target_amount DECIMAL(10,2),
    target_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Table de relation many-to-many entre pockets et transactions
CREATE TABLE IF NOT EXISTS pocket_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    pocket_id UUID NOT NULL REFERENCES pockets(id) ON DELETE CASCADE,
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(pocket_id, transaction_id)
);

-- 4. Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(transaction_type);

CREATE INDEX IF NOT EXISTS idx_pockets_user_id ON pockets(user_id);
CREATE INDEX IF NOT EXISTS idx_pockets_type ON pockets(pocket_type);

CREATE INDEX IF NOT EXISTS idx_pocket_transactions_pocket_id ON pocket_transactions(pocket_id);
CREATE INDEX IF NOT EXISTS idx_pocket_transactions_transaction_id ON pocket_transactions(transaction_id);
CREATE INDEX IF NOT EXISTS idx_pocket_transactions_user_id ON pocket_transactions(user_id);

-- 5. Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 6. Triggers pour mettre à jour automatiquement updated_at
CREATE TRIGGER update_transactions_updated_at 
    BEFORE UPDATE ON transactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pockets_updated_at 
    BEFORE UPDATE ON pockets 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. Règles RLS (Row Level Security)

-- Activer RLS sur toutes les tables
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pockets ENABLE ROW LEVEL SECURITY;
ALTER TABLE pocket_transactions ENABLE ROW LEVEL SECURITY;

-- Politique pour les transactions : chaque utilisateur ne peut voir que ses propres transactions
CREATE POLICY "Users can view their own transactions" ON transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own transactions" ON transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own transactions" ON transactions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own transactions" ON transactions
    FOR DELETE USING (auth.uid() = user_id);

-- Politique pour les pockets : chaque utilisateur ne peut voir que ses propres pockets
CREATE POLICY "Users can view their own pockets" ON pockets
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own pockets" ON pockets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own pockets" ON pockets
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own pockets" ON pockets
    FOR DELETE USING (auth.uid() = user_id);

-- Politique pour les relations pocket-transactions
CREATE POLICY "Users can view their own pocket transactions" ON pocket_transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own pocket transactions" ON pocket_transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own pocket transactions" ON pocket_transactions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own pocket transactions" ON pocket_transactions
    FOR DELETE USING (auth.uid() = user_id);

-- 8. Fonction pour calculer automatiquement le montant dépensé d'un pocket
CREATE OR REPLACE FUNCTION update_pocket_spent()
RETURNS TRIGGER AS $$
BEGIN
    -- Si c'est une insertion
    IF TG_OP = 'INSERT' THEN
        UPDATE pockets 
        SET spent = spent + (
            SELECT amount FROM transactions WHERE id = NEW.transaction_id
        )
        WHERE id = NEW.pocket_id;
        RETURN NEW;
    END IF;
    
    -- Si c'est une suppression
    IF TG_OP = 'DELETE' THEN
        UPDATE pockets 
        SET spent = spent - (
            SELECT amount FROM transactions WHERE id = OLD.transaction_id
        )
        WHERE id = OLD.pocket_id;
        RETURN OLD;
    END IF;
    
    -- Si c'est une mise à jour
    IF TG_OP = 'UPDATE' THEN
        -- Soustraire l'ancien montant
        UPDATE pockets 
        SET spent = spent - (
            SELECT amount FROM transactions WHERE id = OLD.transaction_id
        )
        WHERE id = OLD.pocket_id;
        
        -- Ajouter le nouveau montant
        UPDATE pockets 
        SET spent = spent + (
            SELECT amount FROM transactions WHERE id = NEW.transaction_id
        )
        WHERE id = NEW.pocket_id;
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ language 'plpgsql';

-- 9. Trigger pour mettre à jour automatiquement le montant dépensé
CREATE TRIGGER update_pocket_spent_trigger
    AFTER INSERT OR UPDATE OR DELETE ON pocket_transactions
    FOR EACH ROW EXECUTE FUNCTION update_pocket_spent();

-- 10. Fonction pour nettoyer les relations orphelines
CREATE OR REPLACE FUNCTION cleanup_orphaned_pocket_transactions()
RETURNS void AS $$
BEGIN
    DELETE FROM pocket_transactions 
    WHERE transaction_id NOT IN (SELECT id FROM transactions)
    OR pocket_id NOT IN (SELECT id FROM pockets);
END;
$$ language 'plpgsql';

-- 11. Vues utiles pour les requêtes complexes

-- Vue pour obtenir les transactions avec leurs pockets associés
CREATE OR REPLACE VIEW transaction_with_pockets AS
SELECT 
    t.*,
    array_agg(p.id) as pocket_ids,
    array_agg(p.name) as pocket_names
FROM transactions t
LEFT JOIN pocket_transactions pt ON t.id = pt.transaction_id
LEFT JOIN pockets p ON pt.pocket_id = p.id
GROUP BY t.id, t.user_id, t.title, t.amount, t.date, t.description, 
         t.category_id, t.transaction_type, t.recurrence_type, 
         t.created_at, t.updated_at;

-- Vue pour obtenir les statistiques par pocket
CREATE OR REPLACE VIEW pocket_statistics AS
SELECT 
    p.*,
    COUNT(pt.transaction_id) as transaction_count,
    COALESCE(SUM(t.amount), 0) as total_amount
FROM pockets p
LEFT JOIN pocket_transactions pt ON p.id = pt.pocket_id
LEFT JOIN transactions t ON pt.transaction_id = t.id
GROUP BY p.id, p.user_id, p.name, p.icon, p.color, p.budget, p.spent,
         p.pocket_type, p.savings_goal_type, p.target_amount, p.target_date,
         p.created_at, p.updated_at;

-- 12. Commentaires pour la documentation
COMMENT ON TABLE transactions IS 'Table des transactions financières des utilisateurs';
COMMENT ON TABLE pockets IS 'Table des pockets (catégories de budget) des utilisateurs';
COMMENT ON TABLE pocket_transactions IS 'Table de relation many-to-many entre pockets et transactions';
COMMENT ON COLUMN transactions.transaction_type IS 'Type de transaction: income, expense, savings_deposit';
COMMENT ON COLUMN pockets.pocket_type IS 'Type de pocket: needs, wants, savings, custom';
COMMENT ON COLUMN pockets.savings_goal_type IS 'Type d''objectif d''épargne pour les pockets savings'; 