import React, { createContext, useContext, useEffect, useState } from "react";
import mqtt, { IClientOptions } from "precompiled-mqtt";
import { MQTT_URL, MQTT_USER, MQTT_PASSWORD, MQTT_TOPICS, getMqttTopic } from "../config";
import { Log } from "../types";

interface MqttContextType {
  client: mqtt.MqttClient | null;
  publish: (topic: string, message: string) => void;
  isConnected: boolean;
  hasError: boolean;
  errors: string[];
  connect: (url: string, username: string, password: string) => void;
  isConnecting: boolean;
  logs: Log[];
  limpaLogs: () => void
  openedModal: string | undefined
}

const MqttContext = createContext<MqttContextType>({
  client: null,
  publish: () => { },
  isConnected: false,
  hasError: false,
  errors: [],
  connect: () => { },
  isConnecting: false,
  logs: [],
  limpaLogs: () => {},
  openedModal: undefined
});

export const useMqtt = () => useContext(MqttContext);

export const MqttProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [client, setClient] = useState<mqtt.MqttClient | null>(null);
  const [isConnected, setIsConnected] = useState<boolean>(false);
  const [isConnecting, setIsConnecting] = useState<boolean>(false);
  const [hasError, setHasError] = useState<boolean>(false);
  const [errors, setErrors] = useState<string[]>([]);
  const [repeatedLogCounter, setRepeatedLogCounter] = useState<number>(0);
  const [logs, setLogs] = useState<Log[]>([]);
  const [openedModal, setOpenedModal] = useState<string | undefined>();

  const logsTopic = getMqttTopic("logs");
  const erroTopic = getMqttTopic("erro");
  const finalizadoTopic = getMqttTopic("finalizado");
  const maxLength = 64

  const limpaLogs = () => {
    setLogs([])
  }
  useEffect(() => {
    connect(MQTT_URL, MQTT_USER, MQTT_PASSWORD); // Connect with default values on load
  }, []);
  const updateStateOnMessage = (topic: string, message: any) => {
    console.log(`received ${message.toString()} on topic ${topic}`)
    let msg = (message.toString());

    switch (topic) {
      case logsTopic:
        updateLogs(msg);
        break;
      case erroTopic:
        showErroModal(msg);
        break;
      case finalizadoTopic:
        setOpenedModal('F');
        break;
    }
  }

  const showErroModal = (msg: string) => {
    setOpenedModal(msg);
  }

  const updateLogs = (msg: string) => {
    const newLog = {
      msg: msg,
      timestamp: new Date()
    }
    if (logs.length > 0 && msg === logs[logs.length - 1].msg) {
      if (repeatedLogCounter === 0) {
        setRepeatedLogCounter((prev) => prev + 1)
      } else {
        setLogs((prev) => [...prev, newLog].slice(prev.length - maxLength, prev.length));
        setRepeatedLogCounter(0);
      }
    } else {
      setRepeatedLogCounter(0);
      setLogs((prev) => [...prev, newLog].slice(prev.length - maxLength, prev.length));
    }
  }

  const connect = (url: string, username: string, password: string) => {
    const options: IClientOptions = {
      username: username,
      password: password,
    };

    if (url) {
      setIsConnected(false);
      setErrors([]);
      setHasError(false);
      setIsConnecting(true);

      const mqttClient = mqtt.connect(url, options);
      setClient(mqttClient);

      mqttClient.on("connect", () => {
        setIsConnected(true);
        setHasError(false);
        setIsConnecting(false);
        setErrors([]);
        for (let topic of MQTT_TOPICS) {
          console.log("subscribing to", topic);
          mqttClient.subscribe(topic);
        }
      });

      mqttClient.on("disconnect", () => {
        setIsConnected(false);
      });

      mqttClient.on("message", updateStateOnMessage);
      mqttClient.on("error", (error: Error) => {
        setIsConnected(false);
        setIsConnecting(false);
        setHasError(true);
        setErrors((prevErrors) => [...prevErrors, error.message]);
      });

      return () => {
        setIsConnected(false);
        mqttClient.end();
      };
    }
  };

  const publish = (topic: string, message: string) => {
    if (client && client.connected) {
      client.publish(topic, message);
    }
  };

  return (
    <MqttContext.Provider
      value={{
        client,
        publish,
        isConnected,
        hasError,
        errors,
        connect,
        isConnecting,
        logs,
        limpaLogs,
        openedModal
      }}
    >
      {children}
    </MqttContext.Provider>
  );
};
