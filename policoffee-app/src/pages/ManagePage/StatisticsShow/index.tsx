import {
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardTitle,
  IonList,
  IonItem,
  IonText,
} from "@ionic/react";

import styles from "./StatisticsShow.module.css";

import { SupabaseClient, createClient } from "@supabase/supabase-js";
import { useEffect, useState } from "react";

interface StatisticsShowInterface {
  supabase: SupabaseClient | undefined
}
const StatisticsShow: React.FC<StatisticsShowInterface> = ({ supabase }) => {
  const [loadingSupa, setLoadingSupa] = useState<boolean>(false);
  const [statistics, setStatistics] = useState<any>();

  const refreshStatistics = async () => {
    setLoadingSupa(true);
    try {
      const response = await supabase
        ?.from("log_stats")
        .select();

      const data: any = response?.data;

      let typeCount: any = {};
      if (data) {
        for (let obj of data) {
          typeCount = {
            ...typeCount,
            [obj.type]: obj.type_count
          }
        }
      }
      setStatistics(typeCount);
    } catch {
      alert(
        "Não foi possível carregar as estatísticas. Verifique sua conexão com a internet"
      );
    } finally {
      setLoadingSupa(false);
    }
  };

  useEffect(() => {
    refreshStatistics();
    const intervalId = setInterval(refreshStatistics, 5000);

    return () => clearInterval(intervalId);
  }, [supabase]);

  return (
    <IonCard>
      <IonCardHeader>
        <IonCardTitle className={styles.header}>
          Nas últimas 24 horas
        </IonCardTitle>
      </IonCardHeader>

      <IonCardContent>
        <IonList>
          {statistics?.Verifying ? (
            <IonItem>
              <IonText><span className={styles.success_stats}>{statistics['Verifying']}
              </span> tentativas de desbloquear</IonText>
            </IonItem>
          ) : ''}
          {statistics?.Verification_Error ? (
            <IonItem>
              <IonText>
                <span className={styles.warning_stats}>
                  {statistics['Verification_Error']}
                </span> senhas erradas inseridas</IonText>
            </IonItem>
          ) : ''}
          {statistics?.Blocked ? (
            <IonItem>
              <IonText>
                <span className={styles.danger_stats}>
                  {statistics['Blocked']}
                </span> bloqueios
              </IonText>
            </IonItem>
          ) : ''}
          {statistics?.Modify ? (
            <IonItem>
              <IonText>
                <span className={styles.info_stats}>
                  {statistics['Modify']}
                </span> modificações de senha</IonText>
            </IonItem>
          ) : ''}
        </IonList>
      </IonCardContent>
    </IonCard>
  );
};

export default StatisticsShow;
