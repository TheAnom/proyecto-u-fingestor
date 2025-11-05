# FinGestor - Sistema de Gestión Académica y Financiera

[Proyecto Propuesta](./01_intro)

[Base de Datos](./02_database)


Sistema web desarrollado en Ruby on Rails para la administración integral de instituciones educativas, incluyendo gestión de estudiantes, control de pagos, asignación de cursos y generación de reportes.

## Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Requisitos del Sistema](#requisitos-del-sistema)
3. [Instalación y Configuración](#instalación-y-configuración)
4. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
5. [Modelos de Datos](#modelos-de-datos)
6. [Funcionalidades](#funcionalidades)
7. [Seguridad y Autenticación](#seguridad-y-autenticación)
8. [API REST](#api-rest)
9. [Guía de Usuario](#guía-de-usuario)
10. [Mantenimiento y Despliegue](#mantenimiento-y-despliegue)

## Descripción General

FinGestor es una aplicación web desarrollada con Ruby on Rails para la gestión integral de instituciones educativas. El sistema centraliza la administración de estudiantes, pagos, cursos y reportes académicos, facilitando el control financiero y académico de manera eficiente y segura.

### Características Principales

- Registro y administración completa de estudiantes
- Control de pagos por múltiples conceptos (inscripción, mensualidades, exámenes, papelería)
- Asignación de estudiantes a cursos con seguimiento de calificaciones
- Sistema de roles con permisos diferenciados (Administrador, Suplente)
- Generación de reportes mensuales y estados de cuenta en formato PDF
- API REST para integración con sistemas externos
- Interfaz responsiva con notificaciones en tiempo real
- Paginación automática en todas las tablas de datos
- Sistema de búsqueda y filtrado de información
- Validaciones exhaustivas de integridad de datos

### Público Objetivo

- Administradores de instituciones educativas
- Personal de caja y administración financiera
- Consultores y personal académico

## Requisitos del Sistema

### Software Requerido

| Componente | Versión Mínima | Notas |
|------------|-----------------|-------|
| Ruby | 3.2+ | Lenguaje de programación |
| Rails | 8.1.1 | Framework web |
| SQLite3 | 3.8+ | Base de datos (incluida por defecto) |
| Bundler | 2.4+ | Gestor de dependencias |

## Instalación

### Paso 1: Clonar el Repositorio

```bash
git clone <repository-url>
cd fingestor-proyecto
```

### Paso 2: Instalar Dependencias

```bash
bundle install
```

### Paso 3: Preparar Base de Datos

```bash
bin/rails db:prepare
bin/rails db:seed
```

Esto creará:
- Base de datos SQLite3 en `db/development.sqlite3`
- Roles: Administrador y Suplente
- Usuario admin (password: Admin1234)
- Grados académicos
- Conceptos de pago

### Paso 4: Iniciar Servidor

```bash
bin/rails server
```

Acceder en: http://localhost:3000

### Credenciales Iniciales

| Usuario | Password | Rol |
|---------|----------|-----|
| admin | Admin1234 | Administrador |

## Stack y Arquitectura

### Stack Tecnológico

| Componente | Tecnología | Descripción |
|------------|------------|-------------|
| Framework | Rails 8.1.1 | Framework web MVC |
| Base de Datos | SQLite3 | Base de datos SQL embebida |
| Frontend | Hotwire (Turbo/Stimulus) | Interactividad dinámica |
| Estilos | Tailwind CSS | Framework CSS utility-first |
| Servidor | Puma | Servidor HTTP concurrente |
| Autenticación | BCrypt | Hashing de contraseñas |
| PDF | Prawn | Generación de reportes |
| Paginación | Kaminari | Control de listados |

### Gemas Principales

```ruby
gem 'rails', '~> 8.1.1'     # Framework web
gem 'sqlite3'                # Base de datos
gem 'puma'                   # Servidor HTTP
gem 'bcrypt'                 # Encriptación
gem 'prawn'                  # PDFs
gem 'kaminari'               # Paginación
gem 'tailwindcss-rails'      # Estilos
gem 'turbo-rails'            # Hotwire Turbo
gem 'stimulus-rails'         # Hotwire Stimulus
gem 'jbuilder'               # JSON
```

### Estructura de Directorios

| Directorio | Contenido | Descripción |
|------------|-----------|-------------|
| app/controllers | Controladores | Lógica de aplicación y endpoints |
| app/models | Modelos ActiveRecord | Entidades y lógica de negocio |
| app/views | Vistas ERB | Templates HTML |
| app/assets | Archivos estáticos | Imágenes, estilos, JavaScript |
| config/ | Configuración | Routes, database, environments |
| db/migrate | Migraciones | Cambios de esquema de BD |
| db/seeds.rb | Datos iniciales | Datos de demostración y configuración |
| lib/ | Librerías | Código personalizado reutilizable |
| test/ | Tests | Pruebas automatizadas |
| Gemfile | Dependencias | Gemas Ruby necesarias |

## Modelos y Relaciones

- **Estudiante**
  - belongs_to `Grado`
  - has_many `Pagos` (dependent: destroy)
  - has_many `AsignacionCurso` (dependent: destroy)
  - has_many `Cursos`, through: `AsignacionCurso`
  - Validaciones: `nombre_completo` requerido

- **Pago**
  - belongs_to `ConceptoPago`, `Estudiante`, `Usuario`
  - Validaciones: `monto` > 0, `fecha` requerida

- **Curso**
  - belongs_to `Profesor`
  - has_many `AsignacionCurso` y `Estudiantes` (through)

- **AsignacionCurso**
  - belongs_to `Estudiante`, `Curso`
  - Validaciones: `nota` en 0..100 (opcional) y unicidad por `[estudiante_id, curso_id]`

- **Profesor**: has_many `Cursos`

- **Grado**: has_many `Estudiantes`

- **ConceptoPago**: has_many `Pagos`

- **Usuario**
  - belongs_to `Rol`
  - has_many `Pagos`
  - `has_secure_password` y `has_secure_token :api_token`
  - Validaciones: `nombre` único, password ≥ 8 (allow_nil)

  | nombre | string | Requerido, único, 3-50 chars | Username |
  | password_digest | string | Hashed con bcrypt | Contraseña encriptada |
  | rol_id | integer | Requerido, FK | Rol asignado |
  | api_token | string | Generado automáticamente | Token para API |

  **Validaciones:**
  - Password mínimo 8 caracteres con mayúscula, minúscula y número
  - Username alfanumérico con guiones bajos
  - Unicidad de username case-insensitive
  - Solo roles Administrador o Suplente permitidos

- **Rol**: has_many `Usuarios`; has_many `Permisos` through `PermisoRol`

- **Permiso / PermisoRol**: relación many-to-many para permisos por rol

## Funcionalidades

### Módulo de Ingresos

**Ruta:** `/dashboard/ingresos`

| Funcionalidad | Descripción | Permisos |
|---------------|-------------|----------|
| Registro de estudiantes | Alta rápida con validaciones | Administrador, Suplente |
| Registro de pagos | Asociación estudiante-concepto-monto | Administrador, Suplente |
| Listado paginado | 20 registros por página | Administrador, Suplente |
| Edición inline | Modificación de datos sin recargar | Administrador, Suplente |
| Eliminación | Con confirmación y refresh automático | Administrador |
| Notificaciones visuales | Feedback en tiempo real | Todos |

### Módulo de Consultas

**Ruta:** `/dashboard/consultas`

**Información disponible:**
- Pagos por concepto (Inscripción, Enero-Noviembre)
- Estado de solvencia mensual
- Pagos de exámenes y papelería
- Cursos asignados con calificaciones
- Promedio general del estudiante

### Módulo de Control de Usuarios

**Ruta:** `/dashboard/control_usuarios`

**Acceso:** Solo Administrador

| Sección | Operaciones | Características |
|----------|-------------|-------------------|
| Usuarios | CRUD completo | Roles, password con toggle visibility |
| Cursos | CRUD completo | Asignación de profesores |
| Profesores | CRUD completo | Información de contacto |
| Asignaciones | CRUD completo | Estudiante-curso-nota |

**Características especiales:**
- Paginación en todas las tablas (20 por página)
- Actualización automática post-acción
- Validaciones con errores por campo
- Notificaciones toast
- Campo password con icono de mostrar/ocultar

### Módulo de Reportes

#### Reporte Mensual

**Ruta:** `/reportes/mensual`

**Contenido:**
- Filtrado por rango de fechas
- Total de ingresos
- Desglose por concepto de pago
- Listado detallado de transacciones

**Formatos de exportación:**
- HTML (vista en navegador)
- JSON (integración con sistemas)
- PDF (documento imprimible)

#### Estado de Cuenta

**Ruta:** `/reportes/estado_cuenta`

**Contenido:**
- Historial completo de pagos por estudiante
- Total pagado
- Desglose por concepto

**Formatos:** HTML, JSON, PDF

## Rutas del Sistema

### Rutas Web Principales

- `GET /` → Home#index
- Autenticación: `GET /login`, `POST /login`, `DELETE /logout`
- Dashboard:
  - `GET /dashboard` (estadísticas)
  - `GET|POST /dashboard/ingresos` (formulario y alta rápida de estudiante + listado de pagos)
  - `POST /dashboard/guardar_pago`
  - `GET /dashboard/consultas`
  - `GET /dashboard/consultas_datos` (JSON detallado de estudiante seleccionado)
  - Administración (solo administrador):
    - `GET /dashboard/control_usuarios`
    - `POST /dashboard/guardar_usuario`
    - `POST /dashboard/guardar_curso`
    - `POST /dashboard/guardar_profesor`
    - `POST /dashboard/guardar_asignacion`
- Recursos mínimos (update/destroy): `estudiantes`, `pagos`, `asignacion_cursos`, `cursos`, `profesores`, `usuarios`
- Reportes:
  - `GET /reportes/mensual` (HTML, JSON, PDF)
  - `GET /reportes/estado_cuenta` (HTML, JSON, PDF)

## Flujos Funcionales

- **Ingreso de pagos y alta rápida de estudiantes** (`/dashboard/ingresos`)
  - Lista estudiantes y conceptos; permite crear estudiante y registrar pagos con fecha del día.

- **Consultas** (`/dashboard/consultas` + `consultas_datos`)
  - Devuelve en JSON los pagos por concepto (Inscripción, Enero..Noviembre), solvencia del mes actual, estado de exámenes/papelería, asignaciones y promedio.

- **Control de usuarios y catálogo** (`/dashboard/control_usuarios`)
  - Alta/edición de usuarios, cursos, profesores y asignaciones. Restringido a administrador.

- **Reportes**
  - **Mensual**: filtro por fecha, totales, agrupado por concepto. Exporta HTML/JSON/PDF.
  - **Estado de cuenta**: por estudiante, totales y detalle. Exporta HTML/JSON/PDF.

## Seguridad y Autenticación

### Sistema de Autenticación

| Componente | Implementación | Descripción |
|------------|------------------|-------------|
| Hashing de contraseñas | BCrypt | Algoritmo de encriptación irreversible |
| Sesiones | Rails session cookie | Almacenamiento seguro del usuario_id |
| Timeout | 30 minutos | Expiración automática por inactividad |
| Throttling | 10 intentos/5min | Protección contra fuerza bruta |
| API Token | has_secure_token | Token regenerable para API REST |

### Roles y Permisos

| Rol | Acceso Dashboard | Acceso Control Usuarios | Acceso Reportes | API |
|-----|-----------------|-------------------------|-----------------|-----|
| Administrador | Completo | Sí | Sí | Sí |
| Suplente | Completo | No | No | Sí |
| Consultor | Solo consultas | No | Sí | Sí |

### Validaciones de Seguridad

**Contraseñas:**
- Mínimo 8 caracteres
- Al menos una mayúscula
- Al menos una minúscula
- Al menos un número
- Validación solo en creación o cambio explícito

**Sesiones:**
- Regeneración de ID tras login exitoso
- Verificación de actividad cada request
- Limpieza automática tras timeout

**Protección contra ataques:**
- CSRF protection habilitado (Rails default)
- Strong parameters en todos los controladores
- Throttling de login por IP
- Validación estricta de entrada de datos

## API REST

### Endpoints Disponibles

**Base URL:** `/api/v1`

#### Autenticación API

**Método:** Bearer Token en header Authorization

```bash
Authorization: Bearer <api_token>
```

**Obtener token:**

```bash
rails console
Usuario.find_by(nombre: 'admin').api_token
```

#### Estudiantes

| Método | Endpoint | Descripción | Respuesta |
|---------|----------|-------------|----------|
| GET | `/api/v1/estudiantes` | Listar todos | JSON array |
| GET | `/api/v1/estudiantes/:id` | Detalle individual | JSON object |

**Ejemplo de respuesta:**

```json
{
  "id": 1,
  "nombre_completo": "Juan Pérez",
  "telefono": "12345678",
  "grado_id": 1,
  "institucion": "Colegio Nacional"
}
```

#### Pagos

| Método | Endpoint | Descripción | Parámetros |
|---------|----------|-------------|------------|
| GET | `/api/v1/pagos` | Listar pagos | `estudiante_id`, `desde`, `hasta` |

**Ejemplo:**

```bash
curl -H "Authorization: Bearer TOKEN" \
  "http://localhost:3000/api/v1/pagos?estudiante_id=1"
```

### Rate Limiting

- 60 peticiones por minuto por usuario
- 429 Too Many Requests si se excede
- Conteo por api_token o IP

### Códigos de Respuesta

| Código | Significado | Uso |
|--------|-------------|-----|
| 200 | OK | Petición exitosa |
| 401 | Unauthorized | Token inválido o ausente |
| 404 | Not Found | Recurso no existe |
| 422 | Unprocessable Entity | Validaciones fallidas |
| 429 | Too Many Requests | Rate limit excedido |

## Datos Iniciales (Seeds)

### Contenido del Seed

El archivo `db/seeds.rb` crea los datos iniciales necesarios:

| Tipo | Cantidad | Descripción |
|------|----------|-------------|
| Roles | 2 | Administrador, Suplente |
| Usuarios | 1 | admin (contraseña: Admin1234) |
| Grados | Variable | Niveles educativos |
| Conceptos de Pago | Variable | Inscripción, Mensualidades, Exámenes, Papelería |

### Ejecución

```bash
bin/rails db:seed
```

**Nota:** Si necesitas recargar los seeds:

```bash
bin/rails db:reset  # Elimina y recrea la BD
bin/rails db:seed   # Recarga los datos
```

## Guía de Usuario

### Primer Acceso al Sistema

1. Abrir navegador en `http://localhost:3000`
2. Iniciar sesión con credenciales de administrador
3. El sistema redirige automáticamente al dashboard

### Flujo de Trabajo: Registro de Pago

| Paso | Acción | Resultado |
|------|--------|----------|
| 1 | Navegar a Dashboard > Ingresos | Vista con formularios |
| 2 | Buscar o crear estudiante | Estudiante seleccionado |
| 3 | Seleccionar concepto de pago | Concepto asignado |
| 4 | Ingresar monto | Monto registrado |
| 5 | Guardar pago | Notificación y refresh |

### Flujo de Trabajo: Generar Reporte

1. Navegar a **Reportes > Mensual**
2. Seleccionar rango de fechas
3. Elegir formato de exportación (HTML/JSON/PDF)
4. Descargar o visualizar reporte

### Gestión de Usuarios (Solo Administrador)

1. Navegar a **Dashboard > Control de Usuarios**
2. Seleccionar sección (Usuarios/Cursos/Profesores/Asignaciones)
3. Usar formulario para operaciones CRUD
4. Confirmar acciones de eliminación

**Características especiales:**
- Campo password con icono para mostrar/ocultar
- Actualización automática tras cada acción
- Notificaciones visuales de éxito/error
- Paginación automática en tablas grandes

## Mantenimiento y Despliegue

### Comandos Útiles

| Comando | Propósito | Uso |
|---------|----------|-----|
| `bin/rails db:migrate` | Ejecutar migraciones | Después de cambios en esquema |
| `bin/rails db:rollback` | Revertir migración | Si hay errores |
| `bin/rails c` | Consola interactiva | Depuración y queries |
| `bin/rails routes` | Listar rutas | Verificar endpoints |
| `bin/rails assets:precompile` | Compilar assets | Antes de producción |

### Backup de Base de Datos

**Crear backup:**

```bash
cp db/development.sqlite3 db/backups/development_$(date +%Y%m%d).sqlite3
```

**Restaurar backup:**

```bash
cp db/backups/development_20241104.sqlite3 db/development.sqlite3
```

### Despliegue en Producción

#### Variables de Entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|----------|
| `RAILS_ENV` | Ambiente | `production` |
| `SECRET_KEY_BASE` | Clave secreta | Generar con `rails secret` |
| `RAILS_SERVE_STATIC_FILES` | Servir assets | `true` |

#### Pasos de Despliegue

1. **Preparar entorno:**
   ```bash
   export RAILS_ENV=production
   export SECRET_KEY_BASE=$(bin/rails secret)
   ```

2. **Compilar assets:**
   ```bash
   bin/rails assets:precompile
   ```

3. **Ejecutar migraciones:**
   ```bash
   bin/rails db:migrate
   ```

4. **Iniciar servidor:**
   ```bash
   bin/rails server -e production
   ```

### Solución de Problemas

| Problema | Causa Probable | Solución |
|----------|----------------|----------|
| BD no existe | No inicializada | `bin/rails db:prepare` |
| Migraciones pendientes | BD desactualizada | `bin/rails db:migrate` |
| Assets no cargan | No compilados | `bin/rails assets:precompile` |
| Sesión expira rápido | Timeout 30 min | Normal, reiniciar sesión |
| API retorna 401 | Token inválido | Regenerar en `rails console` |

### Logs y Monitoreo

**Ver logs en desarrollo:**

```bash
tail -f log/development.log
```

**Ver logs en producción:**

```bash
tail -f log/production.log
```

**Health check:**

```bash
curl http://localhost:3000/up
```

### Seguridad en Producción

**Recomendaciones:**

1. Usar SSL/TLS (HTTPS)
2. Configurar firewall (solo puertos necesarios)
3. Actualizar SECRET_KEY_BASE periódicamente
4. Configurar backups automáticos
5. Monitorear logs de acceso
6. Implementar rate limiting adicional
7. Usar variables de entorno para credenciales
8. Mantener Rails y gems actualizadas

### Testing

**Ejecutar tests:**

```bash
bin/rails test
```

**Análisis de seguridad:**

```bash
bundle exec brakeman
```

**Linter de código:**

```bash
bundle exec rubocop
```

---

## Soporte y Contacto

Para reportar problemas o solicitar nuevas funcionalidades, contactar al equipo de desarrollo.

## Licencia

Este proyecto es de uso interno de la institución educativa.

## Notas Finales

- Mantener siempre las dependencias actualizadas por seguridad
- Realizar backups periódicos de la base de datos
- Monitorear logs regularmente en producción
- Documentar cualquier cambio significativo en la configuración

## Enlaces de Referencia

- [Documentación de Rails 8](https://guides.rubyonrails.org/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Hotwire](https://hotwired.dev/)
