import {
  IonContent,
  IonHeader,
  IonPage,
  IonTitle,
  IonToolbar,
  useIonModal,
} from "@ionic/react";

import ScheduleManager from "./ScheduleManager";
import IniciaPreparoForm from "./IniciaPreparoForm";
import SemAguaModal from "../../components/SemAguaModal";
import { useMqtt } from "../../contexts/MqttContext";
import { useEffect } from "react";
import SemCanecaModal from "../../components/SemCanecaModal";
import TimeoutEbulidorModal from "../../components/TimeoutEbulidorModal";

const ManagePage: React.FC = () => {
  const {
    openedModal
  } = useMqtt();

  const [presentSemAguaModal, dismissSemAguaModal] = useIonModal(SemAguaModal, {
    onDismiss: () => dismissSemAguaModal(),
  });

  const [presentSemCanecaModal, dismissSemCanecaModal] = useIonModal(SemCanecaModal, {
    onDismiss: () => dismissSemCanecaModal(),
  });

  const [presentTimeoutEbulidorModal, dismissTimeoutEbulidorModal] = useIonModal(TimeoutEbulidorModal, {
    onDismiss: () => dismissTimeoutEbulidorModal(),
  });

  useEffect(() => {
    switch (openedModal) {
      case 'A':
        presentSemAguaModal();
        break;
      case 'X':
        presentSemCanecaModal();
        break;
      case 'E':
        presentTimeoutEbulidorModal();
        break;
    }
  }, [openedModal])
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
