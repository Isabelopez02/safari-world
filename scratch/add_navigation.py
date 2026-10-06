import sys
fpath = r'c:\Users\USUARIO\Desktop\Universidad\flutter\zoologico_front\zoologico_front\lib\features\mapa\screens\pantalla_mapa.dart'
with open(fpath, 'r', encoding='utf-8') as f:
    c = f.read()

import_str = "import 'pantalla_detalle_animal.dart';\n"
c = c.replace("import '../widgets/ruta_painter.dart';", "import '../widgets/ruta_painter.dart';\n" + import_str)

old_onpressed = """              child: OutlinedButton(
                onPressed: () {},"""
new_onpressed = """              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaDetalleAnimal(animal: _marcadorSeleccionado!),
                    ),
                  );
                },"""
c = c.replace(old_onpressed, new_onpressed)

with open(fpath, 'w', encoding='utf-8') as f:
    f.write(c)
