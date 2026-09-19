# CLAUDE.md — ScareClownGame

Guía de convenciones para trabajar en este proyecto de Roblox. Léelo antes de tocar código.

## Stack y flujo

- Sincronización vía **Rojo** (`default.project.json` + `src/`). El DataModel de Studio se genera desde estos archivos — **nunca edites a mano en Studio** nada que viva bajo una ruta gestionada por Rojo (`ReplicatedStorage.Shared`, `ServerScriptService.Server`, `StarterPlayer.StarterPlayerScripts.Client`); el próximo sync lo sobrescribe. `Workspace`, `Lighting` y el resto de servicios no listados en `default.project.json` sí se editan libremente en Studio (geometría del mapa, iluminación, etc.) porque Rojo no los toca.
- Antes de programar: `rojo serve default.project.json` en la carpeta del proyecto y "Connect" en el plugin de Rojo dentro de Studio.
- Toda UI se construye **por código** (Luau), no como instancias pegadas a mano ni `.rbxm` — así el diff de git muestra los cambios reales. Ver `src/client/MainMenu.luau` como referencia de patrón.

## Estructura de carpetas

```
src/
  client/   -> StarterPlayer.StarterPlayerScripts.Client (LocalScripts, UI, input)
  server/   -> ServerScriptService.Server (lógica autoritativa, rondas, IA)
  shared/   -> ReplicatedStorage.Shared (módulos usados por client y server: constantes, tipos, utils)
```

Un `init.client.luau` / `init.server.luau` en una carpeta la convierte en el script raíz de esa carpeta; los demás archivos del directorio quedan como sus hijos (`require(script.Nombre)`).

## Reglas de Luau/estilo

- `local` siempre; nunca variables globales implícitas.
- `PascalCase` para servicios, clases/módulos y nombres de Instance; `camelCase` para variables y funciones locales.
- Usa `task.spawn` / `task.wait` / `task.delay` — no los `spawn`/`wait`/`delay` legacy (deprecados, peor scheduling).
- `:WaitForChild(nombre, timeout)` con timeout explícito en cualquier código que corra en producción; sin timeout solo en scripts de arranque donde el hijo es garantizado por el propio proyecto.
- Módulos compartidos (`shared/`) no deben requerir nada de `client/` ni `server/` — la dependencia va siempre hacia adentro (shared es la base).

## Cliente/Servidor (seguridad)

- El servidor es la única fuente de verdad para vidas, rondas, inventario, daño, economía. El cliente nunca decide el resultado de una acción, solo la solicita.
- Toda `RemoteEvent`/`RemoteFunction` que reciba el servidor debe validar tipo, rango y que el jugador remitente puede razonablemente hacer esa acción (anti-exploit). Nunca confíes en datos de posición/estado que vengan del cliente sin sanity-check server-side.
- Nombrar remotes por acción, no por sistema genérico: `RequestStartRound`, no `GameEvent`.
- Un cliente comprometido puede llamar cualquier remote con cualquier argumento en cualquier momento — diseña cada handler asumiendo eso.

## Rendimiento

- Nada de trabajo pesado en `RenderStepped`/`Heartbeat` sin necesidad; preferir eventos (`GetPropertyChangedSignal`, `.Touched`, cambios de estado) sobre polling en bucle.
- Reusa instancias (pooling) para efectos/objetos que se crean y destruyen con frecuencia (proyectiles, partículas de jumpscare, etc.) en vez de `Instance.new`/`Destroy` constante.
- `TweenService` para animaciones de UI/objetos en vez de loops manuales con `RunService`.

## UI

- Tamaños y posiciones en escala (`UDim2.fromScale` / componente `Scale`, no `Offset` fijo) para que funcione en cualquier resolución — clave en un juego con soporte de PC/móvil.
- Layouts (`UIListLayout`, `UIGridLayout`) en vez de posicionar hijos a mano cuando haya una lista de elementos.
- Un `CanvasGroup` como raíz de cada pantalla de UI permite fade in/out de todo el árbol con una sola propiedad (`GroupTransparency`) — patrón ya usado en el menú principal.

## Persistencia de datos

- `DataStoreService` siempre envuelto en `pcall` con reintentos; nunca dejar que un fallo de DataStore tumbe el servidor.
- Guardar en `game:BindToClose` además de al salir el jugador, para no perder progreso en shutdown por deploy.

## Testing

- Antes de dar una feature por terminada: probarla con `solo_playtest` (o `multiplayer_playtest` si involucra a más de un jugador) vía el MCP, no asumir que "debería funcionar" por leer el código.
- Casos a cubrir además del camino feliz: respawn del personaje, un segundo jugador uniéndose a mitad de ronda, desconexión durante una acción en curso.

## Git

- Commits pequeños por feature/fase, no un commit gigante por sesión.
- No commitear binarios pesados (audio/video/modelos) sin necesidad; si hace falta un asset grande, súbelo a Roblox (`upload_asset`) y referencia el `assetId` en el código en vez de versionarlo en git.
