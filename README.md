ChessPlus
Funcionalidades implementadas
Este es un juego de ajedrez con elementos RPG integrados. A continuación, detallo las funcionalidades principales implementadas, organizadas por componentes clave:
1. Sistema de Ajedrez Clásico
•	Tablero y Piezas: Un tablero de 8x8 con piezas estándar (Peón/P, Torre/T, Caballo/H, Alfil/B, Reina/Q, Rey/K) para dos equipos (Rojo y Azul).
•	Movimiento de Piezas: Validación de movimientos según reglas tradicionales (e.g., peones avanzan hacia adelante, capturan en diagonal; caballos en L; torres, alfiles y reinas en líneas rectas/diagonales sin saltar piezas; rey en casillas adyacentes).
•	Selección y Movimiento: Los jugadores seleccionan piezas de su turno y mueven a posiciones válidas. Incluye animaciones de movimiento suave.
•	Turnos: Alternancia entre equipos Rojo y Azul, con indicadores visuales (paleta de colores).
2. Sistema RPG de Batalla
•	Captura con Batalla: Cuando una pieza intenta capturar otra, no se elimina inmediatamente; en su lugar, se inicia una batalla RPG entre las dos piezas.
•	Clases de Piezas: Cada tipo de pieza tiene una clase con ventajas/desventajas:
o	Guerrero (W): Peón, Torre.
o	Estratega (S): Caballo, Rey.
o	Mago (M): Alfil, Reina.
o	Debilidades: Guerrero > Estratega > Mago > Guerrero (ciclo).
•	Ventaja en Batalla: Si una clase es débil contra la otra, el atacante gana un bono de daño (+100%).
•	Acciones de Batalla:
o	Ataque (A): Daño fijo (20% de HP), ignora defensa.
o	Especial (S): Ataque con bono de ventaja, ignora defensa.
o	Defensa (D): Reduce daño entrante a la mitad (50%) por turno.
o	Crítico (R): Ataque aleatorio de alto daño (60%), con probabilidad variable (1 de 3 slots).
•	Sistema de HP: Cada pieza tiene barras de vida (inicialmente 100%). La batalla continúa hasta que una llegue a 0.
•	Efectos Visuales: Partículas para golpes, críticos, escudos, ventajas y especiales.
3. Promoción de Peones
•	Cuando un peón llega al extremo opuesto del tablero, se pausa el juego y se abre un menú de actualización.
•	Opciones: Convertir el peón en Torre, Caballo, Alfil o Reina (mantiene el equipo).
4. Sistema de Sonido y Música
•	Efectos de sonido para acciones: movimiento, selección, batalla, golpes, críticos, escudos, victoria, destrucción.
•	Música de fondo que se detiene al ganar.
5. Interfaz de Usuario y Visuales
•	Barras de HP: Visualización de vida para ambos equipos durante batallas.
•	Indicadores de Turno: Cambio de paleta de colores para resaltar el turno actual.
•	Animaciones: Introducción/salida de la batalla, movimientos de piezas, victoria.
•	Efectos de Paleta: Shader para cambiar colores entre equipos Rojo/Azul.
•	Botones del Tablero: Grid de botones para seleccionar posiciones.
6. Condiciones de Victoria y Fin del Juego
•	El juego termina cuando se captura el Rey de un equipo.
•	Pantalla de victoria con animación y sonido.
•	Opción de reinicio para volver al tablero inicial.
7. Gestión de Estados
•	Pausa del juego durante batallas.
•	Prevención de acciones inválidas (e.g., mover piezas enemigas, movimientos ilegales).
•	Estado de "terminado" para bloquear interacciones post-victoria.
