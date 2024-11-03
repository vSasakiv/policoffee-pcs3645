import {
  IonButton,
  IonIcon,
  IonCardContent,
  IonCardTitle,
  IonCard,
  IonCardHeader,
} from "@ionic/react";
import { lockClosed } from "ionicons/icons";
import { useMqtt } from "../../../contexts/MqttContext";
import { getMqttTopic } from "../../../config";

const LockBtnCard: React.FC = () => {
  const { publish } = useMqtt();
  const lockTopic = getMqttTopic("start");

  const publishLock = () => {
    publish(lockTopic, "start");
  };

  return (
    <IonCard>
      <IonCardContent>
        <IonButton
          onClick={() => publishLock()}
          className="ion-margin-top"
          type="submit"
          color="danger"
          expand="full"
        >
          <IonIcon slot="start" icon={lockClosed}></IonIcon>
          Trancar
        </IonButton>
      </IonCardContent>
    </IonCard>
  );
};

export default LockBtnCard;
