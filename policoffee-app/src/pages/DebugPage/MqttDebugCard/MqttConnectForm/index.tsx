import { useMqtt } from "../../../../contexts/MqttContext";
import { IonItem, IonButton, IonInput, IonIcon } from "@ionic/react";
import { ErrorMessage } from "@hookform/error-message";
import { useForm, SubmitHandler, FieldValues } from "react-hook-form";
import styles from "./MqttConnectForm.module.css";
import { logoRss } from "ionicons/icons";

const MqttConnectForm: React.FC = () => {
  const { client, hasError, isConnecting, errors, connect } = useMqtt();
  const {
    handleSubmit,
    register,
    formState: { errors: formErrors },
  } = useForm();

  const onSubmit: SubmitHandler<FieldValues> = (data) => {
    console.log("data is", data);
    connect(data.url, data.username, data.password);
  };

  return (
    <>
      <form onSubmit={handleSubmit(onSubmit)} className={styles.form}>
        <h3>Conectar a outro Broker</h3>
        <div>
          <div className={styles.input}>
            <IonInput
              label="Host"
              color={formErrors.url ? "danger" : ""}
              {...register("url", {
                required: "Insira o Host MQTT!",
              })}
              placeholder="wss://mqtt.yourhost.here:8884/mqtt"
              aria-label="Host MQTT"
            />
          </div>
          <ErrorMessage
            errors={formErrors}
            name="url"
            as={<div style={{ color: "red" }} />}
          />
        </div>

        <div>
          <div className={styles.input}>
            <IonInput
              label="Usuário"
              color={formErrors.username ? "danger" : ""}
              {...register("username", {
                required: "Insira o usuário!",
              })}
              placeholder="Seu Usuário"
              aria-label="Usuário"
            />
          </div>
          <ErrorMessage
            errors={formErrors}
            name="username"
            as={<div style={{ color: "red" }} />}
          />
        </div>

        <div>
          <div className={styles.input}>
            <IonInput
              label="Senha"
              color={formErrors.password ? "danger" : ""}
              {...register("password", {
                required: "Insira a senha!",
              })}
              placeholder="Sua Senha"
              aria-label="Senha"
            />
          </div>
          <ErrorMessage
            errors={formErrors}
            name="password"
            as={<div style={{ color: "red" }} />}
          />
        </div>

        <div>
          <IonButton className="ion-margin-top" type="submit">
            <IonIcon slot="start" icon={logoRss}></IonIcon>
            Conectar
          </IonButton>
        </div>
      </form>
    </>
  );
};

export default MqttConnectForm;
