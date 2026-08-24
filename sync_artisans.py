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
    uid = requests.post(url, json=login_payload).json().get('result')
    
    if not uid:
        print("Erro: Falha no login do Odoo!")
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

def main():
    print(f"🚀 Iniciando Sincronização Robusta para {DB}...")
    
    try:
        # Usamos import_artisans.csv como fonte completa
        with open('import_artisans.csv', mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                name = row['name'].strip()
                print(f"📦 Processando: {name}")

                vals = {
                    'name': name,
                    'street': row['street'],
                    'city': row['city'],
                    'zip': row['zip'],
                    'email': row['email'],
                    'website': row['website'],
                    'x_is_artisan': True,
                    'x_island': row['x_island'],
                    'x_geo_group': row['x_geo_group'],
                    'country_id': 185, 
                }
                
                # 1. Verificar se já existe (Partner)
                existing = execute('res.partner', 'search', [['name', '=', name]])
                
                if existing:
                    print(f"   🔄 Atualizando parceiro existente (ID: {existing[0]})")
                    execute('res.partner', 'write', existing, vals)
                else:
                    print(f"   ➕ Criando novo parceiro...")
                    execute('res.partner', 'create', vals)

                # 2. Sincronizar Empresa (Company)
                existing_comp = execute('res.company', 'search', [['name', '=', name]])
                if existing_comp:
                    execute('res.company', 'write', existing_comp, vals)
                else:
                    execute('res.company', 'create', vals)

    except Exception as e:
        print(f"🔥 Erro crítico: {e}")

if __name__ == "__main__":
    main()
