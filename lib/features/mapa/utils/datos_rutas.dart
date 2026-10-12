import 'pathfinding.dart';

// Este es el grafo (red de caminos) que representa tu mapa
final GrafoZoolologico grafoMapa = GrafoZoolologico()
  // 1. NODOS PRINCIPALES (Los cruces y caminos de tierra)
  // Usé aproximaciones visuales según tu imagen. Puedes ajustarlos luego tocando tu mapa!
  ..agregarNodo('entrada', 900, 770)
  ..agregarNodo('plaza_principal', 900, 680)
  // Ruta Izquierda (Granja y Monos)
  ..agregarNodo('camino_izq_1', 700, 700)
  ..agregarNodo('camino_izq_2', 400, 720) // Frente granja
  ..agregarNodo('camino_izq_3', 180, 650) // Curva izq
  ..agregarNodo('camino_izq_4', 200, 450) // Subiendo izq
  ..agregarNodo('camino_izq_5', 380, 450) // Frente monos
  // Ruta Centro-Izquierda (Cocodrilo y Sabana)
  ..agregarNodo('camino_c_izq_1', 650, 450)
  ..agregarNodo('camino_c_izq_2', 650, 360) // Frente Sabana
  // Ruta Centro (Elefante y Osos)
  ..agregarNodo('camino_centro_1', 950, 600)
  ..agregarNodo('camino_centro_2', 950, 450) // Osos
  // Ruta Derecha (Acuáticos, Aves y Felinos)
  ..agregarNodo('camino_der_1', 1150, 700) // Pinguinos
  ..agregarNodo('camino_der_2', 1350, 680) // Pelicanos/Nutrias
  ..agregarNodo('camino_der_3', 1350, 560) // Felinos
  ..agregarNodo('camino_der_4', 1250, 400) // Acuaticos norte
  // 2. CONEXIONES DE LOS CAMINOS (Por donde se puede caminar)
  ..agregarArista('entrada', 'plaza_principal')
  ..agregarArista('plaza_principal', 'camino_izq_1')
  ..agregarArista('camino_izq_1', 'camino_izq_2')
  ..agregarArista('camino_izq_2', 'camino_izq_3')
  ..agregarArista('camino_izq_3', 'camino_izq_4')
  ..agregarArista('camino_izq_4', 'camino_izq_5')
  ..agregarArista('camino_izq_1', 'camino_c_izq_1')
  ..agregarArista('camino_izq_5', 'camino_c_izq_1')
  ..agregarArista('camino_c_izq_1', 'camino_c_izq_2')
  ..agregarArista('plaza_principal', 'camino_centro_1')
  ..agregarArista('camino_centro_1', 'camino_centro_2')
  ..agregarArista('camino_centro_2', 'camino_c_izq_2')
  ..agregarArista('camino_centro_2', 'camino_der_4')
  ..agregarArista('plaza_principal', 'camino_der_1')
  ..agregarArista('camino_der_1', 'camino_der_2')
  ..agregarArista('camino_der_2', 'camino_der_3')
  ..agregarArista('camino_der_3', 'camino_der_4')
  // 3. NODOS DE LOS ANIMALES (Tus coordenadas exactas)
  ..agregarNodo('A01', 346, 287) // Chimpancé
  ..agregarNodo('A02', 438, 305) // Mono
  ..agregarNodo('A03', 570, 214) // Cebra
  ..agregarNodo('A04', 634, 273) // Camello
  ..agregarNodo('A05', 709, 277) // Jirafa
  ..agregarNodo('A06', 904, 308) // Oso 1
  ..agregarNodo('A07', 1026, 292) // Oso 2
  ..agregarNodo('A08', 1170, 233) // Delfín
  ..agregarNodo('A09', 1279, 277) // Foca
  ..agregarNodo('A10', 1451, 414) // León
  ..agregarNodo('A11', 1378, 474) // Tigre
  ..agregarNodo('A12', 1518, 494) // Leopardo
  ..agregarNodo('A13', 1123, 539) // Elefante
  ..agregarNodo('A14', 1270, 647) // Pingüino
  ..agregarNodo('A15', 1369, 603) // Nutria
  ..agregarNodo('A16', 1466, 638) // Pelícano
  ..agregarNodo('A17', 664, 554) // Cocodrilo
  ..agregarNodo('A18', 273, 638) // Vaca
  ..agregarNodo('A19', 377, 650) // Oveja
  ..agregarNodo('A20', 458, 635) // Cerdo
  // BAÑOS (WC)
  ..agregarNodo('B01', 420, 580)
  ..agregarNodo('B02', 900, 520)
  ..agregarNodo('B03', 1300, 720)
  // 4. CONECTAR ANIMALES AL CAMINO MÁS CERCANO
  ..agregarArista('camino_izq_5', 'A01')
  ..agregarArista('camino_izq_5', 'A02')
  ..agregarArista('camino_c_izq_2', 'A03')
  ..agregarArista('camino_c_izq_2', 'A04')
  ..agregarArista('camino_c_izq_2', 'A05')
  ..agregarArista('camino_centro_2', 'A06')
  ..agregarArista('camino_centro_2', 'A07')
  ..agregarArista('camino_der_4', 'A08')
  ..agregarArista('camino_der_4', 'A09')
  ..agregarArista('camino_der_3', 'A10')
  ..agregarArista('camino_der_3', 'A11')
  ..agregarArista('camino_der_3', 'A12')
  ..agregarArista('camino_centro_1', 'A13')
  ..agregarArista('camino_der_1', 'A14')
  ..agregarArista('camino_der_2', 'A15')
  ..agregarArista('camino_der_2', 'A16')
  ..agregarArista('camino_izq_1', 'A17')
  ..agregarArista('camino_izq_2', 'A18')
  ..agregarArista('camino_izq_2', 'A19')
  ..agregarArista('camino_izq_2', 'A20')
  // CONEXIONES DE BAÑOS
  ..agregarArista('camino_izq_2', 'B01')
  ..agregarArista('camino_centro_2', 'B02')
  ..agregarArista('camino_der_1', 'B03');
