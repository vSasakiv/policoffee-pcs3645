import { IonContent, IonPage, IonButton } from "@ionic/react";
import Lottie from "react-lottie";
import blockedAnimationData from "./BlockedAnimation.json";

const SemCanecaModal = ({ onDismiss }: { onDismiss: () => void }) => {
  const blockedAnimationOptions = {
    loop: false,
    autoplay: true,
    animationData: blockedAnimationData,
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
          <h1>Não há caneca na cafeteira!</h1>
          <p>Foi feita uma tentativa de preparo, porém não há caneca!</p>

          <Lottie options={blockedAnimationOptions} height={200} width={200} />

          <IonButton onClick={onDismiss} expand="block" color="danger">
            Voltar
          </IonButton>
        </div>
      </IonContent>
    </IonPage>
  );
};

export default SemCanecaModal;