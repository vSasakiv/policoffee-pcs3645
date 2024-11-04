import {
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardTitle,
  IonList,
  IonItem,
} from "@ionic/react";

import StatusIndicator from "../../../components/StatusIndicator";
import { useMqtt } from "../../../contexts/MqttContext";
import { StatusToRepresentationMap } from "../../../types";
import { airplane, wifi } from "ionicons/icons";
import MqttConnectForm from "./MqttConnectForm";

const MqttDebugCard: React.FC = () => {
  const { client, isConnected } = useMqtt();

  const connectedStatusRep: StatusToRepresentationMap = {
    disconnected: {
      color: "danger",
      name: "Desconectado",
      icon: airplane,
    },
    connected: {
      color: "success",
      name: "Conectado",
      icon: wifi,
    },
  };

  return (
    <IonCard>
      <IonCardHeader>
        <IonCardTitle>Cliente MQTT</IonCardTitle>
      </IonCardHeader>

      <IonCardContent>
        <IonList>
          <IonItem>
            <StatusIndicator
              iconSize="large"
              status={isConnected ? "connected" : "disconnected"}
              defaultStatus="disconnected"
              statusToRep={connectedStatusRep}
            />
          </IonItem>
        </IonList>
      </IonCardContent>

      <MqttConnectForm />
    </IonCard>
  );
};

export default MqttDebugCard;
