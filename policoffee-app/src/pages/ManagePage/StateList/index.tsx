import {
    IonCard,
    IonCardContent,
    IonCardHeader,
    IonCardTitle,
    IonList,
    IonItem,
    IonLabel,
    IonButton,
    IonIcon,
} from "@ionic/react";

import StatusIndicator from "../../../components/StatusIndicator";
import { useMqtt } from "../../../contexts/MqttContext";
import { getMqttTopic } from "../../../config";
import { StatusToRepresentationMap } from "../../../types";
import {
    closeCircle,
    checkmarkCircle,
    lockClosed,
    lockOpen,
    refresh,
} from "ionicons/icons";
import { useEffect, useState } from "react";
import styles from "./StateList.module.css";

const StateList: React.FC = () => {
    const { publish, isLocked, isBlocked } = useMqtt();

    const [lockedStatus, setLockedStatus] = useState<string>("locked");
    const [blockedStatus, setBlockedStatus] = useState<string>("unblocked");

    const resetTopic = getMqttTopic("reset");

    useEffect(() => {
        const lockedStatus = isLocked ? "locked" : "unlocked";
        setLockedStatus(lockedStatus)
    }, [isLocked]);

    useEffect(() => {
        const blockedStatus = isBlocked ? "blocked" : "unblocked";
        setBlockedStatus(blockedStatus);
    }, [isBlocked]);

    const blockedStatusRep: StatusToRepresentationMap = {
        blocked: {
            color: "danger",
            name: "Bloqueado",
            icon: closeCircle,
        },
        unblocked: {
            color: "success",
            name: "Não bloqueado",
            icon: checkmarkCircle,
        },
    };

    const lockedStatusRep: StatusToRepresentationMap = {
        locked: {
            color: "danger",
            name: "Trancado",
            icon: lockClosed,
        },
        unlocked: {
            color: "success",
            name: "Destrancado",
            icon: lockOpen,
        },
    };

    const publishReset = () => {
        publish(resetTopic, "reset");
    };

    return (
        <IonCard>
            <IonCardHeader>
                <IonCardTitle className={styles.header}>
                    Armário
                    <IonButton
                        color="danger"
                        className="ion-margin-top"
                        type="submit"
                        onClick={() => publishReset()}
                    >
                        <IonIcon slot="start" icon={refresh}></IonIcon>
                        Resetar
                    </IonButton>
                </IonCardTitle>
            </IonCardHeader>

            <IonCardContent>
                <IonList>
                    <IonItem>
                        <StatusIndicator
                            iconSize="large"
                            status={lockedStatus}
                            defaultStatus="locked"
                            statusToRep={lockedStatusRep}
                        />
                    </IonItem>
                    <IonItem>
                        <StatusIndicator
                            iconSize="large"
                            status={blockedStatus}
                            defaultStatus="unblocked"
                            statusToRep={blockedStatusRep}
                        />
                    </IonItem>
                </IonList>
            </IonCardContent>
        </IonCard>
    );
};

export default StateList;
