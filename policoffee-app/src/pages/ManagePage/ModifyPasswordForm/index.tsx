import {
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardTitle,
} from "@ionic/react";
import { SubmitHandler, FieldValues } from "react-hook-form";
import PasswordForm from "../../../components/PasswordForm";
import { create } from "ionicons/icons";
import { getMqttTopic } from "../../../config";
import { useMqtt } from "../../../contexts/MqttContext";

const ModifyPasswordForm: React.FC = () => {
  const { publish } = useMqtt();
  const modifyTopic = getMqttTopic("modify");
  const startTopic = getMqttTopic("start");

  const onSubmit: SubmitHandler<FieldValues> = (data) => {
    console.log("testando submit", data.senha);
    publish(startTopic, "start");
    publish(modifyTopic, data.senha);
  };

  return (
    <IonCard>
      <IonCardHeader>
        <IonCardTitle>Modificar Senha</IonCardTitle>
      </IonCardHeader>

      <IonCardContent>
        <PasswordForm
          onSubmit={onSubmit}
          submitBtnText="Mudar Senha"
          btnIcon={create}
          placeholder="Nova senha"
        />
      </IonCardContent>
    </IonCard>
  );
};

export default ModifyPasswordForm;
