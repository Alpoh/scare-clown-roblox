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

## Fase 5 — Atmósfera y audio

- [ ] Música ambiente + stings de susto, conectados al toggle "MUSICA: ON/OFF" ya existente en Ajustes.
- [ ] Iluminación/efectos de terror en el mapa (esto sí se edita directo en Studio, no vía Rojo).
- **Prueba:** confirmar en playtest que el toggle de música realmente silencia/reactiva el audio (hoy solo cambia el texto).

## Fase 6 — Persistencia y progresión

- [ ] `DataStoreService` para stats básicas (rondas jugadas, veces atrapado, veces como clown).
- [ ] Guardado en `PlayerRemoving` y `game:BindToClose`.
- **Prueba:** jugar una ronda, salir, volver a entrar — las stats persisten. Probar también un fallo simulado de DataStore (pcall no debe tumbar el server).

## Fase 7 — Pulido y balance

- [ ] Ajustes reales en el panel de Ajustes (sensibilidad, volumen si aplica, no solo el toggle de música).
- [ ] Balancing de velocidades/tiempos según feedback de playtesting.
- [ ] Bug bash general con `multiplayer_playtest`.

## Fase 8 — Preparación de release

- [ ] Ícono y thumbnails del juego.
- [ ] Revisión final de textos/UI en español.
- [ ] Última pasada de `docs/CLAUDE.md` para reflejar decisiones tomadas durante el desarrollo.

---

**Nota:** las fases 2–8 son un esqueleto razonable, no un compromiso cerrado. Cuando se defina mejor la mecánica exacta (¿el clown es un jugador o un NPC? ¿hay objetivos que recolectar o es solo escapar?), esta lista se ajusta.
