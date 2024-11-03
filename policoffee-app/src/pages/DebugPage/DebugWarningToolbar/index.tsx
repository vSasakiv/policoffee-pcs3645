import { IonIcon, IonTitle, IonToolbar } from "@ionic/react";

import styles from "./DebugWarningToolbar.module.css";
import { cafe } from "ionicons/icons";

const DebugWarningToolbar: React.FC = () => {
  return (
    <IonToolbar className={styles.footerToolbar}>
      <IonTitle size="small" className={styles.footerText}>
        proceda com cuidado, apenas para programadores
        <IonIcon icon={cafe} className={styles.textIcon} />
      </IonTitle>
    </IonToolbar>
  );
};

export default DebugWarningToolbar;
