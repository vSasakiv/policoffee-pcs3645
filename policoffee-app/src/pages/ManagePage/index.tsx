import {
  IonContent,
  IonHeader,
  IonPage,
  IonTitle,
  IonToolbar,
} from "@ionic/react";

import { useMqtt } from "../../contexts/MqttContext";
import { useEffect, useState } from "react";
import { SUPABASE_URL, SUPABASE_API_KEY } from "../../config";

import ModifyPasswordForm from "./ModifyPasswordForm";
import StateList from "./StateList";
import LogsCard from "./LogsCard";
import StatisticsShow from "./StatisticsShow";
import { SupabaseClient, createClient } from "@supabase/supabase-js";

const ManagePage: React.FC = () => {
  const { client } = useMqtt();
  const [supabase, setSupabase] = useState<SupabaseClient | undefined>();
  const onMessage = (topic: string, payload: any) => {
    console.log("received", payload, "on", topic);
  };

  useEffect(() => {
    // client?.on("message", onMessage);
    const supabase = createClient(SUPABASE_URL, SUPABASE_API_KEY);
    setSupabase(supabase);

    // Clean up function
    // return () => {
    //   client?.removeListener("message", onMessage);
    // };
  }, []);

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Gerenciar Armário</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className={"ion-padding ion-margin"} fullscreen>
        <IonHeader collapse="condense">
          <IonToolbar>
            <IonTitle size="large">Gerenciar Armário</IonTitle>
          </IonToolbar>
        </IonHeader>

        <ModifyPasswordForm />
        <StateList />
        <StatisticsShow supabase={supabase} />
        <LogsCard supabase={supabase}/>
      </IonContent>
    </IonPage>
  );
};

export default ManagePage;
