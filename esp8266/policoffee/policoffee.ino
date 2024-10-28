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
#define PIN_RX 255
#define PIN_PREPARAR D1
#define PIN_TX D2
#define PIN_FIM_TEMPERATURA D3
#define PIN_SEM_AGUA D4
#define PIN_SEM_XICARA D5
#define PIN_TIMEOUT_EBULIDOR D6
#define PIN_SENSOR_TEMPERATURA D7

#define TEMPERATURA_ALVO 90
#define DELAY_PREPARACAO 200 // ms
#define MAX_PAYLOAD_SIZE 32

#define BIG_COFFEE_MODE 'G'
#define TOPICO_INICIAR "malcong/inicio"
#define LOGS_TOPIC "malcong/logs"

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
    FINALIZADO
};

class ControladorCafe
{
private:
    EstadoCafe estadoAtual;
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
    }

    bool inicia()
    {
        bool deveComecar = verificaCondicoesPreparo();
        if (deveComecar)
        {
            estadoAtual = INICIO;
        }
        return deveComecar;
    }

    void loop()
    {
        switch (estadoAtual)
        {
        case AGUARDANDO:
            break;

        case INICIO:
            iniciaPreparo();
            estadoAtual = PREPARANDO;
            break;

        case PREPARANDO:
            delay(DELAY_PREPARACAO);
            softSerial.write(BIG_COFFEE_MODE);
            estadoAtual = MONITORANDO_TEMPERATURA;
            break;

        case MONITORANDO_TEMPERATURA:
            sensorTemperatura.requestTemperatures();

            if (!sensorTemperatura.getAddress(endereco_temp,0)) { 
                Serial.println("SENSOR NAO CONECTADO");
            } else {
                float temperatura = sensorTemperatura.getTempC(endereco_temp); 
                Serial.print("Temperatura = "); 
                Serial.println(temperatura);
                if (temperatura >= TEMPERATURA_ALVO)
                {
                    digitalWrite(PIN_FIM_TEMPERATURA, HIGH);
                    estadoAtual = FINALIZADO;
                }
            }
            break;

        case FINALIZADO:
            delay(DELAY_PREPARACAO);
            digitalWrite(PIN_PREPARAR, LOW);
            digitalWrite(PIN_FIM_TEMPERATURA, LOW);
            estadoAtual = AGUARDANDO;
            break;
        }
    }

private:
    bool verificaCondicoesPreparo()
    {
        return (digitalRead(PIN_SEM_AGUA) == LOW &&
                digitalRead(PIN_SEM_XICARA) == LOW);
    }

    void iniciaPreparo()
    {
        digitalWrite(PIN_PREPARAR, HIGH);
    }
};

void logger(String log)
{
    client.publish(LOGS_TOPIC, log.c_str());
}

ControladorCafe controlador;

void setup()
{
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
        delay(500);
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

    Serial.print("Message received on topic: ");
    Serial.println(topic);
    Serial.print("Message: ");
    Serial.println(message);

    if (strcmp(topic, TOPICO_INICIAR) == 0)
    {
        controlador.inicia();
    }
}

void reconnect()
{
    // Loop until we’re reconnected
    while (!client.connected())
    {
        Serial.print("Attempting MQTT connection…");
        String clientId = "ESP8266Client -123123";
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
