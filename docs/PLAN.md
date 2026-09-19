# Plan de desarrollo — ScareClownGame

Fases pequeñas y verificables. Cada fase se cierra con una prueba concreta en Studio (playtest vía MCP), no solo "el código compila". Las fases 2 en adelante son una propuesta razonable para un juego de terror/persecución con payaso — ajustar contenido según la visión real del juego cuando se defina.

## Fase 0 — Tooling y base ✅ (hecho)

- [x] Rojo instalado (CLI + plugin) y `default.project.json` sincronizando `src/client`, `src/server`, `src/shared`.
- [x] Repo git local inicializado.
- [x] Menú principal (`src/client/MainMenu.luau`): título, subtítulo, botón JUGAR, botón AJUSTES con panel funcional.
- [x] Bloqueo de movimiento del personaje mientras el menú está abierto; se libera al presionar JUGAR.
- **Prueba:** `solo_playtest` — menú visible, AJUSTES abre/cierra panel, JUGAR libera al personaje. Ya verificado.

## Fase 1 — Estado de ronda (servidor autoritativo) ✅ (hecho)

- [x] Módulo `shared/RoundState.luau` con los estados posibles (`Waiting`, `Starting`, `Playing`, `Ended`) como constantes.
- [x] `server/RoundManager.luau`: máquina de estados simple, temporizador de espera antes de iniciar, evento `RoundStateChanged` replicado a los clientes.
- [x] HUD mínimo en cliente (`src/client/RoundHud.luau`) que muestre el estado/temporizador actual (texto simple, sin arte todavía).
- **Prueba:** `multiplayer_playtest` con 2 clientes — verificado que ambos ven el mismo estado ("Starting" y luego "Playing") al mismo tiempo que el servidor.

## Fase 2 — Mapa y spawn ✅ (hecho)

- [x] Puntos de spawn de jugadores (`Workspace.Map.LobbySpawns` como `SpawnLocation`, `Workspace.Map.PlayAreaSpawns` como marcadores) separados del punto de spawn del "clown" (`Workspace.Map.ClownSpawns`, reservado para Fase 3).
- [x] Bloqueo de zona de espera: `LobbyGate` (pared física en `Workspace.Map`) con `CanCollide=true` mientras `RoundState ~= Playing`; `src/server/SpawnManager.luau` la abre/cierra y teletransporta jugadores según el estado, suscrito a `RoundManager.StateChanged` (sin acoplar `RoundManager` a `SpawnManager`).
- **Prueba:** `solo_playtest` — verificado que el jugador aparece en el lobby, queda bloqueado físicamente en el gate al intentar cruzar durante `Waiting`, y es liberado + teletransportado al área de juego apenas el estado pasa a `Playing`.

## Fase 3 — El Clown (enemigo/rol especial) ✅ (hecho)

Decisión de diseño: el clown es **un jugador** elegido al azar cada ronda (no NPC) — descarta la rama de IA de persecución del checklist original.

- [x] Selección server-side aleatoria del clown (`src/server/RoleManager.luau`) al entrar a `Starting`, replicada a todos los clientes vía `ClownAssigned`.
- [x] Kit de habilidad del clown: velocidad aumentada (`WalkSpeed 22` vs `16`) y color distintivo aplicado server-side. Habilidad activa de "susto" queda diferida (no bloquea el testing de esta fase).
- [x] Condición de atrapar (`src/server/CatchManager.luau`): `Touched` en el `HumanoidRootPart` del clown, validado server-side (ronda en `Playing`, víctima no es el clown, no atrapada ya); congela a la víctima (`WalkSpeed/JumpPower/JumpHeight = 0`) y notifica a todos vía `PlayerCaught`.
- [x] Spawns del clown separados de los sobrevivientes (`SpawnManager` ahora usa `RoleManager.getClown()` para elegir el pool de spawn correcto).
- **Prueba:** `multiplayer_playtest` con 3 clientes — verificado rol asignado y replicado, velocidad/color aplicados, clown atrapó a un sobreviviente y todos los clientes vieron la notificación. Anti-exploit verificado en dos niveles: (1) grep confirma que no existe ningún `OnServerEvent`/`FireServer` en el código servidor — los remotes de ronda/rol/captura son estrictamente servidor→cliente; (2) un cliente disparó `FireServer` falsificado en los tres remotes (autodeclararse clown, declarar una captura falsa, forzar fin de ronda) y no tuvo ningún efecto en el estado del servidor.

## Fase 4 — Condición de victoria/derrota ✅ (hecho)

Regla elegida: el Clown gana si atrapa a todos los sobrevivientes antes de que se acabe el tiempo; los sobrevivientes ganan si el tiempo se agota con al menos uno libre (no hay sistema de objetivos, así que esa rama del checklist original no aplica).

- [x] `src/server/WinConditionManager.luau`: cuenta capturas vía `CatchManager.PlayerCaught`; si igualan a los sobrevivientes, declara "Clown" y corta `Playing` antes de tiempo (`RoundManager.endPlayingEarly()`); si `Playing` llega a `Ended` sin decisión previa, declara "Survivors". Resultado replicado por `RoundResult`.
- [x] `RoundManager.luau` ahora espera `Playing` en pasos de 1s en vez de un solo `task.wait`, para poder cortarlo antes de tiempo sin tocar el resto de la máquina de estados.
- [x] `src/client/ResultScreen.luau`: pantalla de resultado con el mismo patrón `CanvasGroup` + fade del menú principal; se oculta sola en cuanto el estado deja de ser `Ended`.
- [x] Vuelta automática a `Waiting` — ya la daba `RoundManager` de fábrica (el timer de `Ended` no cambió); confirmado que el ciclo completo se repite solo.
- **Prueba:** `multiplayer_playtest` con 3 clientes, ronda completa sin intervención manual del estado — el clown atrapó a los dos sobrevivientes, `Playing` se cortó antes de sus 60s, todos los clientes vieron "EL CLOWN GANO", y el juego volvió solo a `Waiting` y arrancó un nuevo ciclo. La rama "tiempo agotado → ganan los sobrevivientes" queda cubierta por construcción (mismo `declareResult`, solo que disparado por el `Ended` natural en vez del corte anticipado) pero no se re-verificó por separado en este playtest por el tiempo que toma dejar correr los 60s completos.

## Fase 5 — Atmósfera y audio ✅ (hecho)

- [x] Música ambiente (`SoundService.AmbientMusic`, asset de Creator Store insertado tras habilitar "Allow Loading Third Party Assets") + sting de susto (`SoundService.CatchSting`) al atrapar a alguien. `src/client/AudioController.luau` controla ambos; el toggle "MUSICA: ON/OFF" del menú ahora silencia/reactiva el audio real (antes solo cambiaba el texto).
- [x] Iluminación/efectos de terror: `Lighting` (ambient oscuro, fog rojo/negro, `Atmosphere` con haze, `SunRays` apagado) configurado directo en Studio (no vía Rojo). Luces de punto parpadeantes (`Workspace.Map.Lights`) animadas por `src/client/AmbientEffects.luau`.
- **Prueba:** verificado en playtest que el toggle de música cambia `Volume` del `Sound` real (no solo el texto) y que las luces parpadean (medido con `GetPropertyChangedSignal` — 7 cambios de brillo en 3s).
- **Bug encontrado y corregido durante el testing:** `AmbientEffects` inicialmente no producía parpadeo porque `lights:GetChildren()` se leía justo después de `WaitForChild("Lights")`, antes de que los hijos (las luces) terminaran de replicarse al cliente — carrera de replicación silenciosa, sin error. Se corrigió combinando el barrido inicial con `lights.ChildAdded:Connect(tryFlicker)`, patrón robusto para instancias que llegan después.

## Fase 6 — Dependencias: Wally, Janitor, Signal, Promise ✅ (hecho)

- [x] **Wally** instalado (CLI) e inicializado (`wally.toml` + `wally.lock` versionados en git; `Packages/` en `.gitignore`, se regenera con `wally install`). `default.project.json` sincroniza `Packages/` a `ReplicatedStorage.Packages`.
- [x] Dependencias agregadas: `Janitor` (`howmanysmall/janitor@1.18.3`), `Signal` (`sleitnick/signal@1.5.0`), `Promise` (`evaera/promise@4.0.0`).
- [x] Reglas de uso documentadas en `docs/CLAUDE.md` (sección "Janitor, Signal y Promise"): cuándo usar cada uno, cómo se integran entre sí (Janitor limpia Signals/Promises automáticamente), y cuándo no usarlos para evitar ceremonia innecesaria. El código existente (`BindableEvent` manuales en `RoundManager`/`RoleManager`/`CatchManager`) se migra de forma oportunista cuando se toque, no en un refactor masivo.
- **Prueba:** `solo_playtest` — `require` de los tres paquetes desde `ReplicatedStorage.Packages` funciona en runtime (Signal conectado/disparado, Promise resuelta, Janitor limpiando la conexión), verificado con `eval_server_runtime`.

## Fase 7 — Persistencia y progresión ✅ (hecho)

- [x] `DataStoreService` (store `PlayerStats_v1`) para stats básicas: rondas jugadas, veces atrapado, veces como clown. `src/shared/PlayerStats.luau` (puro: `withDefaults`/`increment`, siempre devuelve tabla nueva) + `src/server/StatsService.luau` (cache en memoria por `UserId`, carga/guarda con `Promise` y reintentos con backoff, nunca un `pcall` sin capturar).
- [x] Guardado en `PlayerRemoving` y en `game:BindToClose` (con `Promise.all` + `:await()` para esperar a que terminen los guardados antes de que el servidor cierre).
- **Prueba:** `solo_playtest` — jugué una ronda (subió `RoundsPlayed`/`TimesAsClown`), detuve y reinicié el playtest, los stats se cargaron intactos. `multiplayer_playtest` con 2 clientes — `TimesCaught` sube para la víctima real. Fallo de DataStore simulado (`SetAsync` con un valor no serializable) confirmó que el error se captura sin afectar al resto del servidor (la ronda siguió avanzando con normalidad).

## Fase 8 — Pulido y balance ✅ (hecho)

- [x] Ajuste real de volumen: `src/client/UISlider.luau` (slider genérico reutilizable, drag + click-to-jump) reemplaza el toggle ON/OFF; `AudioController.setMusicVolume` ahora recibe un valor continuo 0-1. Sensibilidad de cámara **descartada**: `UserGameSettings.MouseSensitivity` es de solo lectura para scripts de juego en la práctica (`"lacking capability RobloxScript"`), a pesar de que la documentación la muestra como ReadWrite — lo intenté, tiró un error no capturado que mataba todo el arranque del cliente, lo revertí. Implementar sensibilidad real requeriría reemplazar el `PlayerModule`/`CameraModule` por defecto de Roblox, fuera de alcance de "pulido".
- [x] Bug encontrado y corregido en el camino: el panel de Ajustes (`Frame` sin `Active=true`) dejaba pasar clics en su propio fondo hacia el `Dimmer` de atrás, cerrándose solo. Se corrige con `settingsPanel.Active = true`.
- [x] Balancing: probé una persecución real (sobreviviente huyendo con `Humanoid:MoveTo`, no teletransporte) vía `multiplayer_playtest` — captura en ~2s con `CLOWN_WALK_SPEED=22`. Bajé la velocidad del clown a `19` (de +37.5% a +18.75% sobre el `WalkSpeed` base de 16). Las duraciones de `RoundConfig` se dejan igual: no hay evidencia real que justifique cambiarlas todavía.
- [x] Bug bash: un jugador se desconectó a mitad de una ronda `Playing` (`multiplayer_playtest leave_client`) — el servidor no se cayó, el jugador restante se retiró de la cuenta correctamente, y el ciclo de rondas siguió solo hasta `Waiting` con normalidad.
- **Nota honesta sobre balance:** en un mapa completamente abierto y sin obstáculos (el placeholder de la Fase 2), *cualquier* ventaja de velocidad del clown converge a una captura en pocos segundos — es matemática de persecución, no algo que se arregle solo tocando números. Un balance real necesita geometría de mapa con obstáculos/rutas (fuera del alcance de esta fase) y feedback de jugadores reales, que todavía no existen. El valor `19` es una mejora razonable sobre `22`, no un número "final".

## Fase 9 — Preparación de release

- [ ] Ícono y thumbnails del juego.
- [ ] Revisión final de textos/UI en español.
- [ ] Última pasada de `docs/CLAUDE.md` para reflejar decisiones tomadas durante el desarrollo.

---

**Nota:** las fases 2–4 y 7–9 son un esqueleto razonable, no un compromiso cerrado (la Fase 6 de dependencias ya quedó fija). Cuando se defina mejor la mecánica exacta (¿el clown es un jugador o un NPC? ¿hay objetivos que recolectar o es solo escapar?), esta lista se ajusta.
