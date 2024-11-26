import { IonContent, IonPage, IonButton } from "@ionic/react";
import Lottie from "react-lottie";
import animationData from "./OkAnimation.json";

const CafePreparadoModal = ({ onDismiss }: { onDismiss: () => void }) => {
  const animationOptions = {
    loop: false,
    autoplay: true,
    animationData: animationData,
    rendererSettings: {
      preserveAspectRatio: "xMidYMid slice",
    },
  };

  return (
    <IonPage>
      <IonContent
        className="ion-padding"
        style={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          height: "100%",
        }}
      >
        <div
          className="wrapper"
          style={{
            textAlign: "center",
            display: "flex",
            flexDirection: "column",
            gap: 64,
          }}
        >
          <h1>Café preparado com sucesso!</h1>

          <p>Aproveite seu cafézinho!</p>

          <Lottie options={animationOptions} height={200} width={200} />

          <IonButton onClick={onDismiss} expand="block" color="success">
            Voltar
          </IonButton>
        </div>
      </IonContent>
    </IonPage>
  );
};

export default CafePreparadoModal;