import json
import requests
import csv

# CONFIGURAÇÃO
URL = "http://localhost:8069"
DB = "local_market_artisans"
USERNAME = "thermoenergetics@gmail.com"
PASSWORD = "admin" # Password que definiste no setup inicial

def execute(model, method, *args):
    url = f"{URL}/jsonrpc"
    # Login
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

    # Executar comando
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
    print(f"🚀 Iniciando Sincronização API para {DB}...")
    
    try:
        with open('import_companies.csv', mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                name = row['name']
                print(f"📦 Processando: {name}")

                # 1. Preparar dados da Empresa
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
                    'country_id': 185, # ID de Portugal no Odoo
                }
                
                # 2. Criar no Odoo
                res = execute('res.company', 'create', vals)
                
                if res:
                    print(f"   ✅ Sucesso! Criada com ID: {res}")
                else:
                    print(f"   ❌ Falha ao criar {name}")

    except Exception as e:
        print(f"🔥 Erro crítico: {e}")

if __name__ == "__main__":
    main()
