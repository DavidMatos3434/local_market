import json
import requests
import csv

# CONFIGURAÇÃO
URL = "http://localhost:8069"
DB = "local_market_artisans"
USERNAME = "thermoenergetics@gmail.com"
PASSWORD = "admin"

def execute(model, method, *args):
    url = f"{URL}/jsonrpc"
    login_payload = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {"service": "common", "method": "login", "args": [DB, USERNAME, PASSWORD]},
        "id": 1
    }
    try:
        response = requests.post(url, json=login_payload)
        uid = response.json().get('result')
        if not uid:
            return None

        execute_payload = {
            "jsonrpc": "2.0",
            "method": "call",
            "params": {
                "service": "object",
                "method": "execute_kw",
                "args": [DB, uid, PASSWORD, model, method, args]
            },
            "id": 2
        }
        return requests.post(url, json=execute_payload).json().get('result')
    except Exception as e:
        print(f"Erro na API: {e}")
        return None

def main():
    print("🧹 Iniciando limpeza de dados (Ilhas e Grupos Geo)...")
    
    # 1. Carregar dados do CSV como fonte de verdade
    csv_data = {}
    try:
        with open('import_artisans.csv', mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                csv_data[row['name'].strip()] = {
                    'island': row['x_island'],
                    'geo_group': row['x_geo_group']
                }
    except Exception as e:
        print(f"Erro ao ler CSV: {e}")
        return

    # 2. Buscar artesãos no Odoo (res.partner)
    partners = execute('res.partner', 'search_read', [['x_is_artisan', '=', True]], ['id', 'name', 'x_island'])
    
    if not partners:
        print("Nenhum artesão encontrado no Odoo.")
        return

    print(f"Encontrados {len(partners)} artesãos. Verificando integridade...")

    for p in partners:
        p_id = p['id']
        name = p['name'].strip()
        current_island = p.get('x_island')

        # Se a ilha estiver vazia ou for falsa (NULL no Odoo)
        if not current_island:
            print(f"⚠️ Artesão '{name}' sem ilha. Tentando corrigir...")
            
            if name in csv_data:
                fix = csv_data[name]
                vals = {
                    'x_island': fix['island'],
                    'x_geo_group': fix['geo_group']
                }
                # Atualizar res.partner
                execute('res.partner', 'write', [p_id], vals)
                print(f"   ✅ Corrigido para: {fix['island']} ({fix['geo_group']})")
                
                # Sincronizar também com a Empresa se existir
                companies = execute('res.company', 'search', [['name', '=', name]])
                if companies:
                    execute('res.company', 'write', companies, vals)
                    print(f"   🏢 Empresa sincronizada também.")
            else:
                print(f"   ❌ Não encontrado no CSV para correção automática.")

    print("✨ Limpeza concluída!")

if __name__ == "__main__":
    main()
