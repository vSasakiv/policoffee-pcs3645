#include "MqttCredentials.h"
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <SoftwareSerial.h>
#include <time.h>
#include <TZ.h>
#include <FS.h>
#include <LittleFS.h>
#include <CertStoreBearSSL.h>
#include <OneWire.h>
#include <DallasTemperature.h>


#define BAUD_RATE 9600
#define PIN_PREPARAR D1
#define PIN_TX D2
#define PIN_FIM_TEMPERATURA D3
#define PIN_SEM_AGUA D8
#define PIN_SEM_XICARA D5
#define PIN_TIMEOUT_EBULIDOR D6
#define PIN_SENSOR_TEMPERATURA D7

#define PIN_RX 255
#define TEMPERATURA_ALVO 30
#define DELAY_PREPARACAO 200 // ms
#define MAX_PAYLOAD_SIZE 32

#define BIG_COFFEE_MODE 'G'
#define SMALL_COFFEE_MODE 'M'
#define TOPICO_INICIAR "malcong/inicio"
#define TOPICO_FINALIZADO "malcong/finalizado"
#define TOPICO_ERRO "malcong/erro"
#define LOGS_TOPIC "malcong/logs"
#define LED_BLINK_INTERVAL 500 // ms

#include <string>

const char *ssid = WIFI_SSID;
const char *password = WIFI_PASS;
const char *mqtt_server = MQTT_HOST;

BearSSL::CertStore certStore;

WiFiClientSecure espClient;
PubSubClient client(espClient);
SoftwareSerial softSerial(PIN_RX, PIN_TX);
OneWire oneWire(PIN_SENSOR_TEMPERATURA); 
DallasTemperature sensorTemperatura(&oneWire);
DeviceAddress endereco_temp;

unsigned long previousMillis = 0;
bool ledState = false;

void setup_wifi();
void setDateTime();
void callback(char *topic, byte *payload, unsigned int length);
void reconnect();
void logger(String log);

enum EstadoCafe
{
    AGUARDANDO,
    INICIO,
    PREPARANDO,
    MONITORANDO_TEMPERATURA,
    FINALIZADO,
    ERRO
};

enum TipoErro {
    SEM_AGUA = 'A',
    SEM_XICARA = 'X',
    TIMEOUT_EBULIDOR = 'E',

    SEM_ERRO = '0'
};

class ControladorCafe
{
private:
    EstadoCafe estadoAtual;
    unsigned long previousTempMeasurementMillis = 0;
    unsigned long delayTempMeasurementMillis = 20000; // 2s
    char tamanho;
    TipoErro erro;
public:
    ControladorCafe()
    {
        estadoAtual = AGUARDANDO;

        // Configura os pinos
        pinMode(PIN_SEM_AGUA, INPUT);
        pinMode(PIN_SEM_XICARA, INPUT);
        pinMode(PIN_PREPARAR, OUTPUT);
        pinMode(PIN_FIM_TEMPERATURA, OUTPUT);

        // Estado inicial dos pinos de saída
        digitalWrite(PIN_PREPARAR, LOW);
        digitalWrite(PIN_FIM_TEMPERATURA, LOW);

        digitalWrite(LED_BUILTIN, HIGH); // LED starts off (HIGH is off for ESP8266)
    }

    void inicia(char tamanho)
    {
        logger("validando tamanho");
        if (tamanho == BIG_COFFEE_MODE || tamanho == SMALL_COFFEE_MODE) {
            logger("iniciando");
            estadoAtual = INICIO;
            ControladorCafe::tamanho = tamanho;
        } else {
            logger("Modo de tamanho inválido: ");
            logger(String(tamanho));
        }
    }

    void loop()
    {
        bool comecou;
        unsigned long currentMillis;
        setLEDState(); // Update LED state based on current state

        switch (estadoAtual)
        {
        case AGUARDANDO:
            break;

        case INICIO:
            iniciaPreparo();
            delay(DELAY_PREPARACAO);

            logger("escrevendo serial: ");
            logger(String(tamanho));
            softSerial.write(tamanho);
            delay(500);
            comecou = verificaCondicoesPreparo();

            if (comecou) {
              logger("tudo certo, monitorando temp");
              estadoAtual = MONITORANDO_TEMPERATURA;  
            } else { // FPGA retornou erro
              logger("deu ruim");
              estadoAtual = ERRO;
            }
            break;

        case MONITORANDO_TEMPERATURA:
            if (verificaTimeoutEbulidor()) {
                estadoAtual = ERRO;
            }
            else {
                sensorTemperatura.requestTemperatures();

                if (!sensorTemperatura.getAddress(endereco_temp,0)) { 
                    logger("SENSOR NAO CONECTADO");
                } else {
                    currentMillis = millis();
                    // Só mede se passou o tempo
                    if (currentMillis - previousTempMeasurementMillis >= delayTempMeasurementMillis) {
                        previousTempMeasurementMillis = currentMillis;

                        if (atingiuTemperaturaAlvo()) {
                            setFimTemperatura();
                            estadoAtual = FINALIZADO;
                        }
                    }
                }
            }
            break;

        case FINALIZADO:
            publicaFinalizado();
            delay(DELAY_PREPARACAO);
            resetSinaisDeControle();
            estadoAtual = AGUARDANDO;
            break;
        }

        case ERRO:
            publicaErro();
            estadoAtual = AGUARDANDO;
            erro = SEM_ERRO;
    }

    void blinkLED() {
        unsigned long currentMillis = millis();
        if (currentMillis - previousMillis >= LED_BLINK_INTERVAL) {
            previousMillis = currentMillis;
            ledState = !ledState;
            digitalWrite(LED_BUILTIN, ledState);
        }
    }

private:
    void publicaFinalizado() {
        client.publish(String(TOPICO_FINALIZADO).c_str(), String("finalizado").c_str());
    }
    bool atingiuTemperaturaAlvo() {
        float temperatura = sensorTemperatura.getTempC(endereco_temp); 
        logger("Temperatura = "); 
        logger(String(temperatura));
        return temperatura >= TEMPERATURA_ALVO;
    }

    void setLEDState() {
        switch (estadoAtual) {
            case AGUARDANDO:
             // Quick triple flash
                delay(200);
                for(int i = 0; i < 3; i++) {
                    digitalWrite(LED_BUILTIN, LOW);
                    delay(100);
                    digitalWrite(LED_BUILTIN, HIGH);
                    delay(100);
                }
                break;
            case INICIO:
                digitalWrite(LED_BUILTIN, HIGH);  // LED solid on
                break;
            case MONITORANDO_TEMPERATURA:
                blinkLED();  // LED blinking
                break;
            case FINALIZADO:
                digitalWrite(LED_BUILTIN, LOW); // LED off
                break;
        }
    }
    bool verificaCondicoesPreparo()
    {
        int pinoAgua = digitalRead(PIN_SEM_AGUA);
        int pinoXicara = digitalRead(PIN_SEM_XICARA);

        logger("SEM AGUA: ");
        logger(String(pinoAgua));

        logger("SEM XICARA: ");
        logger(String(pinoXicara));

        if (pinoAgua == HIGH) {
            erro = SEM_AGUA;
        }
        else if (pinoXicara == HIGH) {
            erro = SEM_XICARA;
        }

        return (pinoAgua == LOW && pinoXicara == LOW);
    }

    void iniciaPreparo()
    {
        digitalWrite(PIN_PREPARAR, HIGH);
    }

    bool verificaTimeoutEbulidor() {
        int pinoTimeoutEbulidor = digitalRead(PIN_TIMEOUT_EBULIDOR);

        logger("TIMEOUT EBULIDOR: ");
        logger(String(pinoTimeoutEbulidor));

        if (pinoTimeoutEbulidor == HIGH) {
            erro = TIMEOUT_EBULIDOR;
        }

        return (pinoTimeoutEbulidor == HIGH);
    }

    void setFimTemperatura() {
        digitalWrite(PIN_FIM_TEMPERATURA, HIGH);
    }

    void resetSinaisDeControle() {
        digitalWrite(PIN_PREPARAR, LOW);
        digitalWrite(PIN_FIM_TEMPERATURA, LOW);
    }

    void publicaErro() {
        client.publish(String(TOPICO_ERRO).c_str(), String(erro).c_str());
    }
};

void logger(String log)
{
    client.publish(LOGS_TOPIC, log.c_str());
}

ControladorCafe controlador;

void setup()
{
    pinMode(LED_BUILTIN, OUTPUT);
    delay(200);

    softSerial.begin(BAUD_RATE);
    Serial.begin(BAUD_RATE);
    sensorTemperatura.begin();
    delay(200);

    LittleFS.begin();
    setup_wifi();
    setDateTime();

    int numCerts = certStore.initCertStore(LittleFS, PSTR("/certs.idx"), PSTR("/certs.ar"));
    Serial.printf("Number of CA certs read: %d\n", numCerts);
    if (numCerts == 0)
    {
        Serial.printf("No certs found. Did you run certs-from-mozilla.py and upload the LittleFS directory before running?\n");
        return;
    }

    BearSSL::WiFiClientSecure *bear = new BearSSL::WiFiClientSecure();
    bear->setCertStore(&certStore);

    client = *(new PubSubClient(*bear));

    client.setServer(mqtt_server, MQTT_PORT);
    client.setCallback(callback);
}

void loop()
{

    if (!client.connected())
    {
        reconnect();
    }
    client.loop();
    controlador.loop();
}

void setDateTime()
{
    configTime(TZ_Europe_Berlin, "pool.ntp.org", "time.nist.gov");

    Serial.print("Waiting for NTP time sync: ");
    time_t now = time(nullptr);
    while (now < 8 * 3600 * 2)
    {
        delay(100);
        Serial.print(".");
        now = time(nullptr);
    }
    Serial.println();

    struct tm timeinfo;
    gmtime_r(&now, &timeinfo);
    Serial.printf("%s %s", tzname[0], asctime(&timeinfo));
}

void setup_wifi()
{
    delay(10);
    // We start by connecting to a WiFi network
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);

    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED)
    {
        digitalWrite(LED_BUILTIN, LOW);
        delay(250);
        digitalWrite(LED_BUILTIN, HIGH);
        delay(250);
        Serial.print(".");
    }

    randomSeed(micros());

    Serial.println("");
    Serial.println("WiFi connected");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());
}

void callback(char *topic, byte *payload, unsigned int length)
{
    char message[MAX_PAYLOAD_SIZE];
    if (length >= MAX_PAYLOAD_SIZE)
    {
        length = MAX_PAYLOAD_SIZE - 1;
    }
    memcpy(message, payload, length);
    message[length] = '\0';

    logger("message received");
    logger(String(topic));
    logger(String(message)); 
    Serial.print("Message received on topic: ");
    Serial.println(topic);
    Serial.print("Message: ");
    Serial.println(message);

    if (strcmp(topic, TOPICO_INICIAR) == 0)
    {
        controlador.inicia(message[0]);
    }
}

void reconnect()
{
    // Loop until we’re reconnected
    while (!client.connected())
    {
        Serial.print("Attempting MQTT connection…");
        String clientId = "ESP8266Client -123123";

        digitalWrite(LED_BUILTIN, HIGH);
        delay(100);
        digitalWrite(LED_BUILTIN, LOW);
        delay(100);
        digitalWrite(LED_BUILTIN, HIGH);
        delay(100);
        digitalWrite(LED_BUILTIN, LOW);
        delay(500);

        // Attempt to connect
        // Insert your password
        if (client.connect(clientId.c_str(), MQTT_USER, MQTT_PASS))
        {
            Serial.println("connected");
            client.subscribe(TOPICO_INICIAR);
        }
        else
        {
            Serial.print("failed, rc = ");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}
