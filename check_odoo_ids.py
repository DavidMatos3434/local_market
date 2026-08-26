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

print("🔍 Procurando IDs corretos no Odoo...")
countries = execute('res.country', 'search_read', [['name', 'in', ['Portugal', 'Paraguay', 'Paraguai']]], ['id', 'name', 'code'])
print(f"Países encontrados: {countries}")
