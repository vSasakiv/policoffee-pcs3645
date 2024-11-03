import React from "react";
import {
  IonCard,
  IonCardHeader,
  IonCardContent,
  IonIcon,
  IonText,
} from "@ionic/react";
import { StatusIndicatorInterface } from "../../types";
import styles from "./StatusIndicator.module.css";

const StatusIndicator: React.FC<StatusIndicatorInterface> = ({
  statusToRep,
  status,
  iconSize,
  defaultStatus
}) => {
  const currentStatus = statusToRep[status] || statusToRep[defaultStatus];

  return (
    <div className={styles.indicator}>
      <IonIcon
        size={iconSize}
        icon={currentStatus.icon}
        color={currentStatus.color}
      />
      <IonText>{currentStatus.name}</IonText>
    </div>
  );
};

export default StatusIndicator;
