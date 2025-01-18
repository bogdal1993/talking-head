#!/bin/bash

# Директории
TH2_DIR="/home/barabanshchikov/th2"
AUDIO2FACE_DIR="/home/barabanshchikov/.local/share/ov/pkg/audio2face-2023.2.0"
SIGNALLING_DIR="/home/barabanshchikov/th2/Linux/MyProject/Samples/PixelStreaming/WebServers/SignallingWebServer/platform_scripts/bash"
UDP_GRPC_DIR="/home/barabanshchikov/th2/udp_to_grpc"
ARI_SERVER_DIR="/home/barabanshchikov/th2/ari_server"
STREAMING_SERVER_DIR="/home/barabanshchikov/.local/share/ov/pkg/deps/321b626abba810c3f8d1dd4d247d2967/exts/omni.audio2face.player/omni/audio2face/player/scripts/streaming_server"
LOGS_DIR="/home/barabanshchikov/th2/logs"

# Создание директории для логов, если её нет
mkdir -p "$LOGS_DIR"

# Массив для хранения PID всех запущенных процессов
declare -a PIDS

# Функция для запуска и мониторинга процесса
run_process() {
    local name=$1
    local command=$2
    local dir=$3
    local log_file="$LOGS_DIR/${name}.log"
    echo "Запуск $name..."
    cd "$dir" || { echo "Ошибка: не удалось перейти в директорию $dir"; exit 1; }
    eval "$command >> $log_file 2>&1 &"
    PIDS+=($!)  # Сохраняем PID запущенного процесса
}

# Функция для выполнения curl-запросов
run_curl_scripts() {
    cd "$TH2_DIR" || { echo "Ошибка: не удалось перейти в директорию $TH2_DIR"; exit 1; }
    ./run.sh
    ./run2.sh
}

# Функция для завершения всех процессов
cleanup() {
    echo "Завершение всех процессов..."
    for pid in "${PIDS[@]}"; do
        if ps -p "$pid" > /dev/null; then
            echo "Завершение процесса с PID $pid..."
            kill "$pid"
        fi
    done
    exit 0
}

# Ловушка для обработки Ctrl+C (SIGINT)
trap cleanup SIGINT

# Запуск всех процессов в фоновом режиме
run_process "myproject" "./MyProject.sh -PixelStreamingIP=127.0.0.1 -PixelStreamingPort=8888 -PixelStreamingWebRTCMaxFps=30 -RenderOffscreen -ResX=1920 -ResY=1080 -ForceRes -StdOut -FullStdOutLogOutput" "$TH2_DIR/Build/Linux"
run_process "signalling" "sudo ./Start_WithTURN_SignallingServer.sh" "$SIGNALLING_DIR"
run_process "audio2face" "./audio2face_headless.sh --allow-root" "$AUDIO2FACE_DIR"
sleep 20
run_process "udp_server" "source /home/barabanshchikov/a2fenv/bin/activate && python udp_server_v2.py" "$UDP_GRPC_DIR"
run_process "ari_server" "conda activate ari_env && python ari_stasis.py" "$ARI_SERVER_DIR"

# Запуск тестового аудио и повторный запуск run2.sh
(
    cd "$STREAMING_SERVER_DIR" || { echo "Ошибка: не удалось перейти в директорию $STREAMING_SERVER_DIR"; exit 1; }
    source /home/barabanshchikov/a2fenv/bin/activate
    python3 test_client.py output.wav /World/audio2face/PlayerStreaming >> "$LOGS_DIR/test_audio.log" 2>&1
    cd "$TH2_DIR" || { echo "Ошибка: не удалось перейти в директорию $TH2_DIR"; exit 1; }
    ./run2.sh >> "$LOGS_DIR/run2.log" 2>&1
) &
PIDS+=($!)  # Сохраняем PID тестового аудио

# Бесконечный цикл для поддержания работы скрипта
while true; do
    sleep 1
done