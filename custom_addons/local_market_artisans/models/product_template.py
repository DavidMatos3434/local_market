from odoo import models, fields

class ProductTemplate(models.Model):
    _inherit = 'product.template'

    x_materials = fields.Many2many(
        'product.attribute.value', 
        string='Materiais Açorianos',
        help="Ex: Escama de Peixe, Miolo de Hortênsia, Lã, Basalto"
    )
    
    x_is_regional = fields.Boolean(string='Produto Regional Certificado', default=True)
