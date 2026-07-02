from odoo import models, fields

class ResPartner(models.Model):
    _inherit = 'res.partner'

    x_is_artisan = fields.Boolean(string='É Artesão?', default=True)
    x_upa = fields.Char(string='Carta UPA')
    x_island = fields.Selection([
        ('Flores', 'Flores'),
        ('Corvo', 'Corvo'),
        ('Terceira', 'Terceira'),
        ('Faial', 'Faial'),
        ('Pico', 'Pico'),
        ('São Jorge', 'São Jorge'),
        ('Graciosa', 'Graciosa'),
        ('São Miguel', 'São Miguel'),
        ('Santa Maria', 'Santa Maria'),
    ], string='Ilha')

    x_geo_group = fields.Selection([
        ('ocidental', 'Grupo Ocidental'),
        ('central', 'Grupo Central'),
        ('oriental', 'Grupo Oriental'),
    ], string='Grupo Geográfico')
