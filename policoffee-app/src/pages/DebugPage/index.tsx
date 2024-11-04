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
} from "@ionic/react";

import MqttDebugCard from "./MqttDebugCard";
import DebugWarningToolbar from "./DebugWarningToolbar";
import { useState } from "react";
import { useMqtt } from "../../contexts/MqttContext";
import LogViewer from "./LogViewer";

const DebugPage: React.FC = () => {
  const [darkMode, setDarkMode] = useState(false);
  const { logs } = useMqtt();

  // Function to toggle dark mode
  const toggleDarkMode = () => {
    const newMode = !darkMode;
    setDarkMode(newMode);
    document.body.classList.toggle("dark", newMode); // Toggle dark mode class on body
  };

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
