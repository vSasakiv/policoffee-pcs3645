import { IonContent, IonPage, IonButton } from "@ionic/react";
import Lottie from "react-lottie";
import animationData from "./SemAguaAnimation.json";

const SemAguaModal = ({ onDismiss }: { onDismiss: () => void }) => {
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
          <h1>Cafeteira sem água!</h1>
          <p>Foi feita uma tentativa de preparar café, porém a cafeteira não possui água. Reabasteça antes de realizar um novo preparo.</p>
          <Lottie options={animationOptions} height={200} width={200} />

          <IonButton onClick={onDismiss} expand="block" color="danger">
            Voltar
          </IonButton>
        </div>
      </IonContent>
    </IonPage>
  );
};

export default SemAguaModal;