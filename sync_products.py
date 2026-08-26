import json
import requests
import csv
import base64

# CONFIGURAÇÃO
URL = "http://localhost:8069"
DB = "local_market_artisans"
USERNAME = "thermoenergetics@gmail.com"
PASSWORD = "admin"

def execute(model, method, *args, **kwargs):
    url = f"{URL}/jsonrpc"
    login_payload = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {"service": "common", "method": "login", "args": [DB, USERNAME, PASSWORD]},
        "id": 1
    }
    try:
        res = requests.post(url, json=login_payload).json()
        uid = res.get('result')
        if not uid:
            print("Erro: Falha no login Odoo.")
            return None

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
    except Exception as e:
        print(f"Erro de rede: {e}")
        return None

def download_image_as_base64(url):
    try:
        response = requests.get(url, timeout=10)
        if response.status_status == 200:
            return base64.b64encode(response.content).decode('utf-8')
    except:
        pass
    return False

def sync_csv(filename):
    print(f"\n📄 Lendo ficheiro: {filename}")
    try:
        with open(filename, mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                prod_name = row['name'].strip()
                comp_name = row['company_id'].strip()
                print(f"📦 Artigo: {prod_name} -> {comp_name}")

                # 1. Buscar Empresa
                company_ids = execute('res.company', 'search', [('name', 'ilike', comp_name)])
                if not company_ids:
                    print(f"   ⚠️ Empresa '{comp_name}' não encontrada.")
                    continue
                cid = company_ids[0]

                # Garantir que a empresa está em Portugal
                pt_ids = execute('res.country', 'search', [['code', '=', 'PT']])
                if pt_ids:
                    execute('res.company', 'write', [cid], {'country_id': pt_ids[0]})

                # 2. Buscar/Criar Categoria (Simplificado: pega a última parte)
                categ_path = row['categ_id'].split('/')
                last_categ = categ_path[-1].strip()
                categ_ids = execute('product.category', 'search', [('name', '=', last_categ)])
                categ_id = categ_ids[0] if categ_ids else 1 # Fallback para All

                # 3. Verificar Duplicados
                exists = execute('product.template', 'search', [('name', '=', prod_name), ('company_id', '=', cid)])
                if exists:
                    print(f"   🔄 Já existe. Atualizando...")
                    pid = exists[0]
                    vals = {
                        'list_price': float(row['list_price']),
                        'standard_price': float(row.get('standard_price', 0)),
                        'categ_id': categ_id,
                    }
                    execute('product.template', 'write', [pid], vals)
                else:
                    print(f"   ➕ Criando novo...")
                    vals = {
                        'name': prod_name,
                        'list_price': float(row['list_price']),
                        'standard_price': float(row.get('standard_price', 0)),
                        'company_id': cid,
                        'categ_id': categ_id,
                        'detailed_type': 'product',
                    }
                    
                    # Tentar carregar imagem se houver URL
                    if row.get('image_1920'):
                        img_data = download_image_as_base64(row['image_1920'])
                        if img_data:
                            vals['image_1920'] = img_data

                    execute('product.template', 'create', vals)

    except Exception as e:
        print(f"❌ Erro ao processar {filename}: {e}")

def main():
    print("🚀 Sincronização Inteligente de Catálogo iniciada...")
    
    # Lista de ficheiros para sincronizar
    files = [
        'import_products_acor.csv',
        'import_pottery_products.csv'
    ]

    for f in files:
        sync_csv(f)

    print("\n✨ Processo de catálogo terminado!")

if __name__ == "__main__":
    main()
