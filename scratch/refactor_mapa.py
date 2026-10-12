fpath = r'lib/features/mapa/screens/pantalla_mapa.dart'
with open(fpath, 'r', encoding='utf-8') as f:
    c = f.read()

# 1. Add imports for datos_marcadores.dart and barra_inferior_mapa.dart
import_target = "import 'pantalla_detalle_animal.dart';"
import_replacement = """import 'pantalla_detalle_animal.dart';
import '../utils/datos_marcadores.dart';
import '../widgets/barra_inferior_mapa.dart';"""
c = c.replace(import_target, import_replacement)

# 2. Replace local marcadores and banios declaration with:
#    List<MarcadorMapa> marcadores = marcadoresZoologico;
#    List<MarcadorMapa> banios = baniosZoologico;
start_marker = "  final List<MarcadorMapa> marcadores = ["
end_marker = "  final List<MarcadorMapa> banios = ["

idx_start = c.find(start_marker)
if idx_start != -1:
    idx_banios = c.find(end_marker)
    # Find the closing ]; of banios
    idx_banios_end = c.find("  ];\n", idx_banios) + 5
    old_block = c[idx_start:idx_banios_end]
    new_block = """  final List<MarcadorMapa> marcadores = marcadoresZoologico;
  final List<MarcadorMapa> banios = baniosZoologico;"""
    c = c.replace(old_block, new_block)
else:
    print("Could not find start_marker!")

# 3. Replace _buildBarraInferior(), _buildBarraExploracion(), _buildBarraVistaPrevia(), _buildBarraNavegando()
# with BarraInferiorMapa in build()
old_methods_start = "  Widget _buildBarraInferior() {"
old_methods_end = "  @override\n  Widget build(BuildContext context) {"

idx_methods_start = c.find(old_methods_start)
idx_methods_end = c.find(old_methods_end)

if idx_methods_start != -1 and idx_methods_end != -1:
    c = c[:idx_methods_start] + c[idx_methods_end:]
    print("Removed old bottom bar methods from pantalla_mapa.dart")
else:
    print("Could not find bottom bar methods!")

# 4. In build(), replace _buildBarraInferior() with BarraInferiorMapa(...)
old_call = "child: _buildBarraInferior(),"
new_call = """child: BarraInferiorMapa(
              keyAnimales: _keyAnimales,
              marcadorSeleccionado: _marcadorSeleccionado,
              isNavigating: _isNavigating,
              marcadores: marcadores,
              bottomBarPulseController: _bottomBarPulseController,
              onTapExploraciones: () => _mostrarAnimalesPorVisitar(context),
              onCerrarSeleccion: () => setState(() {
                _marcadorSeleccionado = null;
                _rutaActual = [];
              }),
              onIniciarNavegacion: () {
                setState(() => _isNavigating = true);
                _routeProgressController.forward(from: 0);
              },
              onCancelarNavegacion: () {
                setState(() {
                  _isNavigating = false;
                  _marcadorSeleccionado = null;
                  _rutaActual = [];
                });
              },
            ),"""

c = c.replace(old_call, new_call)

with open(fpath, 'w', encoding='utf-8') as f:
    f.write(c)

print('pantalla_mapa.dart refactored successfully!')
