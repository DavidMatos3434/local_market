import requests

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
    res = requests.post(url, json=login_payload).json()
    uid = res.get('result')
    if not uid: return None
    execute_payload = {"jsonrpc": "2.0", "method": "call", "params": {"service": "object", "method": "execute_kw", "args": [DB, uid, PASSWORD, model, method, args, kwargs]}, "id": 2}
    return requests.post(url, json=execute_payload).json().get('result')

def main():
    print("🌍 Corrigindo País para Portugal...")
    
    # 1. Achar o ID real de Portugal
    pt_ids = execute('res.country', 'search', [['code', '=', 'PT']])
    if not pt_ids:
        print("❌ Erro: Portugal (PT) não encontrado no Odoo!")
        return
    pt_id = pt_ids[0]
    print(f"✅ ID de Portugal encontrado: {pt_id}")

    # 2. Atualizar todos os Parceiros (Artisans)
    partners = execute('res.partner', 'search', [['x_is_artisan', '=', True]])
    if partners:
        execute('res.partner', 'write', partners, {'country_id': pt_id})
        print(f"✅ {len(partners)} artesãos atualizados para Portugal.")

    # 3. Atualizar todas as Empresas
    companies = execute('res.company', 'search', [])
    if companies:
        execute('res.company', 'write', companies, {'country_id': pt_id})
        print(f"✅ {len(companies)} empresas atualizadas para Portugal.")

if __name__ == "__main__":
    main()
