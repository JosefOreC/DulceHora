# DulceHora - Aplicación Móvil de Pastelería

## Descripción

Aplicación móvil Android para "DulceHora", una pastelería que permite a los clientes realizar encargos de pasteles y postres para fechas futuras, con opciones de personalización, pago de señal y gestión de producción.

## Estado Actual del Proyecto

**Infraestructura Completa** - La arquitectura base está implementada y lista para desarrollo de UI

### Componentes Implementados

#### 1. Arquitectura MVC
- **Modelo**: Clases de datos (Product, User, Order, Customization, PriceConfig)
- **Controlador**: Interfaces y repositorios para abstracción de base de datos
- **Vista**: Pendiente implementación

#### 2. Base de Datos
- **Abstracción mediante interfaces**: Permite cambiar fácilmente de Firestore a otra BD
- **Implementación Firestore**: Repositorios completos para productos, usuarios y pedidos
- **Inyección de dependencias**: Service Locator pattern

#### 3. Autenticación
- Google Sign-In
- Email/Password
- Prevención de emails duplicados
- Registro solo para clientes (empleados se agregan por admin)

#### 4. Datos de Prueba
- 18 productos en 5 categorías
- Precios dinámicos por tamaño y sabor
- Imágenes de productos (Unsplash)
- Script de siembra automática

#### 5. Diseño
- Esquema de colores temático de pastelería
- Tema Material 3 completo
- Colores para estados de pedidos y ocasiones

## Estructura del Proyecto

```
lib/
├── config/
│   ├── app_colors.dart          # Esquema de colores
│   ├── app_theme.dart           # Tema Material 3
│   └── service_locator.dart     # Inyección de dependencias
├── modelo/
│   ├── product.dart             # Modelo de producto
│   ├── user.dart                # Modelo de usuario
│   ├── order.dart               # Modelo de pedido
│   ├── customization.dart       # Personalización
│   └── price_config.dart        # Configuración de precios
├── controlador/
│   ├── interfaces/              # Abstracción de BD
│   │   ├── i_product_repository.dart
│   │   ├── i_user_repository.dart
│   │   ├── i_order_repository.dart
│   │   └── i_auth_service.dart
│   ├── repositories/            # Implementación Firestore
│   │   ├── firestore_product_repository.dart
│   │   ├── firestore_user_repository.dart
│   │   └── firestore_order_repository.dart
│   └── services/
│       └── firebase_auth_service.dart
├── data/
│   ├── products_seed.dart       # 18 productos
│   └── seed_database.dart       # Script de siembra
├── ui/                          # (Pendiente)
└── main.dart
```

## Requisitos

- Flutter SDK 3.10.1 o superior
- Dart 3.10.1 o superior
- Firebase configurado (firebase_options.dart debe existir)

## Dependencias Principales

```yaml
dependencies:
  firebase_core: ^3.8.1
  cloud_firestore: ^5.5.0
  firebase_auth: ^5.3.3
  google_sign_in: ^6.2.2
  provider: ^6.1.2
  intl: ^0.19.0
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
```

## Instalación

1. Clonar el repositorio
2. Ejecutar `flutter pub get`
3. Configurar Firebase (si no está configurado)
4. Ejecutar la aplicación: `flutter run`

## Configuración de Firebase

Asegúrate de tener el archivo `lib/firebase_options.dart` configurado correctamente con tus credenciales de Firebase.

## Historias de Usuario

### Clientes (HU-C)
- **HU-C1**: Encargar pastel para fecha futura y personalizar texto/adorno ⏳
- **HU-C2**: Elegir horario de recogida o entrega ⏳
- **HU-C3**: Pagar señal y recibir comprobante ⏳
- **HU-C4**: Ver productos recomendados según ocasión ⏳

### Empleados (HU-E)
- **HU-E1**: Pastelero - ver calendario de encargos y plan de producción ⏳
- **HU-E2**: Encargado - marcar pedidos listos y asignar repartidor ⏳
- **HU-E3**: Admin - gestionar precios por tamaño/sabor ⏳
- **HU-E4**: Gestor - ver días de alta demanda para planificar ⏳

✅ = Completado | ⏳ = Pendiente

## Características Implementadas

### Sistema de Roles
- `customer`: Clientes que realizan pedidos
- `pastryChef`: Pastelero - ve calendario de producción
- `manager`: Encargado - gestiona pedidos y asigna repartidores
- `admin`: Administrador - gestiona precios
- `analyst`: Gestor - ve reportes de demanda

### Catálogo de Productos (18 productos)

**Pasteles**:
- Chocolate Clásico, Vainilla Elegante, Red Velvet Premium
- Zanahoria, Tres Leches, Fresa con Crema, Limón
- Pastel de Boda Personalizado

**Cupcakes**:
- Gourmet Surtidos, Chocolate Intenso

**Galletas**:
- Decoradas Personalizadas, Chispas de Chocolate

**Postres Especiales**:
- Cheesecake, Tiramisú, Brownies, Macarons

**Panes Dulces**:
- Roscón de Reyes, Pan de Elote

### Flujo de Pedidos
1. **Pendiente**: Pedido realizado, pago recibido
2. **Confirmado**: Confirmado por staff
3. **En Producción**: Siendo preparado
4. **Listo**: Listo para recoger/entregar
5. **En Camino**: En ruta de entrega
6. **Completado**: Pedido completado
7. **Cancelado**: Pedido cancelado

## Próximos Pasos

1. **Implementar UI del Catálogo**
   - Pantalla de productos (accesible sin login)
   - Filtros por categoría y ocasión
   - Detalle de producto

2. **Implementar Autenticación UI**
   - Pantallas de login/registro
   - Integración con Google Sign-In

3. **Implementar Flujo de Pedidos**
   - Personalización de pasteles
   - Selección de fecha y hora
   - Pago de señal
   - Comprobante

4. **Implementar Funcionalidades de Empleados**
   - Calendario de producción
   - Gestión de pedidos
   - Gestión de precios
   - Reportes

## Notas Técnicas

- **Catálogo accesible sin login**: Según requerimientos
- **Solo clientes pueden registrarse**: Empleados se agregan por backend/admin
- **Precios dinámicos**: Calculados según tamaño y sabor seleccionados
- **Siembra automática**: Los productos se cargan en Firestore en el primer arranque
- **Abstracción de BD**: Fácil cambio de Firestore a otra base de datos

## Autor

Desarrollado para el proyecto DulceHora

## Licencia

Proyecto educativo/comercial
