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

## Clean Code

- Nombres que dicen qué hacen (`lockCharacter`, `RoundConfig.Playing`), no abreviaturas crípticas ni nombres genéricos (`data`, `temp`, `handle2`).
- Funciones cortas y de un solo nivel de abstracción: una función que arma la UI no debería también decidir reglas de negocio de la ronda. Si una función necesita comentarios tipo "-- ahora hacemos X" para separar bloques, probablemente son dos funciones.
- Cero números/strings mágicos sueltos en la lógica: duraciones, límites, nombres de estado van a un módulo de config o constantes (`RoundConfig.luau`, `RoundState.luau`), nunca hardcodeados donde se usan.
- Duplicación: si la misma lógica aparece dos veces (p. ej. crear un botón con corner+stroke+scale), extraer una función helper — ya se hizo con `makeButton`/`makePanelButton` en el menú.
- **Regla estricta: cero comentarios en el código**, ni de qué hace ni de por qué. Si algo necesita explicación, el nombre de la variable/función/módulo debe cargar con ese significado, o el código se reestructura hasta que sea obvio por sí solo. Nada de `-- Background`, `-- TODO`, `-- por qué hacemos esto`.

## Principios SOLID (aplicados a módulos Luau)

Luau no es un lenguaje de clases, pero los mismos principios aplican a nivel de **módulo**:

- **S — Responsabilidad única:** cada ModuleScript hace una cosa (`RoundManager` solo gestiona el estado de la ronda; no debería además manejar puntajes de jugador o el HUD — eso va en sus propios módulos).
- **O — Abierto/cerrado:** agregar comportamiento nuevo debería significar *agregar* un módulo/handler, no reescribir un `if/elseif` gigante ya existente. Ej.: nuevas reacciones a cambios de ronda se suscriben a la señal/evento existente en vez de meterse dentro de `RoundManager.setState`.
- **L — Sustitución:** si dos "cosas" comparten una interfaz (p. ej. distintos tipos de enemigo con `:GetSpeed()`/`:OnCaught()`), cualquiera debe poder reemplazar a la otra sin que el código que las usa necesite saber cuál es cuál.
- **I — Segregación de interfaces:** preferir varios módulos pequeños con una función clara (`RoundState`, `RoundConfig`, `RoundManager` separados) en vez de un único `GameManager.luau` gigante que todo el mundo importa para todo.
- **D — Inversión de dependencias:** la lógica de alto nivel no debería depender de detalles concretos de bajo nivel. `shared/` nunca depende de `client/` o `server/` (regla ya vigente en este repo); los sistemas de servidor se comunican por eventos/RemoteEvents/BindableEvents en vez de requerir directamente los internals de otro sistema.

## Cliente/Servidor (seguridad)

- El servidor es la única fuente de verdad para vidas, rondas, inventario, daño, economía. El cliente nunca decide el resultado de una acción, solo la solicita.
- Toda `RemoteEvent`/`RemoteFunction` que reciba el servidor debe validar tipo, rango y que el jugador remitente puede razonablemente hacer esa acción (anti-exploit). Nunca confíes en datos de posición/estado que vengan del cliente sin sanity-check server-side.
- Nombrar remotes por acción, no por sistema genérico: `RequestStartRound`, no `GameEvent`.
- Un cliente comprometido puede llamar cualquier remote con cualquier argumento en cualquier momento — diseña cada handler asumiendo eso.

## Rendimiento

- Nada de trabajo pesado en `RenderStepped`/`Heartbeat` sin necesidad; preferir eventos (`GetPropertyChangedSignal`, `.Touched`, cambios de estado) sobre polling en bucle.
- Reusa instancias (pooling) para efectos/objetos que se crean y destruyen con frecuencia (proyectiles, partículas de jumpscare, etc.) en vez de `Instance.new`/`Destroy` constante.
- `TweenService` para animaciones de UI/objetos en vez de loops manuales con `RunService`.

## Replicación cliente/servidor (instancias que llegan tarde)

- `WaitForChild` en un padre solo garantiza que el padre existe, **no** que sus hijos ya replicaron al cliente. Iterar `padre:GetChildren()` justo después de un `WaitForChild(padre)` puede ver una lista vacía o incompleta sin ningún error — falla en silencio.
- Para instancias creadas dinámicamente (o que llegan después por streaming), combinar el barrido inicial con `padre.ChildAdded:Connect(handler)` — el mismo handler procesa lo que ya está y lo que llegue después. No asumir que "no hay hijos todavía" significa "no van a llegar".
- Caso real: `src/client/AmbientEffects.luau` (Fase 5) no producía parpadeo porque `lights:GetChildren()` se leía antes de que las luces terminaran de replicarse; no había ningún error que lo delatara, solo cero efecto. Se corrigió con el patrón `GetChildren()` + `ChildAdded`.

## UI

- Tamaños y posiciones en escala (`UDim2.fromScale` / componente `Scale`, no `Offset` fijo) para que funcione en cualquier resolución — clave en un juego con soporte de PC/móvil.
- Layouts (`UIListLayout`, `UIGridLayout`) en vez de posicionar hijos a mano cuando haya una lista de elementos.
- Un `CanvasGroup` como raíz de cada pantalla de UI permite fade in/out de todo el árbol con una sola propiedad (`GroupTransparency`) — patrón ya usado en el menú principal.

## Persistencia de datos

- `DataStoreService` siempre envuelto en `pcall` con reintentos; nunca dejar que un fallo de DataStore tumbe el servidor.
- Guardar en `game:BindToClose` además de al salir el jugador, para no perder progreso en shutdown por deploy.

## Testing y TDD

- Antes de dar una feature por terminada: probarla con `solo_playtest` (o `multiplayer_playtest` si involucra a más de un jugador) vía el MCP, no asumir que "debería funcionar" por leer el código.
- Casos a cubrir además del camino feliz: respawn del personaje, un segundo jugador uniéndose a mitad de ronda, desconexión durante una acción en curso.
- Para lógica no trivial (máquinas de estado, cálculos, reglas de negocio), escribir primero los casos que debe cumplir — aunque sea como plan textual o como llamadas de verificación en `eval_server_runtime`/`eval_client_runtime` — antes de implementar, e implementar hasta que esos casos pasen. Es el mismo espíritu de TDD aplicado sin depender de un framework de test formal.
- Para que eso sea posible, la lógica pura (sin llamadas a la API de Roblox) debe vivir separada en módulos de `shared/`/`server/` que reciban sus dependencias como parámetros en vez de leer servicios globales directamente — así se puede verificar el comportamiento de un módulo (p. ej. las transiciones de `RoundManager`) llamándolo directo, sin necesitar todo el DataModel montado.

## Versionado

- `src/shared/GameVersion.luau` es la única fuente de verdad del número de versión del juego (semver: `MAYOR.MENOR.PARCHE`). Se muestra en la esquina inferior derecha del menú principal.
- **Regla obligatoria: al cerrar cada fase del `docs/PLAN.md` siempre se hace bump de versión**, nunca se pasa a la siguiente fase sin subir el número. Qué campo subir depende de lo que trajo esa fase, no es automático:
  - MENOR (`0.X.0`) — la fase agregó una mecánica o sistema nuevo jugable (p. ej. estado de ronda, IA del clown, condición de victoria).
  - PARCHE (`0.1.X`) — la fase fue un ajuste, fix o pulido sobre algo que ya existía, sin mecánica nueva.
  - MAYOR (`X.0.0`) — reservado para el primer release público, no se usa durante el desarrollo por fases.
- Subir el número en `GameVersion.luau`, commitear, y etiquetar ese commit con `git tag vX.Y.Z` (`git push --tags`). El tag de git y el valor del archivo siempre deben coincidir.

## Git

- Commits pequeños por feature/fase, no un commit gigante por sesión.
- No commitear binarios pesados (audio/video/modelos) sin necesidad; si hace falta un asset grande, súbelo a Roblox (`upload_asset`) y referencia el `assetId` en el código en vez de versionarlo en git.
