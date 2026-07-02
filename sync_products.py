import json
import requests

# CONFIGURAÇÃO
URL = "http://localhost:8069"
DB = "local_market_artisans"
USERNAME = "thermoenergetics@gmail.com"
PASSWORD = "admin"

def execute(model, method, *args, **kwargs):
    url = f"{URL}/jsonrpc"
    # Autenticação para obter o UID
    login_payload = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {"service": "common", "method": "login", "args": [DB, USERNAME, PASSWORD]},
        "id": 1
    }
    res = requests.post(url, json=login_payload).json()
    uid = res.get('result')
    if not uid:
        print("Erro: Falha no login Odoo. Verifique as credenciais.")
        return None

    # Execução do comando via execute_kw
    execute_payload = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
            "service": "object",
            "method": "execute_kw",
            "args": [DB, uid, PASSWORD, model, method, args, kwargs]
        },
        "id": 2
    }
    return requests.post(url, json=execute_payload).json().get('result')

def main():
    print("🚀 Sincronizando artigos do catálogo CADA...")

    # Mapeamento de Artesão -> Produtos
    data_to_sync = [
        {
            'artisan_name': 'AÇORBORDADOS',
            'products': [
                {'name': 'Bordado a Branco - Toalha Tradicional', 'price': 85.0, 'desc': 'Bordado exclusivo feito à mão em puro linho.'},
                {'name': 'Bordado a Branco - Almofada', 'price': 45.0, 'desc': 'Almofada tradicional com bordado a branco.'},
            ]
        },
        {
            'artisan_name': 'RICARDO JORGE MACHADO SIMAS',
            'products': [
                {'name': 'Alguidar Terceirense Tradicional', 'price': 25.0, 'desc': 'Peça emblemática para a típica Alcatra da Terceira.'},
                {'name': 'Talha de Barro para Líquidos', 'price': 35.0, 'desc': 'Talha artesanal em barro cozido.'},
            ]
        }
    ]

    for entry in data_to_sync:
        name = entry['artisan_name']
        print(f"\n📦 Processando: {name}")

        # Buscar o ID da Empresa diretamente pelo nome
        company_ids = execute('res.company', 'search', [('name', 'ilike', name)])
        if not company_ids:
            print(f"   ⚠️ Empresa '{name}' não encontrada. Saltando...")
            continue
        
        cid = company_ids[0]

        for p in entry['products']:
            # Verificar se o produto já existe para esta empresa
            exists = execute('product.template', 'search', [('name', '=', p['name']), ('company_id', '=', cid)])
            
            if exists:
                print(f"   ℹ️ O artigo '{p['name']}' já existe.")
                continue

            vals = {
                'name': p['name'],
                'list_price': p['price'],
                'company_id': cid,
                'description_sale': p['desc'],
                'detailed_type': 'product',
            }

            res = execute('product.template', 'create', vals)
            if res:
                print(f"   ✅ Sucesso: '{p['name']}' criado!")

    print("\n✨ Sincronização concluída!")

if __name__ == "__main__":
    main()
