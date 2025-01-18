### Инструкция по запуску комплекса приложений для аватара с lip sync через Audio2Face NVIDIA, интеграцией с Asterisk и трансляцией через WebRTC Pixel Streaming

#### 1. Запуск MyProject на Unreal Engine с Pixel Streaming
**Описание:** Запуск основного приложения на Unreal Engine с настройками для Pixel Streaming.

**Команда:**
```bash
cd /home/barabanshchikov/th2/Build/Linux
./MyProject.sh -PixelStreamingIP=127.0.0.1 -PixelStreamingPort=8888 -PixelStreamingWebRTCMaxFps=30 -RenderOffscreen -ResX=1920 -ResY=1080 -ForceRes -StdOut -FullStdOutLogOutput >> log.log 2>&1
```

**Требования:**
- Отдельное окно терминала.
- Директория: `/home/barabanshchikov/th2/Build/Linux`.

---

#### 2. Запуск Signalling Web Server с поддержкой TURN
**Описание:** Запуск сервера сигнализации для WebRTC с поддержкой TURN.

**Команда:**
```bash
cd /home/barabanshchikov/th2/Linux/MyProject/Samples/PixelStreaming/WebServers/SignallingWebServer/platform_scripts/bash
sudo ./Start_WithTURN_SignallingServer.sh
```

**Требования:**
- Отдельное окно терминала.
- Права `sudo`.
- Директория: `/home/barabanshchikov/th2/Linux/MyProject/Samples/PixelStreaming/WebServers/SignallingWebServer/platform_scripts/bash`.

---

#### 3. Запуск Audio2Face в headless режиме
**Описание:** Запуск NVIDIA Audio2Face в headless режиме для генерации движений губ.

**Команда:**
```bash
cd /home/barabanshchikov/.local/share/ov/pkg/audio2face-2023.2.0
./audio2face_headless.sh
```

**Требования:**
- Отдельное окно терминала.
- Директория: `/home/barabanshchikov/.local/share/ov/pkg/audio2face-2023.2.0`.

**Успешный запуск:**

В консоли после запуска приложения audio2face_headless появится сообщение

```
app ready
```

---

#### 4. Активация Audio2Face и выполнение curl-запросов
**Описание:** Активация Audio2Face и выполнение необходимых curl-запросов для настройки.

**Условие:** Запуск возможен только после появления сообщения 
```
app ready
```

в консоли после запуска приложения audio2face_headless из пункта 3

**Команды:**
1. Запуск первого скрипта:
   ```bash
   cd /home/barabanshchikov/th2
   ./run.sh
   ```
   Ожидаемый результат: `{"status":"OK","message":"Succeeded"}`.

2. Запуск второго скрипта:
   ```bash
   cd /home/barabanshchikov/th2
   ./run2.sh
   ```
   Ожидаемый результат: `{"status":"OK","message":"Succeeded"}`.

**Требования:**
- Скрипты выполняются в текущем окне терминала.
- Директория: `/home/barabanshchikov/th2`.
- Скрипт `run2.sh` нужно запустить несколько раз, первый после запуска /run.sh и второй раз во время воспроизведения тестового аудио.

---

#### 5. Запуск тестового аудио для Audio2Face
**Описание:** Воспроизведение тестового аудио для проверки работы Audio2Face.

**Команда:**
```bash
cd /home/barabanshchikov/.local/share/ov/pkg/deps/321b626abba810c3f8d1dd4d247d2967/exts/omni.audio2face.player/omni/audio2face/player/scripts/streaming_server
source /home/barabanshchikov/a2fenv/bin/activate
python3 test_client.py output.wav /World/audio2face/PlayerStreaming
```

**Требования:**
- Отдельное окно терминала.
- Директория: `/home/barabanshchikov/.local/share/ov/pkg/deps/321b626abba810c3f8d1dd4d247d2967/exts/omni.audio2face.player/omni/audio2face/player/scripts/streaming_server`.
- Активация виртуального окружения `a2fenv`.
- Для проверки работы lip sync во время запуска тестового скрипта нужно перейти на страницу https://avatar.twin-ai.com/ и 
понаблюдать за движением губ у аватара, они начнут шевелиться только после повторного запуска run2.sh из пунка 6

---

#### 6. Повторный запуск скрипта run2.sh во время запуска тестового аудио
**Описание:** После запуска тестового аудио необходимо повторно выполнить скрипт `run2.sh` для завершения настройки.

**Команда:**
```bash
cd /home/barabanshchikov/th2
./run2.sh
```
Ожидаемый результат: `{"status":"OK","message":"Succeeded"}`.

**Требования:**
- Выполняется в том же окне терминала, где был запущен `test_client.py`, или в новом.
- Директория: `/home/barabanshchikov/th2`.

---

#### 7. Запуск UDP-сервера для приема RTP-потока
**Описание:** Запуск UDP-сервера для приема RTP-потока и передачи его в Audio2Face через gRPC.

**Команда:**
```bash
source /home/barabanshchikov/a2fenv/bin/activate
cd /home/barabanshchikov/th2/udp_to_grpc
python udp_server_v2.py
```

**Требования:**
- Отдельное окно терминала.
- Директория: `/home/barabanshchikov/th2/udp_to_grpc`.

---

#### 8. Запуск ARI-сервера для интеграции с Asterisk
**Описание:** Запуск ARI-сервера для интеграции с Asterisk и управления вызовами.

**Команда:**
```bash
cd /home/barabanshchikov/th2/ari_server
conda activate ari_env
python ari_stasis.py
```

**Требования:**
- Отдельное окно терминала.
- Активация окружения `ari_env`.
- Директория: `/home/barabanshchikov/th2/ari_server`.

---

### Порядок запуска:
1. Запустите **Signalling Web Server** (пункт 2).
2. Запустите **MyProject на Unreal Engine** (пункт 1).
3. Запустите **Audio2Face в headless режиме** (пункт 3).
4. Активируйте Audio2Face и выполните curl-запросы (пункт 4).
5. Воспроизведите тестовое аудио (пункт 5).
6. **Обязательно** выполните повторный запуск скрипта `run2.sh` (пункт 6).
7. Запустите **UDP-сервер** (пункт 7).
8. Запустите **ARI-сервер** (пункт 8).
9. Убедитесь, что Audio2Face корректно обрабатывает поток.

### Примечания:
- Для остановки приложений используйте `Ctrl+C` в соответствующих окнах терминалов. 
- Перезапуск приложения происходит методом отключения текущего экземпляра и повторным запуском по инструкции

### Возможные проблемы
1. Нет движения губ
- Убедитесь что все приложения запущены и в логах stdout нет ошибок
- Перезапустите последовательно все приложения по инструкции.