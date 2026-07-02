{
    'name': 'Local Market Artisans',
    'version': '1.0',
    'category': 'Sales',
    'summary': 'Gestão de Artesãos dos Açores',
    'description': 'Módulo para adicionar campos geográficos (Ilha, Grupo) aos contactos e empresas dos artesãos.',
    'author': 'David / Local Market OS',
    'depends': [
        'base', 
        'contacts',
        'sale_management', # Vendas
        'stock',           # Inventário
        'mrp',             # Fabricação (Bill of Materials)
        'account',         # Contabilidade/IVA
    ],
    'data': [
        'views/res_partner_views.xml',
        'views/res_company_views.xml',
    ],
    'installable': True,
    'application': True,
}
