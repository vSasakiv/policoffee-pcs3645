import React from "react";
import {
  IonList,
  IonItem,
  IonLabel,
  IonNote,
  IonIcon,
  IonText,
} from "@ionic/react";
import {
  alertCircleOutline,
  checkmarkCircleOutline,
  informationCircleOutline,
  removeCircleOutline,
} from "ionicons/icons";
import { LogInterface } from "../../../../types";
import styles from "./LogsList.module.css";
import { format } from "date-fns";

interface LogsListProps {
  logs: LogInterface[] | undefined;
}

interface LogStyleInterface {
  color: string;
  icon: any;
}

interface StatusToStyleMap {
  [key: string]: LogStyleInterface;
}

const LogsList: React.FC<LogsListProps> = ({ logs }) => {
  const statusToStyle: StatusToStyleMap = {
    Default: {
      color: "",
      icon: removeCircleOutline,
    },
    Error: {
      color: "danger",
      icon: alertCircleOutline,
    },
    Warning: {
      color: "warning",
      icon: checkmarkCircleOutline,
    },
    Info: {
      color: "primary",
      icon: informationCircleOutline,
    },
  };

  const getLogStatus = (log: string) => {
    const index = log.indexOf(":");
    if (index === -1) return "Default";

    const status = log.substring(0, index);
    return Object.keys(statusToStyle).includes(status) ? status : "Default";
  };

  const formatToDate = (timestamp: string) => {
    return format(new Date(timestamp), "dd/MM/yyyy");
  };

  const formatToTime = (timestamp: string) => {
    // timestamp in the format of 2024-04-02T09:15:47Z
    return format(new Date(timestamp), "HH:mm:ss");
  };

  return (
    <IonList>
      {logs?.map((log, index) => {
        const style = statusToStyle[getLogStatus(log.message)];

        return (
          <IonItem key={index} className={styles.logs}>
            <IonIcon color={style.color} icon={style.icon} slot="start" />
            <IonLabel className={styles.label} color={style.color}>
              {log.message}
            </IonLabel>
            <IonNote slot="end">
              <div style={{ display: "flex", flexDirection: "column" }}>
                <IonText>
                  <p>{formatToDate(log.date)}</p>
                  <p>{formatToTime(log.date)}</p>
                </IonText>
              </div>
            </IonNote>
          </IonItem>
        );
      })}
    </IonList>
  );
};

export default LogsList;
