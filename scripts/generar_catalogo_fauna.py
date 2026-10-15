"""Genera datos Dart desde el inventario y el manifiesto de fotos verificado.

No usa la cantidad de individuos de 2023 como población vigente. Las referencias
de zona existentes se conservan; las demás fichas no inventan coordenadas.
"""
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
records=json.loads((ROOT/'docs/fauna/catalogo_huachipa.json').read_text(encoding='utf-8'))

GROUPS={
 'Felinos': dict(dieta='Carnívoro',alimentos=['Mamíferos','Aves','Otras presas, según especie'],
  reconocimiento='Observa las orejas, la forma de la cola, las patas y el patrón del pelaje. Compara esas señales con la señalética para distinguir felinos de aspecto parecido.',
  rol='Los depredadores regulan poblaciones de presas y ayudan a mantener el equilibrio de las redes alimentarias.',
  consejos=['Observa desde la distancia indicada y habla en voz baja.','Si está descansando o permanece oculto, espera unos minutos sin golpear las barreras.','Fotografía sin flash y no intentes atraer su atención con comida o movimientos bruscos.'],
  amenazas=['Pérdida y fragmentación de hábitats naturales.','Caza, tráfico y conflictos entre fauna y actividades humanas.']),
 'Primates':dict(dieta='Variable según especie',alimentos=['Frutos','Hojas','Semillas','Invertebrados, según especie'],
  reconocimiento='Fíjate en el tamaño corporal, el color de la cara, la longitud de la cola y cómo utiliza sus manos al desplazarse. Las especies de monos no comparten todas las mismas adaptaciones.',
  rol='Muchos primates dispersan semillas y participan en la regeneración del bosque mientras buscan alimento.',
  consejos=['Guarda alimentos y objetos pequeños fuera de su alcance.','Observa sus interacciones sin imitarlos ni intentar tocarlos.','No arrojes comida: la dieta de los ejemplares la determina el equipo del parque.'],
  amenazas=['Pérdida y fragmentación del bosque.','Captura para el comercio ilegal de fauna silvestre.']),
 'Psitácidas':dict(dieta='Principalmente herbívoro',alimentos=['Frutos','Semillas','Nueces','Brotes'],
  reconocimiento='Observa el pico curvado, los colores de la frente, las alas y la cola. Estos detalles ayudan a distinguir guacamayos, loros y pericos.',
  rol='La alimentación de estas aves puede contribuir a dispersar semillas, transportar frutos y regular su disponibilidad en los bosques.',
  consejos=['Fotografía sin flash y evita gritar o silbar para provocar respuestas.','No ofrezcas semillas ni galletas al ave.','Mira el pico y las patas para reconocer adaptaciones a la alimentación y al desplazamiento.'],
  amenazas=['Captura y tráfico de aves como mascotas.','Pérdida de árboles y de lugares de anidación.']),
 'Rapaces':dict(dieta='Carnívoro',alimentos=['Mamíferos pequeños','Aves','Otras presas, según especie'],
  reconocimiento='Fíjate en el pico, las garras y la forma de las alas. La postura de descanso no permite medir por sí sola la capacidad de vuelo de una rapaz.',
  rol='Las rapaces participan en el control de poblaciones de presas; las especies carroñeras también retiran restos de animales.',
  consejos=['Acércate con calma, sin golpear vidrios ni mallas.','Observa el pico y las patas mientras el ave está posada.','Evita el flash y respeta las distancias indicadas.'],
  amenazas=['Transformación y pérdida del hábitat.','Persecución, contaminación y tráfico de fauna.']),
 'Aves acuáticas':dict(dieta='Variable según especie',alimentos=['Vegetación acuática','Invertebrados','Semillas u otras presas, según especie'],
  reconocimiento='Observa la forma del pico, el largo de las patas y cómo busca alimento. Son adaptaciones diferentes a la vida en el agua y en las orillas.',
  rol='Las aves de humedales conectan ambientes acuáticos y terrestres y participan en sus redes alimentarias.',
  consejos=['Observa desde el borde permitido y evita perseguir a las aves.','No arrojes pan, bolsas ni objetos al agua.','Fíjate en los movimientos del pico y las patas al alimentarse.'],
  amenazas=['Pérdida de humedales y alteración de sus niveles de agua.','Contaminación y acumulación de residuos en ambientes acuáticos.']),
 'Aves de bosque':dict(dieta='Variable según especie',alimentos=['Frutos','Semillas','Invertebrados, según especie'],
  reconocimiento='Compara el tamaño y la forma del pico, el plumaje y la longitud de la cola. En muchas aves los colores cambian entre edades y sexos.',
  rol='Las aves de bosque participan en la dispersión de semillas y en otras relaciones de las redes alimentarias.',
  consejos=['Camina despacio y busca aves en ramas y zonas de sombra.','Escucha sus vocalizaciones sin reproducir sonidos para atraerlas.','No alimentes a las aves y evita usar flash.'],
  amenazas=['Pérdida de bosques y lugares para anidar.','Captura y comercio de fauna silvestre.']),
 'Aves corredoras':dict(dieta='Omnívoro',alimentos=['Semillas','Frutos','Brotes','Invertebrados'],
  reconocimiento='Observa las patas largas, el tamaño corporal y las alas reducidas de estas aves no voladoras.',
  rol='Estas aves participan en la dispersión de semillas y consumen materia vegetal y pequeños animales.',
  consejos=['Respeta la barrera y no acerques manos ni comida al pico.','Observa la forma de caminar desde un lugar seguro.','No provoques carreras ni persigas al animal.'],
  amenazas=['La alteración del hábitat afecta a sus poblaciones silvestres.','El bienestar de los ejemplares bajo cuidado depende de un manejo apropiado.']),
 'Serpientes':dict(dieta='Carnívoro',alimentos=['Vertebrados e invertebrados, según especie'],
  reconocimiento='Observa el patrón de las escamas y la forma corporal desde el área permitida. El aspecto externo por sí solo no permite decidir si una serpiente es venenosa.',
  rol='Las serpientes son depredadoras y también sirven de alimento a otros animales; forman parte de las redes alimentarias.',
  consejos=['No golpees el vidrio ni intentes mover la exhibición.','Una serpiente inmóvil puede estar descansando o regulando su temperatura.','No introduzcas manos u objetos y evita el flash.'],
  amenazas=['Pérdida de hábitats y persecución por temor o desconocimiento.','Captura y comercio ilegal de reptiles.']),
 'Tortugas':dict(dieta='Variable según especie',alimentos=['Vegetación','Frutos','Invertebrados u otras presas, según especie'],
  reconocimiento='Observa el caparazón, el cuello y las patas. Las adaptaciones para caminar y nadar son distintas entre tortugas terrestres y acuáticas.',
  rol='Según la especie, las tortugas dispersan semillas, consumen vegetación y participan en las redes alimentarias acuáticas.',
  consejos=['No levantes ni golpees el caparazón de una tortuga.','Evita tocar el agua y no introduzcas comida.','Observa a su ritmo: una tortuga quieta puede estar descansando.'],
  amenazas=['Extracción de ejemplares y huevos del medio natural.','Pérdida de hábitats, contaminación y comercio ilegal.']),
 'Lagartos':dict(dieta='Variable según especie',alimentos=['Vegetación o invertebrados, según especie'],
  reconocimiento='Fíjate en la piel, las escamas, los dedos y la cola. Muchos lagartos alternan zonas de sol y sombra para regular su temperatura.',
  rol='Según su dieta, los lagartos consumen vegetación o pequeños animales y son presas de otras especies.',
  consejos=['Observa sin tocar el vidrio ni intentar cambiar su posición.','El descanso y la regulación de temperatura forman parte de su actividad normal.','No introduzcas dedos, objetos o comida al recinto.'],
  amenazas=['Pérdida y alteración de sus hábitats.','Extracción y comercio de animales para cautiverio.']),
 'Crocodilianos':dict(dieta='Carnívoro',alimentos=['Peces','Invertebrados','Otros vertebrados, según tamaño y especie'],
  reconocimiento='Observa el hocico, la cola musculosa y la posición de los ojos. Los cocodrilos y los caimanes pertenecen a familias diferentes.',
  rol='Son depredadores de ambientes acuáticos y forman parte del equilibrio de ríos, lagunas y humedales.',
  consejos=['Respeta estrictamente la barrera y no acerques las manos al agua.','No arrojes comida ni objetos para provocar movimiento.','Busca ojos y hocico sobre la superficie sin acercarte al borde.'],
  amenazas=['Pérdida de humedales y degradación de ríos.','Caza y comercio ilegal de ejemplares o sus productos.']),
 'Anfibios':dict(dieta='Carnívoro en la fase adulta',alimentos=['Invertebrados y pequeñas presas acuáticas'],
  reconocimiento='Observa la piel y las adaptaciones al agua. En las ranas del género Telmatobius, los pliegues de la piel tienen importancia en la vida acuática.',
  rol='Los anfibios participan en redes alimentarias acuáticas y son sensibles a cambios en la calidad de su ambiente.',
  consejos=['No toques el agua ni los animales: su piel es muy sensible.','Busca con calma entre refugios y vegetación sin golpear el vidrio.','Respeta la iluminación y evita el flash.'],
  amenazas=['Contaminación y alteración de hábitats acuáticos.','Extracción del medio natural y enfermedades emergentes.']),
 'Mamíferos acuáticos':dict(dieta='Carnívoro',alimentos=['Peces','Crustáceos','Otras presas acuáticas, según especie'],
  reconocimiento='Observa la forma corporal y cómo utiliza las extremidades al nadar. Las nutrias y los lobos marinos pertenecen a grupos de mamíferos distintos.',
  rol='Como depredadores acuáticos, participan en la regulación de las redes alimentarias de ríos o ambientes costeros.',
  consejos=['No introduzcas objetos ni alimentos al agua.','Observa el nado desde el área permitida y no golpees los vidrios.','Consulta la programación del día para actividades educativas; no es un horario de alimentación.'],
  amenazas=['Contaminación, residuos y alteración de ambientes acuáticos.','Captura y conflictos con actividades humanas, según la especie.']),
 'Xenartros':dict(dieta='Variable según especie',alimentos=['Vegetación o invertebrados, según especie'],
  reconocimiento='Observa las garras, la forma del hocico y el modo de desplazarse. Perezosos, armadillos y osos hormigueros tienen adaptaciones muy distintas.',
  rol='Este grupo incluye consumidores de vegetación e insectos y especies que modifican el suelo al buscar alimento.',
  consejos=['Espera en silencio y busca el animal entre ramas o refugios.','No provoques movimiento ni intentes tocarlo.','Respeta su ritmo de descanso y evita el flash.'],
  amenazas=['Pérdida de hábitat y fragmentación de bosques.','Captura y comercio ilegal de fauna.']),
 'Herbívoros':dict(dieta='Herbívoro',alimentos=['Hojas','Pastos','Brotes','Frutos, según especie'],
  reconocimiento='Observa la forma de las patas, las orejas y los dientes o el hocico. Estas estructuras ayudan a explicar cómo obtiene su alimento.',
  rol='Los herbívoros transforman vegetación en alimento disponible para las redes tróficas; algunos también dispersan semillas.',
  consejos=['No ofrezcas comida aunque se acerque al borde.','Respeta la barrera y no intentes tocar al animal.','Observa cómo utiliza el hocico y las patas para alimentarse o desplazarse.'],
  amenazas=['Pérdida y fragmentación del hábitat natural.','Caza y conflictos con actividades humanas, según especie.']),
 'Otros mamíferos':dict(dieta='Variable según especie',alimentos=['Frutos','Invertebrados','Otros alimentos, según especie'],
  reconocimiento='Observa el hocico, las orejas, la cola y la forma de caminar. Cada especie presenta adaptaciones propias a su ambiente y alimentación.',
  rol='Estos mamíferos cumplen diferentes funciones como consumidores, depredadores y dispersores de semillas.',
  consejos=['Espera unos minutos en silencio si el animal se encuentra oculto.','No introduzcas comida, dedos ni objetos al recinto.','Observa sin golpear barreras ni usar flash.'],
  amenazas=['Pérdida de hábitats y conflictos con actividades humanas.','Captura y comercio de fauna silvestre.']),
 'Pingüinos':dict(dieta='Carnívoro',alimentos=['Peces pequeños','Calamares','Crustáceos'],
  reconocimiento='Observa el dorso oscuro, el vientre claro y las alas transformadas en aletas. El pingüino de Humboldt tiene una banda oscura en el pecho.',
  rol='Conecta las redes alimentarias del mar y la costa al capturar presas en el agua y descansar o reproducirse en tierra.',
  consejos=['Observa sus desplazamientos tanto en tierra como bajo el agua.','No golpees los vidrios ni ofrezcas alimentos.','Evita usar flash y respeta sus momentos de descanso.'],
  amenazas=['Alteraciones de los ecosistemas marinos y disponibilidad de alimento.','Captura incidental, contaminación y perturbación de zonas de reproducción.']),
}

RECOGNITION={
 'Panthera leo':'Los machos adultos suelen presentar melena. Observa el cuerpo robusto, las patas y la punta de la cola. La guía de Huachipa también menciona una leona blanca: es una variación de color del león.',
 'Panthera tigris':'Observa las rayas del pelaje; el patrón es distinto entre individuos. El pelaje blanco que menciona la guía del parque es una variación de color y no una especie diferente.',
 'Panthera pardus':'Busca las rosetas del pelaje, el cuerpo esbelto y la cola larga. El leopardo suele ser menos robusto que un jaguar.',
 'Panthera onca':'Observa el cuerpo robusto y las rosetas, que con frecuencia incluyen puntos en su interior. Jaguar y otorongo son nombres del mismo felino.',
 'Tremarctos ornatus':'Busca las marcas claras de la cara y el pecho, que varían entre individuos. Es el único oso nativo de Sudamérica.',
 'Giraffa camelopardalis':'Observa el cuello largo, las manchas y los osiconos de la cabeza. Los osiconos no son cuernos como los de un antílope.',
 'Equus quagga':'Observa el patrón de rayas y la crin. Las rayas son distintas entre individuos.',
 'Crocuta crocuta':'Busca el pelaje manchado y las patas delanteras más largas que las traseras, que dan al lomo un aspecto inclinado.',
 'Hydrochoerus hydrochaeris':'Observa el cuerpo robusto, las orejas pequeñas y los ojos altos en la cabeza, adaptaciones útiles para una vida cercana al agua.',
 'Platalea alba':'Su pico largo termina en una parte ancha y aplanada, con forma de cuchara. Observa cómo lo mueve al buscar alimento en aguas poco profundas.',
 'Eudocimus ruber':'El adulto tiene plumaje rojo intenso y pico largo y curvado. La intensidad del color depende de factores como edad y alimentación.',
 'Threskiornis aethiopicus':'Observa el plumaje blanco, la cabeza y cuello oscuros del adulto y el pico curvado.',
 'Pavo cristatus':'En el macho adulto destaca el tren de plumas decorativas con ocelos; las hembras presentan plumaje más discreto.',
 'Aix galericulata':'El macho adulto presenta un plumaje muy vistoso; la hembra tiene tonos más discretos. Compara la forma del pico y el comportamiento en el agua.',
 'Chrysolophus pictus':'El macho adulto presenta una cresta dorada y plumaje de colores intensos. La hembra muestra tonos pardos que facilitan el camuflaje.',
 'Tapirus terrestris':'Observa el hocico corto y flexible, parecido a una pequeña trompa, y su cuerpo robusto.',
 'Myrmecophaga tridactyla':'Busca el hocico alargado, la gran cola y la franja oscura diagonal del cuerpo. No tiene dientes.',
 'Lontra felina':'Es una nutria pequeña de ambiente costero, con pelaje denso y cuerpo alargado. No es la nutria marina del Pacífico norte, Enhydra lutris.',
 'Pteronura brasiliensis':'Observa la mancha clara de la garganta, la cola aplanada y el cuerpo alargado. También recibe el nombre de lobo de río.',
 'Otaria flavescens':'Observa las aletas y las pequeñas orejas externas. Los lobos marinos pertenecen a los otáridos y se distinguen de las focas verdaderas.',
}

# Resúmenes propios para taxones sin introducción en español en la API consultada.
SUPPLEMENT={
 'A23': 'La vicuña es un camélido silvestre de los Andes. Vive en pastizales de altura y presenta cuerpo esbelto y fibra muy fina. No debe confundirse con la alpaca doméstica.',
 'OS012': 'El escinco de fuego es un lagarto de bosques tropicales africanos. Presenta escamas brillantes y colores rojizos en los costados. Busca refugio y alimento cerca del suelo.',
 'OS014': 'El mono choro es un primate de los bosques tropicales de Sudamérica. Su pelaje denso y su cola prensil lo ayudan en la vida arborícola. Se alimenta principalmente de frutos y otros recursos del bosque.',
 'OS027': 'La tortuga de patas rojas es una tortuga terrestre de Sudamérica. Destacan las escamas rojizas o anaranjadas de sus patas y cabeza. Su caparazón forma parte del esqueleto y no se puede separar del cuerpo.',
 'OS065': 'El gavilán bicolor es una rapaz de bosques neotropicales. Su cuerpo y sus alas están adaptados para maniobrar entre la vegetación mientras busca presas.',
 'OS069': 'El inventario utiliza el nombre armadillo peludo andino. Es un mamífero con caparazón segmentado y pilosidad visible. La fuente taxonómica consultada agrupa este nombre con Dasyphractus vellerosus; se conserva el nombre original del reporte para no ocultar esa diferencia.',
 'OS115': 'Esta tortuga de agua dulce está registrada con el nombre Phrynops nasutus en OSINFOR y aparece como Mesoclemmys nasuta en la fuente taxonómica consultada. Habita ambientes acuáticos de Sudamérica tropical.',
 'OS127': 'Oxyrhopus fitzingeri es una serpiente nativa de Ecuador y Perú. El inventario de Huachipa la registra como culebra de costa. La apariencia de una serpiente no basta para decidir si es peligrosa o venenosa.',
}

def text(value):
    return re.sub(r'\s+',' ',value or '').strip()

def quote(value):
    return json.dumps(text(value),ensure_ascii=False).replace('$',r'\$')

def strings(values): return '['+', '.join(quote(v) for v in values)+']'

def reproduction(r):
    genus=r['cientifico'].split()[0]
    if r['grupo'] in ('Rapaces','Psitácidas','Aves acuáticas','Aves de bosque','Aves corredoras','Pingüinos'):
        return 'Ovípara: se reproduce por huevos. El nido, la incubación y el cuidado de las crías dependen de la especie. La presencia de huevos o crías en el parque debe confirmarse con su equipo.'
    if r['grupo']=='Anfibios':
        return 'Se reproduce por huevos en el agua. El desarrollo pasa por una fase de renacuajo antes de la transformación a la forma adulta.'
    if genus in ('Boa','Epicrates','Eunectes','Tiliqua'):
        return 'Da a luz crías vivas. Este tipo de reproducción la diferencia de otros reptiles que ponen huevos.'
    if r['grupo'] in ('Tortugas','Crocodilianos','Serpientes','Lagartos'):
        return 'Ovípara: pone huevos. Las condiciones de incubación y el desarrollo varían por especie; el parque maneja los nidos según las necesidades de cada ejemplar.'
    if genus in ('Macropus','Osphranter'):
        return 'Es un marsupial: la cría nace en una etapa muy temprana y continúa su desarrollo en el marsupio de la madre, alimentándose de leche.'
    return 'Vivípara: las crías se desarrollan en el cuerpo de la madre y, tras nacer, se alimentan de leche. El cuidado parental y la organización social varían según la especie.'

def feeding(r,g):
    genus=r['cientifico'].split()[0]
    diet=g['dieta'];food=g['alimentos']
    if genus in ('Saimiri','Saguinus','Sapajus','Plecturocebus','Callicebus','Callimico','Aotus'):
        return 'Omnívoro',['Frutos','Invertebrados','Otros alimentos vegetales, según especie']
    if genus in ('Ateles','Lagothrix','Pithecia','Cacajao'):
        return 'Principalmente frugívoro',['Frutos','Semillas','Hojas y otros vegetales']
    if genus=='Alouatta':return 'Principalmente folívoro',['Hojas','Frutos','Flores']
    if genus in ('Equus','Kobus','Lama','Vicugna','Camelus','Macropus'):
        return 'Herbívoro',['Pastos','Hierbas','Otros vegetales, según especie']
    if genus=='Giraffa':return 'Herbívoro',['Hojas de árboles','Brotes','Ramas tiernas']
    if genus=='Hydrochoerus':return 'Herbívoro',['Pastos','Plantas acuáticas','Otros vegetales']
    if genus=='Vultur': return 'Carroñero',['Carroña de vertebrados']
    if genus in ('Myrmecophaga','Tamandua'):return 'Insectívoro',['Hormigas','Termitas']
    if genus in ('Bradypus','Choloepus'):return 'Principalmente folívoro',['Hojas','Brotes','Frutos, según especie']
    if genus in ('Chaetophractus','Cabassous'):return 'Principalmente insectívoro',['Invertebrados del suelo','Otros alimentos, según especie']
    if genus in ('Tremarctos',):return 'Omnívoro, principalmente vegetal',['Frutos','Bromelias','Brotes','Otros alimentos de temporada']
    if genus in ('Crocuta','Galictis'):return 'Carnívoro',['Vertebrados','Otras presas, según especie']
    if genus in ('Lycalopex','Nasua'):return 'Omnívoro',['Frutos','Invertebrados','Vertebrados pequeños']
    if genus=='Potos':return 'Principalmente frugívoro',['Frutos','Néctar','Otros alimentos de origen vegetal']
    if genus=='Iguana':return 'Principalmente herbívoro',['Hojas','Flores','Frutos']
    if genus=='Dracaena':return 'Carnívoro especializado',['Caracoles','Otros invertebrados acuáticos']
    if genus in ('Chamaeleo','Eublepharis'):return 'Insectívoro',['Insectos','Otros invertebrados']
    if genus in ('Lepidothyris','Mochlus','Pogona','Tiliqua'):return 'Omnívoro',['Invertebrados','Materia vegetal, según especie']
    if genus=='Chelonoidis':return 'Principalmente herbívoro',['Hojas','Frutos','Flores','Otros alimentos de temporada']
    if genus=='Podocnemis':return 'Principalmente herbívoro',['Vegetación acuática','Frutos','Otros alimentos, según edad']
    if genus in ('Mesoclemmys','Phrynops'):return 'Principalmente carnívoro',['Invertebrados acuáticos','Peces','Otras presas pequeñas']
    if genus=='Phoenicopterus':return 'Filtrador',['Pequeños crustáceos','Algas','Otros organismos acuáticos']
    if genus in ('Platalea','Threskiornis','Eudocimus','Nycticorax','Jabiru'):return 'Principalmente carnívoro',['Invertebrados acuáticos','Peces y otras presas pequeñas']
    if genus in ('Ramphastos','Pteroglossus'):return 'Principalmente frugívoro',['Frutos','Invertebrados','Otras presas ocasionales']
    if genus in ('Mitu','Penelope','Ortalis','Patagioenas'):return 'Principalmente herbívoro',['Frutos','Semillas','Brotes y otros vegetales']
    if genus in ('Otaria',):return 'Carnívoro',['Peces','Calamares','Otras presas marinas']
    if genus in ('Pteronura','Lontra'):return 'Carnívoro',['Peces','Crustáceos','Otras presas acuáticas']
    return diet,food

def excerpt_sentences(value):
    value=text(value)
    return re.split(r'(?<=[.!?])\s+(?=[A-ZÁÉÍÓÚ])',value)

status_names={'LC':'Preocupación menor','NT':'Casi amenazado','VU':'Vulnerable',
              'EN':'En peligro','CR':'En peligro crítico','DD':'Datos insuficientes',
              'EW':'Extinto en estado silvestre','EX':'Extinto'}
lines=["// GENERADO por scripts/generar_catalogo_fauna.py. Editar docs/fauna/catalogo_huachipa.json.",
       "import '../models/datos_animal.dart';",'',
       'class RegistroFauna {',
       '  final String id, nombre, zona;',
       '  final double x, y;',
       '  final bool enMapa;',
       '  final DatosAnimal datos;',
       '  const RegistroFauna({required this.id, required this.nombre, required this.zona,',
       '    required this.x, required this.y, required this.enMapa, required this.datos});','}',
       '', 'const int especiesReportadasHuachipa = 152;',
       "const String fechaReporteEspeciesHuachipa = '10/10/2025';",
       "const String fuenteReporteEspeciesHuachipa = 'https://www.gob.pe/institucion/munilima/noticias/1261823-el-alcalde-de-lima-apertura-un-nuevo-hospital-veterinario-en-huachipa-los-reyes-del-zoologico-tienen-su-clinica-top';",
       '', 'const List<RegistroFauna> catalogoFauna = [']
for r in records:
    if not r.get('foto',{}).get('asset'): raise SystemExit('Falta foto de '+r['id'])
    g=GROUPS[r['grupo']];old=r.get('perfil_previo',{});photo=r['foto']
    if r['id'] in {'A01','A15','A28','A29','A31','A32','A34','A35','A37','A38','A39','A42','A43','A44','A48'}:
        old={}
    summary=text(r.get('wiki_resumen',''))
    if summary.endswith(('...', '…')):
        complete=summary[:-3] if summary.endswith('...') else summary[:-1]
        end=complete.rfind('.')
        if end>80: summary=complete[:end+1]
    if len(summary.split())>180: summary=' '.join(excerpt_sentences(summary)[:3])
    if not summary: summary=SUPPLEMENT.get(r['id']) or old.get('comportamiento') or f"{r['nombre']} pertenece al grupo {r['grupo'].lower()}. Consulta la fuente biológica enlazada para conocer su clasificación y distribución."
    recognition=RECOGNITION.get(r['cientifico']) or next((s for s in excerpt_sentences(summary) if re.search(r'plumaje|pelaje|se caracteriza|pico|coloraci|color |mide|longitud',s,re.I)),g['reconocimiento'])
    distribution=old.get('distribucion') or next((s for s in excerpt_sentences(summary) if re.search(r'distribu|habita|nativ|oriund|endémic|se encuentra|originari|desde|África|América|Sudamérica|Asia|Australia',s,re.I)),'Consulta el área de distribución en la fuente biológica de esta especie.')
    diet,foods=feeding(r,g)
    cs=r.get('estado_conservacion') or {}
    status=status_names.get(str(cs.get('status','')).upper(),'Sin categoría global verificada') if 'IUCN' in (cs.get('authority') or '') and not cs.get('place') else 'Sin categoría global verificada'
    tips=g['consejos']
    threats=g['amenazas']
    if r['cientifico'] in ('Lama glama','Vicugna pacos','Camelus sp.'):
        status='Animal domesticado'
        threats=['El bienestar requiere alimento adecuado, agua, espacio y atención especializada.','Evita alimentar o manipular al ejemplar durante la visita.']
    if r['id']=='OS069': status='Consultar evaluación del taxón registrado'
    if r['cientifico']=='Hydrochoerus hydrochaeris':
        tips=['Observa la relación entre el estanque y las zonas de descanso.','No ofrezcas comida ni intentes acariciar a los ejemplares.','Si permanece oculto, espera con calma y consulta al equipo del parque.']
    refs=[(r['fuente_nombre'],r['fuente_presencia'])]
    if r.get('fuente_biologia'):refs.append(('Perfil biológico e identificación · iNaturalist',r['fuente_biologia']))
    if r.get('fuente_wikipedia'):refs.append(('Resumen biológico · Wikipedia (CC BY-SA)',r['fuente_wikipedia']))
    if cs.get('url') and 'IUCN' in (cs.get('authority') or ''):refs.append(('Evaluación de conservación · IUCN',cs['url']))
    description=summary
    behavior=old.get('comportamiento') or next((s for s in excerpt_sentences(summary) if re.search('social|solitari|grupos|nocturn|diurn|arbóre|aliment',s,re.I)),g['reconocimiento'])
    curiosity=old.get('curiosidad') or next((s for s in excerpt_sentences(summary) if re.search('únic|cola|mayor|menor|especial|capaz',s,re.I)),g['rol'])
    narration=old.get('narracion') if r['id'].startswith('A') and old.get('narracion') else f"Conoce a {r['nombre']}. {description} {tips[0]}"
    if r['nombre']=='Tigre de Bengala':
        # El inventario respalda la especie; la guía reciente menciona el nombre de Bengala.
        pass
    values=dict(dieta=diet,alimentos=foods,horaApertura='9:00 a. m.',horaCierre='5:00 p. m.',
        habitat=r['zona'],comportamiento=behavior,nombreCientifico=r['cientifico'],
        curiosidad=curiosity,estadoConservacion=status,narracionAudioguia=narration,
        distribucion=distribution,fuente=r['fuente_nombre'],descripcion=description,
        reconocimiento=recognition,reproduccion=reproduction(r),rolEcologico=g['rol'],
        recomendaciones=tips,amenazas=threats,referenciaPresencia=r['referencia'],
        imagen=photo['asset'],autorImagen=photo['autor'],licenciaImagen=photo['licencia'],
        urlImagen=photo['fuente'],notaImagen=photo['nota'])
    lines.extend(['  RegistroFauna(',f"    id: {quote(r['id'])}, nombre: {quote(r['nombre'])}, zona: {quote(r['zona'])},",
        f"    x: {float(r['x'])}, y: {float(r['y'])}, enMapa: {str(r['en_mapa']).lower()},",'    datos: DatosAnimal('])
    for key,value in values.items():lines.append('      '+key+': '+(strings(value) if isinstance(value,list) else quote(value))+',')
    lines.append('      registroHistorico: '+str(r['fecha_registro']<'2025-01-01').lower()+',')
    lines.append('      fuentes: [')
    for title,url in refs:lines.append(f'        ReferenciaAnimal(titulo: {quote(title)}, url: {quote(url)}),')
    lines.extend(['      ],','    ),','  ),'])
lines.append('];')
(ROOT/'lib/core/data/catalogo_fauna.dart').write_text('\n'.join(lines)+'\n',encoding='utf-8')
(ROOT/'lib/core/data/base_datos_animales.dart').write_text("""import '../models/datos_animal.dart';
import 'catalogo_fauna.dart';

/// Un único catálogo respalda tanto las fichas como sus fotografías y marcadores.
final Map<String, DatosAnimal> baseDatosAnimales = Map.unmodifiable({
  for (final registro in catalogoFauna) registro.nombre: registro.datos,
});
""",encoding='utf-8')
markerfile=ROOT/'lib/core/data/datos_marcadores.dart'
previous=markerfile.read_text(encoding='utf-8-sig')
bathrooms=previous[previous.index('/// Baños actualmente'):]
markerfile.write_text("""import 'package:flutter/material.dart';
import '../models/marcador_mapa.dart';
import 'catalogo_fauna.dart';

/// Las fichas históricas sin ubicación documentada se consultan desde el catálogo.
/// Los puntos conservados del plano son referencias aproximadas por zona.
final List<MarcadorMapa> marcadoresZoologico = [
  for (final registro in catalogoFauna)
    MarcadorMapa(
      id: registro.id, nombre: registro.nombre,
      x: registro.x, y: registro.y,
      habitat: registro.zona, imagen: registro.datos.imagen,
      tieneUbicacionMapa: registro.enMapa,
    ),
];

"""+bathrooms,encoding='utf-8')
print(f'{len(records)} fichas generadas con fotografía, créditos y referencias.')
