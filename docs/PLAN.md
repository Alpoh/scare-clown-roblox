# Plan de desarrollo — ScareClownGame

Fases pequeñas y verificables. Cada fase se cierra con una prueba concreta en Studio (playtest vía MCP), no solo "el código compila". Las fases 2 en adelante son una propuesta razonable para un juego de terror/persecución con payaso — ajustar contenido según la visión real del juego cuando se defina.

## Fase 0 — Tooling y base ✅ (hecho)

- [x] Rojo instalado (CLI + plugin) y `default.project.json` sincronizando `src/client`, `src/server`, `src/shared`.
- [x] Repo git local inicializado.
- [x] Menú principal (`src/client/MainMenu.luau`): título, subtítulo, botón JUGAR, botón AJUSTES con panel funcional.
- [x] Bloqueo de movimiento del personaje mientras el menú está abierto; se libera al presionar JUGAR.
- **Prueba:** `solo_playtest` — menú visible, AJUSTES abre/cierra panel, JUGAR libera al personaje. Ya verificado.

## Fase 1 — Estado de ronda (servidor autoritativo)

- [ ] Módulo `shared/RoundState.luau` con los estados posibles (`Waiting`, `Starting`, `Playing`, `Ended`) como constantes.
- [ ] `server/RoundManager.luau`: máquina de estados simple, temporizador de espera antes de iniciar, evento `RoundStateChanged` replicado a los clientes.
- [ ] HUD mínimo en cliente que muestre el estado/temporizador actual (texto simple, sin arte todavía).
- **Prueba:** `multiplayer_playtest` con 2 clientes — ambos ven el mismo estado de ronda al mismo tiempo; forzar el timer y confirmar que el cambio de estado llega a los dos.

## Fase 2 — Mapa y spawn

- [ ] Puntos de spawn de jugadores (`SpawnLocation` o sistema propio) separados del punto de spawn del "clown".
- [ ] Bloqueo de zona de espera (lobby) mientras `RoundState == Waiting`, liberación al pasar a `Playing`.
- **Prueba:** `solo_playtest` — el jugador aparece en el lobby, no puede entrar al mapa de juego hasta que inicia la ronda.

## Fase 3 — El Clown (enemigo/rol especial)

- [ ] Selección server-side de quién es "el clown" al iniciar la ronda (aleatorio o por votación, definir).
- [ ] IA básica de persecución si el clown es NPC, o kit de habilidad si es un jugador (velocidad, habilidad de "susto").
- [ ] Condición de atrapar a un jugador (Touched + validación server-side, nunca confiar en el cliente que "me atraparon").
- **Prueba:** `multiplayer_playtest` con 2-3 clientes — el clown puede atrapar a otro jugador y el servidor registra el evento correctamente; probar que un cliente exploiteado no puede autodeclararse ganador.

## Fase 4 — Condición de victoria/derrota

- [ ] Reglas de fin de ronda (todos atrapados / tiempo agotado / objetivo cumplido — definir cuál aplica).
- [ ] Pantalla de resultado (ganador/perdedor) reutilizando el patrón `CanvasGroup` del menú.
- [ ] Vuelta automática a `Waiting` tras mostrar resultados.
- **Prueba:** jugar una ronda completa en `multiplayer_playtest` de principio a fin sin intervención manual del estado.

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
