import {
  IonContent,
  IonHeader,
  IonItem,
  IonLabel,
  IonPage,
  IonTitle,
  IonGrid,
  IonCol,
  IonToolbar,
  IonButton,
} from "@ionic/react";

import MqttDebugCard from "./MqttDebugCard";
import DebugWarningToolbar from "./DebugWarningToolbar";
import { useState } from "react";
import { useMqtt } from "../../contexts/MqttContext";
import LogViewer from "./LogViewer";
import { getMqttTopic } from "../../config";

const DebugPage: React.FC = () => {
  const [darkMode, setDarkMode] = useState(false);
  const { logs, publish, limpaLogs } = useMqtt();

  const topicoReset = getMqttTopic("reset")
  const publishReset = () => {
    publish(topicoReset, 'resetando');
  }
  
  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>DEBUG</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className={"ion-padding ion-margin"} fullscreen>
        <IonHeader collapse="condense">
          <IonToolbar>
            <IonTitle size="large">DEBUG</IonTitle>
          </IonToolbar>
        </IonHeader>

        <DebugWarningToolbar />
        <MqttDebugCard />
        <IonButton
          onClick={publishReset}
          className="ion-margin-top"
          expand="full"
          color="danger">
          Resetar
        </IonButton>
        <IonButton
          onClick={limpaLogs}
          className="ion-margin-top"
          expand="full"
          color="danger">
          Limpar Logs
        </IonButton>
        <IonItem className={"ion-"}>
          <IonGrid>
            <div>
              <IonLabel>Logs</IonLabel>
            </div>
            <IonCol>
              <LogViewer logs={logs} />
            </IonCol>
          </IonGrid>
        </IonItem>
      </IonContent>
    </IonPage>
  );
};

export default DebugPage;
