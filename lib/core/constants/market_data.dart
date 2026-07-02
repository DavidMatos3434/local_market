class MarketData {
  // Grupos Geográficos e Ilhas
  static const Map<String, List<String>> geoGroups = {
    'Grupo Ocidental': ['Flores', 'Corvo'],
    'Grupo Central': ['Terceira', 'Faial', 'Pico', 'São Jorge', 'Graciosa'],
    'Grupo Oriental': ['São Miguel', 'Santa Maria'],
  };

  // Categorias e Subcategorias
  static const Map<String, List<String>> categories = {
    'Bens Alimentares': [],
    'Cerâmica': [],
    'Construção Tradicional': [],
    'Fibras Vegetais': [],
    'Madeira e Cortiça': [],
    'Metal': [],
    'Outras Artes e Ofícios': [],
    'Papel e Artes Gráficas': [],
    'Pedra': [],
    'Pele e Couro': [],
    'Restauro': [],
    'Têxteis': [
      'Bordados',
      'Têxteis para o Lar',
      'Rendas',
      'Tecelagem',
      'Malha',
      'Macramé',
      'Bonecos de Pano',
      'Acessórios de Vestuário',
      'Arte de Estampar',
      'Trajes',
      'Vestuário por Medida',
      'Feltragem',
      'Preparação de Fibras Têxteis',
    ],
  };
}
