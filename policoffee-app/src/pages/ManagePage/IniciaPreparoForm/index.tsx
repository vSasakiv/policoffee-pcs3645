import {
  IonButton,
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardTitle,
} from "@ionic/react";
import { SubmitHandler, FieldValues } from "react-hook-form";
import { getMqttTopic } from "../../../config";
import { useMqtt } from "../../../contexts/MqttContext";

const IniciaPreparoForm: React.FC = () => {
  const { publish } = useMqtt();
  const iniciaPreparoTopic = getMqttTopic("inicio");

  const iniciaPreparoMedio = () => {
    publish(iniciaPreparoTopic, 'M');
  };
  const iniciaPreparoGrande = () => {
    publish(iniciaPreparoTopic, 'G');
  };

  return (
    <IonCard>
      <IonCardHeader>
        <IonCardTitle>Iniciar Preparo</IonCardTitle>
      </IonCardHeader>

      <IonCardContent>
        <IonButton onClick={iniciaPreparoMedio}>Médio</IonButton>
        <IonButton onClick={iniciaPreparoGrande}>Grande</IonButton>
      </IonCardContent>
    </IonCard>
  );
};

export default IniciaPreparoForm;
