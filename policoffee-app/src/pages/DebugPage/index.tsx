import {
  IonContent,
  IonHeader,
  IonIcon,
  IonItem,
  IonLabel,
  IonPage,
  IonTitle,
  IonToggle,
  IonToolbar,
} from "@ionic/react";

import MqttDebugCard from "./MqttDebugCard";
import DebugWarningToolbar from "./DebugWarningToolbar";
import { useState } from "react";
import { moon, sunny } from "ionicons/icons";
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
        <IonItem>
          <IonIcon icon={darkMode ? moon : sunny} slot="start" />
          <IonLabel>Dark Mode</IonLabel>
          <IonToggle
            slot="end"
            checked={darkMode}
            onIonChange={toggleDarkMode}
          />
        </IonItem>

        <IonItem>
          <LogViewer logs={logs}/>
        </IonItem>
      </IonContent>
    </IonPage>
  );
};

export default DebugPage;
