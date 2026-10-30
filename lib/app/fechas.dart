const List<String> diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

const List<String> _diasLargos = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const List<String> _meses = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

String nombreMes(DateTime fecha) => _meses[fecha.month - 1];

String fechaLarga(DateTime fecha) =>
    '${_diasLargos[fecha.weekday - 1]} ${fecha.day} de ${nombreMes(fecha).toLowerCase()}';

String fechaCorta(DateTime fecha) =>
    '${diasCortos[fecha.weekday - 1]} ${fecha.day}/${fecha.month}';

String horaTexto(DateTime fecha) =>
    '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;