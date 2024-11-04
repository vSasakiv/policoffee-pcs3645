import {
  IonContent,
  IonHeader,
  IonPage,
  IonTitle,
  IonToolbar,
} from "@ionic/react";

import ScheduleManager from "./ScheduleManager";
import IniciaPreparoForm from "./IniciaPreparoForm";

const ManagePage: React.FC = () => {
  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Gerenciar Cafeteira</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className={"ion-padding ion-margin"} fullscreen>
        <IonHeader collapse="condense">
          <IonToolbar>
            <IonTitle size="large">Gerenciar Cafeteira</IonTitle>
          </IonToolbar>
        </IonHeader>

        <IniciaPreparoForm />
        <ScheduleManager />
      </IonContent>
    </IonPage>
  );
};

export default ManagePage;
