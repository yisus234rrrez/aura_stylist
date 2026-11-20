import 'dart:convert';

import 'package:aura_stylist/services/remote/api_service.dart';
import 'package:aura_stylist/services/remote/aura_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Map<String, dynamic> _clientes = <String, dynamic>{
  'data': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'documento': '1019742901',
      'nombres': 'Valentina',
      'apellidos': 'Restrepo Duque',
      'fechaNacimiento': '1995-09-14',
      'celular': '+57 312 458 9012',
      'correo': 'valentina.restrepo@email.com',
    },
    <String, dynamic>{
      'id': 2,
      'documento': '1020481230',
      'nombres': 'Camila',
      'apellidos': 'Morales Gómez',
      'fechaNacimiento': '1998-04-21',
      'celular': '+57 315 890 2341',
      'correo': 'camila.morales@outlook.com',
    },
  ],
};

const Map<String, dynamic> _especialidades = <String, dynamic>{
  'data': <Map<String, dynamic>>[
    <String, dynamic>{'id': 1, 'nombre': 'Peluquería y Colorimetría', 'activa': true},
    <String, dynamic>{'id': 2, 'nombre': 'Estética de Uñas y Manicure', 'activa': true},
    <String, dynamic>{'id': 3, 'nombre': 'Cuidado Facial y Piel', 'activa': true},
  ],
};

const Map<String, dynamic> _servicios = <String, dynamic>{
  'data': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'nombre': 'Balayage Iluminado Botánico',
      'precio': 280000,
      'descripcion': 'Incluye matización orgánica',
      'duracion': 180,
      'activo': true,
      'especialidadId': 1,
    },
    <String, dynamic>{
      'id': 2,
      'nombre': 'Corte de Estilo & Brushing',
      'precio': 95000,
      'descripcion': 'Corte y secado',
      'duracion': 60,
      'activo': true,
      'especialidadId': 1,
    },
    <String, dynamic>{
      'id': 3,
      'nombre': 'Manicure Spa Ruso',
      'precio': 120000,
      'descripcion': 'Cuidado de cutícula',
      'duracion': 75,
      'activo': true,
      'especialidadId': 2,
    },
  ],
};

const Map<String, dynamic> _profesionales = <String, dynamic>{
  'data': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'documento': '1020485932',
      'nombres': 'Laura',
      'apellidos': 'Gómez Restrepo',
      'fechaNacimiento': '1989-05-14',
      'porcentaje': 45,
      'estado': true,
      'especialidadId': 1,
      'especialidad': <String, dynamic>{
        'id': 1,
        'nombre': 'Peluquería y Colorimetría',
      },
    },
    <String, dynamic>{
      'id': 2,
      'documento': '1032647110',
      'nombres': 'Sofía',
      'apellidos': 'Peña Valderrama',
      'fechaNacimiento': '1995-09-22',
      'porcentaje': 40,
      'estado': true,
      'especialidadId': 2,
      'especialidad': <String, dynamic>{
        'id': 2,
        'nombre': 'Estética de Uñas y Manicure',
      },
    },
  ],
};

const Map<String, dynamic> _liquidaciones = <String, dynamic>{
  'data': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'fechaInicio': '2026-10-01',
      'fechaFin': '2026-10-15',
      'totalFacturado': 22800000,
      'subtotalComisionNegocio': 11400000,
      'subtotalComisionProfesionales': 11400000,
    },
    <String, dynamic>{
      'id': 2,
      'fechaInicio': '2026-10-16',
      'fechaFin': '2026-10-31',
      'totalFacturado': 0,
      'subtotalComisionNegocio': 0,
      'subtotalComisionProfesionales': 0,
    },
  ],
};

const Map<String, dynamic> _comisiones = <String, dynamic>{
  'data': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'profesionalId': 1,
      'profesionalNombre': 'Laura G.',
      'total': 3270000,
      'porcentaje': 45,
      'servicios': 34,
      'estado': 'Preliminar',
    },
    <String, dynamic>{
      'id': 2,
      'profesionalId': 2,
      'profesionalNombre': 'Sofía P.',
      'total': 1740000,
      'porcentaje': 40,
      'servicios': 28,
      'estado': 'Preliminar',
    },
  ],
};

const Map<String, dynamic> _horarios = <String, dynamic>{
  'data': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'profesionalId': 1,
      'diaSemana': 1,
      'horaInicio': '08:00:00',
      'horaFin': '18:00:00',
      'tieneAlmuerzo': true,
      'horaInicioAlmuerzo': '13:00:00',
      'horaFinAlmuerzo': '14:00:00',
    },
  ],
};

Map<String, dynamic> _responseFor(String path) {
  if (path.contains('/api/clientes/')) {
    final String document = path.split('/').last;
    final List<Map<String, dynamic>> items =
        (_clientes['data'] as List<dynamic>).cast<Map<String, dynamic>>();
    Map<String, dynamic>? match;
    for (final Map<String, dynamic> item in items) {
      if ('${item['documento']}' == document) {
        match = item;
        break;
      }
    }
    return <String, dynamic>{'data': match ?? items.first};
  }
  if (path.endsWith('/api/clientes')) return _clientes;
  if (path.endsWith('/api/especialidades')) return _especialidades;
  if (path.endsWith('/api/servicios')) return _servicios;
  if (path.endsWith('/api/profesionales')) return _profesionales;
  if (path.contains('/api/comisiones/') && path.endsWith('/servicios')) {
    return <String, dynamic>{
      'data': <String, dynamic>{
        'id': 7,
        'liquidacionComisionId': 18,
        'porcentaje': 35,
        'subTotal': 70000,
        'total': 24500,
        'comisionServicios': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 11,
            'servicioId': 71,
            'precio': 35000,
            'valorComision': 12250,
            'fechaServicio': '2026-11-18T00:00:00',
            'servicio': <String, dynamic>{
              'id': 71,
              'nombre': 'Corte de Cabello',
            },
          },
        ],
      },
    };
  }
  if (path.endsWith('/api/comisiones')) return _comisiones;
  if (path.endsWith('/api/horarios-laboral')) return _horarios;
  if (path.contains('/api/agenda/')) {
    return <String, dynamic>{
      'data': <Map<String, dynamic>>[
        <String, dynamic>{
          'profesionalId': 1,
          'profesionalNombre': 'Laura Gómez Restrepo',
          'totalSlots': 1,
          'totalDisponibles': 0,
          'totalOcupados': 1,
          'slots': <Map<String, dynamic>>[
            <String, dynamic>{
              'horaInicio': '2026-11-18 09:00:00',
              'horaFin': '2026-11-18 09:45:00',
              'disponible': false,
              'reserva': <String, dynamic>{
                'id': 500,
                'fechaInicio': '2026-11-18 09:00:00',
                'fechaFin': '2026-11-18 09:45:00',
                'cliente': <String, dynamic>{
                  'id': 1,
                  'nombre': 'Valentina Restrepo Duque',
                },
                'servicio': <String, dynamic>{
                  'id': 1,
                  'nombre': 'Balayage Iluminado Botánico',
                  'precio': 280000,
                },
              },
            },
          ],
        },
      ],
    };
  }
  if (path.endsWith('/api/reservas')) {
    return <String, dynamic>{
      'data': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 500,
          'fecha': '2026-11-18',
          'horaInicio': '09:00:00',
          'horaFin': '09:45:00',
          'clienteId': 1,
          'servicioId': 1,
          'profesionalId': 1,
          'estado': 2,
        },
        <String, dynamic>{
          'id': 601,
          'fecha': '2026-11-18',
          'horaInicio': '14:00:00',
          'horaFin': '15:00:00',
          'clienteId': 2,
          'servicioId': 2,
          'profesionalId': 2,
          'estado': 1,
          'cliente': <String, dynamic>{
            'nombres': 'Camila',
            'apellidos': 'Morales Gómez',
          },
          'servicio': <String, dynamic>{'nombre': 'Manicure Spa Ruso'},
          'profesional': <String, dynamic>{
            'nombres': 'Sofía',
            'apellidos': 'Peña Valderrama',
          },
        },
      ],
    };
  }
  if (path.endsWith('/api/agenda')) {
    return <String, dynamic>{
      'data': <Map<String, dynamic>>[
        <String, dynamic>{'fecha': '2026-11-16 08:00'},
        <String, dynamic>{'fecha': '2026-11-16 08:30'},
      ],
    };
  }
  if (path.endsWith('/api/liquidaciones-comisiones')) return _liquidaciones;
  return <String, dynamic>{'data': <dynamic>[]};
}

void configureMockApi() {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  FlutterSecureStorage.setMockInitialValues(<String, String>{});

  AuraApi.api = ApiService(
    baseUrl: 'https://test.local',
    client: MockClient((http.Request request) async {
      final String path = request.url.path.toLowerCase();
      if (path.endsWith('/api/sesion')) {
        final Map<String, dynamic> body = request.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(request.body) as Map<String, dynamic>;
        final bool valid = (body['usuario'] == '1102822682' &&
                body['clave'] == '1102822682') ||
            (body['usuario'] == '123456789' && body['clave'] == '123456789');
        if (!valid) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'success': false,
              'message': 'Credenciales inválidas.',
            }),
            401,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode(<String, dynamic>{
            'accessToken': 'test-token',
            'tokenType': 'bearer',
            'expiresIn': 3600,
            'empresaId': 1,
            'empresaNombre': 'Test',
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }

      if (request.method == 'GET' &&
          path.endsWith('/api/liquidaciones-comisiones') &&
          request.url.queryParameters['ultimo'] == 'true') {

        return http.Response(
          jsonEncode(<String, dynamic>{
            'data': (_liquidaciones['data'] as List<dynamic>).first,
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }

      if (request.method == 'GET') {
        return http.Response(
          jsonEncode(_responseFor(path)),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }

      return http.Response(
        jsonEncode(<String, dynamic>{'success': true, 'data': <dynamic>[]}),
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    }),
  );
}
